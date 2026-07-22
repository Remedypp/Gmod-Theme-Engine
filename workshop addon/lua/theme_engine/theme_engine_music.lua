DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}
DarkThemeEngine.AllMusic = DarkThemeEngine.AllMusic or {}
DarkThemeEngine._MusicCovers = DarkThemeEngine._MusicCovers or {}

local ALL_MUSIC_LOOKUP = {}
local IsMusicPlaying = false
local DarkTheme_NeedsStartupMusic = true
local lastVolume = -1
local WasInGame = false
local DATA_DIR = "theme_engine_data"
local MUSIC_CACHE_FILE = DATA_DIR .. "/music_cache.json"
local MAX_MUSIC_CACHE_BYTES = 1024 * 1024
local CachedMusicJSON = nil
local LastMusicScanTime = 0
local MusicDiskCacheInvalidated = false

local MAX_TRACKS = 512
local MAX_MUSIC_BYTES = 80 * 1024 * 1024
local MAX_META_BYTES = 256 * 1024
local MAX_ID3_BYTES = 1024 * 1024
local MAX_ID3_FRAME_BYTES = 512 * 1024
local MAX_COVER_BYTES = 512 * 1024
local MAX_TEXT_BYTES = 256

local MUSIC_EXTENSIONS = { mp3 = true, wav = true, ogg = true }
local COVER_MIME_TYPES = {
    ["image/jpeg"] = true,
    ["image/jpg"] = true,
    ["image/png"] = true,
    ["image/webp"] = true,
}
local SafeMetaText
local SafeYouTubeURL

local function SafeStringCleaning(text)
    if not text then return "Unknown" end
    text = string.gsub(text, "%z", "")
    text = string.gsub(text, "\255\254", "")
    text = string.gsub(text, "\254\255", "")
    text = string.sub(text, 1, MAX_TEXT_BYTES)
    return string.Trim(text)
end

local function IsSafePathSegment(name)
    return type(name) == "string"
        and name ~= ""
        and #name <= 128
        and not string.find(name, "[/\\]", 1, false)
        and not string.find(name, "%.%.", 1, false)
end

local function IsSafeMusicExt(name)
    local ext = string.lower(string.GetExtensionFromFilename(name or "") or "")
    return MUSIC_EXTENSIONS[ext] == true
end

local function IsReasonableMusicFile(path, pathID)
    if type(path) ~= "string" or string.find(path, "%.%.", 1, false) then return false end
    if not IsSafeMusicExt(path) then return false end
    local sz = file.Size(path, pathID)
    return not sz or sz <= MAX_MUSIC_BYTES
end

local function IsValidCachedTrack(track)
    if type(track) ~= "table" or type(track.path) ~= "string" or type(track.name) ~= "string" then return false end
    if #track.path > 260 or #track.name > 128 then return false end
    if string.find(track.path, "%.%.", 1, false) then return false end
    if not IsSafeMusicExt(track.path) then return false end
    track.name = SafeStringCleaning(track.name)
    track.album = SafeMetaText(track.album) or ""
    track.title = SafeMetaText(track.title)
    track.artist = SafeMetaText(track.artist)
    track.desc = SafeMetaText(track.desc)
    track.youtube = SafeYouTubeURL(track.youtube)
    return true
end

local function LoadMusicCache()
    if MusicDiskCacheInvalidated or not file.Exists(MUSIC_CACHE_FILE, "DATA") then return false end
    local sz = file.Size(MUSIC_CACHE_FILE, "DATA")
    if not sz or sz <= 0 or sz > MAX_MUSIC_CACHE_BYTES then return false end
    local raw = file.Read(MUSIC_CACHE_FILE, "DATA")
    local parsed = raw and util.JSONToTable(raw)
    if type(parsed) ~= "table" or type(parsed.tracks) ~= "table" then return false end

    local tracks, lookup = {}, {}
    for _, track in ipairs(parsed.tracks) do
        if #tracks >= MAX_TRACKS then break end
        if IsValidCachedTrack(track) then
            local norm = string.lower(track.path)
            if not lookup[norm] then
                lookup[norm] = true
                table.insert(tracks, track)
            end
        end
    end
    if #tracks == 0 then return false end

    DarkThemeEngine.AllMusic = tracks
    ALL_MUSIC_LOOKUP = lookup
    DarkThemeEngine._MusicCovers = {}
    CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
    LastMusicScanTime = SysTime()
    return true
end

local function SaveMusicCache()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(MUSIC_CACHE_FILE, util.TableToJSON({
        version = 1,
        savedAt = os.time(),
        tracks = DarkThemeEngine.AllMusic or {},
    }, false))
    MusicDiskCacheInvalidated = false
end

SafeMetaText = function(value)
    if value == nil then return nil end
    local cleaned = SafeStringCleaning(tostring(value))
    if cleaned == "" then return nil end
    return cleaned
end

SafeYouTubeURL = function(value)
    if value == nil then return nil end
    local url = string.Trim(tostring(value))
    if #url > 220 then return nil end
    if string.match(url, "^https://www%.youtube%.com/watch%?v=[%w_%-]+$") then return url end
    if string.match(url, "^https://youtube%.com/watch%?v=[%w_%-]+$") then return url end
    if string.match(url, "^https://youtu%.be/[%w_%-]+$") then return url end
    return nil
end

local function SafeCoverURI(value)
    if value == nil then return nil end
    local uri = string.Trim(tostring(value))
    if #uri == 0 or #uri > 2048 then return nil end
    if string.match(uri, "^data:image/[A-Za-z0-9%+%-]+;base64,[A-Za-z0-9%+/=]+$") then
        return uri
    end
    if string.match(uri, "^asset://garrysmod/[%w%._%-%s/]+$") then
        return uri
    end
    if string.match(uri, "^https://[%w%._%-%:/%?%%&=#+]+%.jpg$") or
       string.match(uri, "^https://[%w%._%-%:/%?%%&=#+]+%.jpeg$") or
       string.match(uri, "^https://[%w%._%-%:/%?%%&=#+]+%.png$") or
       string.match(uri, "^https://[%w%._%-%:/%?%%&=#+]+%.webp$") then
        return uri
    end
    return nil
