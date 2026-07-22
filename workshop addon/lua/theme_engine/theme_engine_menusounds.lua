DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}

local KNOWN_MENU_SOUNDS = {
    "garrysmod/ui_click.wav",
    "garrysmod/ui_hover.wav",
    "garrysmod/ui_return.wav",
    "ui/buttonclick.wav",
    "ui/buttonclickrelease.wav",
}

local MAX_PACKS = 96
local DATA_DIR = "theme_engine_data"
local MENU_SOUND_CACHE_FILE = DATA_DIR .. "/menu_sounds_cache.json"
local MAX_MENU_SOUND_CACHE_BYTES = 128 * 1024
local MAX_EXTRACTED_SOUND_BYTES = 8 * 1024 * 1024
local CachedPacks = nil
local CachedPacksTime = 0
local CACHE_SECONDS = 60
local FetchedIcons = {}
local MenuSoundDiskCacheInvalidated = false

local function NormalizePath(path)
    return string.lower(string.gsub(tostring(path or ""), "\\", "/"))
end

local function SafeId(id)
    id = tostring(id or "")
    if #id > 160 then return "" end
    if string.find(id, "%.%.", 1, false) then return "" end
    if string.find(id, "[\r\n]", 1, false) then return "" end
    return id
end

local function ReadAddonTitle(folderName)
    local title = folderName
    local jsonPath = "addons/" .. folderName .. "/addon.json"
    local jsonSize = file.Size(jsonPath, "GAME")
    if jsonSize and jsonSize > 0 and jsonSize < 64 * 1024 then
        local raw = file.Read(jsonPath, "GAME")
        local parsed = raw and util.JSONToTable(raw)
        if parsed and type(parsed.title) == "string" and parsed.title ~= "" then
            title = parsed.title
        end
    end
    return title
end

local function AddPack(packs, seen, id, name, addonName, wsid, isLocal, sounds)
    id = SafeId(id)
    if id == "" or seen[id] then return end
    local found = 0
    for _ in pairs(sounds or {}) do found = found + 1 end
    if found <= 0 then return end
    seen[id] = true
    table.insert(packs, {
        id = id,
        name = name or id,
        addon = addonName or name or id,
        wsid = tostring(wsid or ""),
        isLocal = isLocal == true,
        sounds = sounds,
        count = found,
    })
end

local function IsValidPack(pack)
    if type(pack) ~= "table" or SafeId(pack.id) == "" or type(pack.sounds) ~= "table" then return false end
    if type(pack.name) ~= "string" or #pack.name > 160 then return false end
    if type(pack.addon) ~= "string" or #pack.addon > 220 then return false end
    if pack.wsid ~= nil and not string.match(tostring(pack.wsid), "^%d*$") then return false end
    local safeSounds = {}
    local count = 0
    for key, value in pairs(pack.sounds) do
        local normKey = NormalizePath(key)
        local soundPath = NormalizePath(value)
        if #normKey <= 80
        and #soundPath <= 260
        and not string.find(soundPath, "%.%.", 1, false)
        and (string.match(soundPath, "%.wav$") or string.match(soundPath, "%.mp3$") or string.match(soundPath, "%.ogg$")) then
            safeSounds[normKey] = value
            count = count + 1
        end
    end
    pack.sounds = safeSounds
    pack.count = tonumber(pack.count) or count
    return count > 0 or pack.id == "default"
end

local function LoadMenuSoundCache()
    if not file.Exists(MENU_SOUND_CACHE_FILE, "DATA") then return nil end
    local sz = file.Size(MENU_SOUND_CACHE_FILE, "DATA")
    if not sz or sz <= 0 or sz > MAX_MENU_SOUND_CACHE_BYTES then return nil end
    local raw = file.Read(MENU_SOUND_CACHE_FILE, "DATA")
    local parsed = raw and util.JSONToTable(raw)
    if type(parsed) ~= "table" or type(parsed.packs) ~= "table" then return nil end
    local packs = {}
    for _, pack in ipairs(parsed.packs) do
        if #packs >= MAX_PACKS then break end
        if IsValidPack(pack) then table.insert(packs, pack) end
    end
    if #packs == 0 then return nil end
    CachedPacks = packs
    CachedPacksTime = SysTime()
    return packs
end

local function SaveMenuSoundCache(packs)
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(MENU_SOUND_CACHE_FILE, util.TableToJSON({
        version = 1,
        savedAt = os.time(),
        packs = packs or {},
    }, false))
end

local function BuildSoundMap(searchPath, prefix, playablePrefix)
    local sounds = {}
    for _, rel in ipairs(KNOWN_MENU_SOUNDS) do
        if file.Exists(prefix .. rel, searchPath) then
            sounds[NormalizePath(rel)] = (playablePrefix or "") .. rel
        end
    end
    return sounds
