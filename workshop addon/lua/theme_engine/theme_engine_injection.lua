DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}

function DarkTheme_SetCakeCookie(dateString)
    DarkThemeEngine.Settings.CakeEatenDate = dateString
    DarkThemeEngine.SaveSettings()
end

local hasInjected = false

local WorkshopPending = {}

local function NormalizeWorkshopID(wsid)
    wsid = tostring(wsid or ""):match("^(%d+)$")
    if not wsid or #wsid > 20 then return nil end
    return wsid
end

local function FindWorkshopAddon(wsid)
    if not engine or not engine.GetAddons then return nil end
    wsid = tostring(wsid or "")
    for _, addon in ipairs(engine.GetAddons() or {}) do
        if tostring(addon.wsid or "") == wsid then return addon end
    end
    return nil
end

local function NotifyWorkshopJS(wsid, status, message)
    if not DarkThemeEngine.CallJS then return end
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_OnWorkshopInstallStatus)window.DarkThemeEngine_OnWorkshopInstallStatus('%s','%s','%s');",
        string.JavascriptSafe(tostring(wsid or "")),
        string.JavascriptSafe(tostring(status or "")),
        string.JavascriptSafe(tostring(message or ""))
    ))
end

local function RefreshWorkshopUI()
    if not IsValid(pnlMainMenu) then return end
    if UpdateSubscribedAddons then pcall(UpdateSubscribedAddons) end
    if DarkThemeEngine.CallJS then
        DarkThemeEngine.CallJS("if(window.DarkThemeEngine_WorkshopRefreshCurrentAddonView)window.DarkThemeEngine_WorkshopRefreshCurrentAddonView();")
    end
end

local function ApplyWorkshopAddons(reason)
    if not steamworks or not steamworks.ApplyAddons then return end
    local ok, err = pcall(steamworks.ApplyAddons)
    if not ok then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("error", "Workshop", "ApplyAddons failed: " .. tostring(err)) end
    end
    timer.Simple(0.25, RefreshWorkshopUI)
    timer.Simple(1.5, RefreshWorkshopUI)
end

local function QueueWorkshopApply(reason, delay)
    timer.Remove("DarkThemeEngine_WorkshopApplyDebounce")
    timer.Create("DarkThemeEngine_WorkshopApplyDebounce", delay or 0.75, 1, function()
        ApplyWorkshopAddons(reason)
    end)
end

local function HasPendingWorkshop()
    return next(WorkshopPending) ~= nil
end

local function StartWorkshopPoll()
    if timer.Exists("DarkThemeEngine_WorkshopPendingPoll") then return end
    timer.Create("DarkThemeEngine_WorkshopPendingPoll", 1, 0, function()
        if not HasPendingWorkshop() then
            timer.Remove("DarkThemeEngine_WorkshopPendingPoll")
            return
        end

        local now = SysTime()
        for wsid, state in pairs(WorkshopPending) do
            local addon = FindWorkshopAddon(wsid)
            if addon and addon.mounted then
                NotifyWorkshopJS(wsid, "mounted", "Addon mounted")
                WorkshopPending[wsid] = nil
                RefreshWorkshopUI()
            elseif addon and addon.downloaded ~= false then
                if state.lastStatus ~= "downloaded" then
                    NotifyWorkshopJS(wsid, "downloaded", "Download complete, mounting addon")
                    state.lastStatus = "downloaded"
                end
                if (state.applyAttempts or 0) < 5 and now - (state.lastApply or 0) > 2.5 then
                    state.applyAttempts = (state.applyAttempts or 0) + 1
                    state.lastApply = now
                    QueueWorkshopApply("downloaded " .. wsid, 0.2)
                end
            else
                if state.lastStatus ~= "downloading" then
                    NotifyWorkshopJS(wsid, "downloading", "Waiting for Steam download")
                    state.lastStatus = "downloading"
                end
                if now - state.started > 180 then
                    NotifyWorkshopJS(wsid, "restart_needed", "Steam has not exposed the addon yet; restart GMod if it remains pending")
                    WorkshopPending[wsid] = nil
                end
            end
        end
    end)
end

function DarkThemeEngine_WorkshopSubscribe(wsid)
    wsid = NormalizeWorkshopID(wsid)
    if not wsid or not steamworks or not steamworks.Subscribe then return end

    local ok, err = pcall(steamworks.Subscribe, tonumber(wsid))
    if not ok then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("error", "Workshop", "Subscribe failed for " .. wsid .. ": " .. tostring(err)) end
        NotifyWorkshopJS(wsid, "error", "Subscribe failed")
        return
    end
    if steamworks.SetShouldMountAddon then
        local mountOk, mountErr = pcall(steamworks.SetShouldMountAddon, wsid, true)
        if not mountOk then
            if DarkThemeEngine_Log then DarkThemeEngine_Log("warn", "Workshop", "Mount request failed for " .. wsid .. ": " .. tostring(mountErr)) end
        end
    end

    WorkshopPending[wsid] = {
        started = SysTime(),
        lastStatus = "",
        applyAttempts = 0,
        lastApply = 0,
    }
    NotifyWorkshopJS(wsid, "subscribed", "Subscribed; waiting for download")
    RefreshWorkshopUI()
    StartWorkshopPoll()
end

function DarkThemeEngine_WorkshopUnsubscribe(wsid)
    wsid = NormalizeWorkshopID(wsid)
    if not wsid or not steamworks or not steamworks.Unsubscribe then return end

    WorkshopPending[wsid] = nil
    local ok, err = pcall(steamworks.Unsubscribe, tonumber(wsid))
    if not ok then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("error", "Workshop", "Unsubscribe failed for " .. wsid .. ": " .. tostring(err)) end
        NotifyWorkshopJS(wsid, "error", "Unsubscribe failed")
        return
    end
    NotifyWorkshopJS(wsid, "unsubscribed", "Unsubscribed")
    QueueWorkshopApply("unsubscribe " .. wsid, 0.5)
