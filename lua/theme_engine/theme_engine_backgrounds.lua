DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}

DarkThemeEngine.AllBackgrounds = DarkThemeEngine.AllBackgrounds or {}
DarkThemeEngine.AllBackgroundsLookup = DarkThemeEngine.AllBackgroundsLookup or {}

local DATA_DIR = "theme_engine_data"
local SETTINGS_FILE = DATA_DIR .. "/settings.json"
local BG_CACHE_FILE = DATA_DIR .. "/backgrounds_cache.json"

local StaticImages = {}
local Active = nil
local Outgoing = nil
local NextSwapTime = 0
local LowercaseDisabled = nil
local CachedBgJSON = nil  

function DarkThemeEngine.SaveSettings()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(SETTINGS_FILE, util.TableToJSON(DarkThemeEngine.Settings, true))
end

local function EnsureSettingsExist()
    if file.Exists(SETTINGS_FILE, "DATA") then
        local content = file.Read(SETTINGS_FILE, "DATA")
        if content and content ~= "" then
            local loaded = util.JSONToTable(content)
            if loaded then
                DarkThemeEngine.Settings = loaded
                return
            end
        end
    end

    DarkThemeEngine.Settings = {
        ThemeOptions = {
            Mode = "light",
            CustomBg = "#2b2b2b",
            CustomText = "#e0e0e0",
            CustomAccent = "#0078d7",
            CustomBorder = "#555555",
            BG_Static = false,
            BG_NoZoom = false,
            BG_NoFade = false,
            EnableMusic = false,
            Music_PlaylistMode = false,
            Music_Shuffle = false
        },
        DisabledBackgrounds = {},
        DisabledMusic = {}
    }
    DarkThemeEngine.SaveSettings()
end
EnsureSettingsExist()

local function LoadBackgroundsCache()
    if file.Exists(BG_CACHE_FILE, "DATA") then
        local content = file.Read(BG_CACHE_FILE, "DATA")
        if content and content ~= "" then
            local cached = util.JSONToTable(content)
            if cached and #cached > 0 then
                DarkThemeEngine.AllBackgrounds = cached
                for _, bg in ipairs(cached) do
                    DarkThemeEngine.AllBackgroundsLookup[string.lower(bg.path)] = true
                end
                CachedBgJSON = content  
                return true
            end
        end
    end
    return false
end

local function SaveBackgroundsCache()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    CachedBgJSON = util.TableToJSON(DarkThemeEngine.AllBackgrounds)
    file.Write(BG_CACHE_FILE, CachedBgJSON)
end

LoadBackgroundsCache()

local function NormalizePath(p)
    if not p then return "" end
    return string.gsub(string.lower(p), "\\", "/")
end

local function GetThemeOptions()
    return DarkThemeEngine.Settings and DarkThemeEngine.Settings.ThemeOptions or {}
end

local function GetDisabledBackgrounds()
    return DarkThemeEngine.Settings and DarkThemeEngine.Settings.DisabledBackgrounds or {}
end

local function EnsureLowercaseDisabled()
    if not LowercaseDisabled then
        LowercaseDisabled = {}
        local disabled = GetDisabledBackgrounds()
        for k, v in pairs(disabled) do
            if type(k) == "string" and v then
                LowercaseDisabled[NormalizePath(k)] = true
            end
        end
    end
end

local function IsBackgroundDisabled(bgName)
    EnsureLowercaseDisabled()
    if not bgName then
        bgName = Active and Active.Name
    end
    if not bgName then return false end
    return LowercaseDisabled[NormalizePath(bgName)] or false
end

function DarkThemeEngine.InvalidateDisabledCache()
    LowercaseDisabled = nil
end