end

local function BuildKnownVirtualMap()
    local sounds = {}
    for _, rel in ipairs(KNOWN_MENU_SOUNDS) do
        sounds[NormalizePath(rel)] = rel
    end
    return sounds
end

local function CollectFolders(basePath, depth, out)
    if depth < 0 or #out >= 256 then return end
    local _, folders = file.Find(basePath .. "/*", "GAME")
    folders = folders or {}
    for _, folderName in ipairs(folders) do
        local path = basePath .. "/" .. folderName
        table.insert(out, path)
        CollectFolders(path, depth - 1, out)
    end
end

local function BuildLocalWorkshopSoundMaps()
    local out = {}
    local folders = {}
    CollectFolders("addons", 3, folders)
    for _, folderPath in ipairs(folders) do
        local wsid = string.match(folderPath, "_(%d%d%d%d%d+)$") or string.match(folderPath, "/(%d%d%d%d%d+)$")
        if wsid then
            local sounds = {}
            for _, rel in ipairs(KNOWN_MENU_SOUNDS) do
                local candidate = folderPath .. "/sound/" .. rel
                if file.Exists(candidate, "GAME") then
                    sounds[NormalizePath(rel)] = candidate
                end
            end
            if next(sounds) ~= nil then out[wsid] = sounds end
        end
    end
    return out
end

local function MountedAddonHasSound(addonTitle, rel)
    if not addonTitle or addonTitle == "" then return false end
    if file.Exists("sound/" .. rel, addonTitle) then return true end
    if file.Exists(rel, addonTitle) then return true end

    local dir, filename = string.match(rel, "^(.*)/([^/]+)$")
    if not dir or not filename then return false end
    for _, base in ipairs({ "sound/" .. dir .. "/*", dir .. "/*" }) do
        for _, f in ipairs(file.Find(base, addonTitle) or {}) do
            if string.lower(f) == string.lower(filename) then
                return true
            end
        end
    end
    return false
end

local function GetDirectAddonFolders()
    local _, folders = file.Find("addons/*", "GAME")
    return folders or {}
end