end

local function DarkTheme_ReadID3Tags(filename, pathID)
    if not file.Open then return nil end
    local fileSize = file.Size(filename, pathID)
    if fileSize and fileSize > MAX_MUSIC_BYTES then return nil end

    local ok, f = pcall( file.Open, filename, "rb", pathID )
    if not ok or not f then return nil end

    local header = f:Read(3)
    if header ~= "ID3" then f:Close() return nil end

    local verMajor = f:ReadByte()
    local verMinor = f:ReadByte()
    local flags = f:ReadByte()
    if not f:ReadByte() then f:Close() return nil end
    f:Seek(6)

    local b1, b2, b3, b4 = f:ReadByte(), f:ReadByte(), f:ReadByte(), f:ReadByte()
    if not b1 or not b2 or not b3 or not b4 then f:Close() return nil end
    local totalSize = bit.lshift(b1, 21) + bit.lshift(b2, 14) + bit.lshift(b3, 7) + b4
    if totalSize <= 0 or totalSize > MAX_ID3_BYTES then f:Close() return nil end

    local tags = {}
    local bytesRead = 0

    while bytesRead < totalSize do
        local frameID = f:Read(4)
        if not frameID or string.len(frameID) < 4 or string.byte(frameID, 1) == 0 then break end

        local s1, s2, s3, s4 = f:ReadByte(), f:ReadByte(), f:ReadByte(), f:ReadByte()
        if not s1 or not s2 or not s3 or not s4 then break end
        local frameSize = 0
        if verMajor == 3 then
            frameSize = bit.lshift(s1, 24) + bit.lshift(s2, 16) + bit.lshift(s3, 8) + s4
        else
            frameSize = bit.lshift(s1, 21) + bit.lshift(s2, 14) + bit.lshift(s3, 7) + s4
        end

        local frameFlags = f:Read(2)
        bytesRead = bytesRead + 10 + frameSize

        if frameSize > 0 and frameSize <= MAX_ID3_FRAME_BYTES then
            if frameID == "TIT2" then
                if frameSize <= MAX_TEXT_BYTES + 1 then
                    local enc = f:ReadByte()
                    tags.title = SafeStringCleaning(f:Read(frameSize - 1))
                else
                    f:Skip(frameSize)
                end
            elseif frameID == "TPE1" then
                if frameSize <= MAX_TEXT_BYTES + 1 then
                    local enc = f:ReadByte()
                    tags.artist = SafeStringCleaning(f:Read(frameSize - 1))
                else
                    f:Skip(frameSize)
                end
            elseif frameID == "APIC" then
                if frameSize > MAX_COVER_BYTES then
                    f:Skip(frameSize)
                    continue
                end
                local enc = f:ReadByte()
                local consumed = 1
                local mime = ""
                local b = f:ReadByte() consumed = consumed + 1
                while b and b ~= 0 and consumed < frameSize and #mime < 32 do
                    mime = mime .. string.char(b)
                    b = f:ReadByte() consumed = consumed + 1
                end
                mime = string.lower(mime)
                local picType = f:ReadByte() consumed = consumed + 1
                local descB = f:ReadByte() consumed = consumed + 1
                local descCount = 1
                if enc == 1 or enc == 2 then
                    local descB2 = f:ReadByte() consumed = consumed + 1
                    while descB and descB2 and not (descB == 0 and descB2 == 0) and consumed < frameSize do
                        descB = descB2
                        descB2 = f:ReadByte() consumed = consumed + 1
                        descCount = descCount + 1
                        if descCount > 500 then break end
                    end
                else
                    while descB and descB ~= 0 and consumed < frameSize do
                        descB = f:ReadByte() consumed = consumed + 1
                        descCount = descCount + 1
                        if descCount > 500 then break end
                    end
                end

                local remaining = frameSize - consumed
                local imgData = nil
                if COVER_MIME_TYPES[mime] and remaining > 0 and remaining <= MAX_COVER_BYTES then
                    imgData = f:Read(remaining)
                elseif remaining > 0 then
                    f:Skip(remaining)
                end
                if imgData and string.len(imgData) > 0 and string.len(imgData) <= MAX_COVER_BYTES then
                    local b64 = util.Base64Encode(imgData)
                    tags.cover = "data:" .. mime .. ";base64," .. b64
                end
            else
                f:Skip(frameSize)
            end
        else
            break
        end
    end
    f:Close()

    if not tags.title or tags.title == "" then tags.title = nil end
    if not tags.artist or tags.artist == "" then tags.artist = nil end
    return tags
end

