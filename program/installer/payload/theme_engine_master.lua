



local THEME_ENGINE_WSID = "3765005303"
local THEME_ENGINE_TEST_WSID = "3679454495"
local THEME_ENGINE_WSIDS = {
    [THEME_ENGINE_WSID] = true,
    [THEME_ENGINE_TEST_WSID] = true,
}
local TAG = "[ThemeEngine] "
local _tModuleLoad = SysTime()

DarkThemeEngine_Debug = DarkThemeEngine_Debug == true
function DarkThemeEngine_Log(level, scope, message)
    level = tostring(level or "info")
    if level == "debug" and not DarkThemeEngine_Debug then return end
    local prefix = TAG
    if scope and scope ~= "" then prefix = prefix .. "[" .. tostring(scope) .. "] " end
    print(prefix .. tostring(message or ""))
end


local CLIENT_ONLY = { ["theme_engine_spawnmenu.lua"] = true }

local loaderOverlay = nil
local loaderQuitButton = nil
local loaderOverlayStartedAt = SysTime()
local loaderOverlayStatus = "WAITING FOR WORKSHOP"
local loaderOverlayMode = "loading"
local loaderOverlayDetail = ""
local loaderOverlayDismissed = false
local loaderLoadedOnce = false
local loaderErrorPopup = nil
local loaderErrorNoticeShown = false
local IsAddonMounted
local GetAddonInfo
local CheckAndLoad
local loaderOriginalBackgroundFunctions = (DarkThemeEngine and DarkThemeEngine._OriginalBackgroundFunctions) or {
    ClearBackgroundImages = _G.ClearBackgroundImages,
    AddBackgroundImage = _G.AddBackgroundImage,
    ChangeBackground = _G.ChangeBackground,
    DrawBackground = _G.DrawBackground,
}

local loaderLogoMaterial = nil
local loaderFontScaleKey = nil
if MENU_DLL then
    loaderLogoMaterial = Material("theme_engine/loader/logo.png", "smooth")
end

local function EnsureLoaderFonts(w, h)
    if not MENU_DLL then return 1 end
    local scale = math.Clamp(math.min((w or 1920) / 1920, (h or 1080) / 1080), 0.68, 1.45)
    local key = math.floor(scale * 100 + 0.5)
    if loaderFontScaleKey == key then return scale end
    loaderFontScaleKey = key
    surface.CreateFont("ThemeEngineLoaderTitle", { font = "Roboto", size = math.max(21, math.floor(30 * scale + 0.5)), weight = 500, antialias = true })
    surface.CreateFont("ThemeEngineLoaderLabel", { font = "Roboto", size = math.max(11, math.floor(15 * scale + 0.5)), weight = 700, antialias = true })
    surface.CreateFont("ThemeEngineLoaderStatus", { font = "Roboto", size = math.max(13, math.floor(18 * scale + 0.5)), weight = 400, antialias = true })
    surface.CreateFont("ThemeEngineLoaderData", { font = "Consolas", size = math.max(9, math.floor(12 * scale + 0.5)), weight = 400, antialias = true })
    return scale
end

local function GetLoaderLayout(w, h)
    local scale = EnsureLoaderFonts(w, h)
    local marginX = math.Clamp(math.floor(w * 0.035), math.floor(16 * scale), math.floor(72 * scale))
    local marginY = math.Clamp(math.floor(h * 0.055), math.floor(14 * scale), math.floor(60 * scale))
    local frameW = math.max(1, w - marginX * 2)
    local frameH = math.max(1, h - marginY * 2)
    local headerH = math.Clamp(math.floor(62 * scale + 0.5), 44, 86)
    local footerH = math.Clamp(math.floor(42 * scale + 0.5), 32, 60)
    local contentTop = marginY + headerH
    local contentBottom = marginY + frameH - footerH
    local contentH = math.max(1, contentBottom - contentTop)
    local logoSize = math.Clamp(math.floor(contentH * 0.28), math.floor(88 * scale), math.floor(236 * scale))
    local buttonW = math.Clamp(math.floor(176 * scale), 136, 240)
    local buttonH = math.Clamp(math.floor(40 * scale), 32, 54)
    local titleGap = math.max(8, math.floor(12 * scale))
    local titleH = math.max(28, math.floor(38 * scale))
    local statusH = math.max(23, math.floor(28 * scale))
    local detailH = loaderOverlayDetail ~= "" and math.max(30, math.floor(38 * scale)) or 0
    local actionGap = math.max(16, math.floor(25 * scale))
    local groupH = logoSize + titleGap + titleH + statusH + detailH + actionGap + buttonH
    local groupTop = contentTop + math.max(math.floor(10 * scale), math.floor((contentH - groupH) * 0.5))
    local centerX = math.floor(w * 0.5)
    local titleY = groupTop + logoSize + titleGap
    local statusY = titleY + titleH
    local detailY = statusY + statusH
    local buttonY = detailY + detailH + actionGap
    if buttonY + buttonH > contentBottom - math.floor(8 * scale) then
        buttonY = contentBottom - buttonH - math.floor(8 * scale)
    end
    return {
        scale = scale,
        x = marginX,
        y = marginY,
        w = frameW,
        h = frameH,
        headerH = headerH,
        footerH = footerH,
        contentTop = contentTop,
        contentBottom = contentBottom,
        centerX = centerX,
        logoSize = logoSize,
        logoY = groupTop + logoSize * 0.5,
        titleY = titleY,
        statusY = statusY,
        detailY = detailY,
        buttonX = centerX - buttonW * 0.5,
        buttonY = buttonY,
        buttonW = buttonW,
        buttonH = buttonH,
    }
end

