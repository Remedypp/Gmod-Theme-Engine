if CLIENT == nil then return end
if SERVER then return end

local _cachedSkinName = nil

local function GetSkinName()
    if _cachedSkinName then return _cachedSkinName end
    local ok, content = pcall(file.Read, "theme_engine_data/settings.json", "DATA")
    if not ok or not content then
        _cachedSkinName = "default"
        return _cachedSkinName
    end
    local s = util.JSONToTable(content)
    _cachedSkinName = (s and s.SpawnMenuSkin) or "default"
    return _cachedSkinName
end

-- Invalidate cache when settings change (called from theme_engine_misc.lua)
function DarkThemeEngine_InvalidateSpawnmenuSkinCache()
    _cachedSkinName = nil
end

local function Apply()
    local skin = GetSkinName()
    local isDefault = not skin or skin == "" or skin == "default"

    local hooks = hook.GetTable()
    local existing = hooks and hooks["ForceDermaSkin"]
    if existing then
        for id in pairs(existing) do hook.Remove("ForceDermaSkin", id) end
    end

    if not isDefault then
        if derma.GetNamedSkin(skin) then
            hook.Add("ForceDermaSkin", "ThemeEngine_SpawnmenuSkin", function() return skin end)
        end
    end

    if derma and derma.RefreshSkins then derma.RefreshSkins() end
end

hook.Add("InitPostEntity", "ThemeEngine_SkinInit", function()
    timer.Simple(0.5, Apply)
end)

hook.Add("SpawnMenuOpen", "ThemeEngine_SkinEnforce", function()
    Apply()
end)
