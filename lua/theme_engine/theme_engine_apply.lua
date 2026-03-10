if not string.JavascriptSafe then
    string.JavascriptSafe = function( str )
        if not str then return "" end
        str = string.gsub( str, "\\", "\\\\" )
        str = string.gsub( str, '"', '\\"' )
        str = string.gsub( str, "'", "\\'" )
        str = string.gsub( str, "\n", "\\n" )
        str = string.gsub( str, "\r", "\\r" )
        str = string.gsub( str, "\t", "\\t" )
        return str
    end
end

if not util.Base64Encode then
    util.Base64Encode = function() return "" end
end

if not IsInGame then IsInGame = function() return false end end
if not IsInLoading then IsInLoading = function() return false end end

local DATA_DIR  = "theme_engine_data"
local DATA_FILE = DATA_DIR .. "/settings.json"

DarkThemeEngine          = DarkThemeEngine          or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}

function DarkThemeEngine.CallJS(js)
    if not IsValid(pnlMainMenu) then return false end
    if pnlMainMenu.Call then
        pnlMainMenu:Call(js)
        return true
    elseif IsValid(pnlMainMenu.HTML) then
        pnlMainMenu.HTML:QueueJavascript(js)
        return true
    end
    return false
end

local CSS_IDS = {
    "dark_theme_css_menu",
    "dark_theme_css_navbar",
    "dark_theme_css_newgame",
    "dark_theme_css_servers",
    "dark_theme_css_workshop",
    "dark_theme_css_extra",
    "dark_theme_css_alwayson"
}

function DarkThemeEngine.RemoveAllCSS()
    for _, id in ipairs(CSS_IDS) do
        DarkThemeEngine.CallJS(string.format([[
            var el = document.getElementById('%s');
            if (el) el.remove();
        ]], id))
    end
end

function DarkThemeEngine.InjectDarkCSS()
    if not DarkThemeCSS then
        return
    end

    local cssFiles = {
        { id = "dark_theme_css_menu",     css = DarkThemeCSS.Menu,     name = "Menu" },
        { id = "dark_theme_css_navbar",   css = DarkThemeCSS.NavBar,   name = "NavBar" },
        { id = "dark_theme_css_newgame",  css = DarkThemeCSS.NewGame,  name = "NewGame" },
        { id = "dark_theme_css_servers",  css = DarkThemeCSS.Servers,  name = "Servers" },
        { id = "dark_theme_css_workshop", css = DarkThemeCSS.Workshop, name = "Workshop" },
    }

    for _, entry in ipairs(cssFiles) do
        local escaped = string.JavascriptSafe(entry.css)
        DarkThemeEngine.CallJS(string.format([[
            (function() {
                var existing = document.getElementById('%s');
                if (existing) existing.remove();
                var style = document.createElement('style');
                style.id = '%s';
                style.textContent = "%s";
                document.head.appendChild(style);
            })();
        ]], entry.id, entry.id, escaped))
    end
end

function DarkThemeEngine.InjectLightCSS()
    if not DarkThemeCSS or not DarkThemeCSS.LightExtra then return end
    local escaped = string.JavascriptSafe(DarkThemeCSS.LightExtra)
    DarkThemeEngine.CallJS(string.format([[
        (function() {
            var existing = document.getElementById('dark_theme_css_extra');
            if (existing) existing.remove();
            var style = document.createElement('style');
            style.id = 'dark_theme_css_extra';
            style.textContent = "%s";
            document.head.appendChild(style);
        })();
    ]], escaped))
end

function DarkThemeEngine.ApplyTheme(mode)

    DarkThemeEngine.RemoveAllCSS()

    if mode == "dark" then
        DarkThemeEngine.InjectDarkCSS()
    elseif mode == "light" then
        DarkThemeEngine.InjectLightCSS()
    end

    if DarkThemeCSS and DarkThemeCSS.AlwaysOn then
        local escaped = string.JavascriptSafe(DarkThemeCSS.AlwaysOn)
        DarkThemeEngine.CallJS(string.format([=[
            (function() {
                var existing = document.getElementById('dark_theme_css_alwayson');
                if (existing) existing.remove();
                var style = document.createElement('style');
                style.id = 'dark_theme_css_alwayson';
                style.textContent = "%s";
                document.head.appendChild(style);
            })();
        ]=], escaped))
    end
end

function DarkThemeEngine_SetMode(mode)

    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.Mode = mode

    if DarkThemeEngine.SaveSettings then
        DarkThemeEngine.SaveSettings()
    else
        file.Write(DATA_FILE, util.TableToJSON(DarkThemeEngine.Settings, true))
    end

    DarkThemeEngine.ApplyTheme(mode)
    DarkThemeEngine.ApplyLoadingCSS()
end

local _loadingCssApplied = false

function DarkThemeEngine.ApplyLoadingCSS()
    local mode = (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "light"
    if mode ~= "dark" then return end
    if not IsValid(pnlLoading) then return end
    local html = pnlLoading.HTML or pnlLoading
    if not IsValid(html) then return end
    local function inject()
        if not IsValid(html) then return end
        html:QueueJavascript("document.body.classList.add('dark');")
        if DarkThemeCSS and DarkThemeCSS.LoadingDark then
            html:QueueJavascript(string.format([[
                (function(){
                    var e=document.getElementById('dt_loading_css');
                    if(e)e.remove();
                    var s=document.createElement('style');
                    s.id='dt_loading_css';
                    s.textContent="%s";
                    document.head.appendChild(s);
                })();
            ]], string.JavascriptSafe(DarkThemeCSS.LoadingDark)))
        end
    end
    if html.IsLoading and html:IsLoading() then
        timer.Simple(0.3, inject)
    else
        inject()
    end
end

timer.Create("DarkTheme_LoadingWatch", 0.2, 0, function()
    if IsInLoading() then
        if not _loadingCssApplied then
            _loadingCssApplied = true
            DarkThemeEngine.ApplyLoadingCSS()
        end
    else
        _loadingCssApplied = false
    end
end)

