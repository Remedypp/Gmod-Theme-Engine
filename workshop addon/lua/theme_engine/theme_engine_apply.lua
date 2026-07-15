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
    if type(js) ~= "string" then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("warn", "JavaScript", "Ignored non-string payload (" .. type(js) .. ")") end
        return false
    end
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
    "dark_theme_css_custom",
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
    DarkThemeEngine.CallJS([[
        (function() {
            var overlay = document.getElementById('dark_theme_custom_overlay');
            if (overlay) overlay.remove();
            if (document && document.body) {
                document.body.classList.remove('dark-theme-custom-active');
                document.body.removeAttribute('data-theme-engine-custom');
            }
        })();
    ]])
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

local CUSTOM_THEME_CSS_FILES = {
    "main_menu.css",
    "addons_page.css",
    "start_new_game.css",
    "servers.css",
    "saves_dupes_demos.css",
    "bottom_navbar.css",
    "loading_screen.css"
}

local VALID_CUSTOM_THEME_FILES = {
    ["main_menu.css"] = true,
    ["addons_page.css"] = true,
    ["start_new_game.css"] = true,
    ["servers.css"] = true,
    ["saves_dupes_demos.css"] = true,
    ["bottom_navbar.css"] = true,
    ["loading_screen.css"] = true,
    ["menu_templates.html"] = true,
    ["theme_manifest.json"] = true,
    ["full_templates.json"] = true,
    ["full_shell.html"] = true
}

local function ThemeLoadLog(msg)
    if DarkThemeEngine_Log then DarkThemeEngine_Log("debug", "ThemeLoader", msg) end
end

local function ThemeLoadWarn(msg)
    if DarkThemeEngine_Log then DarkThemeEngine_Log("warn", "ThemeLoader", msg) else print("[ThemeEngine] [ThemeLoader] " .. tostring(msg or "")) end
end

local function SafeCustomThemeFolder(name)
    name = tostring(name or ""):lower()
    name = name:gsub("[^%w_%-]", "_")
    name = name:gsub("_+", "_")
    if not name:match("^theme_engine_") then
        name = "theme_engine_" .. name
    end
    return name:sub(1, 64)
end

