DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}
DarkThemeEngine.AllMusic = DarkThemeEngine.AllMusic or {}

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
    local f = file.Open(filename, "rb", pathID)
    if not f then return nil end

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
    if file.Exists("sound/theme_engine_music/addon_music_meta.json", "GAME") then
        local rawJson = file.Read("sound/theme_engine_music/addon_music_meta.json", "GAME")
        if rawJson then
            local parsed = util.JSONToTable(rawJson)
            if parsed and type(parsed) == "table" then
                CustomJsonMeta = parsed
            end
        end
    end

    local function AddMusic(jsPath, name, mount, actualFilePath)
        local normPath = string.lower(jsPath)
        if not ALL_MUSIC_LOOKUP[normPath] then
            ALL_MUSIC_LOOKUP[normPath] = true
            local trackData = { path = jsPath, name = name }

            local lowerName = string.lower(name)

            local jsonMeta = CustomJsonMeta[name] or CustomJsonMeta[lowerName]
            if jsonMeta then
                if jsonMeta.title then trackData.title = tostring(jsonMeta.title) end
                if jsonMeta.artist then trackData.artist = tostring(jsonMeta.artist) end
                if jsonMeta.cover then trackData.cover = tostring(jsonMeta.cover) end
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
                        if tags.cover then trackData.cover = tags.cover end
                    end
                end
            end

            table.insert(DarkThemeEngine.AllMusic, trackData)
        end
    end

    AddMusic("sound/theme_engine_music/Memories.mp3", "Memories.mp3", "GAME", "sound/theme_engine_music/Memories.mp3")
    AddMusic("sound/theme_engine_music/Time With You.mp3", "Time With You.mp3", "GAME", "sound/theme_engine_music/Time With You.mp3")

    local files1, _ = file.Find("sound/theme_engine_music/*", "GAME")
    if files1 then
        for _, f in ipairs(files1) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if ext == "mp3" or ext == "wav" or ext == "ogg" then
                AddMusic("sound/theme_engine_music/" .. f, f, "GAME", "sound/theme_engine_music/" .. f)
            end
        end
    end

    local files2, _ = file.Find("theme_engine_music/*", "DATA")
    if files2 then
        for _, f in ipairs(files2) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if ext == "mp3" or ext == "wav" or ext == "ogg" then
                AddMusic("data/theme_engine_music/" .. f, f, "DATA", "theme_engine_music/" .. f)
            end
        end
    end
end

