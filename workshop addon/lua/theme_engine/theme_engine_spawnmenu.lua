if CLIENT == nil then return end
if SERVER then return end













local _cachedSkinName = nil
local _lastSettingsTime = 0
local ALLOW_DYNAMIC_SKIN_EXEC = false

local function IsSafeSkinName(name)
    return type(name) == "string"
        and name ~= ""
        and #name <= 96
        and not string.find(name, "[/\\]", 1, false)
        and not string.find(name, "%.%.", 1, false)
end

local function GetSkinName()
    local ctime = file.Time("theme_engine_data/settings.json", "DATA") or 0
    if _cachedSkinName and ctime == _lastSettingsTime then
        return _cachedSkinName
    end
    _lastSettingsTime = ctime
    local ok, content = pcall(file.Read, "theme_engine_data/settings.json", "DATA")
    if not ok or not content then
        _cachedSkinName = "default"
        return _cachedSkinName
    end
    local s = util.JSONToTable(content)
    _cachedSkinName = (s and s.SpawnMenuSkin) or "default"
    if not IsSafeSkinName(_cachedSkinName) then
        _cachedSkinName = "default"
    end
    return _cachedSkinName
end

function DarkThemeEngine_InvalidateSpawnmenuSkinCache()
    _cachedSkinName = nil
end





local _loadedSkins = {}

local function EnsureSkinLoaded(skin)
    if not IsSafeSkinName(skin) then return false end
    if _loadedSkins[skin] then return true end
    if derma.GetNamedSkin(skin) then
        _loadedSkins[skin] = true
        return true
    end

    if not ALLOW_DYNAMIC_SKIN_EXEC then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("warn", "Spawnmenu", "Dynamic skin Lua loading blocked: " .. tostring(skin)) end
        return false
    end

    local pSkin = string.PatternSafe(skin)
    local foundCode, foundLabel


    for _, fname in ipairs(file.Find("theme_engine_skins/*", "DATA") or {}) do
        if fname:EndsWith(".lua") or fname:EndsWith(".txt") then
            local content = file.Read("theme_engine_skins/" .. fname, "DATA")
            if content and string.find(content, 'derma%.DefineSkin%s*%(%s*["\']' .. pSkin .. '["\']') then
                foundCode, foundLabel = content, "data/" .. fname
                break
            end
        end
    end

    if not foundCode then
        local patterns = { "autorun/client/*.lua", "autorun/*.lua", "skins/*.lua" }
        local paths = { { id = "LUA", pre = "" }, { id = "GAME", pre = "lua/" } }
        for _, sp in ipairs(paths) do
            for _, pattern in ipairs(patterns) do
                local prefix = pattern:match("^(.*%/)%*") or ""
                for _, fname in ipairs(file.Find(sp.pre .. pattern, sp.id) or {}) do
                    local content = file.Read(sp.pre .. prefix .. fname, sp.id)
                    if content and string.find(content, 'derma%.DefineSkin%s*%(%s*["\']' .. pSkin .. '["\']') then
                        foundCode, foundLabel = content, prefix .. fname
                        break
                    end
                end
                if foundCode then break end
            end
            if foundCode then break end
        end
    end

    if not foundCode then return false end

    local _realInclude = include
    include = function(path)
        local code
        for _, pre in ipairs({"lua/", ""}) do
            for _, pid in ipairs({"GAME", "LUA"}) do
                code = file.Read(pre .. path, pid)
                if code and code ~= "" then break end
            end
            if code and code ~= "" then break end
        end
        if code and code ~= "" then RunString(code, path) else _realInclude(path) end
    end
    local ok, err = pcall(RunString, foundCode, foundLabel)
    include = _realInclude
    if not ok then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("error", "Spawnmenu", tostring(err)) else print("[ThemeEngine] [Spawnmenu] " .. tostring(err)) end
        return false
    end

    _loadedSkins[skin] = true
    return derma.GetNamedSkin(skin) ~= nil
end








local _originalGetDefaultSkin = derma.GetDefaultSkin


DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._OriginalGetDefaultSkin = _originalGetDefaultSkin


derma.GetDefaultSkin = function()
    local name = GetSkinName()


    if name and name ~= "" and name ~= "default" then
        EnsureSkinLoaded(name)
        local skin = derma.GetNamedSkin(name)
        if skin then return skin end
    end



    local hookTable = hook.GetTable()
    local savedHooks = hookTable["ForceDermaSkin"]
    hookTable["ForceDermaSkin"] = nil

    local realDefault = _originalGetDefaultSkin()

    hookTable["ForceDermaSkin"] = savedHooks
    return realDefault
end





hook.Add("InitPostEntity", "ThemeEngine_SkinInit", function()
    timer.Simple(0.5, function()
        if derma.RefreshSkins then derma.RefreshSkins() end
    end)
end)

hook.Add("SpawnMenuCreated", "ThemeEngine_SkinOnCreate", function()
    if derma.RefreshSkins then derma.RefreshSkins() end
end)

hook.Add("SpawnMenuOpen", "ThemeEngine_SkinEnforce", function()
    if derma.RefreshSkins then derma.RefreshSkins() end
end)


function DarkThemeEngine_ApplySpawnmenuSkin()
    _cachedSkinName = nil
    if derma.RefreshSkins then derma.RefreshSkins() end
end