function DarkThemeEngine.ScanBackgrounds()
    DarkThemeEngine.AllBackgrounds = {}
    DarkThemeEngine.AllBackgroundsLookup = {}
    local handledPaths = {}

    local function AddBg(path, category, wsid, isLocal)
        local normPath = string.lower(path)
        if not DarkThemeEngine.AllBackgroundsLookup[normPath] then
            DarkThemeEngine.AllBackgroundsLookup[normPath] = true
            handledPaths[normPath] = true
            table.insert(DarkThemeEngine.AllBackgrounds, {
                path = path,
                category = category or "Gmod Background",
                wsid = wsid or "",
                isLocal = isLocal or false
            })
        end
    end

    local function IsImageFile(f)
        local lower = string.lower(f)
        return string.match(lower, "%.jpg$") or string.match(lower, "%.png$")
    end

    local gamemodes = engine.GetGamemodes()
    local countBefore = 0

    local addons = engine.GetAddons()
    if addons then
        for _, addon in ipairs(addons) do
            if addon.mounted and addon.downloaded ~= false and addon.title then
                local isLocal = (addon.wsid == "" or addon.wsid == "0" or not addon.wsid)
                local addonFiles = file.Find("backgrounds/*", addon.title)
                if addonFiles and #addonFiles > 0 then
                    for _, f in ipairs(addonFiles) do
                        if IsImageFile(f) then
                            AddBg("backgrounds/" .. f, addon.title, tostring(addon.wsid), isLocal)
                        end
                    end
                end
                if gamemodes then
                    for _, gm in ipairs(gamemodes) do
                        if gm and gm.name then
                            local gmFiles = file.Find("gamemodes/" .. gm.name .. "/backgrounds/*", addon.title)
                            if gmFiles and #gmFiles > 0 then
                                for _, f in ipairs(gmFiles) do
                                    if IsImageFile(f) then
                                        AddBg("gamemodes/" .. gm.name .. "/backgrounds/" .. f, addon.title, tostring(addon.wsid), isLocal)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    countBefore = #DarkThemeEngine.AllBackgrounds

    local _, legacyFolders = file.Find("addons/*", "GAME")
    if legacyFolders then
        for _, folderName in ipairs(legacyFolders) do
            local title = folderName
            local addonJsonStr = file.Read("addons/" .. folderName .. "/addon.json", "GAME")
            if addonJsonStr then
                local parsed = util.JSONToTable(addonJsonStr)
                if parsed and parsed.title then title = parsed.title end
            end
            local bgFiles = file.Find("addons/" .. folderName .. "/backgrounds/*", "GAME")
            if bgFiles and #bgFiles > 0 then
                for _, f in ipairs(bgFiles) do
                    if IsImageFile(f) then
                        local normPath = string.lower("backgrounds/" .. f)
                        if not handledPaths[normPath] then
                            AddBg("backgrounds/" .. f, title, "", true)
                        end
                    end
                end
            end
            if gamemodes then
                for _, gm in ipairs(gamemodes) do
                    if gm and gm.name then
                        local gmBgFiles = file.Find("addons/" .. folderName .. "/gamemodes/" .. gm.name .. "/backgrounds/*", "GAME")
                        if gmBgFiles and #gmBgFiles > 0 then
                            for _, f in ipairs(gmBgFiles) do
                                if IsImageFile(f) then
                                    local normPath = string.lower("gamemodes/" .. gm.name .. "/backgrounds/" .. f)
                                    if not handledPaths[normPath] then
                                        AddBg("gamemodes/" .. gm.name .. "/backgrounds/" .. f, title, "", true)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    countBefore = #DarkThemeEngine.AllBackgrounds

    local baseFiles = file.Find("backgrounds/*", "MOD")
    if baseFiles then
        for _, f in ipairs(baseFiles) do
            if IsImageFile(f) then
                local normPath = string.lower("backgrounds/" .. f)
                if not handledPaths[normPath] then
                    AddBg("backgrounds/" .. f, "Gmod Background", "", true)
                end
            end
        end
    end
    countBefore = #DarkThemeEngine.AllBackgrounds

    if gamemodes then
        for _, gm in ipairs(gamemodes) do
            if gm and gm.name then
                local gmFiles = file.Find("gamemodes/" .. gm.name .. "/backgrounds/*", "MOD")
                if gmFiles then
                    for _, f in ipairs(gmFiles) do
                        if IsImageFile(f) then
                            local normPath = string.lower("gamemodes/" .. gm.name .. "/backgrounds/" .. f)
                            if not handledPaths[normPath] then
                                AddBg("gamemodes/" .. gm.name .. "/backgrounds/" .. f, "Gamemode: " .. gm.name, "", true)
                            end
                        end
                    end
                end
            end
        end
    end

    local dataFiles = file.Find("theme_engine_backgrounds/*", "DATA")
    if dataFiles then
        for _, f in ipairs(dataFiles) do
            if IsImageFile(f) then
                local normPath = string.lower("data/theme_engine_backgrounds/" .. f)
                if not handledPaths[normPath] then
                    AddBg("data/theme_engine_backgrounds/" .. f, "Custom Backgrounds", "", true)
                end
            end
        end
    end

    local catCounts = {}
    for _, bg in ipairs(DarkThemeEngine.AllBackgrounds) do
        local cat = bg.category or "Unknown"
        catCounts[cat] = (catCounts[cat] or 0) + 1
    end

    SaveBackgroundsCache()