local CachedMusicJSON = nil
local LastMusicScanTime = 0

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

    local currentTrack = ""
    if DarkThemeEngine._CurrentMusicPath then
        currentTrack = DarkThemeEngine._CurrentMusicPath
    end

    local js = string.format(
        "if(window.DarkThemeEngine_ReceiveMusic) window.DarkThemeEngine_ReceiveMusic(%s, %s, %s, '%s');",
        CachedMusicJSON,
        util.TableToJSON(disabledMusic),
        util.TableToJSON(themeOpts),
        string.JavascriptSafe(currentTrack)
    )
    DarkThemeEngine.CallJS(js)
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
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        if not disabledMusic[snd.path] then
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

    local jsMusicArray = util.TableToJSON(validMusic)
    local curVol = GetConVar("snd_musicvolume"):GetFloat() or 1.0
    curVol = math.max(0, math.min(1, curVol))

    if IsValid(pnlMainMenu) then
        local js = string.format([[
            var newPlaylist = %s;
            var isPlaylistMode = %s;
            var isShuffleMode = %s;
            var currentVolume = %s;

            if(!window.DarkTheme_MusicPlaylist) {
                window.DarkTheme_MusicPlaylist = [];
            }

            var currentTrackPath = null;
            var isCurrentlyPlayingInNewList = false;
            if(window.DarkTheme_AudioNode && window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex]) {
                currentTrackPath = window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];
                if (newPlaylist.indexOf(currentTrackPath) !== -1) {
                    isCurrentlyPlayingInNewList = true;
                }
            }

            window.DarkTheme_MusicPlaylist = newPlaylist;
            window.DarkTheme_PlaylistMode = isPlaylistMode;
            window.DarkTheme_ShuffleMode = isShuffleMode;

            var shouldStartNewTrack = true;

            if(window.DarkTheme_MusicPlaylist.length > 0) {
                if (isCurrentlyPlayingInNewList) {
                    window.DarkTheme_MusicIndex = window.DarkTheme_MusicPlaylist.indexOf(currentTrackPath);
                    shouldStartNewTrack = false;
                    if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(currentTrackPath); }
                } else {
                    if(window.DarkTheme_AudioNode) {
                        window.DarkTheme_AudioNode.pause();
                        window.DarkTheme_AudioNode.onended = null;
                        window.DarkTheme_AudioNode = null;
                    }
                    if (window.DarkTheme_ShuffleMode) {
                        window.DarkTheme_MusicIndex = Math.floor(Math.random() * window.DarkTheme_MusicPlaylist.length);
                    } else {
                        window.DarkTheme_MusicIndex = 0;
                    }
                }

                if (!window.DarkTheme_InputMounted) {
                    window.DarkTheme_InputMounted = true;
                    var tryStartMusic = function() {
                        if (window.DarkTheme_AudioNode && window.DarkTheme_AudioNode.paused) {
                            var p = window.DarkTheme_AudioNode.play();
                            if(p !== undefined) {
                                p.then(function() {
                                    window.removeEventListener("click", tryStartMusic, true);
                                    window.removeEventListener("keydown", tryStartMusic, true);
                                    window.removeEventListener("mousemove", tryStartMusic, true);
                                }).catch(function(e){});
                            }
                        }
                    };
                    window.addEventListener("click", tryStartMusic, true);
                    window.addEventListener("keydown", tryStartMusic, true);
                    window.addEventListener("mousemove", tryStartMusic, true);
                }

                window.DarkTheme_PlayNextTrack = function(forceNext) {
                    if(!window.DarkTheme_MusicPlaylist || window.DarkTheme_MusicPlaylist.length === 0) return;

                    if(forceNext) {
                        if (window.DarkTheme_ShuffleMode && window.DarkTheme_MusicPlaylist.length > 1) {
                            var nextIdx = window.DarkTheme_MusicIndex;
                            var attempts = 0;
                            while(nextIdx === window.DarkTheme_MusicIndex && attempts < 15) {
                                nextIdx = Math.floor(Math.random() * window.DarkTheme_MusicPlaylist.length);
                                attempts++;
                            }
                            window.DarkTheme_MusicIndex = nextIdx;
                        } else {
                            window.DarkTheme_MusicIndex++;
                            if(window.DarkTheme_MusicIndex >= window.DarkTheme_MusicPlaylist.length) {
                                window.DarkTheme_MusicIndex = 0;
                            }
                        }
                    }

                    var trackPath = window.DarkTheme_MusicPlaylist[window.DarkTheme_MusicIndex];
                    if(window.DarkTheme_AudioNode) {
                        window.DarkTheme_AudioNode.pause();
                        window.DarkTheme_AudioNode.onended = null;
                        window.DarkTheme_AudioNode = null;
                    }

                    if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(trackPath); }

                    var finalUrl = "asset://garrysmod/" + trackPath;
                    if(trackPath.indexOf("sound/") !== 0 && trackPath.indexOf("data/") !== 0) {
                        finalUrl = "asset://garrysmod/sound/" + trackPath;
                    }

                    window.DarkTheme_AudioNode = new Audio(finalUrl);
                    window.DarkTheme_AudioNode.volume = currentVolume;

                    var playPromise = window.DarkTheme_AudioNode.play();
                    if (playPromise !== undefined) {
                        playPromise.catch(function(e) {});
                    }

                    window.DarkTheme_AudioNode.onended = function() {
                        setTimeout(function() {
                            if (window.DarkTheme_PlaylistMode) {
                               window.DarkTheme_PlayNextTrack(true);
                            } else {
                               window.DarkTheme_AudioNode.currentTime = 0;
                               window.DarkTheme_AudioNode.play();
                            }
                        }, 500);
                    };
                    window.DarkTheme_AudioNode.onerror = function() {
                        setTimeout(function() {
                            if (window.DarkTheme_PlaylistMode) window.DarkTheme_PlayNextTrack(true);
                        }, 500);
                    };
                };

                if (shouldStartNewTrack) {
                    window.DarkTheme_PlayNextTrack(false);
                }
            } else {
               if(window.DarkTheme_AudioNode) {
                   window.DarkTheme_AudioNode.pause();
                   window.DarkTheme_AudioNode = null;
               }
               if(window.DarkThemeEngine_SetCurrentMusic) { window.DarkThemeEngine_SetCurrentMusic(''); }
            }
        ]], jsMusicArray, tostring(isPlaylist), tostring(isShuffle), tostring(curVol))

        DarkThemeEngine.CallJS(js)
        IsMusicPlaying = true
    end
end

function DarkTheme_UpdateMusicPlaylist()
    DarkTheme_PlayStartupMusic()
end

function DarkThemeEngine_SetMusicOption(key, value)
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions[key] = value
    DarkThemeEngine.SaveSettings()

    if key == "EnableMusic" then
        DarkTheme_PlayStartupMusic()
    elseif key == "Music_PlaylistMode" or key == "Music_Shuffle" then
        DarkTheme_UpdateMusicPlaylist()
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
    DarkTheme_UpdateMusicPlaylist()
end

function DarkThemeEngine_EnableAllMusic()
    DarkThemeEngine.Settings.DisabledMusic = {}
    DarkThemeEngine.SaveSettings()
    DarkTheme_UpdateMusicPlaylist()
end

function DarkThemeEngine_DisableAllMusic()
    DarkThemeEngine.Settings.DisabledMusic = DarkThemeEngine.Settings.DisabledMusic or {}
    for _, snd in ipairs(DarkThemeEngine.AllMusic) do
        DarkThemeEngine.Settings.DisabledMusic[snd.path] = true
    end
    DarkThemeEngine.SaveSettings()
    DarkTheme_UpdateMusicPlaylist()
end

hook.Add("Think", "DarkThemeEngine_Music_Think", function()
    local bInGame = IsInGame() or IsInLoading()
    if bInGame then
        if IsMusicPlaying and IsValid(pnlMainMenu) then
            DarkThemeEngine.CallJS("if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.pause(); window.DarkTheme_AudioNode = null; }")
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
            local currentVolume = GetConVar("snd_musicvolume"):GetFloat() or 1.0
            if currentVolume ~= lastVolume then
                lastVolume = currentVolume
                DarkThemeEngine.CallJS("if(window.DarkTheme_AudioNode) { window.DarkTheme_AudioNode.volume = Math.max(0, Math.min(1, " .. currentVolume .. ")); }")
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

function DarkTheme_CopyMusicPathToClipboard()
    local path = "garrysmod/data/theme_engine_music"
    if SetClipboardText then
        SetClipboardText(path)
    end
end