local function SeedGameMusic()
    DarkThemeEngine.AllMusic = {}
    ALL_MUSIC_LOOKUP = {}

    local CustomMeta = {
        ["Memories.mp3"] = { desc = "it has a good rhythm :)", youtube = "https://www.youtube.com/watch?v=v9k493VHDtQ" },
        ["Time With You.mp3"] = { youtube = "https://www.youtube.com/watch?v=CVvAS4RdjNQ" }
    }

    local CustomJsonMeta = {}
    local function TryLoadMeta(path, pathID)
        local sz = file.Size(path, pathID)
        if not sz or sz == 0 or sz > MAX_META_BYTES then return false end
        local raw = file.Read(path, pathID)
        if not raw then return false end
        raw = string.gsub(raw, "^%s*%-%-[^\n]*\n", "")
        raw = string.Trim(raw)
        local parsed = util.JSONToTable(raw)
        if parsed and type(parsed) == "table" then
            CustomJsonMeta = parsed
            return true
        end
        return false
    end


    if not TryLoadMeta("data_static/te_music_meta.json",          "GAME") then
    if not TryLoadMeta("theme_engine_music/te_music_meta.json",   "DATA") then
    if not TryLoadMeta("theme_engine_music/te_music_meta.txt",    "DATA") then
    if not TryLoadMeta("lua/te_music_meta.lua",                   "GAME") then
    if not TryLoadMeta("sound/theme_engine_music/addon_music_meta.json", "GAME") then
    end end end end end

    local function AddMusic(jsPath, name, mount, actualFilePath, album)
        if #DarkThemeEngine.AllMusic >= MAX_TRACKS then return end
        if not IsSafePathSegment(name) or not IsSafeMusicExt(name) then return end
        if album and not IsSafePathSegment(album) then album = "" end
        if not IsReasonableMusicFile(actualFilePath, mount) then return end

        local normPath = string.lower(jsPath)
        if not ALL_MUSIC_LOOKUP[normPath] then
            ALL_MUSIC_LOOKUP[normPath] = true
            local trackData = { path = jsPath, name = SafeStringCleaning(name) }
            trackData.album = SafeMetaText(album) or ""

            local lowerName = string.lower(name)
            local coverData = nil

            local jsonMeta = CustomJsonMeta[name] or CustomJsonMeta[lowerName]
            if jsonMeta then
                if jsonMeta.title then trackData.title = SafeMetaText(jsonMeta.title) end
                if jsonMeta.artist then trackData.artist = SafeMetaText(jsonMeta.artist) end
                if jsonMeta.cover then coverData = SafeCoverURI(jsonMeta.cover) end
                if jsonMeta.desc then trackData.desc = SafeMetaText(jsonMeta.desc) end
                if jsonMeta.youtube then trackData.youtube = SafeYouTubeURL(jsonMeta.youtube) end
            else

                local hardcoded = CustomMeta[name] or CustomMeta[lowerName]
                if hardcoded then
                    if hardcoded.desc then trackData.desc = SafeMetaText(hardcoded.desc) end
                    if hardcoded.youtube then trackData.youtube = SafeYouTubeURL(hardcoded.youtube) end
                end

                if string.lower(string.GetExtensionFromFilename(name) or "") == "mp3" then
                    local tags = DarkTheme_ReadID3Tags(actualFilePath, mount)
                    if tags then
                        if tags.title then trackData.title = tags.title end
                        if tags.artist then trackData.artist = tags.artist end
                        if tags.cover then coverData = tags.cover end
                    end
                end
            end

            if coverData then
                DarkThemeEngine._MusicCovers[jsPath] = coverData
            end

            table.insert(DarkThemeEngine.AllMusic, trackData)
        end
    end

    AddMusic("sound/theme_engine_music/Memories.mp3", "Memories.mp3", "GAME", "sound/theme_engine_music/Memories.mp3")
    AddMusic("sound/theme_engine_music/Time With You.mp3", "Time With You.mp3", "GAME", "sound/theme_engine_music/Time With You.mp3")

    local function ScanSoundFolder(pathID)
        local files, dirs = file.Find("sound/theme_engine_music/*", pathID)
        if not files then return end
        for _, f in ipairs(files) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if ext == "mp3" or ext == "wav" then
                AddMusic("sound/theme_engine_music/" .. f, f, pathID, "sound/theme_engine_music/" .. f)
            end
        end
        if dirs then
            for _, d in ipairs(dirs) do
                local albumPath = "sound/theme_engine_music/" .. d .. "/*"
                local albumFiles, _ = file.Find(albumPath, pathID)
                if not albumFiles then continue end
                for _, af in ipairs(albumFiles) do
                    local ext = string.lower(string.GetExtensionFromFilename(af) or "")
                    if ext == "mp3" or ext == "wav" then
                        local jsPath = "sound/theme_engine_music/" .. d .. "/" .. af
                        AddMusic(jsPath, af, pathID, jsPath, d)
                    end
                end
            end
        end
    end

    ScanSoundFolder("GAME")
    ScanSoundFolder("MOD")

    if not file.IsDir("theme_engine_music", "DATA") then
        file.CreateDir("theme_engine_music")
    end

    local files2, dirs2 = file.Find("theme_engine_music/*", "DATA")
    if files2 then
        for _, f in ipairs(files2) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if ext == "mp3" or ext == "wav" then
                AddMusic("data/theme_engine_music/" .. f, f, "DATA", "theme_engine_music/" .. f)
            end
        end
    end
    if dirs2 then
        for _, d in ipairs(dirs2) do
            local albumFiles, _ = file.Find("theme_engine_music/" .. d .. "/*", "DATA")
            if not albumFiles then continue end
            for _, af in ipairs(albumFiles) do
                local ext = string.lower(string.GetExtensionFromFilename(af) or "")
                if ext == "mp3" or ext == "wav" then
                    local jsPath = "data/theme_engine_music/" .. d .. "/" .. af
                    AddMusic(jsPath, af, "DATA", "theme_engine_music/" .. d .. "/" .. af, d)
                end
            end
        end
    end
end

local function IsKnownMusicPath(path)
    if type(path) ~= "string" or #path > 260 then return false end
    if string.find(path, "%.%.", 1, false) then return false end
    if not IsSafeMusicExt(path) then return false end
    if not ALL_MUSIC_LOOKUP[string.lower(path)] then
        SeedGameMusic()
    end
    return ALL_MUSIC_LOOKUP[string.lower(path)] == true
end

local function IsKnownAlbumName(albumName)
    if type(albumName) ~= "string" or #albumName > 128 then return false end
    if albumName == "" then return true end
    if string.find(albumName, "[/\\]", 1, false) or string.find(albumName, "%.%.", 1, false) then return false end
    if #DarkThemeEngine.AllMusic == 0 then SeedGameMusic() end
    for _, snd in ipairs(DarkThemeEngine.AllMusic or {}) do
        if (snd.album or "") == albumName then return true end
    end
    return false
end

