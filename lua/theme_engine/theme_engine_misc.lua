DarkThemeEngine = DarkThemeEngine or {}

local _cachedSkins = nil

local BUILTIN_SKIN_NAMES = {
    ["Default"] = true, ["default"] = true,
    ["derma"]   = true, ["Derma"]   = true,
}


local function ScanSpawnmenuSkins()
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
            and #skinName >= 2 then
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

    -- im so fucking tired
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
    DarkThemeEngine.Settings.SpawnMenuSkin = skinName
    DarkThemeEngine.SaveSettings()
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

    filename = filename:gsub("[^%w%.%-_]", "_")
    if not filename:match("%.%w+$") then filename = filename .. ".jpg" end
    local savePath = dir .. "/" .. filename

    http.Fetch(url, function(body, _, _, code)
        if code ~= 200 or not body or #body < 100 then
            DarkThemeEngine.CallJS("if(window.DT_OnCustomBgError) window.DT_OnCustomBgError('Download failed (HTTP " .. code .. ")');")
            return
        end
        local ok = pcall(file.Write, savePath, body)
        if not ok then
            DarkThemeEngine.CallJS("if(window.DT_OnCustomBgError) window.DT_OnCustomBgError('Failed to save file');")
            return
        end
        DarkThemeEngine.ScanBackgrounds()
        DarkThemeEngine.CallJS(string.format(
            "if(window.DT_OnCustomBgDone) window.DT_OnCustomBgDone('%s');",
            string.JavascriptSafe(filename)
        ))
        if IsValid(pnlMainMenu) then
            pnlMainMenu:UpdateBackgroundImages()
        end
    end, function()
        DarkThemeEngine.CallJS("if(window.DT_OnCustomBgError) window.DT_OnCustomBgError('Network error');")
    end)
end

function DarkThemeEngine.SendFontsToJS()
    local dir = "theme_engine_fonts"
    if not file.IsDir(dir, "DATA") then file.CreateDir(dir) end
    local fonts = {}
    for _, f in ipairs(file.Find(dir .. "/*.ttf", "DATA") or {}) do
        local name = string.StripExtension(f)
        local assetPath = "asset://garrysmod/data/" .. dir .. "/" .. f
        table.insert(fonts, { name = name, url = assetPath })
    end
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_LoadLocalFonts) window.DarkThemeEngine_LoadLocalFonts(JSON.parse(\"%s\"));",
        string.JavascriptSafe(util.TableToJSON(fonts))
    ))
end

function DarkTheme_SetMenuFont(fontName)
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.MenuFont = fontName
    DarkThemeEngine.SaveSettings()
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_ApplyMenuFont) window.DarkThemeEngine_ApplyMenuFont('%s');",
        string.JavascriptSafe(fontName or "")
    ))
end
