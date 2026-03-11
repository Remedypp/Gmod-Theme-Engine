if CLIENT == nil then return end
if SERVER then return end

local function ReadSkin()
    local ok, content = pcall(file.Read, "theme_engine_data/settings.json", "DATA")
    if not ok or not content then return "default" end
    local s = util.JSONToTable(content)
    return (s and s.SpawnMenuSkin) or "default"
end

local function Apply()
    local skin = ReadSkin()
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
    timer.Simple(2,   Apply)
    timer.Simple(5,   Apply)
end)

hook.Add("SpawnMenuOpen", "ThemeEngine_SkinEnforce", function()
    timer.Simple(0,   Apply)
    timer.Simple(0.1, Apply)
    timer.Simple(0.5, Apply)
end)

timer.Create("ThemeEngine_SkinPoll", 2, 0, Apply)
