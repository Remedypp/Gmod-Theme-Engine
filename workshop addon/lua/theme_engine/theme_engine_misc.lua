DarkThemeEngine = DarkThemeEngine or {}

local _cachedSkins = nil
local MAX_CUSTOM_BG_BYTES = 8 * 1024 * 1024
local MAX_URL_BYTES = 512
local MAX_FONT_BYTES = 5 * 1024 * 1024
local ALLOW_LOCAL_SKIN_FILES = false
local ScanSpawnmenuSkins

local BUILTIN_SKIN_NAMES = {
    ["Default"] = true, ["default"] = true,
    ["derma"]   = true, ["Derma"]   = true,
}

local function SendCustomBgError(msg)
    DarkThemeEngine.CallJS(string.format(
        "if(window.DT_OnCustomBgError) window.DT_OnCustomBgError('%s');",
        string.JavascriptSafe(tostring(msg or "Invalid background"))
    ))
end

local function IsAllowedImageURL(url)
    if type(url) ~= "string" then return false end
    url = string.Trim(url)
    if #url == 0 or #url > MAX_URL_BYTES then return false end
    if string.find(url, "%s") then return false end
    if not string.match(url, "^https?://") then return false end

    local host = string.lower(string.match(url, "^https?://([^/%?:#]+)") or "")
    if host == "" or host == "localhost" or host == "0.0.0.0" then return false end
    if string.match(host, "^127%.") or string.match(host, "^10%.") or string.match(host, "^192%.168%.") then return false end
    if string.match(host, "^172%.1[6-9]%.") or string.match(host, "^172%.2[0-9]%.") or string.match(host, "^172%.3[0-1]%.") then return false end

    local path = string.lower(string.match(url, "^[^%?#]+") or url)
    return string.match(path, "%.jpg$") or string.match(path, "%.jpeg$") or string.match(path, "%.png$")
end

local function SanitizeImageFilename(url, filename)
    local source = filename and filename ~= "" and filename or (string.match(url or "", "([^/%?]+)") or "background.jpg")
    source = string.gsub(source, "[^%w%.%-_]", "_")
    source = string.sub(source, 1, 96)

    local ext = string.lower(string.GetExtensionFromFilename(source) or "")
    if ext ~= "jpg" and ext ~= "jpeg" and ext ~= "png" then
        local urlPath = string.lower(string.match(url or "", "^[^%?#]+") or "")
        ext = string.match(urlPath, "%.png$") and "png" or "jpg"
        source = string.StripExtension(source) .. "." .. ext
    end

    local base = string.StripExtension(source)
    if not base or base == "" or string.sub(base, 1, 1) == "." then base = "background" end
    return base .. "." .. ext, ext
end

local function BodyLooksLikeImage(body, ext)
    if type(body) ~= "string" or #body < 16 or #body > MAX_CUSTOM_BG_BYTES then return false end
    if ext == "png" then
        return string.sub(body, 1, 8) == "\137PNG\r\n\26\n"
    end
    return string.byte(body, 1) == 255 and string.byte(body, 2) == 216
end

local function IsKnownSpawnmenuSkin(skinName)
    if type(skinName) ~= "string" or skinName == "" or #skinName > 96 then return false end
    local skins = _cachedSkins or ScanSpawnmenuSkins()
    for _, skin in ipairs(skins or {}) do
        if skin.name == skinName then return true end
    end
    return false
end