function DarkThemeEngine.ScanMenuSoundPacks()
    local packs = {
        {
            id = "default",
            name = "Default GMod",
            addon = "Garry's Mod",
            wsid = "",
            localPack = true,
            isLocal = true,
            sounds = {},
        }
    }
    local seen = { default = true }

    local defaultSounds = BuildSoundMap("GAME", "sound/theme_engine_menu_sounds/default/", "theme_engine_menu_sounds/default/")
    if next(defaultSounds) ~= nil then
        packs[1].sounds = defaultSounds
        packs[1].count = 0
        packs[1].lockedDefault = true
    end

    local localWorkshopSounds = BuildLocalWorkshopSoundMaps()
    local addons = engine.GetAddons and engine.GetAddons() or {}
    for _, addon in ipairs(addons) do
        if #packs >= MAX_PACKS then break end
        if addon.mounted and addon.title then
            local sounds = {}
            for _, rel in ipairs(KNOWN_MENU_SOUNDS) do
                if MountedAddonHasSound(addon.title, rel) then
                    sounds[NormalizePath(rel)] = rel
                end
            end
            local detectedByTitle = false
            if next(sounds) == nil and string.find(string.lower(addon.title), "menu sound", 1, true) then
                sounds = BuildKnownVirtualMap()
                detectedByTitle = true
            end
            local wsid = tostring(addon.wsid or "")
            local isLocal = (wsid == "" or wsid == "0")
            if not isLocal then
                local localSounds = localWorkshopSounds[wsid]
                if localSounds then sounds = localSounds end
            end
            local id = (wsid ~= "" and wsid ~= "0") and ("workshop:" .. wsid) or ("addon:" .. addon.title)
            AddPack(packs, seen, id, addon.title, addon.title, wsid, isLocal, sounds)
            if detectedByTitle and packs[#packs] and packs[#packs].id == id then
                packs[#packs].detectedByTitle = true
            end
        end
    end

    local folders = GetDirectAddonFolders()
    for _, folderName in ipairs(folders) do
        if #packs >= MAX_PACKS then break end
        local sounds = {}
        local found = 0
        for _, rel in ipairs(KNOWN_MENU_SOUNDS) do
            local candidate = "addons/" .. folderName .. "/sound/" .. rel
            if file.Exists(candidate, "GAME") then
                sounds[NormalizePath(rel)] = candidate
                found = found + 1
            end
        end
        AddPack(packs, seen, "local:" .. folderName, ReadAddonTitle(folderName), folderName, "", true, sounds)
    end

    CachedPacks = packs
    CachedPacksTime = SysTime()
    MenuSoundDiskCacheInvalidated = false
    SaveMenuSoundCache(packs)
    return packs
end

local function GetPacks()
    if CachedPacks and SysTime and SysTime() - CachedPacksTime < CACHE_SECONDS then
        return CachedPacks
    end
    if not MenuSoundDiskCacheInvalidated then
        local cached = LoadMenuSoundCache()
        if cached then return cached end
    end
    return DarkThemeEngine.ScanMenuSoundPacks()
end

local function MaterializeMountedPack(pack)
    if not pack or pack.id == "default" or pack.isLocal or type(pack.sounds) ~= "table" then return false end
    if not pack.addon or pack.addon == "" then return false end

    local safeFolder = string.gsub(pack.id, "[^%w_%-]", "_")
    local dataRoot = "theme_engine_menu_sounds/selected/" .. safeFolder
    file.CreateDir("theme_engine_menu_sounds")
    file.CreateDir("theme_engine_menu_sounds/selected")
    file.CreateDir(dataRoot)

    local extracted = {}
    for key in pairs(pack.sounds) do
        local rel = NormalizePath(key)
        local raw
        for _, candidate in ipairs({ "sound/" .. rel, rel }) do
            local size = file.Size(candidate, pack.addon)
            if size and size > 0 and size <= MAX_EXTRACTED_SOUND_BYTES then
                raw = file.Read(candidate, pack.addon)
                if raw and raw ~= "" then break end
            end
        end
        if raw and raw ~= "" then
            local filename = string.gsub(rel, "[^%w%.%-_]", "_")
            local output = dataRoot .. "/" .. filename
            file.Write(output, raw)
            extracted[rel] = "data/" .. output
        end
    end

    if next(extracted) == nil then return false end
    pack.sounds = extracted
    pack.count = table.Count(extracted)
    return true
end

function DarkThemeEngine.InvalidateMenuSoundCache()
    CachedPacks = nil
    CachedPacksTime = 0
    MenuSoundDiskCacheInvalidated = true
end

function DarkThemeEngine.WarmMenuSoundCache()
    if CachedPacks then return end
    GetPacks()
end

local function IsKnownPack(id)
    id = SafeId(id)
    if id == "default" then return true end
    for _, pack in ipairs(GetPacks()) do
        if pack.id == id then return true end
    end
    return false
end

function DarkThemeEngine_SetMenuSoundPack(id)
    id = SafeId(id)
    if id == "" or not IsKnownPack(id) then return end
    local packs = GetPacks()
    for _, pack in ipairs(packs) do
        if pack.id == id then
            if MaterializeMountedPack(pack) then SaveMenuSoundCache(packs) end
            break
        end
    end
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.MenuSoundPack = id
    if DarkThemeEngine.SaveSettings then DarkThemeEngine.SaveSettings() end
    DarkThemeEngine.SendMenuSoundPacksToJS()
end

function DarkThemeEngine_SetMenuSoundVolume(value)
    value = math.max(0, math.min(1, tonumber(value) or 0.45))
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.MenuSoundVolume = value
    if DarkThemeEngine.SaveSettings then DarkThemeEngine.SaveSettings() end
end

function DarkThemeEngine.SendMenuSoundPacksToJS()
    if not IsValid(pnlMainMenu) then return end
    local packs = GetPacks()
    local active = DarkThemeEngine.Settings
        and DarkThemeEngine.Settings.ThemeOptions
        and DarkThemeEngine.Settings.ThemeOptions.MenuSoundPack
        or "default"
    if not IsKnownPack(active) then
        active = "default"
        DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
        DarkThemeEngine.Settings.ThemeOptions.MenuSoundPack = "default"
        if DarkThemeEngine.SaveSettings then DarkThemeEngine.SaveSettings() end
    end
    for _, pack in ipairs(packs) do
        if pack.id == active then
            if MaterializeMountedPack(pack) then SaveMenuSoundCache(packs) end
            break
        end
    end

    DarkThemeEngine.CallJS(string.format(
        "if(window.SetDarkThemeMenuSoundPacks) window.SetDarkThemeMenuSoundPacks(JSON.parse(%q), %q);",
        util.TableToJSON(packs) or "[]",
        active
    ))

    for _, pack in ipairs(packs) do
        if pack.wsid and pack.wsid ~= "" and pack.wsid ~= "0" and DarkTheme_FetchWorkshopIcon then
            if not FetchedIcons[pack.wsid] then
                FetchedIcons[pack.wsid] = true
                DarkTheme_FetchWorkshopIcon(pack.wsid)
            end
        end
    end
end
