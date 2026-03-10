if CLIENT == nil then return end
if SERVER then return end

--FINNALY WORKS DONT FUCKING MODIFY PLSSS
local function Apply()
    local ok, content = pcall(file.Read, "theme_engine_data/settings.json", "DATA")
    if not ok or not content then return end
    local s = util.JSONToTable(content)
    local skin = s and s.SpawnMenuSkin
    local isDefault = not skin or skin == "" or skin == "default"
    local hooks = hook.GetTable()
    local existing = hooks and hooks["ForceDermaSkin"]
    if existing then
        for id in pairs(existing) do hook.Remove("ForceDermaSkin", id) end
    end
    if not isDefault then
        hook.Add("ForceDermaSkin", "ThemeEngine_SpawnmenuSkin", function() return skin end)
    end
    if derma and derma.RefreshSkins then derma.RefreshSkins() end
end

hook.Add("InitPostEntity",  "ThemeEngine_SkinInit",    Apply)
hook.Add("SpawnMenuOpen",   "ThemeEngine_SkinEnforce", function() timer.Simple(0, Apply) end)
timer.Create("ThemeEngine_SkinPoll", 2, 0, Apply)
