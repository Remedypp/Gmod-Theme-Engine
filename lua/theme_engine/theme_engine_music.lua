DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}
DarkThemeEngine.AllMusic = DarkThemeEngine.AllMusic or {}
DarkThemeEngine._MusicCovers = DarkThemeEngine._MusicCovers or {}

local ALL_MUSIC_LOOKUP = {}
local IsMusicPlaying = false
local DarkTheme_NeedsStartupMusic = true
local lastVolume = -1
local WasInGame = false

local function SafeStringCleaning(text)
    if not text then return "Unknown" end
    text = string.gsub(text, "%z", "")
    text = string.gsub(text, "\255\254", "")
    text = string.gsub(text, "\254\255", "")
    return string.Trim(text)
end

local function DarkTheme_ReadID3Tags(filename, pathID)
    if not file.Open then return nil end
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
    local totalSize = bit.lshift(b1, 21) + bit.lshift(b2, 14) + bit.lshift(b3, 7) + b4

    local tags = {}
    local bytesRead = 0

    while bytesRead < totalSize do
        local frameID = f:Read(4)
        if not frameID or string.len(frameID) < 4 or string.byte(frameID, 1) == 0 then break end

        local s1, s2, s3, s4 = f:ReadByte(), f:ReadByte(), f:ReadByte(), f:ReadByte()
        local frameSize = 0
        if verMajor == 3 then
            frameSize = bit.lshift(s1, 24) + bit.lshift(s2, 16) + bit.lshift(s3, 8) + s4
        else
            frameSize = bit.lshift(s1, 21) + bit.lshift(s2, 14) + bit.lshift(s3, 7) + s4
        end

        local frameFlags = f:Read(2)
        bytesRead = bytesRead + 10 + frameSize

        if frameSize > 0 and frameSize < 10000000 then
            if frameID == "TIT2" then
                local enc = f:ReadByte()
                tags.title = SafeStringCleaning(f:Read(frameSize - 1))
            elseif frameID == "TPE1" then
                local enc = f:ReadByte()
                tags.artist = SafeStringCleaning(f:Read(frameSize - 1))
            elseif frameID == "APIC" then
                local enc = f:ReadByte()
                local consumed = 1
                local mime = ""
                local b = f:ReadByte() consumed = consumed + 1
                while b ~= 0 do
                    mime = mime .. string.char(b)
                    b = f:ReadByte() consumed = consumed + 1
                end
                local picType = f:ReadByte() consumed = consumed + 1
                local descB = f:ReadByte() consumed = consumed + 1
                local descCount = 1
                if enc == 1 or enc == 2 then
                    local descB2 = f:ReadByte() consumed = consumed + 1
                    while not (descB == 0 and descB2 == 0) do
                        descB = descB2
                        descB2 = f:ReadByte() consumed = consumed + 1
                        descCount = descCount + 1
                        if descCount > 500 then break end
                    end
                else
                    while descB ~= 0 do
                        descB = f:ReadByte() consumed = consumed + 1
                        descCount = descCount + 1
                        if descCount > 500 then break end
                    end
                end

                local imgData = f:Read(frameSize - consumed)
                if imgData and string.len(imgData) > 0 then
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
        if not sz or sz == 0 then return false end
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

    -- new system YAAYYY :DDDD
    if not TryLoadMeta("data_static/te_music_meta.json",          "GAME") then
    if not TryLoadMeta("theme_engine_music/te_music_meta.json",   "DATA") then
    if not TryLoadMeta("theme_engine_music/te_music_meta.txt",    "DATA") then
    if not TryLoadMeta("lua/te_music_meta.lua",                   "GAME") then
    if not TryLoadMeta("sound/theme_engine_music/addon_music_meta.json", "GAME") then
    end end end end end

    local function AddMusic(jsPath, name, mount, actualFilePath, album)
        local normPath = string.lower(jsPath)
        if not ALL_MUSIC_LOOKUP[normPath] then
            ALL_MUSIC_LOOKUP[normPath] = true
            local trackData = { path = jsPath, name = name }
            trackData.album = album or ""

            local lowerName = string.lower(name)
            local coverData = nil

            local jsonMeta = CustomJsonMeta[name] or CustomJsonMeta[lowerName]
            if jsonMeta then
                if jsonMeta.title then trackData.title = tostring(jsonMeta.title) end
                if jsonMeta.artist then trackData.artist = tostring(jsonMeta.artist) end
                if jsonMeta.cover then coverData = tostring(jsonMeta.cover) end
                if jsonMeta.desc then trackData.desc = tostring(jsonMeta.desc) end
                if jsonMeta.youtube then trackData.youtube = tostring(jsonMeta.youtube) end
            else
                
                local hardcoded = CustomMeta[name] or CustomMeta[lowerName]
                if hardcoded then
                    if hardcoded.desc then trackData.desc = hardcoded.desc end
                    if hardcoded.youtube then trackData.youtube = hardcoded.youtube end
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

