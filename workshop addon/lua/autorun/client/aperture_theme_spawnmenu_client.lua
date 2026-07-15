if SERVER then return end

if DarkThemeEngine and DarkThemeEngine._SpawnmenuLoaded then
    return
end

local MAX_SPAWNMENU_LOADER_BYTES = 128 * 1024
local code
local paths = {
    { "theme_engine/theme_engine_spawnmenu.lua", "LUA" },
    { "lua/theme_engine/theme_engine_spawnmenu.lua", "GAME" },
}

for _, path in ipairs(paths) do
    local size = file.Size(path[1], path[2])
    if size and size <= MAX_SPAWNMENU_LOADER_BYTES then
        code = file.Read(path[1], path[2])
    end
    if code and code ~= "" then break end
end

if not code or code == "" then
    if DarkThemeEngine_Log then
        DarkThemeEngine_Log("error", "Spawnmenu", "theme_engine_spawnmenu.lua was not found")
    end
    return
end

DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._SpawnmenuLoaded = true

local ok, err = pcall(RunString, code, "theme_engine/theme_engine_spawnmenu.lua")
if not ok then
    if DarkThemeEngine_Log then
        DarkThemeEngine_Log("error", "Spawnmenu", tostring(err))
    else
        print("[ThemeEngine] [Spawnmenu] " .. tostring(err))
    end
    DarkThemeEngine._SpawnmenuLoaded = false
end