ScanSpawnmenuSkins = function()
    if _cachedSkins then return _cachedSkins end


    local skins = {}
    local seen  = {}

    table.insert(skins, {
        name    = "default",
        display = "Default GMod",
        addon   = "Garry's Mod",
        wsid    = "",
        isLocal = true,
    })
    seen["default"] = true

    local addons    = engine.GetAddons() or {}
    local addonByTitle = {}
    for _, addon in ipairs(addons) do
        if addon.mounted and addon.title then
            addonByTitle[addon.title] = addon
        end
    end

    local PATTERNS = {
        "lua/autorun/client/*.lua",
        "lua/autorun/*.lua",
        "lua/skins/*.lua",
    }

    local seenDisplay = {}

    local function TryExtract(content, addonTitle, wsid, isLocal)
        local found = false
        for skinName, displayName in string.gmatch(content,
            'derma%.DefineSkin%s*%(%s*"([^"]+)"%s*,%s*"([^"]+)"') do
            local displayKey = (addonTitle or "") .. "|" .. displayName
            if not seen[skinName]
            and not seenDisplay[displayKey]
            and not BUILTIN_SKIN_NAMES[skinName]
            and #skinName >= 2
            and #skinName <= 96
            and #displayName <= 96
            and not string.find(skinName, "[/\\]", 1, false)
            and not string.find(skinName, "%.%.", 1, false) then
                seen[skinName]      = true
                seenDisplay[displayKey] = true
                table.insert(skins, {
                    name    = skinName,
                    display = displayName,
                    addon   = addonTitle or "Unknown Addon",
                    wsid    = wsid or "",
                    isLocal = isLocal or false,
                })
                found = true
            end
        end
        return found
    end


    local fileToAddon = {}
    for _, addon in ipairs(addons) do
        if not addon.mounted or not addon.title then continue end
        local wsid    = tostring(addon.wsid or "")
        local isLocal = (wsid == "" or wsid == "0")
        for _, pattern in ipairs(PATTERNS) do
            local prefix = pattern:match("^(.*%/)%*") or ""
            for _, fname in ipairs(file.Find(pattern, addon.title) or {}) do
                if not fileToAddon[fname] then
                    fileToAddon[fname] = { title = addon.title, wsid = wsid, isLocal = isLocal }
                end
            end
        end
    end

    local scannedFiles = {}

    file.CreateDir("theme_engine_skins")
    local function ScanDataSkins()
        if not ALLOW_LOCAL_SKIN_FILES then return end
        local files = file.Find("theme_engine_skins/*", "DATA") or {}
        for _, fname in ipairs(files) do
            if not (fname:EndsWith(".lua") or fname:EndsWith(".txt")) then continue end
            if scannedFiles[fname] then continue end
            scannedFiles[fname] = true
            local content = file.Read("theme_engine_skins/" .. fname, "DATA")
            if content then
                TryExtract(content, "Local Skin (No Autorun)", "", true)
            end
        end
    end

    local function ScanPathID(pathID)
        for _, pattern in ipairs(PATTERNS) do
            local prefix = pattern:match("^(.*%/)%*") or ""
            for _, fname in ipairs(file.Find(pattern, pathID) or {}) do
                if scannedFiles[fname] then continue end
                local content = file.Read(prefix .. fname, pathID)
                if not content then continue end
                scannedFiles[fname] = true
                local info       = fileToAddon[fname]
                local addonTitle = info and info.title or nil
                local wsid       = info and info.wsid  or ""
                local isLocal    = not info or info.isLocal
                TryExtract(content, addonTitle or "Workshop Addon", wsid, isLocal)
            end
        end
    end

    ScanDataSkins()
    ScanPathID("GAME")
    ScanPathID("LUA")

    _cachedSkins = skins
    return skins
end

function DarkThemeEngine.InvalidateSpawnmenuCache()
    _cachedSkins = nil
end

function DarkThemeEngine.SendSpawnmenuToJS()
    if not IsValid(pnlMainMenu) then return end
    local skins  = ScanSpawnmenuSkins()
    local active = DarkThemeEngine.Settings.SpawnMenuSkin or "default"

    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_RenderSpawnmenuUI) window.DarkThemeEngine_RenderSpawnmenuUI(JSON.parse(\"%s\"), '%s');",
        string.JavascriptSafe(util.TableToJSON(skins)),
        string.JavascriptSafe(active)
    ))

    for _, skin in ipairs(skins) do
        if skin.wsid and skin.wsid ~= "" and skin.wsid ~= "0" then
            if DarkTheme_FetchWorkshopIcon then
                DarkTheme_FetchWorkshopIcon(skin.wsid)
            end
        end
    end
end

function DarkTheme_SetSpawnmenuSkin(skinName)
    if not IsKnownSpawnmenuSkin(skinName) then return end
    DarkThemeEngine.Settings.SpawnMenuSkin = skinName
    DarkThemeEngine.SaveSettings()
    if DarkThemeEngine_InvalidateSpawnmenuSkinCache then DarkThemeEngine_InvalidateSpawnmenuSkinCache() end
    if DarkThemeEngine_ApplySpawnmenuSkin then DarkThemeEngine_ApplySpawnmenuSkin() end
    local skins = _cachedSkins or ScanSpawnmenuSkins()
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_RenderSpawnmenuUI) window.DarkThemeEngine_RenderSpawnmenuUI(JSON.parse(\"%s\"), '%s');",
        string.JavascriptSafe(util.TableToJSON(skins)),
        string.JavascriptSafe(skinName)
    ))
