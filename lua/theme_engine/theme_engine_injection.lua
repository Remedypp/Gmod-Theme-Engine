DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}

function DarkTheme_SetCakeCookie(dateString)
    DarkThemeEngine.Settings.CakeEatenDate = dateString
    DarkThemeEngine.SaveSettings()
end

local hasInjected = false
local function InjectThemeIntoMenu()
    if hasInjected then return end
    local mode = (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "dark"
    DarkThemeEngine.ApplyTheme(mode)
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.JS)
    DarkThemeEngine.CallJS(string.format("window._DarkThemeEngine_SavedMode = '%s';", string.JavascriptSafe(mode)))
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.BuildRouteJS(DarkThemeEngine._UI.HTML))
    DarkThemeEngine.CallJS("window.DarkThemeEngine_InjectLink();")
    local eatenDate = DarkThemeEngine.Settings.CakeEatenDate or ""
    DarkThemeEngine.CallJS(string.format("window.DarkTheme_CakeEaten_Date = '%s';", string.JavascriptSafe(eatenDate)))
    DarkThemeEngine.CallJS(DarkThemeEngine._UI.AnniversaryJS)
    DarkThemeEngine.CallJS(string.format(
        "window._DarkThemeChangelog = %s; window._DarkThemeCredits = %s;",
        util.TableToJSON(DarkThemeEngine.Changelog or {}),
        util.TableToJSON(DarkThemeEngine.Credits or {})
    ))
    local themeOpts = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_InitSettingsUI) window.DarkThemeEngine_InitSettingsUI(%s);",
        util.TableToJSON(themeOpts)
    ))
    DarkThemeEngine.CallJS("if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew();")
    if DarkThemeEngine.SendFontsToJS then DarkThemeEngine.SendFontsToJS() end
    DarkThemeEngine.CallJS("window._DarkTheme_MiscDirty = true;")
    DarkThemeEngine.CallJS("window._DarkTheme_BgDirty = true; window._DarkTheme_MusicDirty = true;")
    hasInjected = true
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

hook.Add( "MenuStart", "ThemeEngineReinject", function()
    hasInjected = false
    timer.Simple(0, HookDocumentReady)
    timer.Simple(1, function()
        if not hasInjected then HookDocumentReady() end
    end)
end )
HookDocumentReady()
