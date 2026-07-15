DarkThemeEngine = DarkThemeEngine or {}

local MAX_GLADOS_LINES = 64
local MAX_GLADOS_BYTES = 10 * 1024 * 1024
local GLADOS_EXTENSIONS = { wav = true, mp3 = true, ogg = true }
local CachedGladosJSON = nil
local LastGladosScan = 0

local function IsSafeAudioName(name)
    if type(name) ~= "string" or name == "" or #name > 96 then return false end
    if string.find(name, "[/\\]", 1, false) or string.find(name, "%.%.", 1, false) then return false end
    local ext = string.lower(string.GetExtensionFromFilename(name) or "")
    return GLADOS_EXTENSIONS[ext] == true
end

local function IsReasonableAudio(path, pathID)
    if type(path) ~= "string" or string.find(path, "%.%.", 1, false) then return false end
    local size = file.Size(path, pathID)
    return not size or size <= MAX_GLADOS_BYTES
end

local function AddLine(lines, seen, jsPath, name, pathID, realPath)
    if #lines >= MAX_GLADOS_LINES then return end
    if not IsSafeAudioName(name) then return end
    if seen[string.lower(jsPath)] then return end
    if not IsReasonableAudio(realPath or jsPath, pathID) then return end
    seen[string.lower(jsPath)] = true
    table.insert(lines, { path = jsPath, name = name })
end

local function ScanGladosLines()
    local lines, seen = {}, {}

    local function ScanGameFolder(pathID)
        local files = file.Find("sound/theme_engine_glados/*", pathID)
        if not files then return end
        for _, name in ipairs(files) do
            if IsSafeAudioName(name) then
                local path = "sound/theme_engine_glados/" .. name
                AddLine(lines, seen, path, name, pathID, path)
            end
        end
    end

    ScanGameFolder("GAME")
    ScanGameFolder("MOD")

    if not file.IsDir("theme_engine_glados", "DATA") then
        file.CreateDir("theme_engine_glados")
    end

    local dataFiles = file.Find("theme_engine_glados/*", "DATA")
    if dataFiles then
        for _, name in ipairs(dataFiles) do
            if IsSafeAudioName(name) then
                AddLine(lines, seen, "data/theme_engine_glados/" .. name, name, "DATA", "theme_engine_glados/" .. name)
            end
        end
    end

    CachedGladosJSON = util.TableToJSON(lines)
    LastGladosScan = SysTime()
end

function DarkThemeEngine.SendGladosLinesToJS()
    if not IsValid(pnlMainMenu) then return end
    if not CachedGladosJSON or SysTime() - LastGladosScan > 15 then
        ScanGladosLines()
    end
    DarkThemeEngine.CallJS(string.format(
        "if(window.SetDarkThemeGladosLines) window.SetDarkThemeGladosLines(JSON.parse(\"%s\"));",
        string.JavascriptSafe(CachedGladosJSON or "[]")
    ))
end