end

local function CustomClearBackgroundImages()
    StaticImages = {}
end

local function CustomAddBackgroundImage(img)
    local normImg = NormalizePath(img)
    if not DarkThemeEngine.AllBackgroundsLookup[normImg] then
        DarkThemeEngine.AllBackgroundsLookup[normImg] = true
        table.insert(DarkThemeEngine.AllBackgrounds, { path = img })
    end
    table.insert(StaticImages, img)
end

local function ChangeBackground(currentgm, force_swap)
    if IsInGame() or IsInLoading() then return end

    local bgOpts = GetThemeOptions()
    local isStatic = bgOpts.BG_Static and true or false

    if isStatic and not force_swap then
        if not IsBackgroundDisabled() then return end
    end

    if #DarkThemeEngine.AllBackgrounds == 0 then
        Active = nil
        Outgoing = nil
        return
    end

    local validImages = {}
    local isStaticLoop = false

    if isStatic and force_swap and Active and Active.Name then
        table.insert(validImages, Active.Name)
        isStaticLoop = true
    else
        for _, bgData in ipairs(DarkThemeEngine.AllBackgrounds) do
            if bgData and bgData.path and not IsBackgroundDisabled(bgData.path) then
                table.insert(validImages, bgData.path)
            end
        end
    end

    if #validImages == 0 then
        if Active then
            Outgoing = Active
            if bgOpts.BG_NoFade then Outgoing = nil
            else Outgoing.AlphaVel = 255 end
        end
        Active = nil
        DarkThemeEngine.CallJS("if(window.SetCurrentDarkThemeBackground) window.SetCurrentDarkThemeBackground('None');")
        return
    end

    local singleMode = (#validImages == 1)
    local img = validImages[1]
    if not singleMode then img = table.Random(validImages) end

    local attempts = 0
    if Active and Active.Name and not (isStatic and force_swap) then
        while img == Active.Name and attempts < 10 and #validImages > 1 do
            img = table.Random(validImages)
            attempts = attempts + 1
        end
    end

    if Outgoing then Outgoing.mat = nil end
    Outgoing = Active
    if Outgoing then
        Outgoing.AlphaVel = bgOpts.BG_NoFade and 90000 or (isStaticLoop and 50 or 255)
    end

    local mat = Material(img, "nocull smooth")
    if not mat or mat:IsError() then Active = nil return end

    local isNoFade = bgOpts.BG_NoFade or singleMode
    local isNoZoom = bgOpts.BG_NoZoom or singleMode

    Active = {
        Ratio = mat:GetInt("$realwidth") / mat:GetInt("$realheight"),
        Size = 1, BaseSize = 1, Angle = 0,
        AngleVel = isNoZoom and 0 or -(5 / 30),
        SizeVel = isNoZoom and 0 or (0.3 / 30),
        Alpha = isNoFade and 255 or 0,
        AlphaFadeInVel = isNoFade and 90000 or (isStaticLoop and 50 or 255),
        mat = mat, Name = img
    }

    if Active.Ratio < (ScrW() / ScrH()) then
        local addition = ((ScrW() / ScrH()) - Active.Ratio)
        Active.Size = Active.Size + addition
        Active.BaseSize = Active.BaseSize + addition
    end

    NextSwapTime = SysTime() + 20
    DarkThemeEngine.CallJS(string.format(
        "if(window.SetCurrentDarkThemeBackground) window.SetCurrentDarkThemeBackground('%s');",
        string.JavascriptSafe(img or "")
    ))
end

local function Think(tbl, isOutgoing)
    tbl.Angle = tbl.Angle + (tbl.AngleVel * FrameTime())
    local bgOpts = GetThemeOptions()

    if bgOpts.BG_NoZoom then
        
        tbl.Angle = Lerp(FrameTime() * 2, tbl.Angle, 0)
        tbl.Size = Lerp(FrameTime() * 2, tbl.Size, tbl.BaseSize or 1)
        
        if math.abs(tbl.Angle) < 0.01 and math.abs(tbl.Size - (tbl.BaseSize or 1)) < 0.001 then
            tbl.Angle = 0
            tbl.Size = tbl.BaseSize or 1
        end
    elseif bgOpts.BG_Static then

        if not tbl.StartTime then tbl.StartTime = SysTime() end
        local elapsed = SysTime() - tbl.StartTime
        local cycleDuration = 60
        
        local sineVal = (math.sin((elapsed / cycleDuration) * math.pi * 2 - (math.pi / 2)) + 1) / 2
        tbl.Size = (tbl.BaseSize or 1) + (sineVal * 0.15)
    else
        tbl.Size = tbl.Size + ((tbl.SizeVel / tbl.Size) * FrameTime())
    end

    if isOutgoing and tbl.AlphaVel then
        tbl.Alpha = tbl.Alpha - tbl.AlphaVel * FrameTime()
    elseif not isOutgoing then
        tbl.Alpha = math.min(255, tbl.Alpha + tbl.AlphaFadeInVel * FrameTime())
    end
end

local function Render(tbl)
    if not tbl.mat or tbl.Alpha <= 0 then return end
    surface.SetMaterial(tbl.mat)
    surface.SetDrawColor(255, 255, 255, tbl.Alpha)
    
    local scale = tbl.Size * 1.02
    local w = ScrH() * scale * tbl.Ratio
    local h = ScrH() * scale
    local x = ScrW() * 0.5
    local y = ScrH() * 0.5
    surface.DrawTexturedRectRotated(x, y, w, h, tbl.Angle)
end

local function CustomDrawBackground()
    if IsInGame() or IsInLoading() then return end

    local validCount = 0
    for _, bgData in ipairs(DarkThemeEngine.AllBackgrounds) do
        if bgData and bgData.path and not IsBackgroundDisabled(bgData.path) then
            validCount = validCount + 1
        end
    end

    local isStatic = (GetThemeOptions().BG_Static or validCount <= 1)
    if not isStatic and Active and SysTime() > NextSwapTime then ChangeBackground() end
    if Active and IsBackgroundDisabled() then ChangeBackground(nil, true) end
    if not Active and validCount > 0 then ChangeBackground(nil, true) end

    if Active then Think(Active, false) Render(Active) end
    if Outgoing then Think(Outgoing, true) Render(Outgoing) end
end

function ForceDarkThemeBackgroundSwap()
    ChangeBackground(nil, true)
end

function ReceiveThemeDataFromJS(jsonStr, silent)
    local data = util.JSONToTable(jsonStr)
    if not data then return end

    DarkThemeEngine.Settings = data
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.InvalidateDisabledCache()

    if not silent then
        ForceDarkThemeBackgroundSwap()
    else
        
        if Active and Active.Name and IsBackgroundDisabled(Active.Name) then
            ForceDarkThemeBackgroundSwap()
        end

        if Active and type(Active) == "table" then
            local bgOpts = GetThemeOptions()
            local validCount = 0
            for _, bgData in ipairs(DarkThemeEngine.AllBackgrounds) do
                if bgData and bgData.path and not IsBackgroundDisabled(bgData.path) then
                    validCount = validCount + 1
                end
            end
            local singleMode = (validCount <= 1)
            local isNoZoom = bgOpts.BG_NoZoom or singleMode
            if isNoZoom then
                Active.AngleVel = 0
                Active.SizeVel = 0
            else
                Active.AngleVel = -(5 / 30)
                Active.SizeVel = (0.3 / 30)
            end
        end
    end
end

function DarkThemeEngine_ToggleBackground(bgPath)
    DarkThemeEngine.Settings.DisabledBackgrounds = DarkThemeEngine.Settings.DisabledBackgrounds or {}
    if DarkThemeEngine.Settings.DisabledBackgrounds[bgPath] then
        DarkThemeEngine.Settings.DisabledBackgrounds[bgPath] = nil
    else
        DarkThemeEngine.Settings.DisabledBackgrounds[bgPath] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.InvalidateDisabledCache()

    if Active and Active.Name == bgPath and IsBackgroundDisabled(bgPath) then
        ForceDarkThemeBackgroundSwap()
    end
end

function DarkThemeEngine_EnableAllBackgrounds()
    DarkThemeEngine.Settings.DisabledBackgrounds = {}
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.InvalidateDisabledCache()
end

function DarkThemeEngine_DisableAllBackgrounds()
    DarkThemeEngine.Settings.DisabledBackgrounds = DarkThemeEngine.Settings.DisabledBackgrounds or {}
    for _, bg in ipairs(DarkThemeEngine.AllBackgrounds) do
        DarkThemeEngine.Settings.DisabledBackgrounds[bg.path] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.InvalidateDisabledCache()
end

function DarkThemeEngine_SetBGOption(key, value)
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions[key] = value
    DarkThemeEngine.SaveSettings()
end

function DarkTheme_FetchWorkshopIcon(wsid)
    if not wsid or wsid == "" or wsid == "0" then return end

    steamworks.FileInfo(wsid, function(result)
        if result and result.previewid then
            steamworks.Download(result.previewid, false, function(name)
                if name then
                    local url = "../" .. name
                    DarkThemeEngine.CallJS(string.format(
                        "if(window.SetDarkThemeAddonImage) window.SetDarkThemeAddonImage('%s', '%s');",
                        wsid, string.JavascriptSafe(url)
                    ))
                end
            end)
        elseif result and result.previewurl then
            DarkThemeEngine.CallJS(string.format(
                "if(window.SetDarkThemeAddonImage) window.SetDarkThemeAddonImage('%s', '%s');",
                wsid, string.JavascriptSafe(result.previewurl)
            ))
        end
    end)
end

function DarkThemeEngine.SendBackgroundsToJS()
    if not IsValid(pnlMainMenu) then return end

    local now = SysTime()
    if not CachedBgJSON or not DarkThemeEngine._lastScanTime or (now - DarkThemeEngine._lastScanTime) > 10 then
        DarkThemeEngine.ScanBackgrounds()
        DarkThemeEngine._lastScanTime = now
    end

    local disabled = GetDisabledBackgrounds()
    local activeName = Active and Active.Name or "None"
    local bgOpts = GetThemeOptions()

    DarkThemeEngine.CallJS(string.format([[
        window._DarkTheme_Backgrounds = %s;
        window._DarkTheme_DisabledBgs = %s;
        window._DarkTheme_ActiveBg = '%s';
        window._DarkTheme_BgOptions = %s;
        if (window.DarkThemeEngine_RenderBackgroundsUI) window.DarkThemeEngine_RenderBackgroundsUI();
    ]],
        CachedBgJSON or "[]",
        util.TableToJSON(disabled),
        string.JavascriptSafe(activeName),
        util.TableToJSON({
            BG_Static = bgOpts.BG_Static or false,
            BG_NoZoom = bgOpts.BG_NoZoom or false,
            BG_NoFade = bgOpts.BG_NoFade or false
        })
    ))
end

timer.Create("DarkTheme_HijackEngine", 0.1, 0, function()
    if IsValid(pnlMainMenu) then
        DarkThemeEngine.ScanBackgrounds()
        _G.ClearBackgroundImages = CustomClearBackgroundImages
        _G.AddBackgroundImage    = CustomAddBackgroundImage
        _G.ChangeBackground      = ChangeBackground
        _G.DrawBackground        = CustomDrawBackground
        pnlMainMenu:UpdateBackgroundImages()
        timer.Remove("DarkTheme_HijackEngine")
    end
end)

hook.Add("GameContentChanged", "DarkTheme_AddonRefresh", function()
    DarkThemeEngine.ScanBackgrounds()
    if IsValid(pnlMainMenu) then
        pnlMainMenu:UpdateBackgroundImages()
        DarkThemeEngine.CallJS("window._DarkTheme_BgDirty = true; window._DarkTheme_MusicDirty = true;")
    end
end)