local function CustomThemeDecrypt(text, key)
    text = tostring(text or "")
    if text:sub(1, 5) ~= "DTE1:" then return nil, "missing DTE1 header" end
    key = tostring(key or "theme_engine")
    if key == "" then key = "theme_engine" end

    local encoded = text:sub(6)
    local encrypted = encoded
    if util and util.Base64Decode then
        local ok, result = pcall(util.Base64Decode, encoded)
        if ok and result then encrypted = result end
    else
        return nil, "util.Base64Decode unavailable"
    end

    local out = {}
    for i = 1, #encrypted do
        local kb = key:byte(((i - 1) % #key) + 1) or 0
        out[i] = string.char((encrypted:byte(i) - kb - i) % 256)
    end
    return table.concat(out)
end

local function ReadCustomThemePayload(folder, fileName, quiet)
    folder = SafeCustomThemeFolder(folder)
    fileName = tostring(fileName or "")
    if not VALID_CUSTOM_THEME_FILES[fileName] then
        if not quiet then ThemeLoadWarn("Blocked invalid payload name: " .. fileName) end
        return nil
    end

    local candidates = {
        { path = "theme_engine_created_addons/" .. folder .. "/data_static/theme_engine_created_addons/" .. folder .. "/" .. fileName .. ".dte.txt", id = "DATA", label = "DATA created" },
        { path = "theme_engine_full_themes/" .. folder .. "/data_static/theme_engine_full_themes/" .. folder .. "/" .. fileName .. ".dte.txt", id = "DATA", label = "DATA full" },
        { path = "data_static/theme_engine_created_addons/" .. folder .. "/" .. fileName .. ".dte.txt", id = "GAME", label = "GAME created" },
        { path = "data_static/theme_engine_full_themes/" .. folder .. "/" .. fileName .. ".dte.txt", id = "GAME", label = "GAME full" },
    }

    local raw, source, sourcePath, sourceID
    for _, candidate in ipairs(candidates) do
        raw = file.Read(candidate.path, candidate.id)
        if raw and raw ~= "" then
            source = candidate.label
            sourcePath = candidate.path
            sourceID = candidate.id
            break
        end
    end
    if not raw or raw == "" then
        if not quiet then ThemeLoadWarn(folder .. " missing payload: " .. fileName) end
        return nil
    end

    DarkThemeEngine._PayloadCache = DarkThemeEngine._PayloadCache or {}
    local stamp = tostring(file.Time(sourcePath, sourceID) or 0) .. ":" .. tostring(#raw)
    local cacheKey = sourceID .. ":" .. sourcePath
    local cached = DarkThemeEngine._PayloadCache[cacheKey]
    if cached and cached.stamp == stamp then
        if not quiet then ThemeLoadLog(folder .. " loaded " .. fileName .. " from cache (" .. tostring(#cached.decoded) .. " bytes)") end
        return cached.decoded
    end

    local decoded, err = CustomThemeDecrypt(raw, folder .. ":" .. fileName)
    if not decoded then
        if not quiet then ThemeLoadWarn(folder .. " failed to decrypt " .. fileName .. " from " .. source .. ": " .. tostring(err or "unknown error")) end
        return nil
    end

    DarkThemeEngine._PayloadCache[cacheKey] = { stamp = stamp, decoded = decoded }
    if not quiet then ThemeLoadLog(folder .. " loaded " .. fileName .. " from " .. source .. " (" .. tostring(#decoded) .. " bytes)") end
    return decoded
end

local function SanitizeCustomThemeHTML(html)
    html = tostring(html or "")
    if html == "" then return "" end
    html = html:sub(1, 24000)
    html = html:gsub("<%s*/?%s*script[^>]*>", "")
    html = html:gsub("<%s*/?%s*iframe[^>]*>", "")
    html = html:gsub("<%s*/?%s*object[^>]*>", "")
    html = html:gsub("<%s*/?%s*embed[^>]*>", "")
    html = html:gsub("<%s*/?%s*link[^>]*>", "")
    html = html:gsub("<%s*/?%s*meta[^>]*>", "")
    html = html:gsub("<%s*style[^>]*>.-<%s*/%s*style%s*>", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*\"[^\"]*\"", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*'[^']*'", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*[^%s>]+", "")
    html = html:gsub("javascript%s*:", "")
    html = html:gsub("data%s*:%s*text/html", "")
    return html
end

local function SanitizeFullTemplateHTML(html)
    html = tostring(html or "")
    if html == "" then return "" end
    html = html:sub(1, 80000)
    html = html:gsub("asset://garrysmod/[^\"'%s<>]+#/", "#/")
    html = html:gsub("asset://garrysmod/[^\"'%s<>]+#!/", "#!/")
    html = html:gsub("<%s*/?%s*script[^>]*>", "")
    html = html:gsub("<%s*/?%s*iframe[^>]*>", "")
    html = html:gsub("<%s*/?%s*object[^>]*>", "")
    html = html:gsub("<%s*/?%s*embed[^>]*>", "")
    html = html:gsub("javascript%s*:", "")
    html = html:gsub("data%s*:%s*text/html", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*\"[^\"]*\"", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*'[^']*'", "")
    html = html:gsub("%s+on[%w_%-]+%s*=%s*[^%s>]+", "")
    return html
end

local function LoadFullTemplates(folder)
    local payload = ReadCustomThemePayload(folder, "full_templates.json", true)
    if not payload or payload == "" then
        ThemeLoadLog(SafeCustomThemeFolder(folder) .. " has no full_templates.json payload")
        return nil
    end
    if not util.JSONToTable then
        ThemeLoadWarn(SafeCustomThemeFolder(folder) .. " cannot parse full_templates.json because util.JSONToTable is unavailable")
        return nil
    end
    local ok, decoded = pcall(util.JSONToTable, payload)
    if not ok or type(decoded) ~= "table" then
        ThemeLoadWarn(SafeCustomThemeFolder(folder) .. " full_templates.json is invalid JSON")
        return nil
    end

    local out = {}
    local allowed = {
        ["template/main.html"] = true,
        ["template/newgame.html"] = true,
        ["template/servers.html"] = true,
        ["template/addon_list.html"] = true,
        ["template/saves.html"] = true,
        ["template/dupes.html"] = true,
        ["template/demos.html"] = true
    }

    for key, html in pairs(decoded) do
        key = tostring(key or "")
        if allowed[key] and type(html) == "string" then
            out[key] = SanitizeFullTemplateHTML(html)
        elseif key ~= "" then
            ThemeLoadWarn(SafeCustomThemeFolder(folder) .. " ignored unsupported template key: " .. key)
        end
    end

    if next(out) == nil then
        ThemeLoadWarn(SafeCustomThemeFolder(folder) .. " full_templates.json did not contain any supported templates")
        return nil
    end
    return out
end

local function LoadFullShell(folder)
    local payload = ReadCustomThemePayload(folder, "full_shell.html", true)
    if not payload or payload == "" then
        ThemeLoadLog(SafeCustomThemeFolder(folder) .. " has no full_shell.html payload")
        return nil
    end
    local shell = SanitizeFullTemplateHTML(payload)
    if shell == "" then
        ThemeLoadWarn(SafeCustomThemeFolder(folder) .. " full_shell.html sanitized to empty")
        return nil
    end
    ThemeLoadLog(SafeCustomThemeFolder(folder) .. " loaded full_shell.html (" .. tostring(#shell) .. " sanitized bytes)")
    return shell
end

local function InstallFullShell(folder, shell)
    shell = shell or LoadFullShell(folder)
    if not shell or shell == "" then return end
    local escapedShell = string.JavascriptSafe(shell)
    ThemeLoadLog(SafeCustomThemeFolder(folder) .. " installing full menu shell")
    DarkThemeEngine.CallJS(string.format([=[
        (function() {
            var prefix = '[ThemeEngine ThemeLoader JS] ';
            try {
                window._DT_PendingFullShellHTML = "%s";
                window._DT_FullThemeOriginalShell = window._DT_FullThemeOriginalShell || {};

                function getAngularState() {
                    if (!window.angular) return null;
                    var root = document.body || document.documentElement;
                    var injector = angular.element(root).injector();
                    if (!injector) {
                        var probe = document.querySelector('[ng-view]') || document.querySelector('#NavBar') || document.querySelector('.mainmenu');
                        if (probe) injector = angular.element(probe).injector();
                    }
                    if (!injector) return null;
                    var rootScope = null;
                    try { rootScope = injector.get('$rootScope'); } catch(e) {}
                    return {
                        injector: injector,
                        compile: injector.get('$compile'),
                        rootScope: rootScope
                    };
                }

                function getScopeFor(node, state) {
                    var cursor = node;
                    while (cursor) {
                        try {
                            var wrapped = angular.element(cursor);
                            var scope = null;
                            if (wrapped.scope) scope = wrapped.scope();
                            if (!scope && wrapped.isolateScope) scope = wrapped.isolateScope();
                            if (!scope && wrapped.data) scope = wrapped.data('$scope') || wrapped.data('$isolateScope');
                            if (scope) return scope;
                        } catch(e) {}
                        cursor = cursor.parentNode;
                    }
                    return state ? state.rootScope : null;
                }

                window.DarkThemeEngine_InstallPendingFullShell = function(attempt) {
                    attempt = attempt || 1;
                    var state = getAngularState();
                    if (!state) {
                        if (attempt <= 24) {
                            setTimeout(function() { window.DarkThemeEngine_InstallPendingFullShell(attempt + 1); }, 125);
                        } else {
                            console.warn(prefix + 'shell install abandoned: Angular injector unavailable');
                        }
                        return;
                    }

                    var temp = document.createElement('div');
                    temp.innerHTML = window._DT_PendingFullShellHTML || '';
                    var installed = 0;

                    function replaceOne(selector) {
                        var incoming = temp.querySelector(selector);
                        var current = document.querySelector(selector);
                        if (!incoming) { console.warn(prefix + 'shell missing selector ' + selector); return; }
                        if (!current) { console.warn(prefix + 'current document missing selector ' + selector); return; }
                        if (window._DT_FullThemeOriginalShell[selector] === undefined) {
                            window._DT_FullThemeOriginalShell[selector] = current.outerHTML;
                        }
                        var bindScope = getScopeFor(current, state);
                        if (!bindScope) { console.warn(prefix + 'scope unavailable for shell selector ' + selector); return; }
                        var clone = incoming.cloneNode(true);
                        current.parentNode.replaceChild(clone, current);
                        state.compile(clone)(bindScope);
                        installed += 1;
                    }

                    replaceOne('#version');
                    replaceOne('#NavBar');
                    if (installed < 2 || !document.querySelector('#NavBar ul.gamemode_list')) replaceOne('ul.gamemode_list');
                    if (installed < 2 || !document.querySelector('#NavBar ul.language_list')) replaceOne('ul.language_list');
                    if (installed < 2 || !document.querySelector('#NavBar ul.games_list')) replaceOne('ul.games_list');

                    if (installed === 0 && attempt <= 24) {
                        setTimeout(function() { window.DarkThemeEngine_InstallPendingFullShell(attempt + 1); }, 125);
                        return;
                    }

                    window._DT_FullThemeShellActive = installed > 0;
                    try {
                        if (state.rootScope && state.rootScope.$evalAsync) state.rootScope.$evalAsync();
                    } catch(e) {}
                    setTimeout(function() { if (window.DarkThemeEngine_InjectLink) window.DarkThemeEngine_InjectLink(); }, 80);
                    setTimeout(function() { if (window.DarkThemeEngine_InjectLink) window.DarkThemeEngine_InjectLink(); }, 240);
                };

                window.DarkThemeEngine_InstallPendingFullShell(1);
            } catch(e) {
                console.error(prefix + 'shell install failed:', e);
            }
        })();
    ]=], escapedShell))
end

local function InstallFullTemplates(folder, templates)
    templates = templates or LoadFullTemplates(folder)
    if not templates then return end
    local count = 0
    for _ in pairs(templates) do count = count + 1 end
    ThemeLoadLog(SafeCustomThemeFolder(folder) .. " installing " .. tostring(count) .. " full menu templates")
    local json = util.TableToJSON(templates, false) or "{}"
    DarkThemeEngine.CallJS(string.format([=[
        (function() {
            var prefix = '[ThemeEngine ThemeLoader JS] ';
            try {
                var injector = angular.element(document.body).injector();
                if (!injector) { console.warn(prefix + 'Angular injector unavailable; template install skipped'); return; }
                var $templateCache = injector.get('$templateCache');
                var $route = injector.get('$route');
                var templates = %s;
                var oldHash = window.location ? String(window.location.hash || '') : '';
                window._DT_FullThemeOriginalTemplates = window._DT_FullThemeOriginalTemplates || {};
                for (var key in templates) {
                    if (!Object.prototype.hasOwnProperty.call(templates, key)) continue;
                    if (window._DT_FullThemeOriginalTemplates[key] === undefined) {
                        window._DT_FullThemeOriginalTemplates[key] = $templateCache.get(key) || '';
                    }
                    $templateCache.put(key, templates[key]);
                }
                window._DT_FullThemeTemplatesActive = true;
                if (window.location && String(window.location.hash || '').indexOf('/theme') === -1 && $route && $route.reload) {
                    setTimeout(function() {
                        try {
                            $route.reload();
                            if (!oldHash || oldHash === '#') window.location.hash = '#/';
                        } catch(e) {}
                        setTimeout(function() { if (window.DarkThemeEngine_InjectLink) window.DarkThemeEngine_InjectLink(); }, 80);
                        setTimeout(function() { if (window.DarkThemeEngine_InjectLink) window.DarkThemeEngine_InjectLink(); }, 240);
                    }, 25);
                }
            } catch(e) { console.error(prefix + 'template install failed:', e); }
        })();
    ]=], json))
end

local function RestoreFullTemplates()
    ThemeLoadLog("Restoring original GMod menu templates")
    DarkThemeEngine.CallJS([[
        (function() {
            var prefix = '[ThemeEngine ThemeLoader JS] ';
            try {
                if (!window._DT_FullThemeOriginalTemplates && !window._DT_FullThemeOriginalShell) return;
                var injector = angular.element(document.body).injector();
                if (!injector) { console.warn(prefix + 'Angular injector unavailable; restore skipped'); return; }
                var $templateCache = injector.get('$templateCache');
                var $route = injector.get('$route');
                if (window._DT_FullThemeOriginalTemplates) {
                    for (var key in window._DT_FullThemeOriginalTemplates) {
                        if (!Object.prototype.hasOwnProperty.call(window._DT_FullThemeOriginalTemplates, key)) continue;
                        $templateCache.put(key, window._DT_FullThemeOriginalTemplates[key] || '');
                    }
                }
                if (window._DT_FullThemeOriginalShell) {
                    var $compile = injector.get('$compile');
                    var rootScope = null;
                    try { rootScope = injector.get('$rootScope'); } catch(e) {}
                    function getScopeFor(node) {
                        var cursor = node;
                        while (cursor) {
                            try {
                                var wrapped = angular.element(cursor);
                                var scope = null;
                                if (wrapped.scope) scope = wrapped.scope();
                                if (!scope && wrapped.isolateScope) scope = wrapped.isolateScope();
                                if (!scope && wrapped.data) scope = wrapped.data('$scope') || wrapped.data('$isolateScope');
                                if (scope) return scope;
                            } catch(e) {}
                            cursor = cursor.parentNode;
                        }
                        return rootScope;
                    }
                    for (var selector in window._DT_FullThemeOriginalShell) {
                        if (!Object.prototype.hasOwnProperty.call(window._DT_FullThemeOriginalShell, selector)) continue;
                        var current = document.querySelector(selector);
                        if (!current) continue;
                        var temp = document.createElement('div');
                        temp.innerHTML = window._DT_FullThemeOriginalShell[selector] || '';
                        var original = temp.firstElementChild;
                        if (!original) continue;
                        current.parentNode.replaceChild(original, current);
                        if ($compile) {
                            var scope = getScopeFor(original);
                            if (scope) $compile(original)(scope);
                        }
                    }
                    window._DT_FullThemeOriginalShell = null;
                    window._DT_PendingFullShellHTML = null;
                }
                window._DT_FullThemeTemplatesActive = false;
                window._DT_FullThemeShellActive = false;
                if (window.location && String(window.location.hash || '').indexOf('/theme') === -1 && $route && $route.reload) {
                    setTimeout(function() { try { $route.reload(); } catch(e) {} }, 25);
                }
            } catch(e) { console.error(prefix + 'restore failed:', e); }
        })();
    ]])
end

function DarkThemeEngine.InjectCustomTheme(folder)
    folder = SafeCustomThemeFolder(folder)
    if folder == "" then return false end
    if DarkThemeEngine._CustomThemeSuspended then
        ThemeLoadLog(folder .. " apply requested while Theme Engine Options is open; custom theme is suspended")
        DarkThemeEngine.CallJS(string.format(
            "if(window.DarkThemeEngine_OnThemeApplyOK) window.DarkThemeEngine_OnThemeApplyOK(%q);",
            folder
        ))
        return true
    end

    ThemeLoadLog("Applying theme: " .. folder)
    local css = {}
    local cssPayloadCount = 0
    DarkThemeEngine._CustomLoadingCSS = nil
    for _, fileName in ipairs(CUSTOM_THEME_CSS_FILES) do
        local decoded = ReadCustomThemePayload(folder, fileName)
        if decoded and decoded ~= "" then
            cssPayloadCount = cssPayloadCount + 1
            if fileName == "loading_screen.css" then
                DarkThemeEngine._CustomLoadingCSS = decoded
            else
                css[#css + 1] = decoded
            end
        end
    end

    local templateRaw = ReadCustomThemePayload(folder, "menu_templates.html", true) or ""
    local template = SanitizeCustomThemeHTML(templateRaw)
    if templateRaw ~= "" then
        ThemeLoadLog(folder .. " loaded menu_templates.html (" .. tostring(#template) .. " sanitized bytes)")
    else
        ThemeLoadLog(folder .. " has no menu_templates.html overlay")
    end
    local fullTemplates = LoadFullTemplates(folder)
    local fullShell = LoadFullShell(folder)

    if #css == 0 and template == "" and not fullTemplates and not fullShell then
        ThemeLoadWarn(folder .. " cancelled: no CSS, no overlay template, no full shell, and no full templates loaded")
        DarkThemeEngine.CallJS("if(window.DarkThemeEngine_OnThemeApplyFailed) window.DarkThemeEngine_OnThemeApplyFailed('Theme payload is empty or could not be loaded.');")
        return false
    end

    ThemeLoadLog(folder .. " CSS payloads applied: " .. tostring(cssPayloadCount) .. "/" .. tostring(#CUSTOM_THEME_CSS_FILES))

    local escaped = string.JavascriptSafe(table.concat(css, "\n\n"))
    local escapedTemplate = string.JavascriptSafe(template)
    local escapedFolder = string.JavascriptSafe(folder)
    DarkThemeEngine.CallJS(string.format([[
        (function() {
            var existing = document.getElementById('dark_theme_css_custom');
            if (existing) existing.remove();
            var style = document.createElement('style');
            style.id = 'dark_theme_css_custom';
            style.textContent = "%s";
            document.head.appendChild(style);
            var overlay = document.getElementById('dark_theme_custom_overlay');
            if (overlay) overlay.remove();
            if ("%s") {
                overlay = document.createElement('div');
                overlay.id = 'dark_theme_custom_overlay';
                overlay.setAttribute('aria-hidden', 'true');
                overlay.innerHTML = "%s";
                document.body.appendChild(overlay);
            }
            if (document && document.body) {
                document.body.classList.add('dark-theme-custom-active');
                document.body.setAttribute('data-theme-engine-custom', "%s");
            }
        })();
    ]], escaped, escapedTemplate, escapedTemplate, escapedFolder))
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_OnThemeApplyOK) window.DarkThemeEngine_OnThemeApplyOK(%q);",
        folder
    ))
    if fullShell then InstallFullShell(folder, fullShell) end
    if fullTemplates then
        InstallFullTemplates(folder, fullTemplates)
    elseif not fullShell then
        RestoreFullTemplates()
    end
    ThemeLoadLog(folder .. " applied successfully")
    return true
end

function DarkThemeEngine_SetCustomThemeSuspended(suspended)
    DarkThemeEngine._CustomThemeSuspended = suspended == true
    if DarkThemeEngine._CustomThemeSuspended then
        ThemeLoadLog("Theme Engine Options opened; suspending custom theme CSS/overlay")
        DarkThemeEngine.CallJS([[
            (function() {
                var css = document.getElementById('dark_theme_css_custom');
                if (css) css.remove();
                var overlay = document.getElementById('dark_theme_custom_overlay');
                if (overlay) overlay.remove();
                if (document && document.body) {
                    document.body.classList.remove('dark-theme-custom-active');
                    document.body.removeAttribute('data-theme-engine-custom');
                }
            })();
        ]])
        return
    end

    local mode = ((DarkThemeEngine.Settings or {}).ThemeOptions or {}).Mode or ""
    if tostring(mode):sub(1, 7) == "custom:" then
        ThemeLoadLog("Theme Engine Options closed; restoring active custom theme " .. tostring(mode))
        DarkThemeEngine.InjectCustomTheme(tostring(mode):sub(8))
    end
end

function DarkThemeEngine.ApplyTheme(mode)
    ThemeLoadLog("ApplyTheme(" .. tostring(mode or "") .. ")")

    DarkThemeEngine.RemoveAllCSS()

    if mode == "dark" then
        DarkThemeEngine._CustomLoadingCSS = nil
        RestoreFullTemplates()
        DarkThemeEngine.InjectDarkCSS()
    elseif mode == "light" then
        DarkThemeEngine._CustomLoadingCSS = nil
        RestoreFullTemplates()
        DarkThemeEngine.InjectLightCSS()
    elseif tostring(mode or ""):sub(1, 7) == "custom:" then
        if not DarkThemeEngine.InjectCustomTheme(tostring(mode):sub(8)) then
            ThemeLoadWarn("ApplyTheme fallback: custom theme failed, injecting Light CSS")
            DarkThemeEngine.InjectLightCSS()
        end
    end

    if DarkThemeCSS and DarkThemeCSS.AlwaysOn and tostring(mode or ""):sub(1, 7) ~= "custom:" then
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


    if DarkThemeEngine.VguiTheme and DarkThemeEngine.VguiTheme.OnThemeChanged then
        DarkThemeEngine.VguiTheme.OnThemeChanged(tostring(mode or "dark"))
    end
end

function DarkThemeEngine_SetMode(mode)
    mode = tostring(mode or "")
    if mode ~= "dark" and mode ~= "light" and mode:sub(1, 7) ~= "custom:" then
        ThemeLoadWarn("Rejected invalid mode: " .. mode)
        return
    end
    ThemeLoadLog("SetMode(" .. mode .. ")")

    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.Settings.ThemeOptions.Mode = mode
    if mode:sub(1, 7) == "custom:" then
        DarkThemeEngine.Settings.ThemeOptions.CustomThemeFolder = SafeCustomThemeFolder(mode:sub(8))
    else
        DarkThemeEngine.Settings.ThemeOptions.CustomThemeFolder = nil
    end

    if DarkThemeEngine.SaveSettings then
        DarkThemeEngine.SaveSettings()
    else
        file.Write(DATA_FILE, util.TableToJSON(DarkThemeEngine.Settings, true))
    end

    if mode:sub(1, 7) == "custom:" and not DarkThemeEngine.InjectCustomTheme(mode:sub(8)) then
        ThemeLoadWarn("SetMode cancelled custom theme and reverted to light: " .. mode)
        DarkThemeEngine.Settings.ThemeOptions.Mode = "light"
        DarkThemeEngine.Settings.ThemeOptions.CustomThemeFolder = nil
        if DarkThemeEngine.SaveSettings then
            DarkThemeEngine.SaveSettings()
        else
            file.Write(DATA_FILE, util.TableToJSON(DarkThemeEngine.Settings, true))
        end
        DarkThemeEngine.ApplyTheme("light")
        return
    end

    DarkThemeEngine.ApplyTheme(mode)
    DarkThemeEngine.ApplyLoadingCSS()
end

function DarkThemeEngine_ReloadSelectedTheme()
    DarkThemeEngine.Settings.ThemeOptions = DarkThemeEngine.Settings.ThemeOptions or {}
    local mode = tostring(DarkThemeEngine.Settings.ThemeOptions.Mode or "light")
    if mode ~= "dark" and mode ~= "light" and mode:sub(1, 7) ~= "custom:" then
        ThemeLoadWarn("ReloadSelectedTheme rejected invalid mode: " .. mode)
        mode = "light"
        DarkThemeEngine.Settings.ThemeOptions.Mode = mode
    end

    ThemeLoadLog("ReloadSelectedTheme(" .. mode .. ")")
    DarkThemeEngine._CustomLoadingCSS = nil
    DarkThemeEngine._PayloadCache = {}

    if mode:sub(1, 7) == "custom:" then
        local folder = SafeCustomThemeFolder(mode:sub(8))
        DarkThemeEngine.Settings.ThemeOptions.CustomThemeFolder = folder
        if folder == "" or not DarkThemeEngine.InjectCustomTheme(folder) then
            ThemeLoadWarn("ReloadSelectedTheme failed for custom theme; keeping current mode but refreshing library")
        end
    else
        DarkThemeEngine.ApplyTheme(mode)
    end

    DarkThemeEngine.ApplyLoadingCSS()
    if DarkThemeEngine.SendCreatedThemesToJS then
        DarkThemeEngine.SendCreatedThemesToJS()
    end
    DarkThemeEngine.CallJS([[
        if(window.DarkThemeEngine_RenderCommunityThemes) window.DarkThemeEngine_RenderCommunityThemes();
        if(window.DarkThemeEngine_UpdateUI) window.DarkThemeEngine_UpdateUI();
    ]])
end

function DarkThemeEngine.SendCreatedThemesToJS()
    local out = {}
    local added = {}

    local function AddTheme(title, folder, path, kind)
        if not folder or folder == "" or added[folder] then return end
        added[folder] = true
        table.insert(out, {
            name = title,
            folder = folder,
            path = path,
            kind = kind or "created"
        })
    end

    local _, dirs = file.Find("theme_engine_created_addons/*", "DATA")
    dirs = dirs or {}
    for _, folder in ipairs(dirs) do
        if folder:match("^theme_engine_[%w_%-]+$") then
            local root = "theme_engine_created_addons/" .. folder
            local title = folder:gsub("^theme_engine_", ""):gsub("_", " ")
            local addonJson = file.Read(root .. "/addon.json", "DATA")
            local hasPayload = file.Exists(root .. "/data_static/theme_engine_created_addons/" .. folder .. "/theme_manifest.json.dte.txt", "DATA")
            if addonJson and addonJson ~= "" and util.JSONToTable then
                local ok, decoded = pcall(util.JSONToTable, addonJson)
                if ok and decoded and decoded.title then
                    title = tostring(decoded.title)
                end
            end
            if addonJson or hasPayload then
                AddTheme(title, folder, "garrysmod/data/" .. root .. "/", "created")
            end
        end
    end

    local _, fullDataDirs = file.Find("theme_engine_full_themes/*", "DATA")
    fullDataDirs = fullDataDirs or {}
    for _, folder in ipairs(fullDataDirs) do
        if folder:match("^theme_engine_[%w_%-]+$") then
            local root = "theme_engine_full_themes/" .. folder
            local payloadRoot = root .. "/data_static/theme_engine_full_themes/" .. folder
            local title = folder:gsub("^theme_engine_", ""):gsub("_", " ")
            local hasPayload = file.Exists(payloadRoot .. "/theme_manifest.json.dte.txt", "DATA")
                or file.Exists(payloadRoot .. "/main_menu.css.dte.txt", "DATA")
            if hasPayload then
                AddTheme(title, folder, "garrysmod/data/" .. root .. "/", "full")
            end
        end
    end

    local _, addonDirs = file.Find("data_static/theme_engine_created_addons/*", "GAME")
    addonDirs = addonDirs or {}
    for _, folder in ipairs(addonDirs) do
        if folder:match("^theme_engine_[%w_%-]+$") then
            local root = "data_static/theme_engine_created_addons/" .. folder
            local hasPayload = file.Exists(root .. "/theme_manifest.json.dte.txt", "GAME")
                or file.Exists(root .. "/main_menu.css.dte.txt", "GAME")
            if hasPayload then
                local title = folder:gsub("^theme_engine_", ""):gsub("_", " ")
                AddTheme(title, folder, "mounted addon data_static/" .. root .. "/", "created")
            end
        end
    end

    local _, fullAddonDirs = file.Find("data_static/theme_engine_full_themes/*", "GAME")
    fullAddonDirs = fullAddonDirs or {}
    for _, folder in ipairs(fullAddonDirs) do
        if folder:match("^theme_engine_[%w_%-]+$") then
            local root = "data_static/theme_engine_full_themes/" .. folder
            local hasPayload = file.Exists(root .. "/theme_manifest.json.dte.txt", "GAME")
                or file.Exists(root .. "/main_menu.css.dte.txt", "GAME")
            if hasPayload then
                local title = folder:gsub("^theme_engine_", ""):gsub("_", " ")
                local manifest = ReadCustomThemePayload(folder, "theme_manifest.json")
                if manifest and util.JSONToTable then
                    local ok, decoded = pcall(util.JSONToTable, manifest)
                    if ok and decoded and decoded.name then title = tostring(decoded.name) end
                end
                AddTheme(title, folder, "mounted addon data_static/" .. root .. "/", "full")
            end
        end
    end

    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_SetCreatedThemes) window.DarkThemeEngine_SetCreatedThemes(%s);",
        util.TableToJSON(out, false) or "[]"
    ))
end

local _loadingCssApplied = false

function DarkThemeEngine.ApplyLoadingCSS()
    local mode = (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "light"
    local loadingCss = nil
    if mode == "dark" then
        loadingCss = DarkThemeCSS and DarkThemeCSS.LoadingDark or nil
    elseif tostring(mode or ""):sub(1, 7) == "custom:" then
        local folder = SafeCustomThemeFolder(tostring(mode):sub(8))
        loadingCss = DarkThemeEngine._CustomLoadingCSS or ReadCustomThemePayload(folder, "loading_screen.css", true)
    else
        return
    end
    if not loadingCss or loadingCss == "" then return end
    if not IsValid(pnlLoading) then return end
    local html = pnlLoading.HTML or pnlLoading
    if not IsValid(html) then return end
    local function inject()
        if not IsValid(html) then return end
        html:QueueJavascript("document.body.classList.add('dark');document.body.classList.add('dark-theme-custom-loading');")
        html:QueueJavascript(string.format([[
            (function(){
                var e=document.getElementById('dt_loading_css');
                if(e)e.remove();
                var s=document.createElement('style');
                s.id='dt_loading_css';
                s.textContent="%s";
                document.head.appendChild(s);
            })();
        ]], string.JavascriptSafe(loadingCss)))
    end
    if html.IsLoading and html:IsLoading() then
        timer.Simple(0.3, inject)
    else
        inject()
    end
end

timer.Create("DarkTheme_LoadingWatch", 0.5, 0, function()
    if IsInLoading() then
        if not _loadingCssApplied then
            _loadingCssApplied = true
            DarkThemeEngine.ApplyLoadingCSS()
        end
    else
        _loadingCssApplied = false
    end
end)