local function DrawLoaderText(text, font, x, y, color, align)
    text = tostring(text or "")
    surface.SetFont(font)
    local tw = surface.GetTextSize(text)
    if align == "center" then
        x = x - tw * 0.5
    elseif align == "right" then
        x = x - tw
    end
    draw.SimpleText(text, font, math.floor(x + 0.5), math.floor(y + 0.5), color, 0, 0)
end

local function DrawLoaderWrappedText(text, font, centerX, y, maxWidth, color, lineGap)
    surface.SetFont(font)
    local lines = {}
    for paragraph in (tostring(text or "") .. "\n"):gmatch("(.-)\n") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            local candidate = line == "" and word or (line .. " " .. word)
            if line ~= "" and surface.GetTextSize(candidate) > maxWidth then
                lines[#lines + 1] = line
                line = word
            else
                line = candidate
            end
        end
        if line ~= "" then lines[#lines + 1] = line end
    end
    for i = 1, math.min(#lines, 3) do
        DrawLoaderText(lines[i], font, centerX, y + (i - 1) * lineGap, color, "center")
    end
end

local function DrawLoaderBrand(cx, cy, size, alpha)
    if not loaderLogoMaterial or loaderLogoMaterial:IsError() then
        DrawLoaderText("LOGO ASSET UNAVAILABLE", "ThemeEngineLoaderData", cx, cy, Color(215, 183, 90, alpha), "center")
        return
    end
    surface.SetMaterial(loaderLogoMaterial)
    surface.SetDrawColor(226, 238, 242, alpha)
    surface.DrawTexturedRect(math.floor(cx - size * 0.5), math.floor(cy - size * 0.5), math.floor(size), math.floor(size))
end

function ThemeEngine_SetStartupStatus(status, mode, detail)
    loaderOverlayStatus = tostring(status or "INITIALIZING")
    if mode ~= nil then loaderOverlayMode = tostring(mode) end
    if detail ~= nil then loaderOverlayDetail = tostring(detail) end
end

function ThemeEngine_ShowStartupOverlay()
    if not MENU_DLL then return nil end
    if loaderOverlayDismissed then return nil end
    if IsValid(loaderOverlay) then
        loaderOverlay:SetAlpha(255)
        loaderOverlay:MoveToFront()
        return loaderOverlay
    end
    if not IsValid(pnlMainMenu) then
        if not timer.Exists("ThemeEngine_MasterOverlayWait") then
            timer.Create("ThemeEngine_MasterOverlayWait", 0.05, 0, function()
                if IsValid(pnlMainMenu) then
                    timer.Remove("ThemeEngine_MasterOverlayWait")
                    ThemeEngine_ShowStartupOverlay()
                end
            end)
        end
        return nil
    end

    loaderOverlayStartedAt = SysTime()
    loaderOverlay = vgui.Create("DPanel", pnlMainMenu)
    loaderOverlay:Dock(FILL)
    loaderOverlay:SetZPos(30000)
    loaderOverlay:SetMouseInputEnabled(true)
    loaderOverlay:SetKeyboardInputEnabled(false)
    loaderOverlay.Paint = function(_, w, h)
        local elapsed = SysTime() - loaderOverlayStartedAt
        local layout = GetLoaderLayout(w, h)
        local scale = layout.scale
        local grid = math.Clamp(math.floor(56 * scale), 34, 76)
        local inset = math.max(10, math.floor(18 * scale))
        local cyan = Color(113, 194, 222)
        local amber = Color(215, 183, 90)
        surface.SetDrawColor(5, 8, 10, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(113, 194, 222, 7)
        for x = layout.x, layout.x + layout.w, grid do surface.DrawRect(x, layout.y, 1, layout.h) end
        for y = layout.y, layout.y + layout.h, grid do surface.DrawRect(layout.x, y, layout.w, 1) end

        surface.SetDrawColor(113, 194, 222, 42)
        surface.DrawOutlinedRect(layout.x, layout.y, layout.w, layout.h, 1)
        surface.DrawRect(layout.x, layout.y + layout.headerH, layout.w, 1)
        surface.DrawRect(layout.x, layout.y + layout.h - layout.footerH, layout.w, 1)

        DrawLoaderText("APERTURE LABORATORIES", "ThemeEngineLoaderLabel", layout.x + inset, layout.y + math.floor(17 * scale), cyan)
        DrawLoaderText("THEME ENGINE / MENU INTEGRATION", "ThemeEngineLoaderData", layout.x + inset, layout.y + math.floor(39 * scale), Color(132, 151, 159))
        DrawLoaderText("BOOTSTRAP 01", "ThemeEngineLoaderData", layout.x + layout.w - inset, layout.y + math.floor(24 * scale), Color(132, 151, 159), "right")

        local logoAlpha = loaderOverlayMode == "missing" and 255 or math.floor(232 + (math.sin(elapsed * 1.5) * 0.5 + 0.5) * 23)
        DrawLoaderBrand(layout.centerX, layout.logoY, layout.logoSize, logoAlpha)

        DrawLoaderText("THEME ENGINE", "ThemeEngineLoaderTitle", layout.centerX, layout.titleY, Color(224, 235, 238), "center")
        local statusColor = loaderOverlayMode == "missing" and Color(238, 139, 112) or amber
        DrawLoaderText(loaderOverlayStatus, "ThemeEngineLoaderStatus", layout.centerX, layout.statusY, statusColor, "center")
        if loaderOverlayDetail ~= "" then
            DrawLoaderWrappedText(loaderOverlayDetail, "ThemeEngineLoaderData", layout.centerX, layout.detailY, math.min(layout.w - inset * 4, math.floor(720 * scale)), Color(151, 171, 179), math.max(12, math.floor(15 * scale)))
        end
        local barW = math.Clamp(math.floor(layout.w * 0.3), math.floor(200 * scale), math.floor(520 * scale))
        local barX = layout.centerX - barW * 0.5
        local barY = layout.buttonY - math.max(10, math.floor(15 * scale))
        local sweepW = math.max(40, math.floor(barW * 0.2))
        local sweepX = math.floor((elapsed * 105 * scale) % (barW + sweepW)) - sweepW
        local drawStart = math.max(0, sweepX)
        local drawEnd = math.min(barW, sweepX + sweepW)
        if loaderOverlayMode ~= "missing" then
            surface.SetDrawColor(113, 194, 222, 34)
            surface.DrawRect(barX, barY, barW, 2)
            if drawEnd > drawStart then
                surface.SetDrawColor(215, 183, 90, 235)
                surface.DrawRect(barX + drawStart, barY, drawEnd - drawStart, 2)
            end
        end

        local footerY = layout.y + layout.h - layout.footerH + math.max(9, math.floor(15 * scale))
        DrawLoaderText("WORKSHOP LINK  " .. THEME_ENGINE_WSID, "ThemeEngineLoaderData", layout.x + inset, footerY, Color(132, 151, 159))
        local footerState = loaderOverlayMode == "missing" and "STATE  ADDON REQUIRED" or string.format("ELAPSED  %05.2fs", elapsed)
        DrawLoaderText(footerState, "ThemeEngineLoaderData", layout.x + layout.w - inset, footerY, Color(132, 151, 159), "right")
    end
    loaderQuitButton = vgui.Create("DButton", loaderOverlay)
    loaderQuitButton:SetText("")
    loaderQuitButton:SetSize(176, 40)
    loaderQuitButton:SetCursor("hand")
    loaderQuitButton.DoClick = function()
        loaderOverlayDismissed = true
        ThemeEngine_HideStartupOverlay(true)
    end
    loaderQuitButton.Paint = function(button, w, h)
        local hovered = button:IsHovered()
        surface.SetDrawColor(hovered and Color(34, 52, 61, 248) or Color(13, 25, 32, 246))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(hovered and Color(215, 183, 90, 210) or Color(113, 194, 222, 95))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        surface.DrawRect(0, h - 2, w, 2)
        surface.SetFont("ThemeEngineLoaderLabel")
        local _, th = surface.GetTextSize("QUIT")
        DrawLoaderText("QUIT", "ThemeEngineLoaderLabel", w * 0.5, (h - th) * 0.5, hovered and Color(250, 232, 176) or Color(218, 231, 236), "center")
    end
    loaderOverlay.PerformLayout = function(_, w, h)
        if not IsValid(loaderQuitButton) then return end
        local layout = GetLoaderLayout(w, h)
        loaderQuitButton:SetSize(layout.buttonW, layout.buttonH)
        loaderQuitButton:SetPos(math.floor(layout.buttonX), math.floor(layout.buttonY))
    end
    loaderOverlay:MoveToFront()
    return loaderOverlay
end

local function HideAddonErrorNotice()
    timer.Remove("ThemeEngine_MasterAddonErrorNotice")
    if not IsValid(loaderErrorPopup) then
        loaderErrorPopup = nil
        return
    end
    local panel = loaderErrorPopup
    panel:AlphaTo(0, 0.2, 0, function()
        if IsValid(panel) then panel:Remove() end
        if loaderErrorPopup == panel then loaderErrorPopup = nil end
    end)
end

local function ClearAddonErrorState()
    timer.Remove("ThemeEngine_MasterAddonErrorNotice")
    loaderErrorNoticeShown = false
    if IsValid(loaderErrorPopup) then loaderErrorPopup:Remove() end
    loaderErrorPopup = nil
end

local function ShowAddonErrorNotice()
    if not MENU_DLL or loaderErrorNoticeShown or not IsValid(pnlMainMenu) then return end
    if IsAddonMounted and IsAddonMounted() then return end
    loaderErrorNoticeShown = true

    if file.Exists("sound/error.wav", "GAME") then
        surface.PlaySound("error.wav")
    else
        surface.PlaySound("buttons/button10.wav")
    end

    if IsValid(loaderErrorPopup) then loaderErrorPopup:Remove() end
    loaderErrorPopup = vgui.Create("DPanel", pnlMainMenu)
    loaderErrorPopup:SetZPos(31000)
    loaderErrorPopup:SetAlpha(0)
    loaderErrorPopup:SetMouseInputEnabled(true)
    loaderErrorPopup.Paint = function(_, w, h)
        surface.SetDrawColor(16, 22, 26, 250)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(238, 139, 112, 235)
        surface.DrawRect(0, 0, 4, h)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        DrawLoaderText("THEME ENGINE ADDON UNAVAILABLE", "ThemeEngineLoaderLabel", 18, 12, Color(238, 139, 112))
        DrawLoaderWrappedText("Workshop item " .. THEME_ENGINE_WSID .. " is not mounted. Re-enable it in Addons to restore Theme Engine.", "ThemeEngineLoaderData", (w - 92) * 0.5, 38, w - 210, Color(190, 205, 211), 14)
    end
    loaderErrorPopup.PerformLayout = function(panel)
        local sw, sh = pnlMainMenu:GetWide(), pnlMainMenu:GetTall()
        local width = math.Clamp(math.floor(sw * 0.62), 420, 900)
        panel:SetSize(width, 74)
        panel:SetPos(math.floor((sw - width) * 0.5), math.Clamp(math.floor(sh * 0.035), 16, 42))
    end
    loaderErrorPopup:InvalidateLayout(true)

    local close = vgui.Create("DButton", loaderErrorPopup)
    close:SetText("")
    close:SetSize(92, 38)
    close:SetPos(loaderErrorPopup:GetWide() - 104, 18)
    close:SetCursor("hand")
    close:SetMouseInputEnabled(true)
    close:SetKeyboardInputEnabled(false)
    close.Paint = function(button, w, h)
        local hovered = button:IsHovered()
        surface.SetDrawColor(hovered and Color(238, 139, 112, 70) or Color(255, 255, 255, 8))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(hovered and Color(238, 139, 112, 220) or Color(113, 194, 222, 90))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        DrawLoaderText("DISMISS", "ThemeEngineLoaderData", w * 0.5, 12, hovered and Color(255, 229, 219) or Color(218, 231, 236), "center")
    end
    close.DoClick = HideAddonErrorNotice
    loaderErrorPopup.OnSizeChanged = function(panel, w)
        if IsValid(close) then close:SetPos(w - 104, 18) end
    end
    loaderErrorPopup:MoveToFront()
    close:MoveToFront()
    loaderErrorPopup:AlphaTo(255, 0.18, 0)
end

local function ScheduleAddonErrorNotice()
    if not MENU_DLL or loaderErrorNoticeShown or timer.Exists("ThemeEngine_MasterAddonErrorNotice") then return end
    timer.Create("ThemeEngine_MasterAddonErrorNotice", 10, 1, function()
        if IsAddonMounted and IsAddonMounted() then return end
        local info = GetAddonInfo and GetAddonInfo()
        if info and info.downloaded == false then
            ScheduleAddonErrorNotice()
            return
        end
        ShowAddonErrorNotice()
    end)
end

function ThemeEngine_HideStartupOverlay(keepWorkshopWatch)
    timer.Remove("ThemeEngine_MasterOverlayWait")
    timer.Remove("ThemeEngine_MasterOverlayReadyFallback")
    if not keepWorkshopWatch then timer.Remove("ThemeEngine_MasterWorkshopWaitFallback") end
    if not IsValid(loaderOverlay) then return end
    local panel = loaderOverlay
    loaderQuitButton = nil
    panel:AlphaTo(0, 0.32, 0, function()
        if IsValid(panel) then panel:Remove() end
        if loaderOverlay == panel then loaderOverlay = nil end
    end)
end

function ThemeEngine_MarkMainMenuReady()
    if not MENU_DLL then return end
    ThemeEngine_SetStartupStatus("MAIN MENU READY", "loading", "")
    timer.Remove("ThemeEngine_MasterOverlayReadyFallback")
    timer.Simple(0.18, ThemeEngine_HideStartupOverlay)
end

local function ScheduleOverlayReadyFallback()
    if not MENU_DLL then return end
    timer.Remove("ThemeEngine_MasterOverlayReadyFallback")
    timer.Create("ThemeEngine_MasterOverlayReadyFallback", 12, 1, function()
        ThemeEngine_SetStartupStatus("MAIN MENU READY", "loading", "")
        ThemeEngine_HideStartupOverlay()
    end)
end

local function ScheduleWorkshopWaitFallback()
    if not MENU_DLL then return end
    timer.Remove("ThemeEngine_MasterWorkshopWaitFallback")
    timer.Create("ThemeEngine_MasterWorkshopWaitFallback", 0.75, 1, function()
        if IsAddonMounted and IsAddonMounted() then
            if CheckAndLoad then CheckAndLoad() end
            return
        end
        local info = GetAddonInfo and GetAddonInfo()
        if info and info.downloaded == false then
            ThemeEngine_SetStartupStatus("DOWNLOADING WORKSHOP ADDON", "loading", "Steam is retrieving Workshop item " .. THEME_ENGINE_WSID .. ".")
            ScheduleWorkshopWaitFallback()
            return
        end
        if info then
            ThemeEngine_SetStartupStatus("WORKSHOP ADDON UNAVAILABLE", "missing", "The addon is installed but not mounted. Re-enable it in Addons, or press Quit to use Garry's Mod without Theme Engine.")
            ScheduleAddonErrorNotice()
            ScheduleWorkshopWaitFallback()
            return
        end
        ThemeEngine_SetStartupStatus("WORKSHOP ADDON REQUIRED", "missing", "Theme Engine needs Workshop item " .. THEME_ENGINE_WSID .. " to operate.\nSubscribe to the addon, then allow Steam to finish downloading it.")
        ScheduleAddonErrorNotice()
        ScheduleWorkshopWaitFallback()
    end)
end

local ALLOWED_THEME_FILES = {
    ["theme_engine_apply.lua"]       = true,
    ["theme_engine_css.lua"]         = true,
    ["theme_engine_html.lua"]        = true,
    ["theme_engine_js.lua"]          = true,
    ["theme_engine_backgrounds.lua"] = true,
    ["theme_engine_music.lua"]       = true,
    ["theme_engine_menusounds.lua"]  = true,
    ["theme_engine_glados.lua"]      = true,
    ["theme_engine_changelog.lua"]   = true,
    ["theme_engine_injection.lua"]   = true,
    ["theme_engine_vgui.lua"]        = true,
    ["theme_engine_misc.lua"]        = true,
    ["theme_engine_spawnmenu.lua"]   = true,
}


local LOAD_ORDER = {
    ["theme_engine_apply.lua"]       = 10,
    ["theme_engine_css.lua"]         = 20,
    ["theme_engine_html.lua"]        = 20,
    ["theme_engine_js.lua"]          = 20,
    ["theme_engine_backgrounds.lua"] = 30,
    ["theme_engine_music.lua"]       = 30,
    ["theme_engine_menusounds.lua"]  = 32,
    ["theme_engine_glados.lua"]      = 35,
    ["theme_engine_changelog.lua"]   = 30,
    ["theme_engine_injection.lua"]   = 40,
    ["theme_engine_vgui.lua"]        = 45,
    ["theme_engine_misc.lua"]        = 90,
}

local _loaded = false
local _addonInfoCache = nil
local _addonInfoCacheTime = -999
local MAX_THEME_FILE_BYTES = 512 * 1024







local function DTE_GetRealIO()

    if type(io) == "table" and type(io.open) == "function" then return io end

    if type(debug) ~= "table" then return nil end
    local ok, reg = pcall(debug.getregistry)
    if not ok or type(reg) ~= "table" then return nil end

    local loaded = rawget(reg, "_LOADED")
    if type(loaded) ~= "table" then return nil end
    local real_io = rawget(loaded, "io")
    if type(real_io) == "table" and type(real_io.open) == "function" then
        return real_io
    end
    return nil
end


local _DTE_REAL_IO = DTE_GetRealIO()


DarkThemeEngine_HostFS = DarkThemeEngine_HostFS or { io = _DTE_REAL_IO, os = os }

local function DTE_NormalizePath(path)
    path = tostring(path or ""):gsub("\\", "/")
    path = path:gsub("/+", "/")
    return path
end

local function DTE_IsSafeGeneratedAddonPath(path)
    path = DTE_NormalizePath(path)
    if path:find("%.%.", 1, true) or path:find(":", 1, true) then return false end
    if path:sub(1, 1) == "/" then return false end
    return path:match("^addons/theme_engine_[%w_%-]+/") ~= nil
        and not path:find("/lua/", 1, true)
end


local _DTE_GAMEDIR_CACHE = nil
local _DTE_GAMEDIR_CHECKED = false

local function DTE_GameDir()

    if _DTE_GAMEDIR_CHECKED then return _DTE_GAMEDIR_CACHE end
    _DTE_GAMEDIR_CHECKED = true


    if engine and engine.GetGameDir then
        local ok, dir = pcall(engine.GetGameDir)
        if ok and dir and dir ~= "" then
            _DTE_GAMEDIR_CACHE = DTE_NormalizePath(dir):gsub("/$", "")
            return _DTE_GAMEDIR_CACHE
        end
    end




    if _DTE_REAL_IO and _DTE_REAL_IO.open then
        local SENTINEL_NAME = "__dte_gamedir_probe.tmp"
        local SENTINEL_DATA = "DTE_GAMEDIR_PROBE_" .. tostring(os and os.time and os.time() or 1)
        pcall(file.CreateDir, "")
        pcall(file.Write, SENTINEL_NAME, SENTINEL_DATA)




        local candidates = {
            "garrysmod",
            ".",
            "garrysmod/garrysmod",
        }
        for _, prefix in ipairs(candidates) do
            local tryPath = prefix .. "/data/" .. SENTINEL_NAME
            local fh = _DTE_REAL_IO.open(tryPath:gsub("/", "\\"), "rb")
            if not fh then fh = _DTE_REAL_IO.open(tryPath, "rb") end
            if fh then
                local content = fh:read("*a")
                fh:close()
                if content == SENTINEL_DATA then
                    pcall(file.Delete, SENTINEL_NAME)
                    _DTE_GAMEDIR_CACHE = DTE_NormalizePath(prefix)
                    DarkThemeEngine_Log("debug", "Loader", "Game directory detected: " .. _DTE_GAMEDIR_CACHE)
                    return _DTE_GAMEDIR_CACHE
                end
            end
        end
        pcall(file.Delete, SENTINEL_NAME)
    end


    if type(debug) == "table" and debug.getinfo then
        local ok, info = pcall(debug.getinfo, 1, "S")
        if ok and info and info.source then

            local src = info.source:gsub("^@", ""):gsub("\\", "/")
            local base = src:match("^(.*)/lua/includes/")
            if base and base ~= "" then
                _DTE_GAMEDIR_CACHE = base
                DarkThemeEngine_Log("debug", "Loader", "Game directory detected from source: " .. base)
                return _DTE_GAMEDIR_CACHE
            end
        end
    end

    DarkThemeEngine_Log("warn", "Loader", "Could not determine the Garry's Mod directory")
    return nil
end

local function DTE_Mkdir(dir)
    local hostOS = DarkThemeEngine_HostFS and DarkThemeEngine_HostFS.os
    if not hostOS or not hostOS.execute then return false, "os.execute unavailable" end
    dir = tostring(dir or ""):gsub("/", "\\")
    if dir == "" then return false, "empty directory" end
    local ok = pcall(hostOS.execute, 'mkdir "' .. dir:gsub('"', '') .. '" 2>nul')
    if not ok then return false, "mkdir failed" end
    return true
end

function DarkThemeEngine_WriteGeneratedAddonFile(path, data)
    path = DTE_NormalizePath(path)
    if not DTE_IsSafeGeneratedAddonPath(path) then
        return false, "blocked unsafe addon path"
    end

    local hostIO = DarkThemeEngine_HostFS and DarkThemeEngine_HostFS.io
    if not hostIO or not hostIO.open then
        return false, "io.open unavailable"
    end

    local base = DTE_GameDir()
    local realPath = base and (base .. "/" .. path) or path
    local dir = realPath:match("^(.*)/[^/]+$")
    if dir then
        local ok, reason = DTE_Mkdir(dir)
        if not ok then return false, reason end
    end

    local ok, handle = pcall(hostIO.open, realPath, "wb")
    if not ok or not handle then
        return false, "io.open write denied"
    end

    handle:write(data or "")
    handle:close()
    return true, realPath
end





local function IsAllowedThemeFile(name)
    return type(name) == "string"
        and ALLOWED_THEME_FILES[name] == true
        and not string.find(name, "[/\\]", 1, false)
end

local function GetThemeReadCandidates(filepath)
    local out = {}
    local info = GetAddonInfo()
    if info and info.title and info.mounted then
        table.insert(out, { "lua/" .. filepath, info.title })
    end




    if CLIENT or SERVER then
        table.insert(out, { "lua/" .. filepath, "GAME" })
        table.insert(out, { filepath, "LUA" })
    end

    return out
end

local function DiscoverThemeFiles()
    local found, added = {}, {}
    for name in pairs(ALLOWED_THEME_FILES) do
        if not added[name] then
            local filepath = "theme_engine/" .. name
            for _, candidate in ipairs(GetThemeReadCandidates(filepath)) do
                if file.Exists(candidate[1], candidate[2]) then
                    table.insert(found, name)
                    added[name] = true
                    break
                end
            end
        end
    end
    table.sort(found, function(a, b)
        local pa, pb = LOAD_ORDER[a] or 50, LOAD_ORDER[b] or 50
        if pa ~= pb then return pa < pb end
        return a < b
    end)
    return found
end





GetAddonInfo = function()

    if engine and engine.GetAddons then
        if _addonInfoCache and SysTime() - _addonInfoCacheTime < 1 then
            return _addonInfoCache
        end
        local addons = engine.GetAddons()
        local found
        for _, v in ipairs(addons) do
            local wsid = tostring(v.wsid or "")
            if THEME_ENGINE_WSIDS[wsid] then
                if v.mounted then
                    found = v
                    break
                end
                if not found or (found.downloaded == false and v.downloaded ~= false) then
                    found = v
                end
            end
        end
        _addonInfoCache = found
        _addonInfoCacheTime = SysTime()
        return found
    end
    return nil
end

IsAddonMounted = function()
    local info = GetAddonInfo()
    if info then return info.mounted end

    if CLIENT or SERVER then
        return file.Exists("lua/theme_engine/theme_engine_css.lua", "GAME")
    end
    return false
end

local function IsAddonInstalled()
    local info = GetAddonInfo()
    return info ~= nil
end





function DarkThemeEngine_SafeInclude(filepath)
    local name = string.GetFileFromFilename(filepath or "")
    if not IsAllowedThemeFile(name) or filepath ~= ("theme_engine/" .. name) then
        DarkThemeEngine_Log("warn", "Loader", "Blocked unexpected theme file: " .. tostring(filepath))
        return false
    end

    local code
    for _, candidate in ipairs(GetThemeReadCandidates(filepath)) do
        local sz = file.Size(candidate[1], candidate[2])
        if not sz or sz <= MAX_THEME_FILE_BYTES then
            code = file.Read(candidate[1], candidate[2])
        end
        if code and code ~= "" then break end
    end
    if not code or code == "" then
        DarkThemeEngine_Log("error", "Loader", "Could not read " .. filepath)
        return false
    end
    local ok, err = pcall(RunString, code, filepath)
    if not ok then
        DarkThemeEngine_Log("error", "Loader", "Failed to execute " .. filepath .. ": " .. tostring(err))
        return false
    end
    return true
end





local function LoadThemeEngine()
    if _loaded then return end

    timer.Remove("ThemeEngine_MasterWorkshopWaitFallback")
    ClearAddonErrorState()

    local files = DiscoverThemeFiles()
    if #files == 0 then
        if MENU_DLL then
            ThemeEngine_SetStartupStatus("WAITING FOR WORKSHOP FILES", "loading", "The addon is mounted; waiting for its Lua modules to become readable.")
            ThemeEngine_ShowStartupOverlay()
            ScheduleWorkshopWaitFallback()
        end
        return
    end
    if MENU_DLL then
        ThemeEngine_SetStartupStatus("LOADING THEME ENGINE MODULES", "loading", "")
        ThemeEngine_ShowStartupOverlay()
    end

    local state = MENU_DLL and "MENU" or CLIENT and "CLIENT" or SERVER and "SERVER" or "?"
    DarkThemeEngine_Log("info", "Loader", "Loading " .. #files .. " modules (" .. state .. ")")

    if SERVER then
        for _, name in ipairs(files) do
            AddCSLuaFile("theme_engine/" .. name)
        end
        _loaded = true
        DarkThemeEngine_Log("info", "Loader", "Ready (server files registered)")
        return
    end



    local function LoadOne(name)
        local isClientOnly = CLIENT_ONLY[name]
        if MENU_DLL and not isClientOnly then
            DarkThemeEngine_SafeInclude("theme_engine/" .. name)
        elseif CLIENT and isClientOnly then
            if name == "theme_engine_spawnmenu.lua" and DarkThemeEngine and DarkThemeEngine._SpawnmenuLoaded then
                return
            end
            DarkThemeEngine = DarkThemeEngine or {}
            DarkThemeEngine._SpawnmenuLoaded = true
            DarkThemeEngine_SafeInclude("theme_engine/" .. name)
        else
            return
        end
    end

    local deferred = {}
    for _, name in ipairs(files) do
        if (LOAD_ORDER[name] or 50) < 30 then
            LoadOne(name)
        else
            table.insert(deferred, name)
        end
    end

    _loaded = true
    loaderLoadedOnce = true

    if #deferred == 0 then
        DarkThemeEngine_Log("info", "Loader", "Ready")
        ThemeEngine_SetStartupStatus("FINALIZING MAIN MENU", "loading", "")
        ScheduleOverlayReadyFallback()
        return
    end

    local idx = 1
    local function Step()
        if not _loaded then return end
        if idx > #deferred then
            DarkThemeEngine_Log("info", "Loader", "Ready")
            ThemeEngine_SetStartupStatus("FINALIZING MAIN MENU", "loading", "")
            ScheduleOverlayReadyFallback()
            return
        end
        LoadOne(deferred[idx])
        idx = idx + 1
        timer.Simple(0, Step)
    end
    timer.Simple(0, Step)
end

local function UnloadThemeEngine()
    if not _loaded then return end
    _loaded = false
    DarkThemeEngine_Log("info", "Loader", "Addon disabled; unloading")


    if DarkThemeEngine then
        if DarkThemeEngine.RestoreDefaultMenu then
            pcall(DarkThemeEngine.RestoreDefaultMenu)
        end

        if DarkThemeEngine.Cleanup then
            pcall(DarkThemeEngine.Cleanup)
        end

        if DarkThemeEngine._OriginalGetDefaultSkin then
            derma.GetDefaultSkin = DarkThemeEngine._OriginalGetDefaultSkin
            DarkThemeEngine._OriginalGetDefaultSkin = nil
        end
    end

    if loaderOriginalBackgroundFunctions.ClearBackgroundImages then _G.ClearBackgroundImages = loaderOriginalBackgroundFunctions.ClearBackgroundImages end
    if loaderOriginalBackgroundFunctions.AddBackgroundImage then _G.AddBackgroundImage = loaderOriginalBackgroundFunctions.AddBackgroundImage end
    if loaderOriginalBackgroundFunctions.ChangeBackground then _G.ChangeBackground = loaderOriginalBackgroundFunctions.ChangeBackground end
    if loaderOriginalBackgroundFunctions.DrawBackground then _G.DrawBackground = loaderOriginalBackgroundFunctions.DrawBackground end
    if MENU_DLL and IsValid(pnlMainMenu) and pnlMainMenu.UpdateBackgroundImages then
        pcall(pnlMainMenu.UpdateBackgroundImages, pnlMainMenu)
    end


    hook.Remove("InitPostEntity", "ThemeEngine_SkinInit")
    hook.Remove("SpawnMenuCreated", "ThemeEngine_SkinOnCreate")
    hook.Remove("SpawnMenuOpen", "ThemeEngine_SkinEnforce")
    hook.Remove("MenuStart", "ThemeEngineReinject")
    hook.Remove("GameContentChanged", "DarkTheme_AddonRefresh")
    hook.Remove("GameContentChanged", "DarkTheme_MiscAddonRefresh")
    hook.Remove("WorkshopDownloadedFile", "ThemeEngine_WorkshopDownloadReady")
    hook.Remove("WorkshopEnd", "ThemeEngine_WorkshopEndApply")
    hook.Remove("WorkshopSubscriptionsChanged", "ThemeEngine_WorkshopSubsChanged")
    hook.Remove("GameContentChanged", "ThemeEngine_WorkshopMountedRefresh")
    hook.Remove("Think", "DTE_VguiTheme_ScanPopups")
    hook.Remove("LoadingScreenPanelCreated", "DTE_VguiTheme_LoadingPanel")
    hook.Remove("Think", "DTE_VguiTheme_Notifications")

    local addonTimers = {
        "DarkTheme_LoadingWatch",
        "DarkTheme_BackgroundPreviewDriver",
        "DarkTheme_HijackEngine",
        "DarkTheme_BackgroundWarmCache",
        "DarkTheme_AddonRefresh_Debounce",
        "DarkThemeEngine_WorkshopApplyDebounce",
        "DarkThemeEngine_WorkshopPendingPoll",
        "DarkTheme_CoverSend",
        "DarkThemeEngine_Music_Poll",
        "DarkThemeEngine_MusicFileWatch",
    }
    for _, timerName in ipairs(addonTimers) do timer.Remove(timerName) end


    if MENU_DLL and IsValid(pnlMainMenu) and pnlMainMenu.CallJS then
        pcall(pnlMainMenu.CallJS, pnlMainMenu, [[
            if (window.DarkThemeEngine_Unload) {
                window.DarkThemeEngine_Unload();
            } else {
                (function() {
                    var ids = [
                        'dark_theme_css_menu', 'dark_theme_css_navbar', 'dark_theme_css_newgame',
                        'dark_theme_css_servers', 'dark_theme_css_workshop', 'dark_theme_css_custom',
                        'dark_theme_css_extra', 'dark_theme_css_alwayson', 'dark_theme_custom_overlay',
                        'dt_menu_font_style', 'dt_menu_fontsize_style', 'dt_local_fonts_style'
                    ];
                    for (var i = 0; i < ids.length; i++) {
                        var element = document.getElementById(ids[i]);
                        if (element) element.remove();
                    }
                    var link = document.getElementById('theme_options_btn');
                    if (link) {
                        var parent = link.parentElement;
                        link.remove();
                        if (parent && (parent.tagName || '').toLowerCase() === 'li' && parent.children.length === 0) parent.remove();
                    }
                    if (document && document.body) {
                        document.body.classList.remove('dark-theme-custom-active', 'dt-modal-open');
                        document.body.removeAttribute('data-theme-engine-custom');
                    }
                    if (typeof lua !== 'undefined' && window._DT_OriginalPlaySound) lua.PlaySound = window._DT_OriginalPlaySound;
                    try {
                        var injector = angular.element(document.body).injector();
                        if (!injector) return;
                        var cache = injector.get('$templateCache');
                        var route = injector.get('$route');
                        if (window._DT_FullThemeOriginalTemplates) {
                            for (var key in window._DT_FullThemeOriginalTemplates) {
                                if (Object.prototype.hasOwnProperty.call(window._DT_FullThemeOriginalTemplates, key)) {
                                    cache.put(key, window._DT_FullThemeOriginalTemplates[key] || '');
                                }
                            }
                        }
                        cache.remove('template/dark_theme.html');
                        delete route.routes['/theme/'];
                        delete route.routes['/theme'];
                        window.DarkThemeEngine_InjectLink = function() {};
                        if (String(window.location.hash || '').indexOf('#/theme') === 0) window.location.hash = '#/';
                        else if (route.reload) route.reload();
                    } catch (e) {}
                })();
            }
        ]])
    end


    if DarkThemeEngine and DarkThemeEngine.VguiTheme and DarkThemeEngine.VguiTheme.Deactivate then
        pcall(DarkThemeEngine.VguiTheme.Deactivate)
    end


    DarkThemeEngine_ApplySpawnmenuSkin = nil
    DarkThemeEngine_InvalidateSpawnmenuSkinCache = nil

end





local function RemoveAllHooks()
    timer.Remove("ThemeEngine_MasterAddonRegistrationWait")
    timer.Remove("ThemeEngine_MasterWorkshopWaitFallback")
    timer.Remove("ThemeEngine_MasterAddonErrorNotice")
    hook.Remove("GameContentChanged", "ThemeEngineLoader_Watch")
    hook.Remove("MenuStart", "ThemeEngineLoader_StartupOverlay")
    hook.Remove("InitPostEntity", "ThemeEngine_SkinInit")
    hook.Remove("SpawnMenuCreated", "ThemeEngine_SkinOnCreate")
    hook.Remove("SpawnMenuOpen", "ThemeEngine_SkinEnforce")
    hook.Remove("MenuStart", "ThemeEngineReinject")
end





CheckAndLoad = function()
    if IsAddonMounted() then
        ClearAddonErrorState()
        if not _loaded then
            LoadThemeEngine()
        end
    else
        local info = GetAddonInfo()
        local wasRunning = _loaded or loaderLoadedOnce
        if _loaded then
            UnloadThemeEngine()
        end
        if MENU_DLL and info and not wasRunning then
            if info.downloaded == false then
                ThemeEngine_SetStartupStatus("DOWNLOADING WORKSHOP ADDON", "loading", "Steam is retrieving Workshop item " .. THEME_ENGINE_WSID .. ".")
            else
                ThemeEngine_SetStartupStatus("MOUNTING WORKSHOP ADDON", "loading", "Waiting for Garry's Mod to mount the subscribed Theme Engine files.")
            end
            ThemeEngine_ShowStartupOverlay()
            ScheduleWorkshopWaitFallback()
            if info.downloaded ~= false then ScheduleAddonErrorNotice() end
        elseif MENU_DLL and not wasRunning then
            ThemeEngine_SetStartupStatus("WORKSHOP ADDON REQUIRED", "missing", "Theme Engine needs Workshop item " .. THEME_ENGINE_WSID .. " to operate.\nSubscribe to the addon, then allow Steam to finish downloading it.")
            ThemeEngine_ShowStartupOverlay()
            ScheduleAddonErrorNotice()
        elseif MENU_DLL then
            ScheduleAddonErrorNotice()
            ScheduleWorkshopWaitFallback()
        end
    end
end

local function WaitForAddonRegistration()
    timer.Remove("ThemeEngine_MasterAddonRegistrationWait")
    if IsAddonInstalled() then
        CheckAndLoad()
        return
    end

    local wasRunning = _loaded or loaderLoadedOnce
    if _loaded then UnloadThemeEngine() end
    ThemeEngine_SetStartupStatus("WORKSHOP ADDON REQUIRED", "missing", "Theme Engine needs Workshop item " .. THEME_ENGINE_WSID .. " to operate.\nSubscribe to the addon, then allow Steam to finish downloading it.")
    if not wasRunning then ThemeEngine_ShowStartupOverlay() end
    ScheduleAddonErrorNotice()
    timer.Create("ThemeEngine_MasterAddonRegistrationWait", 0.5, 0, function()
        if IsAddonInstalled() then
            timer.Remove("ThemeEngine_MasterAddonRegistrationWait")
            CheckAndLoad()
        end
    end)
end

if MENU_DLL then
    local initialInfo = GetAddonInfo()
    if not initialInfo then
        ThemeEngine_SetStartupStatus("WORKSHOP ADDON REQUIRED", "missing", "Theme Engine needs Workshop item " .. THEME_ENGINE_WSID .. " to operate.\nSubscribe to the addon, then allow Steam to finish downloading it.")
    elseif initialInfo.downloaded == false then
        ThemeEngine_SetStartupStatus("DOWNLOADING WORKSHOP ADDON", "loading", "Steam is retrieving Workshop item " .. THEME_ENGINE_WSID .. ".")
    else
        ThemeEngine_SetStartupStatus("WAITING FOR WORKSHOP", "loading", "Preparing the Theme Engine Workshop files.")
    end
    ThemeEngine_ShowStartupOverlay()

    hook.Add("MenuStart", "ThemeEngineLoader_StartupOverlay", function()
        if IsAddonMounted() then
            ThemeEngine_SetStartupStatus("FINALIZING MAIN MENU", "loading", "")
        elseif not GetAddonInfo() then
            ThemeEngine_SetStartupStatus("WORKSHOP ADDON REQUIRED", "missing", "Theme Engine needs Workshop item " .. THEME_ENGINE_WSID .. " to operate.\nSubscribe to the addon, then allow Steam to finish downloading it.")
        elseif GetAddonInfo().downloaded == false then
            ThemeEngine_SetStartupStatus("DOWNLOADING WORKSHOP ADDON", "loading", "Steam is retrieving Workshop item " .. THEME_ENGINE_WSID .. ".")
        else
            ThemeEngine_SetStartupStatus("WAITING FOR WORKSHOP", "loading", "Preparing the Theme Engine Workshop files.")
        end
        ThemeEngine_ShowStartupOverlay()
        timer.Simple(0, CheckAndLoad)
    end)



    hook.Add("GameContentChanged", "ThemeEngineLoader_Watch", function()
        _addonInfoCache = nil
        _addonInfoCacheTime = -999

        if not IsAddonInstalled() then
            WaitForAddonRegistration()
            return
        end


        timer.Simple(0.1, CheckAndLoad)
    end)



    timer.Simple(0, function()
        WaitForAddonRegistration()
    end)


elseif CLIENT or SERVER then
    timer.Simple(0, function()
        if IsAddonMounted() then
            LoadThemeEngine()
        else
            RemoveAllHooks()
        end
    end)
end