function DarkThemeEngine.InvalidateMusicCache()
    LastMusicScanTime = 0
    CachedMusicJSON = nil
    MusicDiskCacheInvalidated = true
    DarkThemeEngine.CallJS("window._DT_FailedTracks = {}; window._DT_AudioSupport = null;")
end

function DarkThemeEngine.WarmMusicCache()
    if #DarkThemeEngine.AllMusic > 0 and CachedMusicJSON then
        if IsValid(pnlMainMenu) then DarkThemeEngine.SendMusicToJS() end
        return
    end
    if LoadMusicCache() then
        if IsValid(pnlMainMenu) then DarkThemeEngine.SendMusicToJS() end
        return
    end
    if DarkThemeEngine._WarmingMusicCache then return end
    DarkThemeEngine._WarmingMusicCache = true
    timer.Simple(0, function()
        if not IsInGame() and not IsInLoading() then
            SeedGameMusic()
            CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
            LastMusicScanTime = SysTime()
            SaveMusicCache()
            if IsValid(pnlMainMenu) then DarkThemeEngine.SendMusicToJS() end
        end
        DarkThemeEngine._WarmingMusicCache = false
    end)
end

function DarkThemeEngine.SendMusicToJS()
    if not IsValid(pnlMainMenu) then return end

    if #DarkThemeEngine.AllMusic == 0 and LoadMusicCache() then

    elseif SysTime() - LastMusicScanTime > 30 or #DarkThemeEngine.AllMusic == 0 then
        SeedGameMusic()
        CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
        LastMusicScanTime = SysTime()
        SaveMusicCache()
    end

    if not CachedMusicJSON then
        CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
    end

    local settings = DarkThemeEngine.Settings or {}
    local disabledMusic = settings.DisabledMusic or {}
    local themeOpts = settings.ThemeOptions or {}

    local currentTrack = DarkThemeEngine._CurrentMusicPath or ""

    local disabledAlbums = (DarkThemeEngine.Settings or {}).DisabledAlbums or {}
    local js = string.format(
        "if(window.DarkThemeEngine_ReceiveMusic) window.DarkThemeEngine_ReceiveMusic(JSON.parse(\"%s\"), JSON.parse(\"%s\"), JSON.parse(\"%s\"), JSON.parse(\"%s\"), '%s');",
        string.JavascriptSafe(CachedMusicJSON),
        string.JavascriptSafe(util.TableToJSON(disabledMusic)),
        string.JavascriptSafe(util.TableToJSON(themeOpts)),
        string.JavascriptSafe(util.TableToJSON(disabledAlbums)),
        string.JavascriptSafe(currentTrack)
    )
    DarkThemeEngine.CallJS(js)

    DarkThemeEngine._SendCoversToJS()
end

function DarkThemeEngine._SendCoversToJS()
    timer.Remove("DarkTheme_CoverSend")
    local covers = {}
    for path, data in pairs(DarkThemeEngine._MusicCovers or {}) do
        table.insert(covers, { path = path, data = data })
    end
    if #covers == 0 then return end
    local idx = 0
    timer.Create("DarkTheme_CoverSend", 0.05, #covers, function()
        idx = idx + 1
        if idx > #covers then return end
        local c = covers[idx]
        if not IsValid(pnlMainMenu) then return end
        DarkThemeEngine.CallJS(string.format(
            "if(window._DT_SetCover) window._DT_SetCover('%s', '%s');",
            string.JavascriptSafe(c.path),
            string.JavascriptSafe(c.data)
        ))
    end)
end