end

function DarkThemeEngine_WorkshopApplyAddons()
    QueueWorkshopApply("manual ui change", 0.5)
end

hook.Add("WorkshopDownloadedFile", "ThemeEngine_WorkshopDownloadReady", function(wsid)
    wsid = NormalizeWorkshopID(wsid)
    if not wsid or not WorkshopPending[wsid] then return end
    NotifyWorkshopJS(wsid, "downloaded", "Download complete, mounting addon")
    QueueWorkshopApply("downloaded event " .. wsid, 0.35)
    StartWorkshopPoll()
end)

hook.Add("WorkshopEnd", "ThemeEngine_WorkshopEndApply", function()
    if not HasPendingWorkshop() then return end
    QueueWorkshopApply("workshop end", 0.75)
    StartWorkshopPoll()
end)

hook.Add("WorkshopSubscriptionsChanged", "ThemeEngine_WorkshopSubsChanged", function()
    RefreshWorkshopUI()
    if HasPendingWorkshop() then StartWorkshopPoll() end
end)

hook.Add("GameContentChanged", "ThemeEngine_WorkshopMountedRefresh", function()
    timer.Simple(0.35, function()
        RefreshWorkshopUI()
        if HasPendingWorkshop() then StartWorkshopPoll() end
    end)
end)

local function InjectThemeIntoMenu()
    if hasInjected then return end
    local mode = (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "dark"
    DarkThemeEngine.ApplyTheme(mode)
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.JS)
    DarkThemeEngine.CallJS("if(window.DarkThemeEngine_InstallWorkshopDownloadGuard)window.DarkThemeEngine_InstallWorkshopDownloadGuard();")
    DarkThemeEngine.CallJS(string.format("window._DarkThemeEngine_SavedMode = '%s';", string.JavascriptSafe(mode)))
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.BuildRouteJS(DarkThemeEngine._UI.HTML))
    DarkThemeEngine.CallJS("window.DarkThemeEngine_InjectLink();")
    local eatenDate = DarkThemeEngine.Settings.CakeEatenDate or ""
    DarkThemeEngine.CallJS(string.format("window.DarkTheme_CakeEaten_Date = '%s';", string.JavascriptSafe(eatenDate)))
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.AnniversaryJS)
    DarkThemeEngine.CallJS(string.format(
        "window._DT_ChangelogHTML = null; window._DarkThemeChangelog = %s; window._DarkThemeCredits = %s; window._DarkThemeMiniChangelog = %s;",
        util.TableToJSON(DarkThemeEngine.Changelog or {}),
        util.TableToJSON(DarkThemeEngine.Credits or {}),
        util.TableToJSON(DarkThemeEngine.MiniChangelog or {})
    ))
    local themeOpts = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_InitSettingsUI) window.DarkThemeEngine_InitSettingsUI(%s);",
        util.TableToJSON(themeOpts)
    ))
    local lastSeenCL = DarkThemeEngine.Settings.LastSeenChangelog or ""
    DarkThemeEngine.CallJS(string.format(
        "window._DarkTheme_LastSeenChangelog = '%s'; if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew(); setTimeout(function(){if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew();},500);",
        string.JavascriptSafe(lastSeenCL)
    ))
    if DarkThemeEngine.SendFontsToJS then DarkThemeEngine.SendFontsToJS() end
    DarkThemeEngine.CallJS("window._DarkTheme_BgDirty = true; window._DarkTheme_MusicDirty = true; window._DarkTheme_MiscDirty = true;")
    timer.Simple(0.8, function()
        if DarkThemeEngine.WarmBackgroundCache then DarkThemeEngine.WarmBackgroundCache() end
    end)
    timer.Simple(1.4, function()
        if DarkThemeEngine.WarmMenuSoundCache then DarkThemeEngine.WarmMenuSoundCache() end
    end)
    timer.Simple(2.0, function()
        if DarkThemeEngine.WarmMusicCache then DarkThemeEngine.WarmMusicCache() end
    end)
    hasInjected = true
    if ThemeEngine_MarkMainMenuReady then ThemeEngine_MarkMainMenuReady() end
end

local function HookDocumentReady()
    if not IsValid(pnlMainMenu) or not IsValid(pnlMainMenu.HTML) then
        timer.Simple(0.1, HookDocumentReady)
        return
    end
    local html = pnlMainMenu.HTML
    if not html._ThemeEngineHooked then
        html._ThemeEngineHooked = true
        local origOnDocReady = html.OnDocumentReady
        html.OnDocumentReady = function(self, url)
            if origOnDocReady then origOnDocReady(self, url) end
            InjectThemeIntoMenu()
        end
    end
    if not hasInjected and pnlMainMenu.menuLoaded then
        InjectThemeIntoMenu()
    end
end

concommand.Add("theme_engine", function()
    if not IsValid(pnlMainMenu) or not IsValid(pnlMainMenu.HTML) then return end
    DarkThemeEngine.CallJS("window.location.hash = '#/theme/';")
end, nil, "Open Theme Engine settings panel")

concommand.Add("theme_engine_open", function()
    if not IsValid(pnlMainMenu) or not IsValid(pnlMainMenu.HTML) then return end
    DarkThemeEngine.CallJS("window.location.hash = '#/theme/';")
end, nil, "Open Theme Engine settings panel")

hook.Add( "MenuStart", "ThemeEngineReinject", function()
    hasInjected = false
    timer.Simple(0, HookDocumentReady)
    timer.Simple(1, function()
        if not hasInjected then HookDocumentReady() end
    end)
end )
HookDocumentReady()