local CachedMusicJSON = nil
local LastMusicScanTime = 0

function DarkThemeEngine.InvalidateMusicCache()
    LastMusicScanTime = 0
    CachedMusicJSON = nil
    DarkThemeEngine.CallJS("window._DT_FailedTracks = {}; window._DT_AudioSupport = null;")
end

function DarkThemeEngine.SendMusicToJS()
    if not IsValid(pnlMainMenu) then return end

    if SysTime() - LastMusicScanTime > 10 or #DarkThemeEngine.AllMusic == 0 then
        SeedGameMusic()
        CachedMusicJSON = util.TableToJSON(DarkThemeEngine.AllMusic)
        LastMusicScanTime = SysTime()
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
            DarkThemeEngine.CallJS("if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.pause(); window.DarkTheme_AudioNode = null; } if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }")
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
            DarkThemeEngine.CallJS("if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.pause(); window.DarkTheme_AudioNode = null; } if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }")
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
        if not disabledMusic[snd.path] then
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
                if (window._DT_LockTimer) clearTimeout(window._DT_LockTimer);
                window.DarkTheme_PlayNextTrack = function(forceNext) {
                    if (!window.DarkTheme_MusicPlaylist || window.DarkTheme_MusicPlaylist.length === 0) return;
                    if (window._DT_MusicLocked) return;
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
                    
                    var finalUrl = (trackPath.indexOf('sound/') === 0 || trackPath.indexOf('data/') === 0)
                        ? 'asset://garrysmod/' + trackPath
                        : 'asset://garrysmod/sound/' + trackPath;
                    var node = new Audio(finalUrl);
                    node.volume = (window.DarkTheme_MusicVolume != null) ? window.DarkTheme_MusicVolume : 0.6;
                    
                    window.DarkTheme_FormatTime = function(seconds) {
                        if (isNaN(seconds) || !isFinite(seconds)) return "00:00";
                        var m = Math.floor(seconds / 60);
                        var s = Math.floor(seconds %% 60);
                        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
                    };

                    node.addEventListener('timeupdate', function() {
                        var c = node.currentTime;
                        var d = node.duration;
                        if (!isNaN(d) && isFinite(d) && d > 0) {
                            var pct = (c / d) * 100;
                            var barEl = document.getElementById('music_progress_fill');
                            if (barEl) barEl.style.width = pct + '%%';

                            var lblEl = document.getElementById('music_time_label');
                            if (lblEl) lblEl.textContent = window.DarkTheme_FormatTime(c) + " / " + window.DarkTheme_FormatTime(d);
                        }
                    });

                    window.DarkTheme_AudioNode = node;
                    var p = node.play();
                    if (p && p.catch) {
                        p.then(function() { window._DT_MusicLocked = false; })
                         .catch(function(e) {
                            node.onerror = null;
                            window._DT_MusicLocked = false;
                            if (!e || e.name !== 'NotAllowedError') {
                                window._DT_FailedTracks[trackPath] = true;
                                window.DarkTheme_PlayNextTrack(true);
                            }
                        });
                    } else {
                        window._DT_MusicLocked = false;
                    }
                    node.onended = (function(n) { return function() {
                        window._DT_MusicLocked = false;
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
                        window._DT_MusicLocked = false;
                        window._DT_FailedTracks[trackPath] = true;
                        window.DarkTheme_PlayNextTrack(true);
                    };
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
        DarkThemeEngine.CallJS("if(window.DarkTheme_AudioNode){window.DarkTheme_AudioNode.onended=null;window.DarkTheme_AudioNode.onerror=null;window.DarkTheme_AudioNode.pause();window.DarkTheme_AudioNode=null;}if(window.DarkThemeEngine_SetCurrentMusic)window.DarkThemeEngine_SetCurrentMusic('');")
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
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
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
                -- Fade out music over 1 second instead of abrupt stop
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
                    DarkTheme_PlayStartupMusic()
                end
            end)
        end
    end
    WasInGame = bInGame
end)

function DarkThemeEngine_SetCurrentMusicFromJS(path)
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
    DarkThemeEngine.Settings.DisabledAlbums = DarkThemeEngine.Settings.DisabledAlbums or {}
    DarkThemeEngine.Settings.DisabledAlbums[albumName] = nil
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end

function DarkThemeEngine_DisableAlbum(albumName)
    DarkThemeEngine.Settings.DisabledAlbums = DarkThemeEngine.Settings.DisabledAlbums or {}
    DarkThemeEngine.Settings.DisabledAlbums[albumName] = true
    DarkThemeEngine.SaveSettings()
    DarkTheme_LightPlaylistUpdate()
end