function DarkTheme_PlayStartupMusic()
    local settings = DarkThemeEngine.Settings or {}
    local themeOpts = settings.ThemeOptions or {}

    if not themeOpts.EnableMusic then
        if IsMusicPlaying and IsValid(pnlMainMenu) then
            DarkThemeEngine.CallJS("if(window.DarkThemeEngine_StopRealVisualizer)window.DarkThemeEngine_StopRealVisualizer();if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.pause(); window.DarkTheme_AudioNode = null; } if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }")
            IsMusicPlaying = false
        elseif IsValid(pnlMainMenu) then
            DarkThemeEngine.CallJS("if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }")
        end
        return
    end

    local disabledMusic = settings.DisabledMusic or {}
    local validMusic = {}
    local disabledAlbums = settings.DisabledAlbums or {}
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        if not disabledMusic[snd.path] and not disabledAlbums[snd.album or ""] then
            table.insert(validMusic, snd.path)
        end
    end

    if #validMusic == 0 then
        if IsValid(pnlMainMenu) then
            DarkThemeEngine.CallJS("if(window.DarkThemeEngine_StopRealVisualizer)window.DarkThemeEngine_StopRealVisualizer();if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.pause(); window.DarkTheme_AudioNode = null; } if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }")
        end
        IsMusicPlaying = false
        return
    end

    local isPlaylist = themeOpts.Music_PlaylistMode
    if isPlaylist == nil then isPlaylist = true end
    local isShuffle = themeOpts.Music_Shuffle
    if isShuffle == nil then isShuffle = false end

    local validTracks = {}
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        if not disabledMusic[snd.path] and not disabledAlbums[snd.album or ""] then
            table.insert(validTracks, snd)
        end
    end
    local lightTracks = {}
    for _, t in ipairs(validTracks) do
        local copy = {}
        for k, v in pairs(t) do
            if k ~= "cover" then copy[k] = v end
        end
        table.insert(lightTracks, copy)
    end
    local jsMusicArray = util.TableToJSON(lightTracks)

    local curVol = themeOpts.Music_Volume
    if curVol == nil then
        local volCvar = GetConVar("snd_musicvolume")
        curVol = volCvar and volCvar:GetFloat() or 0.6
    end
    curVol = math.max(0, math.min(1, curVol))

    if IsValid(pnlMainMenu) then
        local js = string.format([[
            var allTracks    = JSON.parse("%s");
            var isPlaylistMode = %s;
            var isShuffleMode  = %s;
            window.DarkTheme_MusicVolume = Math.max(0, Math.min(1, %s));

            if (!window._DT_AudioSupport) {
                var _ta = document.createElement('audio');
                window._DT_AudioSupport = {
                    mp3: _ta.canPlayType('audio/mpeg') !== '',
                    wav: _ta.canPlayType('audio/wav')  !== '',
                    ogg: _ta.canPlayType('audio/ogg; codecs="vorbis"') !== '' || _ta.canPlayType('audio/ogg') !== ''
                };
            }

            var newPlaylist = [];
            for (var _ti = 0; _ti < allTracks.length; _ti++) {
                var _tp = allTracks[_ti].path;
                var _te = _tp.split('.').pop().toLowerCase();
                var _ok = (_te === 'mp3' && window._DT_AudioSupport.mp3)
                       || (_te === 'wav' && window._DT_AudioSupport.wav)
                       || (_te === 'ogg' && window._DT_AudioSupport.ogg)
                       || (_te !== 'mp3' && _te !== 'wav' && _te !== 'ogg');
                if (_ok) newPlaylist.push(_tp);
            }

            if (!window._DT_FailedTracks)   window._DT_FailedTracks = {};
            if (!window.DarkTheme_MusicPlaylist) window.DarkTheme_MusicPlaylist = [];

            var currentTrackPath = null;
            var isCurrentlyPlayingInNewList = false;
            if (window.DarkTheme_AudioNode && window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex]) {
                currentTrackPath = window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];
                if (newPlaylist.indexOf(currentTrackPath) !== -1) isCurrentlyPlayingInNewList = true;
            }

            window.DarkTheme_MusicPlaylist = newPlaylist;
            window.DarkTheme_PlaylistMode = isPlaylistMode;
            window.DarkTheme_ShuffleMode = isShuffleMode;

            var shouldStartNewTrack = true;

            if (window.DarkTheme_MusicPlaylist.length > 0) {
                if (isCurrentlyPlayingInNewList) {
                    window.DarkTheme_MusicIndex = window.DarkTheme_MusicPlaylist.indexOf(currentTrackPath);
                    shouldStartNewTrack = false;
                    if (window.DarkThemeEngine_SetCurrentMusic) window.DarkThemeEngine_SetCurrentMusic(currentTrackPath);
                    if (window.DarkThemeEngine_LuaCall && window.DarkThemeEngine_SafePathForLua) window.DarkThemeEngine_LuaCall("DarkThemeEngine_SetCurrentMusicFromJS('" + window.DarkThemeEngine_SafePathForLua(currentTrackPath) + "')");
                } else {
                    if (window.DarkTheme_AudioNode) {
                        window.DarkTheme_AudioNode.onended = null;
                        window.DarkTheme_AudioNode.onerror = null;
                        window.DarkTheme_AudioNode.pause();
                        window.DarkTheme_AudioNode = null;
                    }
                    window.DarkTheme_MusicIndex = window.DarkTheme_ShuffleMode
                        ? Math.floor(Math.random() * window.DarkTheme_MusicPlaylist.length)
                        : 0;
                    currentTrackPath = window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];

                    if (window._DT_TryPlayFn) {
                        window.removeEventListener('click',     window._DT_TryPlayFn, true);
                        window.removeEventListener('keydown',   window._DT_TryPlayFn, true);
                        window.removeEventListener('mousemove', window._DT_TryPlayFn, true);
                        window._DT_TryPlayFn = null;
                    }
                    window._DT_InteractionMounted = false;
                    window._DT_InteractionFired = false;
                }

                if (!window._DT_InteractionMounted) {
                    window._DT_InteractionMounted = true;
                    window._DT_TryPlayFn = function() {
                        if (window._DT_InteractionFired) return;
                        if (!window.DarkTheme_AudioNode || !window.DarkTheme_AudioNode.paused) return;
                        window._DT_InteractionFired = true;
                        var p = window.DarkTheme_AudioNode.play();
                        if (p && p.then) {
                            p.then(function() {
                                window.removeEventListener('click',     window._DT_TryPlayFn, true);
                                window.removeEventListener('keydown',   window._DT_TryPlayFn, true);
                                window.removeEventListener('mousemove', window._DT_TryPlayFn, true);
                                window._DT_TryPlayFn = null;
                            }).catch(function() { window._DT_InteractionFired = false; });
                        } else {
                            window._DT_InteractionFired = false;
                        }
                    };
                    window.addEventListener('click',     window._DT_TryPlayFn, true);
                    window.addEventListener('keydown',   window._DT_TryPlayFn, true);
                    window.addEventListener('mousemove', window._DT_TryPlayFn, true);
                }

                window._DT_MusicLocked = false;
                window._DT_ConsecErrors = 0;
                if (window._DT_LockTimer) clearTimeout(window._DT_LockTimer);
                window.DarkTheme_PlayNextTrack = function(forceNext) {
                    if (!window.DarkTheme_MusicPlaylist || window.DarkTheme_MusicPlaylist.length === 0) return;
                    if (window._DT_MusicLocked) return;
                    if (window._DT_ConsecErrors > window.DarkTheme_MusicPlaylist.length) { window._DT_ConsecErrors = 0; return; }
                    window._DT_MusicLocked = true;
                    if (window._DT_LockTimer) clearTimeout(window._DT_LockTimer);
                    window._DT_LockTimer = setTimeout(function() { window._DT_MusicLocked = false; }, 5000);

                    var attempts = 0;
                    if (forceNext) {
                        do {
                            if (window.DarkTheme_ShuffleMode && window.DarkTheme_MusicPlaylist.length > 1) {
                                var nx = window.DarkTheme_MusicIndex, att = 0;
                                while (nx === window.DarkTheme_MusicIndex && att++ < 15)
                                    nx = Math.floor(Math.random() * window.DarkTheme_MusicPlaylist.length);
                                window.DarkTheme_MusicIndex = nx;
                            } else {
                                window.DarkTheme_MusicIndex = (window.DarkTheme_MusicIndex + 1) %% window.DarkTheme_MusicPlaylist.length;
                            }
                            attempts++;
                        } while (window._DT_FailedTracks[window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex] ]
                                 && attempts < window.DarkTheme_MusicPlaylist.length);
                    }

                    var trackPath = window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];
                    if (window.DarkTheme_AudioNode) {
                        window.DarkTheme_AudioNode.onended = null;
                        window.DarkTheme_AudioNode.onerror = null;
                        window.DarkTheme_AudioNode.pause();
                        window.DarkTheme_AudioNode = null;
                    }
                    if (window.DarkThemeEngine_SetCurrentMusic) window.DarkThemeEngine_SetCurrentMusic(trackPath);
                    if (window.DarkThemeEngine_LuaCall && window.DarkThemeEngine_SafePathForLua) window.DarkThemeEngine_LuaCall("DarkThemeEngine_SetCurrentMusicFromJS('" + window.DarkThemeEngine_SafePathForLua(trackPath) + "')");

                    var isDataPath = (trackPath.indexOf('data/') === 0);
                    var urlCandidates = [];
                    if (isDataPath) {
                        urlCandidates.push('asset://garrysmod/' + trackPath);
                        urlCandidates.push('../' + trackPath);
                    } else if (trackPath.indexOf('sound/') === 0) {
                        urlCandidates.push('asset://garrysmod/' + trackPath);
                    } else {
                        urlCandidates.push('asset://garrysmod/sound/' + trackPath);
                    }

                    window.DarkTheme_FormatTime = function(seconds) {
                        if (isNaN(seconds) || !isFinite(seconds)) return "00:00";
                        var m = Math.floor(seconds / 60);
                        var s = Math.floor(seconds %% 60);
                        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
                    };

                    var _DT_SetupAudioNode = function(url, fallbackUrls) {
                        var node = new Audio(url);
                        node._dtHandled = false;
                        node._dtStartedAt = Date.now();
                        node._dtEarlyEndCount = 0;
                        node._dtKnownDuration = NaN;
                        node.volume = (window.DarkTheme_MusicVolume != null) ? window.DarkTheme_MusicVolume : 0.6;

                        node.addEventListener('loadedmetadata', function() {
                            if (!isNaN(node.duration) && isFinite(node.duration) && node.duration > 0) {
                                node._dtKnownDuration = node.duration;
                            }
                            if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('metadata', true);
                        });

                        node.addEventListener('play', function() {
                            if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('play', true);
                        });

                        node.addEventListener('pause', function() {
                            if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('pause', true);
                        });

                        node.addEventListener('volumechange', function() {
                            if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('volume', true);
                        });

                        node.addEventListener('timeupdate', function() {
                            var c = node.currentTime;
                            var d = node.duration;
                            if (!isNaN(d) && isFinite(d) && d > 0) {
                                node._dtKnownDuration = d;
                                var pct = (c / d) * 100;
                                var barEl = document.getElementById('music_progress_fill');
                                if (barEl) barEl.style.width = pct + '%%';
                                var lblEl = document.getElementById('music_time_label');
                                if (lblEl) lblEl.textContent = window.DarkTheme_FormatTime(c) + " / " + window.DarkTheme_FormatTime(d);
                                var sigEl = document.getElementById('music_signal_label');
                                if (sigEl) sigEl.textContent = "SIGNAL " + Math.max(0, Math.min(99.99, pct)).toFixed(2);
                                if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('progress');
                            }
                        });

                        window.DarkTheme_AudioNode = node;
                        if (window.DarkThemeEngine_AttachRealVisualizer) window.DarkThemeEngine_AttachRealVisualizer(node);
                        var p = node.play();
                        if (p && p.catch) {
                            p.then(function() { window._DT_MusicLocked = false; window._DT_ConsecErrors = 0; })
                             .catch(function(e) {
                                if (node._dtHandled) return;
                                node._dtHandled = true;
                                node.onerror = null;
                                window._DT_MusicLocked = false;
                                if (!e || e.name !== 'NotAllowedError') {
                                    window._DT_ConsecErrors = (window._DT_ConsecErrors || 0) + 1;
                                    if (fallbackUrls && fallbackUrls.length > 0) {
                                        var nextUrl = fallbackUrls.shift();
                                        _DT_SetupAudioNode(nextUrl, fallbackUrls);
                                    } else {
                                        window._DT_FailedTracks[trackPath] = true;
                                        window.DarkTheme_PlayNextTrack(true);
                                    }
                                }
                            });
                        } else {
                            window._DT_MusicLocked = false;
                        }
                        node.onended = (function(n) { return function() {
                            var d = n._dtKnownDuration || n.duration;
                            var c = n.currentTime || 0;
                            var aliveMs = Date.now() - (n._dtStartedAt || Date.now());
                            var hasDuration = !isNaN(d) && isFinite(d) && d > 0;
                            var nearFinish = hasDuration ? (c >= Math.max(0, d - 1.25)) : (aliveMs >= 15000);
                            if (!nearFinish && (n._dtEarlyEndCount || 0) < 2) {
                                n._dtEarlyEndCount = (n._dtEarlyEndCount || 0) + 1;
                                window._DT_MusicLocked = false;
                                try {
                                    if (c > 0 && hasDuration) n.currentTime = Math.max(0, c - 0.05);
                                } catch (e) {}
                                var resume = n.play();
                                if (resume && resume.catch) resume.catch(function(){});
                                return;
                            }
                            window._DT_MusicLocked = false;
                            window._DT_ConsecErrors = 0;
                            setTimeout(function() {
                                if (window.DarkTheme_PlaylistMode) {
                                    window.DarkTheme_PlayNextTrack(true);
                                } else {
                                    n.currentTime = 0;
                                    var rp = n.play();
                                    if (rp && rp.catch) rp.catch(function(){});
                                }
                            }, 300);
                        }; })(node);
                        node.onerror = function() {
                            if (node._dtHandled) return;
                            node._dtHandled = true;
                            window._DT_MusicLocked = false;
                            window._DT_ConsecErrors = (window._DT_ConsecErrors || 0) + 1;
                            if (fallbackUrls && fallbackUrls.length > 0) {
                                var nextUrl = fallbackUrls.shift();
                                _DT_SetupAudioNode(nextUrl, fallbackUrls);
                            } else {
                                window._DT_FailedTracks[trackPath] = true;
                                window.DarkTheme_PlayNextTrack(true);
                            }
                        };
                    };

                    var primaryUrl = urlCandidates.shift();
                    _DT_SetupAudioNode(primaryUrl, urlCandidates);
                };

                if (shouldStartNewTrack) {
                    if (window.DarkThemeEngine_SetCurrentMusic && window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex]) {
                        window.DarkThemeEngine_SetCurrentMusic(window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex]);
                    }
                    window.DarkTheme_PlayNextTrack(false);
                }
            } else {
                if (window.DarkTheme_AudioNode) {
                    window.DarkTheme_AudioNode.onended = null;
                    window.DarkTheme_AudioNode.onerror = null;
                    window.DarkTheme_AudioNode.pause();
                    window.DarkTheme_AudioNode = null;
                }
                if (window.DarkThemeEngine_SetCurrentMusic) window.DarkThemeEngine_SetCurrentMusic('');
            }
        ]], string.JavascriptSafe(jsMusicArray), tostring(isPlaylist), tostring(isShuffle), tostring(curVol))

        DarkThemeEngine.CallJS(js)
        IsMusicPlaying = true
    end
