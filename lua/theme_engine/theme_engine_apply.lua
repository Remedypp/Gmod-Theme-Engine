------------------------------------------------------------
-- x86-64 Compatibility Layer
------------------------------------------------------------
-- string.JavascriptSafe: escapes strings for JS injection
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

-- util.Base64Encode: fallback to empty string if missing
if not util.Base64Encode then
    util.Base64Encode = function() return "" end
end

-- Menu state functions: may not exist on all branches
if not IsInGame then IsInGame = function() return false end end
if not IsInLoading then IsInLoading = function() return false end end

------------------------------------------------------------
local DATA_DIR = "theme_engine_data"
local DATA_FILE = DATA_DIR .. "/settings.json"

DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.Settings = DarkThemeEngine.Settings or {}

local function EnsureDataExists()
    
    if not file.IsDir(DATA_DIR, "DATA") then
        file.CreateDir(DATA_DIR)
    end

    local OLD_FILE = "dark_theme_engine_settings.txt"
    if not file.Exists(DATA_FILE, "DATA") and file.Exists(OLD_FILE, "DATA") then
        local oldContent = file.Read(OLD_FILE, "DATA")
        if oldContent then
            file.Write(DATA_FILE, oldContent)
        end
    end

    if not file.Exists(DATA_FILE, "DATA") then
        local defaultData = {
            ThemeOptions = {
                Mode = "light"
            }
        }
        file.Write(DATA_FILE, util.TableToJSON(defaultData, true))
        DarkThemeEngine.Settings = defaultData
    else
        local content = file.Read(DATA_FILE, "DATA")
        DarkThemeEngine.Settings = util.JSONToTable(content) or {}
    end
end

local function GetThemeMode()
    return (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "light"
end

EnsureDataExists()

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
end