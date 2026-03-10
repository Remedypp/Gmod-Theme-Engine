if SERVER then
    for _, fname in ipairs(file.Find("theme_engine/*.lua", "LUA") or {}) do
        AddCSLuaFile("theme_engine/" .. fname)
    end
end

if CLIENT then
    include("theme_engine/theme_engine_spawnmenu.lua")
end