end

function DarkTheme_UpdateMusicPlaylist()
    DarkTheme_PlayStartupMusic()
end

local function DarkTheme_LightPlaylistUpdate()
    if not IsValid(pnlMainMenu) then return end
    if not IsMusicPlaying then
        DarkTheme_PlayStartupMusic()
        return
    end

    local settings = DarkThemeEngine.Settings or {}
    local themeOpts = settings.ThemeOptions or {}
    if not themeOpts.EnableMusic then
        DarkTheme_PlayStartupMusic()
        return
    end

    local disabledMusic = settings.DisabledMusic or {}
    local disabledAlbums = settings.DisabledAlbums or {}
    local validPaths = {}
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        if not disabledMusic[snd.path] and not disabledAlbums[snd.album or ""] then
            table.insert(validPaths, snd.path)
        end
    end

    if #validPaths == 0 then
        DarkThemeEngine.CallJS("if(window.DarkThemeEngine_StopRealVisualizer)window.DarkThemeEngine_StopRealVisualizer();if(window.DarkTheme_AudioNode){window.DarkTheme_AudioNode.onended=null;window.DarkTheme_AudioNode.onerror=null;window.DarkTheme_AudioNode.pause();window.DarkTheme_AudioNode=null;}if(window.DarkThemeEngine_SetCurrentMusic)window.DarkThemeEngine_SetCurrentMusic('');")
        IsMusicPlaying = false
        return
    end

    local isPlaylist = themeOpts.Music_PlaylistMode
    if isPlaylist == nil then isPlaylist = true end
    local isShuffle = themeOpts.Music_Shuffle
    if isShuffle == nil then isShuffle = false end

    DarkThemeEngine.CallJS(string.format([[
        (function(){
            if (!window.DarkTheme_AudioNode || !window.DarkTheme_PlayNextTrack) {
                DarkThemeEngine_LuaCall('DarkTheme_PlayStartupMusic()');
                return;
            }
            var newList = JSON.parse("%s");
            var curPath = window.DarkTheme_MusicPlaylist && window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];
            window.DarkTheme_MusicPlaylist = newList;
            window.DarkTheme_PlaylistMode = %s;
            window.DarkTheme_ShuffleMode = %s;
            if (curPath && newList.indexOf(curPath) !== -1) {
                window.DarkTheme_MusicIndex = newList.indexOf(curPath);
            } else if (newList.length > 0) {
                window.DarkTheme_MusicIndex = 0;
                window.DarkTheme_PlayNextTrack(false);
            }
        })();
    ]], string.JavascriptSafe(util.TableToJSON(validPaths)), tostring(isPlaylist), tostring(isShuffle)))