end

hook.Add("GameContentChanged", "DarkTheme_MiscAddonRefresh", function()
    DarkThemeEngine.InvalidateSpawnmenuCache()
end)

function DarkTheme_SaveCustomBackground(url, filename)
    local dir = "theme_engine_backgrounds"
    if not file.IsDir(dir, "DATA") then file.CreateDir(dir) end

    url = string.Trim(tostring(url or ""))
    if not IsAllowedImageURL(url) then
        SendCustomBgError("Only direct http(s) .jpg/.jpeg/.png image URLs are allowed")
        return
    end

    filename = SanitizeImageFilename(url, tostring(filename or ""))
    local ext = string.lower(string.GetExtensionFromFilename(filename) or "jpg")
    local savePath = dir .. "/" .. filename

    http.Fetch(url, function(body, _, _, code)
        if code ~= 200 or not body or #body < 100 then
            SendCustomBgError("Download failed (HTTP " .. tostring(code) .. ")")
            return
        end
        if #body > MAX_CUSTOM_BG_BYTES then
            SendCustomBgError("Image is too large")
            return
        end
        if not BodyLooksLikeImage(body, ext) then
            SendCustomBgError("Downloaded file is not a valid image")
            return
        end
        local ok = pcall(file.Write, savePath, body)
        if not ok then
            SendCustomBgError("Failed to save file")
            return
        end

        local bgPath = "data/theme_engine_backgrounds/" .. filename
        local normPath = string.lower(bgPath)
        if DarkThemeEngine.AllBackgroundsLookup and not DarkThemeEngine.AllBackgroundsLookup[normPath] then
            DarkThemeEngine.AllBackgroundsLookup[normPath] = true
            table.insert(DarkThemeEngine.AllBackgrounds, {
                path = bgPath,
                category = "Custom Backgrounds",
                wsid = "",
                isLocal = true,
            })
        end
        DarkThemeEngine.CallJS(string.format(
            "if(window.DT_OnCustomBgDone) window.DT_OnCustomBgDone('%s');",
            string.JavascriptSafe(filename)
        ))
        DarkThemeEngine.CallJS("window._DarkTheme_BgDirty = true;")
        if IsValid(pnlMainMenu) then
            pnlMainMenu:UpdateBackgroundImages()
        end
    end, function()
        SendCustomBgError("Network error")
    end)
end

function DarkThemeEngine.SendFontsToJS()
    local dir = "theme_engine_fonts"
    if not file.IsDir(dir, "DATA") then file.CreateDir(dir) end
    local fonts = {}
    for _, f in ipairs(file.Find(dir .. "/*.ttf", "DATA") or {}) do
        if #f > 96 or string.find(f, "[/\\]", 1, false) then continue end
        local sz = file.Size(dir .. "/" .. f, "DATA")
        if sz and sz > MAX_FONT_BYTES then continue end
        local name = string.StripExtension(f)
        local assetPath = "asset://garrysmod/data/" .. dir .. "/" .. f
        table.insert(fonts, { name = name, url = assetPath })
    end
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_LoadLocalFonts) window.DarkThemeEngine_LoadLocalFonts(JSON.parse(\"%s\"));",
        string.JavascriptSafe(util.TableToJSON(fonts))
    ))
end

function DarkTheme_SetFontSize(size)
    size = math.max(0, math.min(32, tonumber(size) or 0))
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.MenuFontSize = size
    DarkThemeEngine.SaveSettings()
end

function DarkTheme_SetLastSeenChangelog(ver)
    ver = tostring(ver or "")
    if #ver > 32 or string.find(ver, "[^%w%._ %-]") then return end
    DarkThemeEngine.Settings.LastSeenChangelog = ver
    DarkThemeEngine.SaveSettings()
end

function DarkTheme_SetMenuFont(fontName)
    fontName = tostring(fontName or "")
    if #fontName > 96 or string.find(fontName, "[/\\]") then return end
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.MenuFont = fontName
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_ApplyMenuFont) window.DarkThemeEngine_ApplyMenuFont('%s');",
        string.JavascriptSafe(fontName or "")
    ))
end