end

function DarkThemeEngine_SetMusicOption(key, value)
    local allowed = {
        EnableMusic = "boolean",
        Music_PlaylistMode = "boolean",
        Music_Shuffle = "boolean",
        Music_Volume = "number",
    }
    local expected = allowed[key]
    if not expected then return end

    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    if expected == "number" then
        value = tonumber(value) or 0
        value = math.max(0, math.min(1, value))
    else
        value = value == true
    end
    DarkThemeEngine.Settings.ThemeOptions[key] = value
    DarkThemeEngine.SaveSettings()

    if key == "EnableMusic" then
        DarkTheme_PlayStartupMusic()
    elseif key == "Music_PlaylistMode" or key == "Music_Shuffle" then
        if IsMusicPlaying and IsValid(pnlMainMenu) then
            DarkThemeEngine.CallJS(string.format(
                "window.DarkTheme_PlaylistMode=%s;window.DarkTheme_ShuffleMode=%s;",
                tostring((DarkThemeEngine.Settings.ThemeOptions or {}).Music_PlaylistMode or false),
                tostring((DarkThemeEngine.Settings.ThemeOptions or {}).Music_Shuffle or false)
            ))
        else
            DarkTheme_PlayStartupMusic()
        end
    elseif key == "Music_Volume" then
        local safeVol = math.max(0, math.min(1, value))
        lastVolume = safeVol
        DarkThemeEngine.CallJS("window.DarkTheme_MusicVolume=" .. safeVol .. ";if(window.DarkTheme_AudioNode){window.DarkTheme_AudioNode.volume=" .. safeVol .. ";}")
    end
end

function DarkThemeEngine_ToggleMusic(musicPath)
    if not IsKnownMusicPath(musicPath) then return end
    DarkThemeEngine.Settings.DisabledMusic = DarkThemeEngine.Settings.DisabledMusic or {}
    if DarkThemeEngine.Settings.DisabledMusic[musicPath] then
        DarkThemeEngine.Settings.DisabledMusic[musicPath] = nil
    else
        DarkThemeEngine.Settings.DisabledMusic[musicPath] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

function DarkThemeEngine_EnableAllMusic()
    DarkThemeEngine.Settings.DisabledMusic = {}
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

function DarkThemeEngine_DisableAllMusic()
    DarkThemeEngine.Settings.DisabledMusic = DarkThemeEngine.Settings.DisabledMusic or {}
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        DarkThemeEngine.Settings.DisabledMusic[snd.path] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

timer.Create("DarkThemeEngine_Music_Poll", 1, 0, function()
    local bInGame = IsInGame() or IsInLoading()
    if bInGame then
        if IsMusicPlaying then
            if IsValid(pnlMainMenu) and IsValid(pnlMainMenu.HTML) then

                DarkThemeEngine.CallJS([[
                    (function(){
                        var node = window.DarkTheme_AudioNode;
                        if (!node) return;
                        node.onended = null;
                        node.onerror = null;
                        var vol = node.volume;
                        var steps = 20;
                        var interval = 50;
                        var decay = vol / steps;
                        var fadeTimer = setInterval(function(){
                            vol -= decay;
                            if (vol <= 0.01) {
                                clearInterval(fadeTimer);
                                node.pause();
                                window.DarkTheme_AudioNode = null;
                            } else {
                                node.volume = vol;
                            }
                        }, interval);
                    })();
                ]])
            end
            IsMusicPlaying = false
        end
    else
        if WasInGame then
            timer.Simple(0.5, function()
                if not IsInGame() and not IsInLoading() then
                    DarkTheme_PlayStartupMusic()
                end
            end)
        end

        if IsMusicPlaying and IsValid(pnlMainMenu) then
            local storedVol = (DarkThemeEngine.Settings.ThemeOptions or {}).Music_Volume
            local currentVolume
            if storedVol ~= nil then
                currentVolume = storedVol
            else
                local volCvar2 = GetConVar("snd_musicvolume")
                currentVolume = volCvar2 and volCvar2:GetFloat() or 0.6
            end
            if currentVolume ~= lastVolume then
                lastVolume = currentVolume
                local safeVol = math.max(0, math.min(1, currentVolume))
                DarkThemeEngine.CallJS("window.DarkTheme_MusicVolume=" .. safeVol .. ";if(window.DarkTheme_AudioNode){window.DarkTheme_AudioNode.volume=" .. safeVol .. ";}")
            end
        end

        if DarkTheme_NeedsStartupMusic then
            DarkTheme_NeedsStartupMusic = false
            timer.Simple(1, function()
                if not IsInGame() and not IsInLoading() then
                    SeedGameMusic()
                    CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
                    LastMusicScanTime = SysTime()
                    SaveMusicCache()
                    DarkTheme_PlayStartupMusic()
                end
            end)
        end
    end
    WasInGame = bInGame
end)

function DarkThemeEngine_SetCurrentMusicFromJS(path)
    if path ~= "" and not IsKnownMusicPath(path) then return end
    DarkThemeEngine._CurrentMusicPath = path
end

local function CountMusicFiles()
    local count = 0
    local exts = { mp3 = true, wav = true }
    local function countIn(pattern, pathID)
        local files = file.Find(pattern, pathID) or {}
        for _, f in ipairs(files) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if exts[ext] then count = count + 1 end
        end
    end
    countIn("sound/theme_engine_music/*", "GAME")
    countIn("sound/theme_engine_music/*", "MOD")
    countIn("theme_engine_music/*", "DATA")
    return count
end

local _lastKnownMusicCount = -1

timer.Create("DarkThemeEngine_MusicFileWatch", 15, 0, function()
    if IsInGame() or IsInLoading() then return end
    local current = CountMusicFiles()
    if _lastKnownMusicCount == -1 then
        _lastKnownMusicCount = current
        return
    end
    if current ~= _lastKnownMusicCount then
        _lastKnownMusicCount = current
        DarkThemeEngine.InvalidateMusicCache()
        SeedGameMusic()
        CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
        LastMusicScanTime = SysTime()
        SaveMusicCache()
        if IsValid(pnlMainMenu) then
            DarkThemeEngine.SendMusicToJS()
            DarkTheme_PlayStartupMusic()
        end
    end
end)

function DarkTheme_CopyMusicPathToClipboard()
    local path = "garrysmod/data/theme_engine_music"
    if SetClipboardText then
        SetClipboardText(path)
    end
end

function DarkThemeEngine_ToggleAlbum(albumName)
    if not IsKnownAlbumName(albumName) then return end
    DarkThemeEngine.Settings.DisabledAlbums = DarkThemeEngine.Settings.DisabledAlbums or {}
    if DarkThemeEngine.Settings.DisabledAlbums[albumName] then
        DarkThemeEngine.Settings.DisabledAlbums[albumName] = nil
    else
        DarkThemeEngine.Settings.DisabledAlbums[albumName] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

function DarkThemeEngine_EnableAlbum(albumName)
    if not IsKnownAlbumName(albumName) then return end
    DarkThemeEngine.Settings.DisabledAlbums = DarkThemeEngine.Settings.DisabledAlbums or {}
    DarkThemeEngine.Settings.DisabledAlbums[albumName] = nil
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

function DarkThemeEngine_DisableAlbum(albumName)
    if not IsKnownAlbumName(albumName) then return end
    DarkThemeEngine.Settings.DisabledAlbums = DarkThemeEngine.Settings.DisabledAlbums or {}
    DarkThemeEngine.Settings.DisabledAlbums[albumName] = true
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end
