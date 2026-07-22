DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}
DarkThemeEngine._UI.JS = [==[
window.DarkThemeEngine_Icon = function(name, extraClass) {
    name = String(name || 'image').replace(/[^a-z0-9_-]/gi, '').toLowerCase();
    var extra = extraClass ? (' ' + String(extraClass).replace(/[^a-z0-9_ -]/gi, '')) : '';
    return '<span class="dt-ico dt-ico-' + name + extra + '" aria-hidden="true"></span>';
};
window.DarkThemeEngine_IconBox = function(name, size, warm, id) {
    size = Math.max(24, Math.min(120, parseInt(size || 54, 10) || 54));
    var idAttr = id ? (' id="' + String(id).replace(/"/g, '&quot;') + '"') : '';
    var warmClass = warm ? ' is-warm' : '';
    return '<div' + idAttr + ' class="dt-icon-box' + warmClass + '" style="width:' + size + 'px;height:' + size + 'px;border-radius:4px;flex-shrink:0;min-width:' + size + 'px;">' + window.DarkThemeEngine_Icon(name) + '</div>';
};
window.DarkThemeEngine_PulseIcon = function(root) {
    if (!root || !root.querySelector) return;
    var icon = root.querySelector('.dt-ico');
    if (!icon) return;
    icon.classList.remove('dt-ico-pulse');
    void icon.offsetWidth;
    icon.classList.add('dt-ico-pulse');
};
window.DarkThemeEngine_SwitchTab = function(tabName, btnEl) {
    var tabs = document.querySelectorAll('#theme_options_page .theme-tab');
    for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('active');
    var contents = document.querySelectorAll('#theme_options_page .tab-content');
    for (var i = 0; i < contents.length; i++) contents[i].classList.remove('active');
    if (btnEl) btnEl.classList.add('active');
    var content = document.getElementById('tab_' + tabName);
    if (content) content.classList.add('active');
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
    if (tabName === 'backgrounds') {
        if (window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine_SetThemeBackgroundTabOpen(true)');
        if (window._DarkTheme_BgDirty || !window._DarkTheme_Backgrounds || window._DarkTheme_Backgrounds.length === 0) { window._DarkTheme_BgDirty = false; DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }
        else if (window.DarkThemeEngine_RenderBackgroundsUI) { window.DarkThemeEngine_RenderBackgroundsUI(); }
    } else if (window.DarkThemeEngine_LuaCall) {
        window.DarkThemeEngine_LuaCall('DarkThemeEngine_SetThemeBackgroundTabOpen(false)');
    }
    if (tabName === 'music') {
        if (window._DarkTheme_MusicDirty) { window._DarkTheme_MusicDirty = false; DarkThemeEngine_LuaCall('DarkThemeEngine.SendMusicToJS()'); }
        else if (window.DarkThemeEngine_RenderMusicUI) { window.DarkThemeEngine_RenderMusicUI(); }
        if (window.DarkThemeEngine_RefreshPortalMusicPlayer) setTimeout(window.DarkThemeEngine_RefreshPortalMusicPlayer, 60);
    }
    if (tabName === 'main' && !window._DT_CreatedThemesRequested) {
        window._DT_CreatedThemesRequested = true;
        DarkThemeEngine_LuaCall('DarkThemeEngine.SendCreatedThemesToJS()');
    }
    if (tabName === 'misc') {
        DarkThemeEngine_LuaCall('DarkThemeEngine.SendMenuSoundPacksToJS()');
        if (window._DarkTheme_MiscDirty) {
            window._DarkTheme_MiscDirty = false;
            DarkThemeEngine_LuaCall('DarkThemeEngine.SendSpawnmenuToJS()');
        } else if (window._DT_SpawnmenuSkins && window._DT_SpawnmenuSkins.length > 0) {
            var _active = window._DT_LastSpawnmenuActive || 'default';
            window.DarkThemeEngine_RenderSpawnmenuUI(window._DT_SpawnmenuSkins, _active);
        } else {
            DarkThemeEngine_LuaCall('DarkThemeEngine.SendSpawnmenuToJS()');
        }
    }
};
window.DarkThemeEngine_UISelect = function(mode) {
    window._DarkThemeEngine_SavedMode = mode;
    window.DarkThemeEngine_UpdateUI();
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetMode('" + window.DarkThemeEngine_SafePathForLua(mode).slice(0, 96) + "')");
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_OnThemeApplyFailed = function(msg) {
    window._DarkThemeEngine_SavedMode = 'light';
    window.DarkThemeEngine_UpdateUI();
    if (window.console && console.warn) console.warn('[ThemeEngine]', msg || 'Theme could not be applied, reverted to Light Theme.');
};
window.DarkThemeEngine_OnThemeApplyOK = function(folder) {
    window._DT_LastAppliedCustomTheme = folder || '';
};
window.DarkThemeEngine_UpdateUI = function() {
    var mode = window._DarkThemeEngine_SavedMode || 'light';
    var items = { light: document.getElementById('theme_item_light'), dark: document.getElementById('theme_item_dark') };
    for (var k in items) { if (items[k]) { if (k === mode) items[k].classList.add('active-theme'); else items[k].classList.remove('active-theme'); } }
    if (window.DarkThemeEngine_RenderCommunityThemes) window.DarkThemeEngine_RenderCommunityThemes();
    if (!window._DT_CreatedThemesRequested) {
        window._DT_CreatedThemesRequested = true;
        DarkThemeEngine_LuaCall('DarkThemeEngine.SendCreatedThemesToJS()');
    }
};
window.DarkThemeEngine_LuaCall = function(code) {
    if (typeof lua === 'undefined' || !lua.Run) return;
    code = String(code || '');

    var dq = '"(?:[^"\\\\]|\\\\.){0,260}"';
    var sq = "'(?:[^'\\\\]|\\\\.){0,260}'";
    var safePatterns = [
        /^DarkThemeEngine\.SendBackgroundsToJS\(\)$/,
        /^DarkThemeEngine\.SendMusicToJS\(\)$/,
        /^DarkThemeEngine\.SendGladosLinesToJS\(\)$/,
        /^DarkThemeEngine\.SendCreatedThemesToJS\(\)$/,
        /^DarkThemeEngine\.SendSpawnmenuToJS\(\)$/,
        /^DarkThemeEngine\.SendMenuSoundPacksToJS\(\)$/,
        /^DarkThemeEngine\.InvalidateMenuSoundCache\(\); DarkThemeEngine\.SendMenuSoundPacksToJS\(\)$/,
        /^DarkThemeEngine\.InvalidateSpawnmenuCache\(\); DarkThemeEngine\.SendSpawnmenuToJS\(\)$/,
        /^DarkThemeEngine_SetThemePageOpen\((true|false)\)$/,
        /^DarkThemeEngine_SetThemeBackgroundTabOpen\((true|false)\)$/,
        /^DarkThemeEngine_SetCustomThemeSuspended\((true|false)\)$/,
        /^DarkTheme_PlayStartupMusic\(\)$/,
        /^DarkThemeEngine_SetMode\('(light|dark|custom:theme_engine_[A-Za-z0-9_-]{1,64})'\)$/,
        /^DarkThemeEngine_ReloadSelectedTheme\(\)$/,
        /^DarkThemeEngine_SetBGOption\('(BG_Static|BG_NoZoom|BG_NoFade)', (true|false)\)$/,
        /^DarkThemeEngine_SetBGOption\('BG_SwapInterval', [0-9]{1,3}\)$/,
        /^DarkThemeEngine_SetBGOption\('BG_Overlay', (0(\.[0-9]+)?|1(\.0+)?)\)$/,
        /^DarkThemeEngine_SetMusicOption\('(EnableMusic|Music_PlaylistMode|Music_Shuffle)', (true|false)\)$/,
        /^DarkThemeEngine_SetMusicOption\('Music_Volume', (0(\.[0-9]+)?|1(\.0+)?)\)$/,
        new RegExp('^DarkThemeEngine_ToggleBackground\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_SetActiveBackground\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_DisableCategoryBackgrounds\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_EnableCategoryBackgrounds\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_ToggleMusic\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_EnableAlbum\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_DisableAlbum\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_SetCurrentMusicFromJS\\(' + sq + '\\)$'),
        new RegExp('^DarkTheme_SetSpawnmenuSkin\\(' + dq + '\\)$'),
        new RegExp('^DarkThemeEngine_SetMenuSoundPack\\(' + dq + '\\)$'),
        /^DarkThemeEngine_SetMenuSoundVolume\((0(\.[0-9]+)?|1(\.0+)?)\)$/,
        /^DarkTheme_SetFontSize\([0-9]{1,2}\)$/,
        new RegExp('^DarkTheme_SetMenuFont\\(' + dq + '\\)$'),
        new RegExp('^DarkTheme_SaveCustomBackground\\(' + dq + ',' + dq + '\\)$'),
        /^DarkTheme_SetLastSeenChangelog\('[A-Za-z0-9._ -]{0,32}'\)$/,
        /^DarkTheme_SetCakeCookie\('[0-9-]{0,16}'\)$/,
        /^if DarkTheme_FetchWorkshopIcon then DarkTheme_FetchWorkshopIcon\('[0-9]{1,20}'\) end$/,
        /^if gui and gui\.OpenURL then gui\.OpenURL\('https:\/\/steamcommunity\.com\/sharedfiles\/filedetails\/\?id=[0-9]{1,20}'\) end$/,
        /^if gui and gui\.OpenURL then gui\.OpenURL\('https:\/\/(www\.youtube\.com\/watch\?v=|youtube\.com\/watch\?v=|youtu\.be\/)[A-Za-z0-9_-]+'\) end$/
    ];

    for (var i = 0; i < safePatterns.length; i++) {
        if (safePatterns[i].test(code)) {
            lua.Run(code.replace(/%/g, '%%'));
            return;
        }
    }
    if (window.console && console.warn) console.warn('[ThemeEngine] Blocked unsafe LuaCall:', code);
};
window.DarkThemeEngine_EscapeHTML = function(str) {
    if (!str) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
};
window.DarkThemeEngine_EscapeCSSString = function(str) {
    return String(str || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/[\r\n]/g, ' ');
};
window.DarkThemeEngine_InstallWorkshopDownloadGuard = function() {
    if (window._DT_WorkshopGuardInstalled) return true;
    window._DT_WorkshopGuardAttempts = (window._DT_WorkshopGuardAttempts || 0) + 1;
    if (typeof Subscriptions === 'undefined' || !Subscriptions.prototype || typeof lua === 'undefined' || !lua.Run) {
        if (window._DT_WorkshopGuardAttempts < 80) {
            if (window._DT_WorkshopGuardRetry) clearTimeout(window._DT_WorkshopGuardRetry);
            window._DT_WorkshopGuardRetry = setTimeout(window.DarkThemeEngine_InstallWorkshopDownloadGuard, 250);
        }
        return false;
    }

    var proto = Subscriptions.prototype;
    if (typeof proto.Subscribe !== 'function' || typeof proto.Unsubscribe !== 'function' || typeof proto.ApplyChanges !== 'function') return false;
    var originalSubscribe = proto._DT_OriginalSubscribe || proto.Subscribe;
    var originalUnsubscribe = proto._DT_OriginalUnsubscribe || proto.Unsubscribe;
    var originalApplyChanges = proto._DT_OriginalApplyChanges || proto.ApplyChanges;
    proto._DT_OriginalSubscribe = originalSubscribe;
    proto._DT_OriginalUnsubscribe = originalUnsubscribe;
    proto._DT_OriginalApplyChanges = originalApplyChanges;

    window._DT_WorkshopInstalling = window._DT_WorkshopInstalling || {};
    window._DT_WorkshopGuardInstalled = true;
    if (window._DT_WorkshopGuardRetry) {
        clearTimeout(window._DT_WorkshopGuardRetry);
        window._DT_WorkshopGuardRetry = null;
    }

    var addonRouteActive = function() {
        return String(window.location.hash || '').indexOf('/addons') !== -1;
    };

    var cleanWorkshopID = function(wsid) {
        wsid = String(wsid || '').replace(/[^\d]/g, '');
        if (!wsid || wsid.length > 20 || wsid === '0') return '';
        return wsid;
    };

    proto.Subscribe = function(wsid) {
        var id = cleanWorkshopID(wsid);
        if (id && addonRouteActive()) {
            window._DT_WorkshopInstalling[id] = { status: 'subscribed', at: Date.now(), message: 'Subscribed; waiting for download' };
            lua.Run('DarkThemeEngine_WorkshopSubscribe(%s)', id);
            return;
        }
        return originalSubscribe.call(this, wsid);
    };

    proto.Unsubscribe = function(wsid) {
        var id = cleanWorkshopID(wsid);
        if (id && addonRouteActive()) {
            delete window._DT_WorkshopInstalling[id];
            lua.Run('DarkThemeEngine_WorkshopUnsubscribe(%s)', id);
            return;
        }
        return originalUnsubscribe.call(this, wsid);
    };

    proto.ApplyChanges = function() {
        if (addonRouteActive()) {
            lua.Run('DarkThemeEngine_WorkshopApplyAddons()');
            return;
        }
        return originalApplyChanges.call(this);
    };

    window.DarkThemeEngine_OnWorkshopInstallStatus = function(wsid, status, message) {
        wsid = cleanWorkshopID(wsid);
        if (!wsid) return;
        status = String(status || '');
        message = String(message || '');
        if (status === 'mounted' || status === 'unsubscribed') {
            delete window._DT_WorkshopInstalling[wsid];
        } else {
            window._DT_WorkshopInstalling[wsid] = { status: status, message: message, at: Date.now() };
        }
        if (window.DarkThemeEngine_WorkshopRefreshCurrentAddonView) window.DarkThemeEngine_WorkshopRefreshCurrentAddonView();
    };

    window.DarkThemeEngine_WorkshopRefreshCurrentAddonView = function() {
        try {
            if (!addonRouteActive()) return;
            if (typeof Scope !== 'undefined' && Scope && Scope.RefreshCurrentView) {
                if (window._DT_WorkshopRefreshTimer) clearTimeout(window._DT_WorkshopRefreshTimer);
                window._DT_WorkshopRefreshTimer = setTimeout(function() {
                    try {
                        Scope.RefreshCurrentView();
                        if (typeof UpdateDigest === 'function') UpdateDigest(Scope, 50);
                    } catch (e) {}
                }, 250);
            }
        } catch (e) {}
    };

    return true;
};
window._DT_MenuSoundPacks = window._DT_MenuSoundPacks || [];
window._DT_MenuSoundPackActive = window._DT_MenuSoundPackActive || 'default';
window._DT_MenuSoundVolume = window._DT_MenuSoundVolume === undefined ? 0.45 : window._DT_MenuSoundVolume;
window._DT_MenuSoundLastInput = window._DT_MenuSoundLastInput || { click: 0, hover: 0 };
window._DT_MenuSoundLastPlayed = window._DT_MenuSoundLastPlayed || {};
window._DT_MenuSoundKnown = {
    'garrysmod/ui_click.wav': 'click',
    'garrysmod/ui_return.wav': 'click',
    'ui/buttonclick.wav': 'click',
    'ui/buttonclickrelease.wav': 'click',
    'garrysmod/ui_hover.wav': 'hover'
};
window.DarkThemeEngine_NormalizeMenuSound = function(path) {
    return String(path || '').replace(/\\/g, '/').toLowerCase().replace(/^sound\//, '');
};
window.DarkThemeEngine_MenuSoundIsInteractive = function(el) {
    var selector = 'a,button,input,select,textarea,.button,.theme-tab,.theme-btn,.dt-theme-card,.dt-sound-row,.dt-font-row,[onclick],[ng-click],[href]';
    while (el && el !== document && el !== window) {
        try {
            if (el.matches && el.matches(selector)) return true;
        } catch (e) {}
        el = el.parentNode;
    }
    return false;
};
window.DarkThemeEngine_BindMenuSoundInput = function() {
    if (window._DT_MenuSoundInputBound) return;
    window._DT_MenuSoundInputBound = true;
    var markClick = function(ev) {
        if (ev && ev.isTrusted === false) return;
        if (ev && ev.target && !window.DarkThemeEngine_MenuSoundIsInteractive(ev.target)) return;
        window._DT_MenuSoundLastInput.click = Date.now();
    };
    var markHover = function(ev) {
        if (ev && ev.isTrusted === false) return;
        if (ev && ev.target && !window.DarkThemeEngine_MenuSoundIsInteractive(ev.target)) return;
        window._DT_MenuSoundLastInput.hover = Date.now();
    };
    window.addEventListener('mousedown', markClick, true);
    window.addEventListener('mouseup', markClick, true);
    window.addEventListener('click', markClick, true);
    window.addEventListener('keydown', markClick, true);
    window.addEventListener('touchstart', markClick, true);
    window.addEventListener('mouseover', markHover, true);
    window.addEventListener('mousemove', markHover, true);
};
window.DarkThemeEngine_ShouldPlayMenuSound = function(wanted, mapped) {
    var kind = window._DT_MenuSoundKnown[wanted];
    if (!kind) return true;
    var now = Date.now();
    var lastInput = window._DT_MenuSoundLastInput[kind] || 0;
    var maxAge = kind === 'hover' ? 360 : 900;
    if (now - lastInput > maxAge) return false;
    var key = wanted + '>' + (mapped || '');
    var lastPlayed = window._DT_MenuSoundLastPlayed[key] || 0;
    if (now - lastPlayed < 55) return false;
    window._DT_MenuSoundLastPlayed[key] = now;
    return true;
};
window.DarkThemeEngine_InstallMenuSoundHook = function() {
    if (window._DT_MenuSoundHooked || typeof lua === 'undefined' || !lua.PlaySound) return;
    window._DT_MenuSoundHooked = true;
    window.DarkThemeEngine_BindMenuSoundInput();
    window._DT_OriginalPlaySound = lua.PlaySound;
    lua.PlaySound = function(path) {
        var active = window._DT_MenuSoundPackActive || 'default';
        var packs = window._DT_MenuSoundPacks || [];
        var wanted = window.DarkThemeEngine_NormalizeMenuSound(path);
        for (var i = 0; i < packs.length; i++) {
            var pack = packs[i];
            if (pack && pack.id === active && pack.sounds) {
                var mapped = pack.sounds[wanted];
                if (mapped) {
                    if (!window.DarkThemeEngine_ShouldPlayMenuSound(wanted, mapped)) return;
                    if (String(mapped).indexOf('addons/') === 0 || String(mapped).indexOf('data/') === 0 || String(mapped).indexOf('theme_engine_menu_sounds/') === 0) {
                        try {
                            var audio = new Audio(encodeURI('asset://garrysmod/sound/' + mapped));
                            if (String(mapped).indexOf('addons/') === 0 || String(mapped).indexOf('data/') === 0) audio = new Audio(encodeURI('asset://garrysmod/' + mapped));
                            audio.volume = Math.max(0, Math.min(1, window._DT_MenuSoundVolume || 0.45));
                            var p = audio.play();
                            if (p && p.catch) p.catch(function(){});
                            return;
                        } catch (e) {}
                    }
                    return window._DT_OriginalPlaySound.call(lua, mapped);
                }
            }
        }
        if (!window.DarkThemeEngine_ShouldPlayMenuSound(wanted, path)) return;
        return window._DT_OriginalPlaySound.call(lua, path);
    };
};
window.SetDarkThemeMenuSoundPacks = function(packs, active) {
    window._DT_MenuSoundPacks = packs || [];
    window._DT_MenuSoundPackActive = active || 'default';
    window.DarkThemeEngine_InstallMenuSoundHook();
    if (window.DarkThemeEngine_RenderMenuSoundsUI) window.DarkThemeEngine_RenderMenuSoundsUI(window._DT_MenuSoundPacks, window._DT_MenuSoundPackActive);
};
window.DarkThemeEngine_SetMenuSoundPack = function(id) {
    window._DT_MenuSoundPackActive = id || 'default';
    DarkThemeEngine_LuaCall('DarkThemeEngine_SetMenuSoundPack("' + window.DarkThemeEngine_SafePathForLua(window._DT_MenuSoundPackActive).slice(0, 160) + '")');
    if (window.DarkThemeEngine_UpdateMenuSoundSelection) window.DarkThemeEngine_UpdateMenuSoundSelection(window._DT_MenuSoundPackActive);
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_SetMenuSoundVolume = function(value) {
    value = Math.max(0, Math.min(1, parseFloat(value) || 0));
    window._DT_MenuSoundVolume = value;
    var slider = document.getElementById('menusound_volume_slider');
    var label = document.getElementById('menusound_volume_label');
    if (slider) slider.value = Math.round(value * 100);
    if (label) label.textContent = Math.round(value * 100) + '%';
    DarkThemeEngine_LuaCall('DarkThemeEngine_SetMenuSoundVolume(' + value.toFixed(2) + ')');
};
window.DarkThemeEngine_UpdateMenuSoundSelection = function(active) {
    var rows = document.querySelectorAll('#misc_menusounds_list [data-pack-id]');
    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        var isActive = row.getAttribute('data-pack-id') === active;
        if (isActive) row.classList.add('is-active');
        else row.classList.remove('is-active');
        var badge = row.querySelector('[data-pack-active]');
        if (badge) badge.style.display = isActive ? '' : 'none';
    }
};
window.DarkThemeEngine_RenderMenuSoundsUI = function(packs, active) {
    var container = document.getElementById('misc_menusounds_list');
    if (!container) return;
    var oldScroller = container.children && container.children[1] ? container.children[1] : container.firstChild;
    var oldScroll = oldScroller ? (oldScroller.scrollTop || 0) : 0;
    packs = packs || [];
    var volumePct = Math.round((window._DT_MenuSoundVolume === undefined ? 0.45 : window._DT_MenuSoundVolume) * 100);
    var html = '<div class="dt-control-strip">'
        + '<span class="dt-control-label">Volume</span>'
        + '<input id="menusound_volume_slider" type="range" min="0" max="100" step="1" value="' + volumePct + '" oninput="DarkThemeEngine_SetMenuSoundVolume(parseInt(this.value)/100)" style="flex:1;">'
        + '<span id="menusound_volume_label" class="dt-control-value">' + volumePct + '%</span>'
        + '</div>';
    html += '<div class="dt-scrollable" style="display:flex;flex-direction:column;gap:6px;max-height:230px;overflow-y:auto;padding-right:4px;">';
    for (var i = 0; i < packs.length; i++) {
        var p = packs[i] || {};
        var isActive = (p.id === active);
        var safeId = window.DarkThemeEngine_EscapeHTML(String(p.id || 'default'));
        var count = p.id === 'default' ? (p.lockedDefault ? 'locked default' : 'engine default') : (p.detectedByTitle ? 'mounted addon' : ((p.count || 0) + ' sounds'));
        html += '<div class="dt-sound-row' + (isActive ? ' is-active' : '') + '" data-pack-id="' + safeId + '" onclick="DarkThemeEngine_SetMenuSoundPack(&quot;' + safeId + '&quot;)">';
        var wsidStr = String(p.wsid || '');
        var imgUrl = (window._DarkTheme_WsidImages && window._DarkTheme_WsidImages[wsidStr]) ? window._DarkTheme_WsidImages[wsidStr] : '';
        if (p.id === 'default') html += '<img class="dt-sound-thumb" src="../materials/theme_engine/gmod_background.png" />';
        else if (imgUrl) html += '<img class="dt-sound-thumb" src="' + imgUrl + '" />';
        else html += '<div class="dt-sound-thumb">SFX</div>';
        html += '<div style="flex:1;min-width:0;"><div data-pack-title class="dt-sound-title">' + window.DarkThemeEngine_EscapeHTML(p.name || p.id || 'Unknown') + '</div>';
        html += '<div style="font-size:0.78rem;color:#64748b;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + window.DarkThemeEngine_EscapeHTML(p.addon || '') + ' - ' + count + '</div></div>';
        html += '<span data-pack-active class="dt-active-pill" style="display:' + (isActive ? '' : 'none') + ';">Active</span>';
        html += '</div>';
    }
    html += '</div>';
    html += '<div style="margin-top:10px;font-size:0.78rem;color:#64748b;">Workshop packs are detected from mounted addons. If several packs replace the same GMod paths, GMod mount order can still decide which virtual sound is audible. Local fallback only scans <code style="color:#94a3b8;">addons/my_pack/sound/</code>.</div>';
    container.innerHTML = html;
    var newScroller = container.children && container.children[1];
    if (newScroller) newScroller.scrollTop = oldScroll;
};
window.DarkThemeEngine_InitSettingsUI = function(opts) {
    if (!opts) return;
    if (opts.Mode) {
        window._DarkThemeEngine_SavedMode = opts.Mode;
        window.DarkThemeEngine_UpdateUI();
    }
    var bgStatic = document.getElementById('opt_bg_static');
    var bgNoZoom = document.getElementById('opt_bg_nozoom');
    var bgNoFade = document.getElementById('opt_bg_nofade');
    if (bgStatic) { bgStatic.checked = !!opts.BG_Static; DarkThemeEngine_UpdateFadeOptions(bgStatic.checked); }
    if (bgNoZoom) bgNoZoom.checked = !!opts.BG_NoZoom;
    if (bgNoFade) bgNoFade.checked = !!opts.BG_NoFade;
    if (opts.BG_SwapInterval !== undefined) {
        var intSlider = document.getElementById('opt_bg_interval');
        var intLbl = document.getElementById('opt_bg_interval_label');
        if (intSlider) intSlider.value = opts.BG_SwapInterval;
        if (intLbl) intLbl.textContent = opts.BG_SwapInterval + 's';
    }
    if (opts.BG_Overlay !== undefined) {
        var ovSlider = document.getElementById('opt_bg_overlay');
        var ovLbl = document.getElementById('opt_bg_overlay_label');
        var ovPct = Math.round(opts.BG_Overlay * 100);
        if (ovSlider) ovSlider.value = ovPct;
        if (ovLbl) ovLbl.textContent = ovPct + '%';
    }
    var musicEnable = document.getElementById('opt_music_enable');
    var musicPlaylist = document.getElementById('opt_music_playlist');
    var musicShuffle = document.getElementById('opt_music_shuffle');
    if (musicEnable) musicEnable.checked = !!opts.EnableMusic;
    if (musicPlaylist) musicPlaylist.checked = !!opts.Music_PlaylistMode;
    if (musicShuffle) musicShuffle.checked = !!opts.Music_Shuffle;
    if (opts.Music_Volume !== undefined) {
        var pct = Math.round(opts.Music_Volume * 100);
        var slider = document.getElementById('music_volume_slider');
        var lbl = document.getElementById('music_volume_label');
        if (slider) slider.value = pct;
        if (lbl) lbl.textContent = pct + '%';
        window.DarkTheme_MusicVolume = opts.Music_Volume;
    }
    if (opts.MenuFont !== undefined) {
        if (window.DarkThemeEngine_ApplyMenuFont) window.DarkThemeEngine_ApplyMenuFont(opts.MenuFont || '');
        if (window.DarkThemeEngine_SetFontLabel) window.DarkThemeEngine_SetFontLabel(opts.MenuFont || '');
    }
    if (opts.MenuFontSize && opts.MenuFontSize > 0) {
        if (window.DarkThemeEngine_SetFontSize) window.DarkThemeEngine_SetFontSize(opts.MenuFontSize);
    }
    if (opts.MenuSoundVolume !== undefined) {
        window._DT_MenuSoundVolume = Math.max(0, Math.min(1, parseFloat(opts.MenuSoundVolume) || 0));
        var msSlider = document.getElementById('menusound_volume_slider');
        var msLabel = document.getElementById('menusound_volume_label');
        if (msSlider) msSlider.value = Math.round(window._DT_MenuSoundVolume * 100);
        if (msLabel) msLabel.textContent = Math.round(window._DT_MenuSoundVolume * 100) + '%';
    }
    if (window.DarkThemeEngine_UpdateMusicFadeOptions) window.DarkThemeEngine_UpdateMusicFadeOptions();
};
window.DarkThemeEngine_TogglePause = function() {
    var node = window.DarkTheme_AudioNode;
    if (!node) return;
    var btn = document.getElementById('music_btn_pause');
    var player = document.getElementById('music_portal_player');
    if (node.paused) {
        var p = node.play();
        if (p && p.catch) p.catch(function(){});
        if (btn) btn.innerHTML = window.DarkThemeEngine_Icon('pause');
        if (player) player.classList.add('playing');
        if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('play', true);
    } else {
        node.pause();
        if (btn) btn.innerHTML = window.DarkThemeEngine_Icon('play');
        if (player) player.classList.remove('playing');
        if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('pause', true);
    }
};
window.DarkThemeEngine_SkipTrack = function() {
    if (window.DarkTheme_PlayNextTrack) window.DarkTheme_PlayNextTrack(true);
};
window._DarkTheme_Backgrounds = [];
window._DarkTheme_DisabledBgs = {};
window._DarkTheme_ActiveBg = 'None';
window._DarkTheme_PreviewBgPath = window._DarkTheme_PreviewBgPath || null;
window._DarkTheme_PreviewLastSwap = window._DarkTheme_PreviewLastSwap || 0;
window._DarkTheme_PreviewTimer = window._DarkTheme_PreviewTimer || null;
window._DarkTheme_BgOptions = {};
window._DarkTheme_SelectedCategory = null;
window._DarkTheme_Categories = [];
window.SetCurrentDarkThemeBackground = function(bgPath) {
    window._DarkTheme_ActiveBg = bgPath || 'None';
    window._DarkTheme_PreviewBgPath = (bgPath && bgPath !== 'None') ? bgPath : null;
    var el = document.getElementById('bg_now_playing');
    if (el) el.textContent = 'Now Playing: ' + (bgPath && bgPath !== 'None' ? bgPath.split('/').pop() : 'None');
    if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview();
};
window.DarkThemeEngine_FindBackgroundMeta = function(path) {
    var bgs = window._DarkTheme_Backgrounds || [];
    for (var i = 0; i < bgs.length; i++) {
        if (bgs[i].path === path) return bgs[i];
    }
    return null;
};
window.DarkThemeEngine_GetBackgroundUrl = function(path, assetFallback) {
    if (!path) return '';
    path = String(path).replace(/^\/+/, '');
    if (/^(https?:|data:|asset:\/\/)/i.test(path)) return path;
    return assetFallback ? ('../' + path) : ('asset://garrysmod/' + path);
};
window.DarkThemeEngine_BackgroundImgError = function(img) {
    if (!img) return;
    var fallback = img.getAttribute('data-fallback-src');
    if (fallback && img.getAttribute('src') !== fallback) {
        img.setAttribute('src', fallback);
        if (img.parentNode && img.parentNode.style) img.parentNode.style.backgroundImage = "url('" + fallback.replace(/'/g, "\\'") + "')";
        return;
    }
    img.classList.add('dt-bg-img-error');
};
window.DarkThemeEngine_RefreshBackgroundThumbs = function(root) {
    root = root || document;
    var imgs = root.querySelectorAll ? root.querySelectorAll('.bg-card img[data-primary-src]') : [];
    for (var i = 0; i < imgs.length; i++) {
        var img = imgs[i];
        var primary = img.getAttribute('data-primary-src') || img.getAttribute('src') || '';
        if (!primary) continue;
        img.onerror = function() { window.DarkThemeEngine_BackgroundImgError(this); };
        img.classList.remove('dt-bg-img-error');
        img.setAttribute('src', primary);
        if (img.parentNode && img.parentNode.style) img.parentNode.style.backgroundImage = "url('" + primary.replace(/'/g, "\\'") + "')";
    }
};
window.DarkThemeEngine_GetEnabledBackgrounds = function() {
    var bgs = window._DarkTheme_Backgrounds || [];
    var disabled = window._DarkTheme_DisabledBgs || {};
    var out = [];
    for (var i = 0; i < bgs.length; i++) {
        if (bgs[i] && bgs[i].path && !disabled[bgs[i].path]) out.push(bgs[i]);
    }
    return out;
};
window.DarkThemeEngine_SetActivePreviewBackground = function(path, silent) {
    if (!path) return;
    var item = window.DarkThemeEngine_FindBackgroundMeta(path) || { path: path, category: 'Gmod Background' };
    window._DarkTheme_ActiveBg = item.path;
    window._DarkTheme_PreviewBgPath = item.path;
    DarkThemeEngine_LuaCall('DarkThemeEngine_SetActiveBackground("' + window.DarkThemeEngine_SafePathForLua(item.path) + '")');
    if (!window._DarkTheme_RealPreviewState && window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview();
    if (!silent && typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_PreviewStep = function(dir, silent) {
    var bgs = window.DarkThemeEngine_GetEnabledBackgrounds();
    if (!bgs.length) return;
    var current = (window._DarkTheme_ActiveBg && window._DarkTheme_ActiveBg !== 'None') ? window._DarkTheme_ActiveBg : (window._DarkTheme_PreviewBgPath || '');
    var idx = -1;
    for (var i = 0; i < bgs.length; i++) {
        if (bgs[i].path === current) { idx = i; break; }
    }
    var nextIdx = (idx + (dir < 0 ? -1 : 1) + bgs.length) % bgs.length;
    window.DarkThemeEngine_SetActivePreviewBackground(bgs[nextIdx].path, silent);
};
window.DarkThemeEngine_GetPreviewBackground = function() {
    var bgs = window.DarkThemeEngine_GetEnabledBackgrounds ? window.DarkThemeEngine_GetEnabledBackgrounds() : (window._DarkTheme_Backgrounds || []);
    var active = window._DarkTheme_ActiveBg;
    var previewPath = (active && active !== 'None') ? active : window._DarkTheme_PreviewBgPath;
    if (previewPath) {
        var previewItem = window.DarkThemeEngine_FindBackgroundMeta(previewPath);
        if (previewItem) return previewItem;
    }
    for (var i = 0; i < bgs.length; i++) {
        if (bgs[i] && bgs[i].path && !window._DarkTheme_DisabledBgs[bgs[i].path]) {
            window._DarkTheme_PreviewBgPath = bgs[i].path;
            return bgs[i];
        }
    }
    return null;
};
window.DarkThemeEngine_AdvanceBackgroundPreview = function(force) {
    if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview(true);
};
window.DarkThemeEngine_StartBackgroundPreviewTimer = function() {
    if (window._DarkTheme_PreviewTimer) {
        clearInterval(window._DarkTheme_PreviewTimer);
        window._DarkTheme_PreviewTimer = null;
    }
    // Auto-advance is handled by the real Lua background system while Theme Engine is open.
};
window.DarkThemeEngine_PulseBackgroundPreview = function() {
    var box = document.getElementById('dt_bg_live_preview');
    if (!box) return;
    box.classList.remove('bg-option-pulse');
    void box.offsetWidth;
    box.classList.add('bg-option-pulse');
};
window.DarkThemeEngine_AdjustPreviewFit = function(img, box) {
    if (!img || !box || !img.naturalWidth || !img.naturalHeight) return;
    var boxRatio = Math.max(0.2, box.clientWidth / Math.max(1, box.clientHeight));
    var imgRatio = img.naturalWidth / Math.max(1, img.naturalHeight);
    if (Math.abs(Math.log(imgRatio / boxRatio)) > 0.55) box.classList.add('dt-preview-contain');
    else box.classList.remove('dt-preview-contain');
};
window.DarkThemeEngine_ResetPreviewMotion = function() {
    var img = document.getElementById('dt_bg_preview_img');
    if (!img || img.style.display === 'none') return;
    img.classList.add('dt-preview-reset');
    if (window._DarkTheme_PreviewResetTimer) clearTimeout(window._DarkTheme_PreviewResetTimer);
    window._DarkTheme_PreviewResetTimer = setTimeout(function() {
        if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview(true);
    }, 430);
};
window.DarkThemeEngine_UpdateBackgroundPreview = function(skipReset) {
    var item = window.DarkThemeEngine_GetPreviewBackground ? window.DarkThemeEngine_GetPreviewBackground() : null;
    var box = document.getElementById('dt_bg_live_preview');
    var img = document.getElementById('dt_bg_preview_img');
    var prev = document.getElementById('dt_bg_preview_prev_img');
    var empty = document.getElementById('dt_bg_preview_empty');
    var title = document.getElementById('dt_bg_preview_title');
    var sub = document.getElementById('dt_bg_preview_sub');
    var count = document.getElementById('dt_bg_preview_count');
    var dim = document.getElementById('dt_bg_preview_dim');
    var opts = window._DarkTheme_BgOptions || {};
    var total = (window._DarkTheme_Backgrounds || []).length;
    if (count) count.textContent = total + (total === 1 ? ' item' : ' items');
    if (!img || !empty || !title || !sub) return;
    var animClass = '';
    var noFade = !!opts.BG_NoFade;
    if (box) {
        if (noFade) box.classList.add('no-fade');
        else box.classList.remove('no-fade');
        if (opts.BG_NoZoom) box.classList.add('bg-no-zoom');
        else box.classList.remove('bg-no-zoom');
        if (opts.BG_Static) box.classList.add('bg-static');
        else box.classList.remove('bg-static');
        box.style.setProperty('--dt-bg-preview-duration', Math.max(5, Math.min(300, parseFloat(opts.BG_SwapInterval || 20) || 20)) + 's');
    }
    if (dim) dim.style.opacity = Math.max(0, Math.min(0.7, parseFloat(opts.BG_Overlay || 0) || 0));
    if (!item || !item.path) {
        img.style.display = 'none';
        if (prev) prev.style.display = 'none';
        empty.style.display = '';
        title.textContent = 'No background selected';
        sub.textContent = 'Theme Engine preview';
        return;
    }
    var oldPath = img.getAttribute('data-bg-path') || '';
    var oldSrc = img.getAttribute('src') || img.src || '';
    var changed = oldPath !== item.path;
    if (changed && oldPath && oldSrc && prev && !noFade) {
        prev.src = oldSrc;
        prev.className = 'dt-preview-outgoing ' + (img.getAttribute('data-anim-class') || '');
        prev.style.display = '';
        prev.style.opacity = '1';
        setTimeout(function() {
            prev.style.opacity = '0';
        }, 20);
        if (window._DarkTheme_PreviewFadeTimer) clearTimeout(window._DarkTheme_PreviewFadeTimer);
        window._DarkTheme_PreviewFadeTimer = setTimeout(function() {
            if (prev) {
                prev.style.display = 'none';
                prev.removeAttribute('src');
                prev.style.opacity = '0';
            }
        }, 980);
    } else if (prev) {
        prev.style.display = 'none';
        prev.style.opacity = '0';
    }
    var nextSrc = window.DarkThemeEngine_GetBackgroundUrl(item.path, false);
    img.onerror = function() { window.DarkThemeEngine_BackgroundImgError(img); };
    img.onload = null;
    img.setAttribute('data-fallback-src', window.DarkThemeEngine_GetBackgroundUrl(item.path, true));
    if (changed || img.getAttribute('src') !== nextSrc) img.src = nextSrc;
    img.setAttribute('data-bg-path', item.path);
    img.setAttribute('data-anim-class', animClass);
    img.style.display = '';
    if (skipReset) img.classList.remove('dt-preview-reset');
    var nextClassName = 'dt-preview-current ' + animClass;
    if (img.className !== nextClassName) img.className = nextClassName;
    empty.style.display = 'none';
    title.textContent = item.path.split('/').pop();
    sub.textContent = item.category || 'Gmod Background';
    if (window.DarkThemeEngine_StartBackgroundPreviewTimer) window.DarkThemeEngine_StartBackgroundPreviewTimer();
};
window.SetDarkThemeBackgroundPreviewState = function(state) {
    state = state || {};
    window._DarkTheme_RealPreviewState = state;
    var box = document.getElementById('dt_bg_live_preview');
    var current = document.getElementById('dt_bg_preview_img');
    var outgoing = document.getElementById('dt_bg_preview_prev_img');
    var empty = document.getElementById('dt_bg_preview_empty');
    var dim = document.getElementById('dt_bg_preview_dim');
    var title = document.getElementById('dt_bg_preview_title');
    var sub = document.getElementById('dt_bg_preview_sub');
    if (!box || !current || !outgoing || !empty) return;

    box.classList.add('dt-real-background');
    box.classList.remove('dt-preview-contain');
    box.classList.toggle('no-fade', !!state.noFade);
    box.classList.toggle('bg-no-zoom', !!state.noZoom);
    box.classList.toggle('bg-static', !!state.isStatic);
    if (dim) dim.style.opacity = Math.max(0, Math.min(0.7, parseFloat(state.overlay || 0) || 0));

    function commitFrameSource(img, path, primarySrc, loadedSrc) {
        if (img._dtPendingBgPath !== path) return;
        img._dtPendingBgPath = '';
        img._dtPendingBgProbe = null;
        img.setAttribute('data-bg-path', path);
        img.setAttribute('data-fallback-src', window.DarkThemeEngine_GetBackgroundUrl(path, true));
        img.onerror = function() { window.DarkThemeEngine_BackgroundImgError(img); };
        img.src = loadedSrc || primarySrc;
    }

    function stageFrameSource(img, path) {
        var primarySrc = window.DarkThemeEngine_GetBackgroundUrl(path, false);
        if (img.getAttribute('data-bg-path') === path) return;
        if (img._dtPendingBgPath === path) return;

        img._dtPendingBgPath = path;
        var probe = new Image();
        img._dtPendingBgProbe = probe;
        probe.onload = function() { commitFrameSource(img, path, primarySrc, primarySrc); };
        probe.onerror = function() {
            if (img._dtPendingBgPath !== path) return;
            var fallbackSrc = window.DarkThemeEngine_GetBackgroundUrl(path, true);
            var fallbackProbe = new Image();
            img._dtPendingBgProbe = fallbackProbe;
            fallbackProbe.onload = function() { commitFrameSource(img, path, primarySrc, fallbackSrc); };
            fallbackProbe.onerror = function() {
                if (img._dtPendingBgPath !== path) return;
                img._dtPendingBgPath = '';
                img._dtPendingBgProbe = null;
                window.DarkThemeEngine_BackgroundImgError(img);
            };
            fallbackProbe.src = fallbackSrc;
        };
        probe.src = primarySrc;
    }

    function applyFrame(img, frame, layer) {
        if (!frame || !frame.path || (layer === 'outgoing' && state.noFade)) {
            img.style.display = 'none';
            img.style.opacity = '0';
            return;
        }
        var path = String(frame.path);
        stageFrameSource(img, path);

        var panelRatio = Math.max(0.2, box.clientWidth / Math.max(1, box.clientHeight));
        var imageRatio = Math.max(0.05, parseFloat(frame.ratio || 1) || 1);
        var baseSize = Math.max(0.01, parseFloat(frame.baseSize || 1) || 1);
        var motion = Math.max(0.01, (parseFloat(frame.size || baseSize) || baseSize) / baseSize);
        var width;
        var height;
        if (imageRatio >= panelRatio) {
            height = 102 * motion;
            width = height * imageRatio / panelRatio;
        } else {
            width = 102 * motion;
            height = width * panelRatio / imageRatio;
        }

        img.className = layer === 'outgoing' ? 'dt-preview-outgoing' : 'dt-preview-current';
        img.style.display = '';
        img.style.left = '50%';
        img.style.top = '50%';
        img.style.width = width + '%';
        img.style.height = height + '%';
        img.style.opacity = String(Math.max(0, Math.min(1, (parseFloat(frame.alpha || 0) || 0) / 255)));
        img.style.transform = 'translate3d(-50%,-50%,0) rotate(' + (parseFloat(frame.angle || 0) || 0) + 'deg)';
    }

    var currentPath = current.getAttribute('data-bg-path') || '';
    var nextPath = state.active && state.active.path ? String(state.active.path) : '';
    var outgoingPath = state.outgoing && state.outgoing.path ? String(state.outgoing.path) : '';
    if (currentPath && nextPath && currentPath !== nextPath && outgoingPath === currentPath && current.getAttribute('src')) {
        outgoing._dtPendingBgPath = '';
        outgoing._dtPendingBgProbe = null;
        outgoing.setAttribute('data-bg-path', currentPath);
        outgoing.setAttribute('data-fallback-src', current.getAttribute('data-fallback-src') || '');
        outgoing.src = current.getAttribute('src');
    }

    applyFrame(current, state.active, 'active');
    applyFrame(outgoing, state.outgoing, 'outgoing');
    if (state.active && state.active.path) {
        var meta = window.DarkThemeEngine_FindBackgroundMeta(state.active.path) || {};
        window._DarkTheme_ActiveBg = state.active.path;
        window._DarkTheme_PreviewBgPath = state.active.path;
        empty.style.display = 'none';
        if (title) title.textContent = state.active.path.split('/').pop();
        if (sub) sub.textContent = meta.category || 'Gmod Background';
    } else {
        empty.style.display = '';
        if (title) title.textContent = 'No background selected';
        if (sub) sub.textContent = 'Theme Engine preview';
    }

    if (!window._DarkTheme_RealPreviewResizeHooked) {
        window._DarkTheme_RealPreviewResizeHooked = true;
        window.addEventListener('resize', function() {
            if (window._DarkTheme_RealPreviewState) window.SetDarkThemeBackgroundPreviewState(window._DarkTheme_RealPreviewState);
        });
    }
};
window.DarkThemeEngine_PreviewInPanel = function(path) {
    return;
};
window._DarkTheme_GladosLines = window._DarkTheme_GladosLines || [];
window._DarkTheme_GladosLastPlay = 0;
window._DarkTheme_GladosTimer = null;
window._DarkTheme_GladosAudio = null;
window.SetDarkThemeGladosLines = function(lines) {
    window._DarkTheme_GladosLines = (lines && lines.length) ? lines : [];
    if (window._DarkTheme_GladosLines.length > 0) window.DarkThemeEngine_StartGladosAmbient();
};
window.DarkThemeEngine_PlayGladosLine = function(force) {
    if (window._DT_OverlayWorkPaused) return;
    var lines = window._DarkTheme_GladosLines || [];
    if (lines.length === 0) return;
    if (String(window.location.hash || '').indexOf('/theme') === -1) return;
    var now = Date.now();
    if (!force && now - (window._DarkTheme_GladosLastPlay || 0) < 180000) return;
    if (!force && Math.random() > 0.035) return;
    if (window._DarkTheme_GladosAudio && !window._DarkTheme_GladosAudio.paused) return;
    var item = lines[Math.floor(Math.random() * lines.length)];
    if (!item || !item.path) return;
    var audio = new Audio('../' + item.path);
    audio.volume = 0.42;
    window._DarkTheme_GladosAudio = audio;
    window._DarkTheme_GladosLastPlay = now;
    var p = audio.play();
    if (p && p.catch) p.catch(function(){});
};
window.DarkThemeEngine_StartGladosAmbient = function() {
    if (window._DarkTheme_GladosTimer) return;
    window._DarkTheme_GladosTimer = setInterval(function() {
        window.DarkThemeEngine_PlayGladosLine(false);
    }, 30000);
};
window._DarkTheme_WsidImages = window._DarkTheme_WsidImages || {};
window._DarkTheme_WsidFetched = window._DarkTheme_WsidFetched || {};
window.SetDarkThemeAddonImage = function(wsid, url) {
    if (url && url.startsWith('../cache/')) url = 'asset://garrysmod/' + url.substring(3);
    window._DarkTheme_WsidImages[String(wsid)] = url;
    for (var i = 0; i < window._DarkTheme_Categories.length; i++) {
        if (String(window._DarkTheme_Categories[i].wsid) === String(wsid)) {
            window._DarkTheme_Categories[i].imageUrl = url;
            break;
        }
    }
    var imgEl = document.getElementById('cat_icon_' + wsid);
    if (imgEl) {
        imgEl.src = url;
        imgEl.style.display = '';
    }
    var placeholderEl = document.getElementById('cat_placeholder_' + wsid);
    if (placeholderEl) placeholderEl.style.display = 'none';
    var spawnImg = document.getElementById('spawn_icon_' + wsid);
    var spawnPh  = document.getElementById('spawn_ph_' + wsid);
    if (spawnImg) { spawnImg.src = url; spawnImg.style.display = ''; }
    if (spawnPh)  spawnPh.style.display = 'none';
};
window.DarkThemeEngine_SetBgOpt = function(key, value) {
    window._DarkTheme_BgOptions = window._DarkTheme_BgOptions || {};
    window._DarkTheme_BgOptions[key] = value;
    var luaVal = (typeof value === 'boolean') ? (value ? 'true' : 'false') : value;
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetBGOption('" + key + "', " + luaVal + ")");
    if (window._DarkTheme_RealPreviewState && window.SetDarkThemeBackgroundPreviewState) {
        if (key === 'BG_NoZoom') window._DarkTheme_RealPreviewState.noZoom = !!value;
        if (key === 'BG_NoFade') window._DarkTheme_RealPreviewState.noFade = !!value;
        if (key === 'BG_Static') window._DarkTheme_RealPreviewState.isStatic = !!value;
        if (key === 'BG_Overlay') window._DarkTheme_RealPreviewState.overlay = parseFloat(value || 0) || 0;
        window.SetDarkThemeBackgroundPreviewState(window._DarkTheme_RealPreviewState);
    } else if (window.DarkThemeEngine_UpdateBackgroundPreview) {
        window.DarkThemeEngine_UpdateBackgroundPreview(true);
    }
    if (window.DarkThemeEngine_PulseBackgroundPreview) window.DarkThemeEngine_PulseBackgroundPreview();
    if (typeof lua !== 'undefined' && lua.PlaySound) {
        var now = Date.now();
        var isContinuous = key === 'BG_Overlay' || key === 'BG_SwapInterval';
        if (!isContinuous || now - (window._DT_LastBgOptionSound || 0) > 420) {
            window._DT_LastBgOptionSound = now;
            lua.PlaySound('garrysmod/ui_click.wav');
        }
    }
};
window.DarkThemeEngine_UpdateFadeOptions = function(isStatic) {
    var fadeFade = document.getElementById('fade_nofade');
    var fadeInterval = document.getElementById('fade_interval');
    if (fadeFade) fadeFade.style.display = isStatic ? 'none' : '';
    if (fadeInterval) fadeInterval.style.display = isStatic ? 'none' : '';
};
window.DarkThemeEngine_SetOverlayWorkPaused = function(paused) {
    window._DT_OverlayWorkPaused = !!paused;
    if (document && document.body) {
        if (paused) document.body.classList.add('dt-modal-open');
        else document.body.classList.remove('dt-modal-open');
    }
    if (paused) {
        if (window._DT_VizRAF) { cancelAnimationFrame(window._DT_VizRAF); window._DT_VizRAF = null; }
        if (window._DT_FallbackVizRAF) { cancelAnimationFrame(window._DT_FallbackVizRAF); window._DT_FallbackVizRAF = null; }
        if (window._DarkTheme_PreviewTimer) { clearInterval(window._DarkTheme_PreviewTimer); window._DarkTheme_PreviewTimer = null; }
        if (window._DarkTheme_PreviewFadeTimer) { clearTimeout(window._DarkTheme_PreviewFadeTimer); window._DarkTheme_PreviewFadeTimer = null; }
        if (window._DarkTheme_PreviewResetTimer) { clearTimeout(window._DarkTheme_PreviewResetTimer); window._DarkTheme_PreviewResetTimer = null; }
        if (window._DarkTheme_GladosTimer) { clearInterval(window._DarkTheme_GladosTimer); window._DarkTheme_GladosTimer = null; }
        return;
    }
    if (window.DarkThemeEngine_RefreshPortalMusicPlayer) setTimeout(window.DarkThemeEngine_RefreshPortalMusicPlayer, 60);
    if (window.DarkThemeEngine_UpdateBackgroundPreview) setTimeout(function() { window.DarkThemeEngine_UpdateBackgroundPreview(true); }, 80);
    if (window.DarkThemeEngine_StartGladosAmbient) setTimeout(window.DarkThemeEngine_StartGladosAmbient, 120);
};
window.DarkThemeEngine_CloseSubpage = function(panel) {
    if (window._DT_ChangelogChunkTimer) {
        clearTimeout(window._DT_ChangelogChunkTimer);
        window._DT_ChangelogChunkTimer = null;
    }
    if (panel && panel.parentNode) panel.remove();
    if (!document.getElementById('dt_help_panel') && !document.getElementById('dt_changelog_panel')) {
        window.DarkThemeEngine_SetOverlayWorkPaused(false);
    }
};
window.DarkThemeEngine_ShowAddMusicGuide = function() { window.DarkThemeEngine_ShowHelp('music'); };
window.DarkThemeEngine_ShowHelp = function(section) {
    var existing = document.getElementById('dt_help_panel');
    if (existing) { window.DarkThemeEngine_CloseSubpage(existing); return; }
    window.DarkThemeEngine_SetOverlayWorkPaused(true);
    var SECTIONS = window._DT_HelpSections || (window._DT_HelpSections = [
        { id: 'music', icon: window.DarkThemeEngine_Icon('music'), title: 'Menu Music', content:
            '<p style="color:#94a3b8;margin-top:0;">Add custom music to your GMod main menu.</p>'
            + '<div class="dt-guide-step"><strong>Local files (easiest)</strong><br>Drop <code>.mp3</code> or <code>.wav</code> files into:<br><code>garrysmod/data/theme_engine_music/</code><br>No addon needed. Music appears immediately.</div>'
            + '<div class="dt-guide-step"><strong>Subfolders = Albums</strong><br>Create subfolders inside <code>theme_engine_music/</code> to organise tracks into albums:<br><code>data/theme_engine_music/MyAlbum/track1.mp3</code></div>'
            + '<div class="dt-guide-step"><strong>Custom metadata (titles, artist, cover art)</strong><br>Create <code>te_music_meta.json</code> in <code>data/theme_engine_music/</code>. Each song is a key matching the filename exactly. To add more songs, just add more entries:<div style="background:rgba(0,0,0,0.5);padding:10px;border-radius:6px;margin-top:8px;font-family:Consolas,monospace;font-size:0.78rem;color:#a5b4fc;white-space:pre;overflow-x:auto;">{\n  "song.mp3": {\n    "title": "My Track",\n    "artist": "Artist Name",\n    "desc": "A cool track",\n    "youtube": "https://youtu.be/..."\n  },\n  "another_song.mp3": {\n    "title": "Another Track",\n    "artist": "Someone Else",\n    "desc": "Another cool track"\n  }\n}</div><div style="font-size:0.8rem;color:#64748b;margin-top:6px;">All fields are optional. If a field is missing, the engine reads it from the MP3 ID3 tag automatically.</div></div>'
            + '<div class="dt-guide-step"><strong>Workshop addon</strong><br>Put audio in <code>sound/theme_engine_music/</code>, metadata in <code>data_static/te_music_meta.json</code>. Use <a href="https://github.com/WilliamVenner/gmpublisher" style="color:#3b82f6;">gmpublisher</a> to publish.</div>'
            + '<div class="dt-guide-step"><strong>Playback controls</strong><ul class="dt-guide-list"><li><strong>Pause/Resume</strong> and <strong>Skip</strong> buttons appear next to the Now Playing area</li><li>Music fades out smoothly when entering a game instead of cutting abruptly</li><li><strong>Playlist Mode</strong>: auto-advances to the next track</li><li><strong>Shuffle</strong>: randomises track order</li></ul></div>'
        },
        { id: 'backgrounds', icon: window.DarkThemeEngine_Icon('backgrounds'), title: 'Backgrounds', content:
            '<p style="color:#94a3b8;margin-top:0;">Manage background images shown in the main menu.</p>'
            + '<div class="dt-guide-step"><strong>Custom backgrounds</strong><br>Drop <code>.jpg</code> / <code>.png</code> files manually into <code>garrysmod/data/theme_engine_backgrounds/</code>, then reopen or refresh the Backgrounds tab.</div>'
            + '<div class="dt-guide-step"><strong>Where backgrounds come from</strong><br>The engine scans all mounted addons for <code>backgrounds/*.jpg|png</code> and per-gamemode backgrounds.<br>Subscribe to background addons on the Workshop and they appear automatically.</div>'
            + '<div class="dt-guide-step"><strong>Controls</strong><ul class="dt-guide-list"><li>Click a category to see its backgrounds</li><li>Click a background to enable/disable it</li><li>Right-click a background for a full preview</li><li>Use <em>Disable All / Enable All</em> buttons to toggle an entire category</li></ul></div>'
            + '<div class="dt-guide-step"><strong>Animation options</strong><ul class="dt-guide-list"><li><strong>Static</strong>: No automatic rotation</li><li><strong>Disable Zoom</strong>: Remove the slow zoom effect</li><li><strong>Instant Cut</strong>: No fade between backgrounds</li><li><strong>Speed</strong>: How often it changes (5-120s)</li><li><strong>Dim</strong>: Darken the background (0-70%)</li></ul></div>'
        },
        { id: 'themes', icon: window.DarkThemeEngine_Icon('palette'), title: 'Theme Authors', content:
            '<p style="color:#94a3b8;margin-top:0;">Build complete main-menu themes and distribute them through Steam Workshop.</p>'
            + '<div class="dt-guide-step"><strong>Install the editable example</strong><br>Open the Theme Engine setup program and choose <em>Install example theme</em>. It creates:<br><code>garrysmod/addons/theme_engine_example_light/</code></div>'
            + '<div class="dt-guide-step"><strong>Edit and test</strong><br>Edit the readable files under <code>source/</code>, run <code>build_theme.ps1</code>, select <em>GMod Light Example</em>, then press <em>Reload Selected</em>. The full main menu can be updated without restarting Garry\'s Mod.</div>'
            + '<div class="dt-guide-step"><strong>Supported theme surfaces</strong><ul class="dt-guide-list"><li>Main menu and bottom navigation</li><li>Start New Game, Addons, Servers, Saves, Dupes, and Demos</li><li>Loading screen CSS</li><li>Full menu templates and shell overlays</li><li>Mounted materials, fonts, sounds, and other addon assets</li></ul></div>'
            + '<div class="dt-guide-step"><strong>Workshop payload</strong><br>The build script writes encrypted files to:<br><code>data_static/theme_engine_full_themes/theme_engine_your_name/</code><br>The folder ID must begin with <code>theme_engine_</code>. A compiled <code>theme_manifest.json.dte.txt</code> supplies the title and description shown in the Theme Library.</div>'
            + '<div class="dt-guide-step"><strong>Publish safely</strong><br>Build once, then publish the addon folder with gmpublisher. Keep editable source files excluded through <code>addon.json</code>; subscribers only need the compiled <code>data_static</code> payload and mounted assets. Do not use Pastebin or download executable code at runtime.</div>'
            + '<div class="dt-guide-step"><strong>Protected settings</strong><br>Community themes can replace Garry\'s Mod menu surfaces, but Theme Engine Options is intentionally isolated so users can always change or disable a theme.</div>'
        },
        { id: 'spawnmenu', icon: window.DarkThemeEngine_Icon('gamepad'), title: 'Spawnmenu Skin', content:
            '<p style="color:#94a3b8;margin-top:0;">Change the visual theme of the in-game Q menu.</p>'
            + '<div class="dt-guide-step"><strong>How it works</strong><br>Install a spawnmenu skin addon from the Workshop, then select it here. The change applies the next time you open the Q menu in-game.</div>'
            + '<div class="dt-guide-step"><strong>Singleplayer</strong><br>Works fully - skin applies as soon as you open the Q menu.</div>'
            + '<div class="dt-guide-step"><strong>Multiplayer servers</strong><br><strong>Warning:</strong> Only works if the server has the Theme Engine addon mounted. If the server doesn\'t have it, the default spawnmenu will show regardless of your selection.</div>'
            + '<div class="dt-guide-step"><strong>Reverting</strong><br>Select <em>Default GMod</em> to restore the original spawnmenu appearance. All skin addon hooks are removed cleanly.</div>'
        },
        { id: 'fonts', icon: window.DarkThemeEngine_Icon('font'), title: 'Custom Fonts', content:
            '<p style="color:#94a3b8;margin-top:0;">Change the font used throughout the main menu.</p>'
            + '<div class="dt-guide-step"><strong>Built-in fonts</strong><br>Pick any font from the dropdown. Previews update instantly. Click Reset to go back to the default.</div>'
            + '<div class="dt-guide-step"><strong>Type any font name</strong><br>If you know a font installed on your system, type its name in the text field and click Apply.</div>'
            + '<div class="dt-guide-step"><strong>Local .ttf fonts</strong><br>Drop <code>.ttf</code> font files into:<br><code>garrysmod/data/theme_engine_fonts/</code><br>They will appear in the dropdown automatically after reloading the menu.</div>'
            + '<div class="dt-guide-step"><strong>Font Size</strong><br>Use the <em>Font Size</em> slider (8-20px) in the Miscellaneous tab to adjust the menu text size. Click <em>Default</em> to reset.</div>'
        },
        { id: 'misc', icon: window.DarkThemeEngine_Icon('cog'), title: 'Miscellaneous', content:
            '<p style="color:#94a3b8;margin-top:0;">General tips, console commands, and other useful info.</p>'
            + '<div class="dt-guide-step"><strong>Console commands</strong><br>Type <code>theme_engine</code> or <code>theme_engine_open</code> in the console to open the Theme Engine settings panel directly.</div>'
            + '<div class="dt-guide-step"><strong>Dark loading screen</strong><br>The dark theme is automatically applied to the map loading screen. No extra configuration needed.</div>'
            + '<div class="dt-guide-step"><strong>Data folders</strong><br>Theme Engine stores all user data in <code>garrysmod/data/</code>:<ul class="dt-guide-list"><li><code>theme_engine_data/</code> - settings</li><li><code>theme_engine_music/</code> - custom music files</li><li><code>theme_engine_backgrounds/</code> - custom background images</li><li><code>theme_engine_fonts/</code> - custom .ttf fonts</li></ul></div>'
            + '<div class="dt-guide-step"><strong>Workshop compatibility</strong><br>Workshop addons that provide backgrounds or music are detected automatically when mounted. No manual setup required.</div>'
        },
    ]);
    var panel = document.createElement('div');
    panel.id = 'dt_help_panel';
    panel.className = 'dt-subpage-overlay';
    var activeSection = section || 'music';
    var currentSection = null;
    window.DarkThemeEngine_SelectHelpSection = function(nextSection) {
        activeSection = nextSection || 'music';
        renderHelp();
    };
    function renderHelp() {
        var sec = null;
        for (var i = 0; i < SECTIONS.length; i++) { if (SECTIONS[i].id === activeSection) { sec = SECTIONS[i]; break; } }
        if (!sec) sec = SECTIONS[0];
        if (currentSection === sec.id) return;
        currentSection = sec.id;
        var tabs = '';
        for (var i = 0; i < SECTIONS.length; i++) {
            var s = SECTIONS[i];
            var isActive = s.id === activeSection;
            tabs += '<button class="dt-help-tab' + (isActive ? ' active' : '') + '" data-help-section="' + s.id + '" onclick="window.DarkThemeEngine_SelectHelpSection(\'' + s.id + '\')">' + s.icon + ' ' + s.title + '</button>';
        }
        var inner = '<div class="dt-subpage-shell" style="display:flex;width:820px;max-width:94vw;height:76vh;max-height:620px;">'
            + '<div class="dt-scrollable" style="width:210px;flex-shrink:0;padding:20px 12px;border-right:1px solid rgba(126,188,220,0.16);display:flex;flex-direction:column;gap:6px;overflow-y:auto;background:rgba(5,10,15,0.36);">'
            + '<div class="dt-subpage-kicker" style="padding:4px 12px 10px;">Help Topics</div>'
            + tabs
            + '</div>'
            + '<div style="flex:1;min-width:0;padding:24px 28px;color:#d9e5ee;font-size:0.92rem;line-height:1.6;display:flex;flex-direction:column;">'
            + '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;padding-bottom:14px;border-bottom:1px solid rgba(126,188,220,0.16);flex-shrink:0;">'
            + '<div><div class="dt-subpage-kicker">Aperture Laboratories</div><div class="dt-subpage-title" style="font-size:1.35rem;">' + sec.icon + ' ' + sec.title + '</div></div>'
            + '<button id="dt_help_x" style="background:none;border:none;color:#64748b;cursor:pointer;font-size:1.2rem;padding:4px;">' + window.DarkThemeEngine_Icon('close') + '</button>'
            + '</div>'
            + '<div class="dt-scrollable" style="flex:1;min-height:0;overflow-y:auto;padding-right:6px;">'
            + sec.content
            + '</div>'
            + '</div>'
            + '</div>';
        var wasAttached = !!panel.parentNode;
        panel.innerHTML = inner;
        if (!wasAttached) document.body.appendChild(panel);
        document.getElementById('dt_help_x').onclick = function() { window.DarkThemeEngine_CloseSubpage(panel); };
        panel.onclick = function(e) { if (e.target === panel) window.DarkThemeEngine_CloseSubpage(panel); };
    }
    renderHelp();
};
window.DarkThemeEngine_ShowChangelog = function() {
    var existing = document.getElementById('dt_changelog_panel');
    if (existing) { window.DarkThemeEngine_CloseSubpage(existing); return; }
    window.DarkThemeEngine_SetOverlayWorkPaused(true);
    var panel = document.createElement('div');
    panel.id = 'dt_changelog_panel';
    panel.className = 'dt-subpage-overlay';

    var logs = window._DarkThemeChangelog || [];

    var inner = '<div id="dt_changelog_inner" class="dt-subpage-shell" style="width:720px;max-width:92vw;height:76vh;max-height:620px;overflow:hidden;padding:28px;color:#d9e5ee;font-size:0.95rem;line-height:1.5;display:flex;flex-direction:column;">';
    inner += '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid rgba(126,188,220,0.16);flex-shrink:0;">';
    inner += '<div><div class="dt-subpage-kicker">Aperture Laboratories</div><div class="dt-subpage-title" style="font-size:1.4rem;">Changelog</div></div>';
    inner += '<button id="dt_changelog_x" style="background:none;border:none;color:#94a3b8;cursor:pointer;font-size:1.2rem;">' + window.DarkThemeEngine_Icon('close') + '</button>';
    inner += '</div>';
    inner += '<div id="dt_changelog_content" class="dt-scrollable" style="flex:1;min-height:0;overflow-y:auto;padding-right:6px;"><div class="dt-loading-line">Loading changelog...</div>';
    inner += '</div></div>';
    panel.innerHTML = inner;
    panel.onclick = function(e) { if (e.target === panel) window.DarkThemeEngine_CloseSubpage(panel); };
    document.body.appendChild(panel);
    var seenVer = logs[0] ? logs[0].ver : '';
    window._DarkTheme_LastSeenChangelog = seenVer;
    DarkThemeEngine_LuaCall("DarkTheme_SetLastSeenChangelog('" + seenVer.replace(/'/g, "\\'") + "')");
    var dot = document.getElementById('dt_changelog_new');
    if (dot) dot.style.display = 'none';
    var menuDot = document.getElementById('dt_menu_new_dot');
    if (menuDot) menuDot.style.display = 'none';
    var btn = document.getElementById('dt_changelog_btn');
    if (btn) { btn.classList.remove('has-new'); btn.title = ''; }
    document.getElementById('dt_changelog_x').onclick = function() { window.DarkThemeEngine_CloseSubpage(panel); };
    var content = document.getElementById('dt_changelog_content');
    function escapeHTML(value) {
        if (window.DarkThemeEngine_EscapeHTML) return window.DarkThemeEngine_EscapeHTML(String(value || ''));
        return String(value || '').replace(/[&<>"']/g, function(ch) {
            return ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' })[ch];
        });
    }
    function changelogEntryHTML(entry) {
        var out = '<div class="dt-changelog-entry">';
        out += '<div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">';
        out += '<span class="dt-version-badge">v' + escapeHTML(entry.ver) + '</span>';
        if (entry.tag) out += '<span class="dt-tag-badge">' + escapeHTML(entry.tag) + '</span>';
        out += '</div>';
        var sections = entry.sections || [];
        if (sections.length) {
            for (var s = 0; s < sections.length; s++) {
                var section = sections[s] || {};
                out += '<div class="dt-change-section">';
                out += '<div class="dt-change-section-title">' + escapeHTML(section.title || 'Changes') + '</div>';
                var items = section.items || [];
                for (var j = 0; j < items.length; j++) {
                    out += '<div class="dt-change-line"><span>&#8226;</span>' + escapeHTML(items[j]) + '</div>';
                }
                out += '</div>';
            }
        } else {
            var changes = entry.changes || [];
            for (var j = 0; j < changes.length; j++) {
                out += '<div class="dt-change-line"><span>&#8226;</span>' + escapeHTML(changes[j]) + '</div>';
            }
        }
        out += '</div>';
        return out;
    }
    function changelogCreditsHTML() {
        var credits = window._DarkThemeCredits || [];
        if (!credits.length) return '';
        var out = '<div class="dt-credits-block">';
        for (var cv = 0; cv < credits.length; cv++) {
            var cver = credits[cv];
            out += '<div class="dt-credits-title">Credits - v' + escapeHTML(cver.ver) + '</div>';
            var cent = cver.entries || [];
            for (var ci = 0; ci < cent.length; ci++) {
                out += '<div class="dt-credit-row"><span>' + escapeHTML(cent[ci].role) + '</span><strong>' + escapeHTML(cent[ci].name) + '</strong></div>';
            }
        }
        out += '</div>';
        return out;
    }
    if (window._DT_ChangelogHTML) {
        content.innerHTML = window._DT_ChangelogHTML;
    } else {
        content.innerHTML = '';
        var idx = 0;
        var chunks = [];
        function addChunk() {
            if (!document.getElementById('dt_changelog_panel')) return;
            var html = '';
            var end = Math.min(idx + 4, logs.length);
            for (; idx < end; idx++) html += changelogEntryHTML(logs[idx] || {});
            if (html) {
                chunks.push(html);
                content.insertAdjacentHTML('beforeend', html);
            }
            if (idx < logs.length) {
                window._DT_ChangelogChunkTimer = setTimeout(addChunk, 0);
                return;
            }
            var creditsHTML = changelogCreditsHTML();
            if (creditsHTML) {
                chunks.push(creditsHTML);
                content.insertAdjacentHTML('beforeend', creditsHTML);
            }
            window._DT_ChangelogHTML = chunks.join('');
            window._DT_ChangelogChunkTimer = null;
        }
        window._DT_ChangelogChunkTimer = setTimeout(addChunk, 0);
    }
};
window.DarkThemeEngine_ApplyChangelogIndicator = function(isNew, currentVer) {
    var btn = document.getElementById('dt_changelog_btn');
    var dot = document.getElementById('dt_changelog_new');
    var menuDot = document.getElementById('dt_menu_new_dot');
    if (!btn) return false;
    if (isNew) {
        btn.classList.add('has-new');
        btn.title = 'New update: ' + currentVer;
        if (dot) dot.style.display = 'block';
        if (menuDot) menuDot.style.display = 'block';
    } else {
        btn.classList.remove('has-new');
        btn.title = '';
        if (dot) dot.style.display = 'none';
        if (menuDot) menuDot.style.display = 'none';
    }
    return true;
};
window.DarkThemeEngine_CheckChangelogNew = function() {
    var currentVer = (window._DarkThemeChangelog && window._DarkThemeChangelog[0]) ? window._DarkThemeChangelog[0].ver : '';
    var seen = window._DarkTheme_LastSeenChangelog || '';
    var isNew = (currentVer !== '' && seen !== currentVer);
    var applied = window.DarkThemeEngine_ApplyChangelogIndicator(isNew, currentVer);
    if (!applied) {
        if (window._DT_ChangelogRetryTimer) clearInterval(window._DT_ChangelogRetryTimer);
        var retries = 0;
        window._DT_ChangelogRetryTimer = setInterval(function() {
            retries++;
            if (window.DarkThemeEngine_ApplyChangelogIndicator(isNew, currentVer) || retries > 20) {
                clearInterval(window._DT_ChangelogRetryTimer);
                window._DT_ChangelogRetryTimer = null;
            }
        }, 250);
    }
};
window.DarkThemeEngine_FilterBgs = function() {
    if (window._DarkTheme_SelectedCategory) window.DarkThemeEngine_ShowCategoryDetail(window._DarkTheme_SelectedCategory);
    else window.DarkThemeEngine_RenderBackgroundsUI();
};
window.DarkThemeEngine_BuildCategories = function(bgs) {
    var catMap = {};
    for (var i = 0; i < bgs.length; i++) {
        var bg = bgs[i];
        var cName = bg.category || 'Gmod Background';
        if (cName === 'Gamemode: base') cName = 'Gmod Background';
        if (!catMap[cName]) {
            catMap[cName] = { name: cName, wsid: bg.wsid || '', isLocal: bg.isLocal || false, imageUrl: null, fetching: false, backgrounds: [] };
            if (cName === 'Gmod Background') catMap[cName].imageUrl = '../materials/theme_engine/gmod_background.png';
        }
        catMap[cName].backgrounds.push(bg);
    }
    var cats = [];
    for (var key in catMap) cats.push(catMap[key]);
    cats.sort(function(a, b) {
        if (a.name === 'Gmod Background') return -1;
        if (b.name === 'Gmod Background') return 1;
        return a.name.localeCompare(b.name);
    });
    for (var c = 0; c < cats.length; c++) {
        var cat = cats[c];
        var wsidStr = String(cat.wsid);
        if (wsidStr && window._DarkTheme_WsidImages[wsidStr]) {
            cat.imageUrl = window._DarkTheme_WsidImages[wsidStr];
        }
        if (!cat.isLocal && wsidStr && wsidStr !== '' && wsidStr !== '0' && !cat.imageUrl && !window._DarkTheme_WsidFetched[wsidStr]) {
            window._DarkTheme_WsidFetched[wsidStr] = true;
            DarkThemeEngine_LuaCall("if DarkTheme_FetchWorkshopIcon then DarkTheme_FetchWorkshopIcon('" + wsidStr + "') end");
        }
    }
    window._DarkTheme_Categories = cats;
    return cats;
};
window.DarkThemeEngine_RenderBackgroundsUI = function() {
    var bgs = window._DarkTheme_Backgrounds || [];
    var disabled = window._DarkTheme_DisabledBgs || {};
    var opts = window._DarkTheme_BgOptions || {};
    var chkStatic = document.getElementById('opt_bg_static');
    var chkNoZoom = document.getElementById('opt_bg_nozoom');
    var chkNoFade = document.getElementById('opt_bg_nofade');
    var interval = document.getElementById('opt_bg_interval');
    var intervalLabel = document.getElementById('opt_bg_interval_label');
    var overlay = document.getElementById('opt_bg_overlay');
    var overlayLabel = document.getElementById('opt_bg_overlay_label');
    if (chkStatic) chkStatic.checked = !!opts.BG_Static;
    if (chkNoZoom) chkNoZoom.checked = !!opts.BG_NoZoom;
    if (chkNoFade) chkNoFade.checked = !!opts.BG_NoFade;
    if (interval) interval.value = parseInt(opts.BG_SwapInterval || 20, 10) || 20;
    if (intervalLabel) intervalLabel.textContent = (parseInt(opts.BG_SwapInterval || 20, 10) || 20) + 's';
    if (overlay) overlay.value = Math.round((parseFloat(opts.BG_Overlay || 0) || 0) * 100);
    if (overlayLabel) overlayLabel.textContent = Math.round((parseFloat(opts.BG_Overlay || 0) || 0) * 100) + '%';
    DarkThemeEngine_UpdateFadeOptions(!!opts.BG_Static);
    var npEl = document.getElementById('bg_now_playing');
    if (npEl) npEl.textContent = 'Now Playing: ' + (window._DarkTheme_ActiveBg !== 'None' ? window._DarkTheme_ActiveBg.split('/').pop() : 'None');
    var cats = window.DarkThemeEngine_BuildCategories(bgs);
    window._DarkTheme_PreviewBgPath = (window._DarkTheme_ActiveBg && window._DarkTheme_ActiveBg !== 'None') ? window._DarkTheme_ActiveBg : null;
    if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview();
    var filter = (document.getElementById('bg_search_input') || {}).value || '';
    filter = filter.toLowerCase();
    var html = '<div class="bg-grid" style="grid-template-columns:repeat(auto-fill,minmax(280px,1fr));">';
    for (var c = 0; c < cats.length; c++) {
        var cat = cats[c];
        if (filter && cat.name.toLowerCase().indexOf(filter) === -1) continue;
        var iconHtml = '';
        if (cat.imageUrl) {
            iconHtml = '<img id="cat_icon_' + (cat.wsid || c) + '" src="' + cat.imageUrl + '" style="width:80px;height:80px;border-radius:8px;object-fit:cover;box-shadow:0 4px 10px rgba(0,0,0,0.4);flex-shrink:0;min-width:80px;" />';
            iconHtml += '<div id="cat_placeholder_' + (cat.wsid || c) + '" style="display:none;"></div>';
        } else if (cat.isLocal) {
            iconHtml = window.DarkThemeEngine_IconBox('image', 80, false);
        } else if (cat.wsid && cat.wsid !== '' && cat.wsid !== '0') {
            iconHtml = '<img id="cat_icon_' + cat.wsid + '" style="display:none;width:80px;height:80px;border-radius:8px;object-fit:cover;box-shadow:0 4px 10px rgba(0,0,0,0.4);flex-shrink:0;min-width:80px;" />';
            iconHtml += window.DarkThemeEngine_IconBox('image', 80, false, 'cat_placeholder_' + cat.wsid);
        } else {
            iconHtml = window.DarkThemeEngine_IconBox('image', 80, false);
        }
        var encodedCat = encodeURIComponent(cat.name);
        html += '<div class="cat-card" data-cat="' + encodedCat + '" onclick="DarkThemeEngine_ShowCategoryDetail(decodeURIComponent(this.getAttribute(\'data-cat\')))">';
        html += iconHtml;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:1.15rem;font-weight:600;color:#f8fafc;margin-bottom:4px;white-space:pre-wrap;word-break:break-word;">' + window.DarkThemeEngine_EscapeHTML(cat.name) + '</div>';
        html += '<div style="font-size:0.85rem;color:#94a3b8;">' + cat.backgrounds.length + ' Backgrounds</div>';
        html += '</div></div>';
    }
    html += '</div>';
    var catView = document.getElementById('bg_categories_view');
    var detView = document.getElementById('bg_detail_view');
    var loading = document.getElementById('bg_loading');
    if (loading) loading.style.display = 'none';
    if (catView) { catView.innerHTML = html; catView.style.display = 'block'; }
    if (detView) detView.style.display = 'none';
    window._DarkTheme_SelectedCategory = null;
};
window.DarkThemeEngine_ShowCategoryDetail = function(catName) {
    window._DarkTheme_SelectedCategory = catName;
    var cats = window._DarkTheme_Categories || [];
    var disabled = window._DarkTheme_DisabledBgs || {};
    var filter = (document.getElementById('bg_search_input') || {}).value || '';
    filter = filter.toLowerCase();
    var catObj = null;
    for (var c = 0; c < cats.length; c++) { if (cats[c].name === catName) { catObj = cats[c]; break; } }
    if (!catObj) return;
    var catBgs = [];
    for (var i = 0; i < catObj.backgrounds.length; i++) {
        var bg = catObj.backgrounds[i];
        if (!filter || bg.path.toLowerCase().indexOf(filter) !== -1) catBgs.push(bg);
    }
    var html = '';
    html += '<div style="display:flex;align-items:center;gap:15px;margin-bottom:20px;background:rgba(0,0,0,0.35);padding:12px 18px;border-radius:12px;border-left:4px solid #3b82f6;">';
    html += '<button class="theme-btn dt-inline-icon" style="padding:10px 14px;margin-right:10px;background:rgba(255,255,255,0.1);border:none;" onclick="DarkThemeEngine_RenderBackgroundsUI();if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">' + window.DarkThemeEngine_Icon('back') + 'Back</button>';
    if (catObj.imageUrl) {
        html += '<img src="' + catObj.imageUrl + '" style="width:54px;height:54px;border-radius:8px;object-fit:cover;box-shadow:0 4px 10px rgba(0,0,0,0.4);" />';
    } else if (catObj.isLocal) {
        html += window.DarkThemeEngine_IconBox('image', 54, false);
    } else if (catObj.wsid) {
        html += window.DarkThemeEngine_IconBox('image', 54, false);
    }
    html += '<div style="flex:1;">';
    html += '<div style="font-size:1.15rem;font-weight:600;color:#f8fafc;margin-bottom:2px;">' + window.DarkThemeEngine_EscapeHTML(catObj.name) + '</div>';
    html += '<div style="font-size:0.85rem;color:#94a3b8;display:flex;align-items:center;gap:10px;">';
    html += '<span>' + catBgs.length + ' Backgrounds</span>';
    if (catObj.wsid && catObj.wsid !== '' && catObj.wsid !== '0') {
        html += '<span class="dt-inline-icon" style="color:#60a5fa;cursor:pointer;font-weight:500;" onclick="event.stopPropagation();DarkThemeEngine_LuaCall(\'if gui and gui.OpenURL then gui.OpenURL(\\\'https://steamcommunity.com/sharedfiles/filedetails/?id=' + catObj.wsid + '\\\') end\')">' + window.DarkThemeEngine_Icon('link') + 'View on Steam</span>';
    }
    html += '</div>';
    html += '<div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:10px;">';
    var encodedCatKey = encodeURIComponent(catName);
    html += '<button class="theme-btn dt-inline-icon" style="font-size:0.8rem;padding:6px 12px;background:rgba(239,68,68,0.15);color:#f87171;border-color:rgba(239,68,68,0.3);" data-cat="' + encodedCatKey + '" onclick="event.stopPropagation();DarkThemeEngine_DisableCategory(decodeURIComponent(this.getAttribute(\'data-cat\')))">' + window.DarkThemeEngine_Icon('block') + 'Disable All</button>';
    html += '<button class="theme-btn dt-inline-icon" style="font-size:0.8rem;padding:6px 12px;background:rgba(16,185,129,0.15);color:#34d399;border-color:rgba(16,185,129,0.3);" data-cat="' + encodedCatKey + '" onclick="event.stopPropagation();DarkThemeEngine_EnableCategory(decodeURIComponent(this.getAttribute(\'data-cat\')))">' + window.DarkThemeEngine_Icon('check') + 'Enable All</button>';
    html += '</div>';
    html += '</div></div>';
    html += '<div class="bg-grid">';
    var encodedCat = encodeURIComponent(catName);
    for (var i = 0; i < catBgs.length; i++) {
        var bg = catBgs[i];
        var isDisabled = !!disabled[bg.path];
        var filename = bg.path.split('/').pop();
        var encodedPath = encodeURIComponent(bg.path);
        var imgSrc = window.DarkThemeEngine_EscapeHTML(window.DarkThemeEngine_GetBackgroundUrl(bg.path, false));
        var imgFallback = window.DarkThemeEngine_EscapeHTML(window.DarkThemeEngine_GetBackgroundUrl(bg.path, true));
        html += '<div class="bg-card' + (isDisabled ? ' bg-disabled' : '') + '" ';
        html += 'data-path="' + encodedPath + '" data-cat="' + encodedCat + '" ';
        html += 'onmouseenter="DarkThemeEngine_PreviewInPanel(decodeURIComponent(this.getAttribute(\'data-path\')))" ';
        html += 'onclick="DarkThemeEngine_ToggleBg(decodeURIComponent(this.getAttribute(\'data-path\')), this)" ';
        html += 'oncontextmenu="event.preventDefault();DarkThemeEngine_OpenBgPreview(decodeURIComponent(this.getAttribute(\'data-path\')), decodeURIComponent(this.getAttribute(\'data-cat\')))" ';
        html += '>';
        html += '<img src="' + imgSrc + '" data-primary-src="' + imgSrc + '" data-fallback-src="' + imgFallback + '" onerror="DarkThemeEngine_BackgroundImgError(this)" />';
        html += '<div class="bg-name">' + window.DarkThemeEngine_EscapeHTML(filename) + '</div>';
        html += '<div class="bg-disabled-badge">DISABLED</div>';
        html += '</div>';
    }
    html += '</div>';
    var catView = document.getElementById('bg_categories_view');
    var detView = document.getElementById('bg_detail_view');
    if (catView) catView.style.display = 'none';
    if (detView) {
        detView.innerHTML = html;
        detView.style.display = 'block';
        setTimeout(function() { window.DarkThemeEngine_RefreshBackgroundThumbs(detView); }, 25);
    }
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_ToggleBg = function(bgPath, cardEl) {
    if (window._DarkTheme_DisabledBgs[bgPath]) delete window._DarkTheme_DisabledBgs[bgPath];
    else window._DarkTheme_DisabledBgs[bgPath] = true;
    DarkThemeEngine_LuaCall('DarkThemeEngine_ToggleBackground("' + window.DarkThemeEngine_SafePathForLua(bgPath) + '")');
    if (cardEl) {
        if (window._DarkTheme_DisabledBgs[bgPath]) cardEl.classList.add('bg-disabled');
        else cardEl.classList.remove('bg-disabled');
    }
    if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview();
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_ExpandLiveBackground = function() {
    var box = document.getElementById('dt_bg_live_preview');
    var tab = document.getElementById('tab_backgrounds');
    var btn = document.getElementById('dt_bg_expand_btn');
    if (!box || !tab) return;
    var expanded = !box.classList.contains('expanded');
    box.classList.toggle('expanded', expanded);
    tab.classList.toggle('bg-preview-expanded', expanded);
    if (btn) {
        btn.innerHTML = window.DarkThemeEngine_Icon(expanded ? 'collapse' : 'expand') + '<span>' + (expanded ? 'Compact' : 'Expand') + '</span>';
        window.DarkThemeEngine_PulseIcon(btn);
    }
    setTimeout(function() {
        if (window.DarkThemeEngine_UpdateBackgroundPreview) window.DarkThemeEngine_UpdateBackgroundPreview(true);
    }, 60);
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_DisableCategory = function(catName) {
    var cats = window._DarkTheme_Categories || [];
    for (var c = 0; c < cats.length; c++) {
        if (cats[c].name === catName) {
            var bgs = cats[c].backgrounds;
            for (var i = 0; i < bgs.length; i++) window._DarkTheme_DisabledBgs[bgs[i].path] = true;
            break;
        }
    }
    var safeName = window.DarkThemeEngine_SafePathForLua(catName);
    DarkThemeEngine_LuaCall('DarkThemeEngine_DisableCategoryBackgrounds("' + safeName + '")');
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
    window.DarkThemeEngine_ShowCategoryDetail(catName);
};
window.DarkThemeEngine_EnableCategory = function(catName) {
    var cats = window._DarkTheme_Categories || [];
    for (var c = 0; c < cats.length; c++) {
        if (cats[c].name === catName) {
            var bgs = cats[c].backgrounds;
            for (var i = 0; i < bgs.length; i++) delete window._DarkTheme_DisabledBgs[bgs[i].path];
            break;
        }
    }
    var safeName = window.DarkThemeEngine_SafePathForLua(catName);
    DarkThemeEngine_LuaCall('DarkThemeEngine_EnableCategoryBackgrounds("' + safeName + '")');
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
    window.DarkThemeEngine_ShowCategoryDetail(catName);
};
window.DarkThemeEngine_OpenBgPreview = function(bgPath, catName) {
    var allBgs = [];
    var startIdx = 0;
    var cats = window._DarkTheme_Categories || [];
    for (var c = 0; c < cats.length; c++) {
        var cat = cats[c];
        for (var b = 0; b < cat.backgrounds.length; b++) {
            var item = cat.backgrounds[b];
            allBgs.push({ path: item.path, category: cat.name, categoryImage: cat.imageUrl || '' });
            if (item.path === bgPath) startIdx = allBgs.length - 1;
        }
    }
    window._BgPreview = { visible: true, index: startIdx, list: allBgs };
    var modal = document.getElementById('bg_preview_modal');
    if (!modal) return;
    var cur = allBgs[startIdx];

    // Preload the image before showing the modal to prevent animation stutter
    var preloader = new Image();
    preloader.onerror = function() {
        var fallback = window.DarkThemeEngine_GetBackgroundUrl(cur.path, true);
        if (preloader.src !== fallback) preloader.src = fallback;
    };
    preloader.src = window.DarkThemeEngine_GetBackgroundUrl(cur.path, false);
    var showModal = function() {
        modal.innerHTML = '';
        var overlay = document.createElement('div');
        overlay.className = 'preview-overlay';
        if (window._DT_LiveExpandNext) {
            overlay.classList.add('dt-live-expanded');
            window._DT_LiveExpandNext = false;
        }
        overlay.onclick = function() { DarkThemeEngine_ClosePreview(); };
        var catLabel = document.createElement('div');
        catLabel.className = 'preview-cat-label';
        var catImg = document.createElement('img');
        catImg.id = 'preview_cat_img';
        catImg.style.cssText = 'width:28px;height:28px;border-radius:6px;object-fit:cover;';
        catImg.style.display = cur.categoryImage ? '' : 'none';
        catImg.src = cur.categoryImage || '';
        var catText = document.createElement('span');
        catText.id = 'preview_cat_text';
        catText.textContent = cur.category;
        catLabel.appendChild(catImg);
        catLabel.appendChild(catText);
        overlay.appendChild(catLabel);
        var closeBtn = document.createElement('div');
        closeBtn.className = 'preview-close';
        closeBtn.innerHTML = window.DarkThemeEngine_Icon('close');
        closeBtn.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_ClosePreview(); };
        overlay.appendChild(closeBtn);
        var leftArrow = document.createElement('div');
        leftArrow.className = 'preview-arrow left';
        leftArrow.innerHTML = window.DarkThemeEngine_Icon('prev');
        leftArrow.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_PreviewPrev(); };
        overlay.appendChild(leftArrow);
        var rightArrow = document.createElement('div');
        rightArrow.className = 'preview-arrow right';
        rightArrow.innerHTML = window.DarkThemeEngine_Icon('next');
        rightArrow.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_PreviewNext(); };
        overlay.appendChild(rightArrow);
        var previewImg = document.createElement('img');
        previewImg.className = 'preview-bg-image';
        previewImg.id = 'preview_main_img';
        previewImg.setAttribute('data-fallback-src', window.DarkThemeEngine_GetBackgroundUrl(cur.path, true));
        previewImg.onerror = function() { window.DarkThemeEngine_BackgroundImgError(previewImg); };
        previewImg.src = preloader.src;
        previewImg.onclick = function(e) { e.stopPropagation(); };
        overlay.appendChild(previewImg);
        var nameLabel = document.createElement('div');
        nameLabel.className = 'preview-bg-name';
        nameLabel.id = 'preview_name_label';
        nameLabel.textContent = cur.path.split('/').pop() + ' - ' + (startIdx + 1) + ' / ' + allBgs.length;
        overlay.appendChild(nameLabel);
        modal.appendChild(overlay);
        modal.style.display = 'block';
    };
    // If image is already cached (from the grid thumbnail), show immediately
    if (preloader.complete) { showModal(); }
    else { preloader.onload = showModal; preloader.onerror = showModal; }
};
window.DarkThemeEngine_UpdatePreview = function() {
    var p = window._BgPreview;
    if (!p || !p.visible || p.list.length === 0) return;
    var cur = p.list[p.index];
    var img = document.getElementById('preview_main_img');
    var nameLabel = document.getElementById('preview_name_label');
    var catImg = document.getElementById('preview_cat_img');
    var catText = document.getElementById('preview_cat_text');
    if (img) {
        img.setAttribute('data-fallback-src', window.DarkThemeEngine_GetBackgroundUrl(cur.path, true));
        img.onerror = function() { window.DarkThemeEngine_BackgroundImgError(img); };
        img.src = window.DarkThemeEngine_GetBackgroundUrl(cur.path, false);
    }
    if (nameLabel) nameLabel.textContent = cur.path.split('/').pop() + ' - ' + (p.index + 1) + ' / ' + p.list.length;
    if (catText) catText.textContent = cur.category;
    if (catImg) {
        if (cur.categoryImage) { catImg.src = cur.categoryImage; catImg.style.display = ''; }
        else { catImg.style.display = 'none'; }
    }
};
window.DarkThemeEngine_ClosePreview = function() {
    window._BgPreview = { visible: false, index: 0, list: [] };
    var modal = document.getElementById('bg_preview_modal');
    if (modal) { modal.innerHTML = ''; modal.style.display = 'none'; }
};
window.DarkThemeEngine_PreviewNext = function() {
    var p = window._BgPreview;
    if (!p || p.list.length === 0) return;
    p.index = (p.index + 1) % p.list.length;
    window.DarkThemeEngine_UpdatePreview();
};
window.DarkThemeEngine_PreviewPrev = function() {
    var p = window._BgPreview;
    if (!p || p.list.length === 0) return;
    p.index = (p.index - 1 + p.list.length) % p.list.length;
    window.DarkThemeEngine_UpdatePreview();
};
window._DarkTheme_Music = [];
window._DarkTheme_DisabledMusic = {};
window._DarkTheme_MusicOptions = {};
window._DarkTheme_ActiveMusic = 'None';
window.ThemeEngineMusic = window.ThemeEngineMusic || (function() {
    var listeners = [];
    var lastProgressEvent = 0;

    function findTrack(path) {
        var tracks = window._DarkTheme_Music || [];
        for (var i = 0; i < tracks.length; i++) {
            if (tracks[i].path === path) return tracks[i];
        }
        return null;
    }

    function state() {
        var node = window.DarkTheme_AudioNode;
        var path = window._DarkTheme_CurrentMusicPathJS || '';
        var duration = node && isFinite(node.duration) ? node.duration : 0;
        var currentTime = node && isFinite(node.currentTime) ? node.currentTime : 0;
        var track = findTrack(path);
        return {
            path: path,
            track: track,
            title: track ? (track.title || track.name || '') : '',
            artist: track ? (track.artist || '') : '',
            album: track ? (track.album || '') : '',
            cover: track ? (track.cover || '') : '',
            description: track ? (track.desc || '') : '',
            duration: duration,
            currentTime: currentTime,
            progress: duration > 0 ? currentTime / duration : 0,
            volume: node ? node.volume : (window.DarkTheme_MusicVolume || 0),
            paused: !node || node.paused,
            playing: !!node && !node.paused,
            playlist: !!window.DarkTheme_PlaylistMode,
            shuffle: !!window.DarkTheme_ShuffleMode
        };
    }

    function emit(type, force) {
        var now = Date.now();
        if (type === 'progress' && !force && now - lastProgressEvent < 150) return;
        if (type === 'progress') lastProgressEvent = now;
        var detail = { type: type, state: state() };
        for (var i = listeners.length - 1; i >= 0; i--) {
            try { listeners[i](detail); } catch (e) {}
        }
        try {
            window.dispatchEvent(new CustomEvent('themeengine:music', { detail: detail }));
            window.dispatchEvent(new CustomEvent('themeengine:music:' + type, { detail: detail.state }));
        } catch (e) {}
    }

    return {
        version: 1,
        getState: state,
        getCurrentTrack: function() { return findTrack(window._DarkTheme_CurrentMusicPathJS || ''); },
        getTracks: function() { return (window._DarkTheme_Music || []).slice(); },
        subscribe: function(listener) {
            if (typeof listener !== 'function') return function() {};
            listeners.push(listener);
            try { listener({ type: 'ready', state: state() }); } catch (e) {}
            return function() {
                var index = listeners.indexOf(listener);
                if (index !== -1) listeners.splice(index, 1);
            };
        },
        playPause: function() {
            if (window.DarkThemeEngine_TogglePause) window.DarkThemeEngine_TogglePause();
        },
        next: function() {
            if (window.DarkTheme_PlayNextTrack) window.DarkTheme_PlayNextTrack(true);
        },
        previous: function() {
            var list = window.DarkTheme_MusicPlaylist || [];
            if (!list.length || !window.DarkTheme_PlayNextTrack) return;
            window.DarkTheme_MusicIndex = (window.DarkTheme_MusicIndex - 1 + list.length) % list.length;
            window.DarkTheme_PlayNextTrack(false);
        },
        seek: function(seconds) {
            var node = window.DarkTheme_AudioNode;
            if (!node || !isFinite(node.duration)) return false;
            node.currentTime = Math.max(0, Math.min(node.duration, Number(seconds) || 0));
            emit('progress', true);
            return true;
        },
        setVolume: function(value) {
            var volume = Math.max(0, Math.min(1, Number(value) || 0));
            window.DarkTheme_MusicVolume = volume;
            if (window.DarkTheme_AudioNode) window.DarkTheme_AudioNode.volume = volume;
            if (window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall("DarkThemeEngine_SetMusicOption('Music_Volume', " + volume.toFixed(3) + ")");
            emit('volume', true);
        },
        _emit: emit
    };
    window._DT_MenuSoundClickHandler = markClick;
    window._DT_MenuSoundHoverHandler = markHover;
})();
window.DarkThemeEngine_ReceiveMusic = function(tracks, disabled, opts, disabledAlbums, currentTrack) {
    var oldLength = window._DarkTheme_Music ? window._DarkTheme_Music.length : -1;

    window._DarkTheme_Music = tracks || [];
    window._DarkTheme_DisabledMusic = disabled || {};
    window._DarkTheme_MusicOptions = opts || {};
    window._DarkTheme_DisabledAlbums = disabledAlbums || {};

    if (window.DarkThemeEngine_SetCurrentMusic) {
        window.DarkThemeEngine_SetCurrentMusic(currentTrack);
    } else {
        window._DarkTheme_ActiveMusic = currentTrack || 'None';
    }

    for (var i = 0; i < window._DarkTheme_Music.length; i++) {
        var t = window._DarkTheme_Music[i];
        if (!t._parsed) {
            var filename = t.name.replace(/\.[^/.]+$/, '');
            var artist = 'Unknown Artist';
            var title = filename;
            if (filename.indexOf(' - ') !== -1) {
                var parts = filename.split(' - ');
                artist = parts[0].trim();
                title = parts.slice(1).join(' - ').trim();
            } else if (filename.indexOf('_-_') !== -1) {
                var parts = filename.split('_-_');
                artist = parts[0].replace(/_/g, ' ').trim();
                title = parts.slice(1).join(' ').replace(/_/g, ' ').trim();
            } else {
                title = filename.replace(/_/g, ' ');
                title = title.replace(/\b\w/g, function(l) { return l.toUpperCase(); });
            }
            if (!t.title) t.title = title;
            if (!t.artist) t.artist = artist;
            if (t.cover && typeof t.cover === 'string' && !t.cover.startsWith('http') && !t.cover.startsWith('asset://') && !t.cover.startsWith('data:')) {
                t.cover = 'asset://garrysmod/' + t.cover;
            }
            t._parsed = true;
        }
    }

    var newLength = window._DarkTheme_Music.length;

    var chkEnable = document.getElementById('opt_music_enable');
    var chkPlaylist = document.getElementById('opt_music_playlist');
    var chkShuffle = document.getElementById('opt_music_shuffle');
    if (chkEnable) chkEnable.checked = !!opts.EnableMusic;
    if (chkPlaylist) chkPlaylist.checked = !!opts.Music_PlaylistMode;
    if (chkShuffle) chkShuffle.checked = !!opts.Music_Shuffle;

    if (!window._DT_MusicInitialRenderDone || oldLength !== newLength) {
        window._DT_MusicInitialRenderDone = true;
        DarkThemeEngine_RenderMusicUI();
    }
    if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('catalog', true);
};
window._DarkTheme_DisabledAlbums = {};
window._DarkTheme_SelectedAlbum  = null;
window._DarkTheme_Albums         = [];
window.DarkThemeEngine_BuildAlbums = function(tracks) {
    var albumMap = {};
    for (var i = 0; i < tracks.length; i++) {
        var t = tracks[i];
        var key = t.album || '';
        var display = key === '' ? 'Default Pack' : key;
        if (!albumMap[key]) albumMap[key] = { key: key, display: display, tracks: [] };
        albumMap[key].tracks.push(t);
    }
    var albums = [];
    for (var k in albumMap) albums.push(albumMap[k]);
    albums.sort(function(a, b) {
        if (a.key === '') return -1;
        if (b.key === '') return 1;
        return a.display.localeCompare(b.display);
    });
    window._DarkTheme_Albums = albums;
    return albums;
};
window.DarkThemeEngine_RenderAlbumCards = function() {
    var tracks  = window._DarkTheme_Music || [];
    var disabledAlbums = window._DarkTheme_DisabledAlbums || {};
    var albums  = window.DarkThemeEngine_BuildAlbums(tracks);
    var loading = document.getElementById('music_loading');
    if (loading) loading.style.display = 'none';
    var html = '<div class="bg-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr));">';
    for (var i = 0; i < albums.length; i++) {
        var alb = albums[i];
        var isAlbumDisabled = !!disabledAlbums[alb.key];
        var encodedKey = encodeURIComponent(alb.key);
        var icon = window.DarkThemeEngine_IconBox(alb.key === '' ? 'music' : 'image', 70, true);
        html += '<div class="cat-card" style="' + (isAlbumDisabled ? 'opacity:0.5;' : '') + '" data-album="' + encodedKey + '" onclick="DarkThemeEngine_ShowAlbumDetail(decodeURIComponent(this.getAttribute(\'data-album\')))">';
        html += icon;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + window.DarkThemeEngine_EscapeHTML(alb.display) + '</div>';
        html += '<div style="font-size:0.85rem;color:#94a3b8;">' + alb.tracks.length + ' tracks</div>';
        if (isAlbumDisabled) html += '<div style="font-size:0.75rem;color:#f87171;margin-top:4px;font-weight:600;">DISABLED</div>';
        html += '</div></div>';
    }
    html += '</div>';
    var albView = document.getElementById('music_album_view');
    var detView = document.getElementById('music_album_detail_view');
    var trList  = document.getElementById('music_track_list');
    if (albView)  { albView.innerHTML = html; albView.style.display = 'block'; }
    if (detView)  detView.style.display = 'none';
    if (trList)   trList.style.display = 'none';
    window._DarkTheme_SelectedAlbum = null;
};
window.DarkThemeEngine_SafePathForLua = function(p) {
    p = String(p || '').slice(0, 260);
    return p.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/'/g, "\\'");
};
window.DarkThemeEngine_UpdateThemeRouteState = function() {
    var isTheme = String(window.location.hash || '').indexOf('/theme') !== -1;
    if (document && document.body) {
        if (isTheme) document.body.classList.add('dt-theme-route-open');
        else document.body.classList.remove('dt-theme-route-open');
    }
    if (window._DarkThemeRouteOpen === isTheme) return;
    window._DarkThemeRouteOpen = isTheme;
    if (window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine_SetThemePageOpen(' + (isTheme ? 'true' : 'false') + ')');
    if (!isTheme && window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine_SetThemeBackgroundTabOpen(false)');
    if (window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine_SetCustomThemeSuspended(' + (isTheme ? 'true' : 'false') + ')');
    if (isTheme && window.DarkThemeEngine_LuaCall) {
        setTimeout(function() { window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }, 80);
        setTimeout(function() { window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendMenuSoundPacksToJS()'); }, 100);
        setTimeout(function() { if (window.DarkThemeEngine_RefreshPortalMusicPlayer) window.DarkThemeEngine_RefreshPortalMusicPlayer(); }, 120);
    }
};
window.DarkThemeEngine_UpdateThemeRouteState();
window.addEventListener('hashchange', window.DarkThemeEngine_UpdateThemeRouteState);
window.DarkThemeEngine_ToggleTrackJS = function(elem, path) {
    if (!path && elem && elem.getAttribute) {
        var raw = elem.getAttribute('data-path');
        if (raw) path = decodeURIComponent(raw);
    }
    if (!path) return;

    var disabledAlbums = window._DarkTheme_DisabledAlbums || {};
    var tracks = window._DarkTheme_Music || [];
    for (var ti = 0; ti < tracks.length; ti++) {
        if (tracks[ti].path === path) {
            var albumKey = tracks[ti].album || '';
            if (disabledAlbums[albumKey]) return;
            break;
        }
    }

    if (!window._DarkTheme_DisabledMusic) window._DarkTheme_DisabledMusic = {};
    var disabled = window._DarkTheme_DisabledMusic;
    var isDisabled = !!disabled[path];
    var statusDiv = elem ? elem.querySelector('.music-status-label') : null;
    if (isDisabled) {
        disabled[path] = false;
        delete disabled[path];
        if (elem) elem.classList.remove('music-disabled');
        if (statusDiv) {
            statusDiv.textContent = 'ENABLED';
            statusDiv.style.background = 'rgba(16,185,129,0.15)';
            statusDiv.style.color = '#34d399';
            statusDiv.style.border = '1px solid rgba(16,185,129,0.3)';
        }
    } else {
        disabled[path] = true;
        if (elem) elem.classList.add('music-disabled');
        if (statusDiv) {
            statusDiv.textContent = 'DISABLED';
            statusDiv.style.background = 'rgba(148,163,184,0.1)';
            statusDiv.style.color = '#94a3b8';
            statusDiv.style.border = '1px solid rgba(148,163,184,0.2)';
        }
    }
    DarkThemeEngine_LuaCall('DarkThemeEngine_ToggleMusic("' + window.DarkThemeEngine_SafePathForLua(path) + '")');
};
window.DarkThemeEngine_ToggleAlbumJS = function(albumKey, enable) {
    var disabledAlbums = window._DarkTheme_DisabledAlbums || {};
    if (enable) {
        disabledAlbums[albumKey] = false;
        delete disabledAlbums[albumKey];
        DarkThemeEngine_LuaCall('DarkThemeEngine_EnableAlbum("' + window.DarkThemeEngine_SafePathForLua(albumKey) + '")');
    } else {
        disabledAlbums[albumKey] = true;
        DarkThemeEngine_LuaCall('DarkThemeEngine_DisableAlbum("' + window.DarkThemeEngine_SafePathForLua(albumKey) + '")');
    }
    window._DarkTheme_DisabledAlbums = disabledAlbums;
    DarkThemeEngine_ShowAlbumDetail(albumKey);
};
window.DarkThemeEngine_ShowAlbumDetail = function(albumKey) {
    window._DarkTheme_SelectedAlbum = albumKey;
    var albums = window._DarkTheme_Albums.length > 0 ? window._DarkTheme_Albums : window.DarkThemeEngine_BuildAlbums(window._DarkTheme_Music || []);
    var disabled = window._DarkTheme_DisabledMusic || {};
    var disabledAlbums = window._DarkTheme_DisabledAlbums || {};
    var albObj = null;
    for (var i = 0; i < albums.length; i++) { if (albums[i].key === albumKey) { albObj = albums[i]; break; } }
    if (!albObj) return;
    var isAlbumDisabled = !!disabledAlbums[albumKey];
    var encodedKey = encodeURIComponent(albumKey);
    var html = '';
    html += '<div style="display:flex;align-items:center;gap:15px;margin-bottom:20px;background:rgba(0,0,0,0.35);padding:12px 18px;border-radius:12px;border-left:4px solid #3b82f6;">';
    html += '<button class="theme-btn dt-inline-icon" style="padding:10px 14px;background:rgba(255,255,255,0.1);border:none;" onclick="DarkThemeEngine_RenderAlbumCards();if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">' + window.DarkThemeEngine_Icon('back') + 'Back</button>';
    html += '<div style="flex:1;">';
    html += '<div style="font-size:1.1rem;font-weight:600;color:#f8fafc;margin-bottom:8px;">' + window.DarkThemeEngine_EscapeHTML(albObj.display) + '</div>';
    html += '<div style="display:flex;gap:8px;">';
    if (isAlbumDisabled) {
        html += '<button class="theme-btn dt-inline-icon" style="font-size:0.8rem;padding:6px 12px;background:rgba(16,185,129,0.15);color:#34d399;border-color:rgba(16,185,129,0.3);" data-album="' + encodedKey + '" onclick="DarkThemeEngine_ToggleAlbumJS(decodeURIComponent(this.getAttribute(\'data-album\')), true)">' + window.DarkThemeEngine_Icon('check') + 'Enable Album</button>';
    } else {
        html += '<button class="theme-btn dt-inline-icon" style="font-size:0.8rem;padding:6px 12px;background:rgba(239,68,68,0.15);color:#f87171;border-color:rgba(239,68,68,0.3);" data-album="' + encodedKey + '" onclick="DarkThemeEngine_ToggleAlbumJS(decodeURIComponent(this.getAttribute(\'data-album\')), false)">' + window.DarkThemeEngine_Icon('block') + 'Disable Album</button>';
    }
    html += '</div></div></div>';
    html += '<div class="music-list">';
    var allTracks = window._DarkTheme_Music || [];
    for (var i = 0; i < albObj.tracks.length; i++) {
        var t = albObj.tracks[i];
        var isDisabled = isAlbumDisabled || !!disabled[t.path];
        var encodedPath = encodeURIComponent(t.path);
        var globalIdx = allTracks.indexOf(t);
        html += '<div class="music-track' + (isDisabled ? ' music-disabled' : '') + '"';
        html += ' data-path="' + encodedPath + '"';
        html += ' onclick="window.DarkThemeEngine_ToggleTrackJS(this);if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')"';
        html += ' oncontextmenu="event.preventDefault();DarkThemeEngine_OpenMusicPreview(' + globalIdx + ')">';
        html += '<div class="music-track-icon">';
        if (t.cover) html += '<img src="' + t.cover + '" style="width:100%;height:100%;object-fit:cover;" />';
        else html += window.DarkThemeEngine_Icon('music');
        html += '</div>';
        html += '<div class="music-track-copy">';
        html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:1rem;font-weight:bold;color:#f8fafc;">' + window.DarkThemeEngine_EscapeHTML(t.title || t.name || 'Unknown') + '</span>';
        html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.85rem;color:#94a3b8;">' + window.DarkThemeEngine_EscapeHTML(t.artist || 'Unknown Artist') + '</span>';
        html += '<span class="music-track-hint">Right-click for track info</span>';
        html += '</div>';
        if (!isDisabled) html += '<div class="music-status-label" style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);">ENABLED</div>';
        else html += '<div class="music-status-label" style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;background:rgba(148,163,184,0.1);color:#94a3b8;border:1px solid rgba(148,163,184,0.2);">DISABLED</div>';
        html += '</div>';
    }
    html += '</div>';
    var albView = document.getElementById('music_album_view');
    var detView = document.getElementById('music_album_detail_view');
    var trList  = document.getElementById('music_track_list');
    if (albView) albView.style.display = 'none';
    if (trList)  trList.style.display = 'none';
    if (detView) { detView.innerHTML = html; detView.style.display = 'block'; }
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_EnsurePortalMusicPlayer = function() {
    var existing = document.getElementById('music_portal_player');
    if (existing && document.getElementById('music_visualizer_canvas')) return;
    var old = document.getElementById('music_now_playing');
    if (!old && !existing) return;
    var host = old;
    while (host && !(host.classList && (host.classList.contains('active-bg-banner') || host.classList.contains('dt-music-now-playing')))) host = host.parentNode;
    if (existing) host = existing;
    if (!host) return;
    host.outerHTML = '<div class="portal-player" id="music_portal_player">'
        + '<div class="portal-topline"><span>Forms FORM-29827281-12-2:</span><span id="music_signal_label">SIGNAL 00.00</span></div>'
        + '<div class="portal-track-row"><div class="portal-track-label">Now playing</div><div class="portal-track-name" id="music_now_playing">NO ACTIVE TRANSMISSION</div></div>'
        + '<div class="portal-viz" id="music_visualizer">'
        + '<canvas id="music_visualizer_canvas" width="560" height="48"></canvas>'
        + '</div>'
        + '<div class="portal-controls">'
        + '<button class="portal-button" id="music_btn_pause" onclick="DarkThemeEngine_TogglePause()" title="Pause/Resume">' + window.DarkThemeEngine_Icon('play') + '</button>'
        + '<button class="portal-button" onclick="DarkThemeEngine_SkipTrack()" title="Next Track">' + window.DarkThemeEngine_Icon('music-next') + '</button>'
        + '<span id="music_time_label" style="font-size:0.75rem;font-variant-numeric:tabular-nums;min-width:84px;text-align:right;">00:00 / 00:00</span>'
        + '<div id="music_progress_track" class="portal-progress-track"><div id="music_progress_fill" class="portal-progress-fill"></div></div>'
        + '</div></div>';
};
window.DarkThemeEngine_StopRealVisualizer = function() {
    if (window._DT_VizRAF) {
        cancelAnimationFrame(window._DT_VizRAF);
        window._DT_VizRAF = null;
    }
    if (window._DT_FallbackVizRAF) {
        cancelAnimationFrame(window._DT_FallbackVizRAF);
        window._DT_FallbackVizRAF = null;
    }
    var player = document.getElementById('music_portal_player');
    if (player) player.classList.remove('real-viz');
};
window.DarkThemeEngine_DrawPortalWave = function(data, phase) {
    var canvas = document.getElementById('music_visualizer_canvas');
    if (!canvas || !canvas.getContext) return false;
    var ctx = canvas.getContext('2d');
    var w = canvas.width, h = canvas.height;
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = 'rgba(215,154,57,0.045)';
    for (var gx = 0; gx < w; gx += 24) ctx.fillRect(gx, 0, 1, h);
    for (var gy = 8; gy < h; gy += 10) ctx.fillRect(0, gy, w, 1);
    ctx.strokeStyle = 'rgba(215,154,57,0.26)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, h * 0.5);
    ctx.lineTo(w, h * 0.5);
    ctx.stroke();
    ctx.strokeStyle = 'rgba(226,170,89,0.78)';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    var len = data ? data.length : 96;
    for (var i = 0; i < len; i++) {
        var x = (i / (len - 1)) * w;
        var amp = data ? ((data[i] - 128) / 128) : (Math.sin((i * 0.26) + phase) * 0.5 + Math.sin((i * 0.08) - phase * 1.7) * 0.24);
        var y = h * 0.5 + amp * (h * 0.32);
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();
    ctx.strokeStyle = 'rgba(255,208,138,0.22)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (var j = 0; j < len; j += 2) {
        var xx = (j / (len - 1)) * w;
        var vv = data ? ((data[j] - 128) / 128) : (Math.sin((j * 0.18) + phase * 1.35) * 0.42);
        var yy = h * 0.5 + vv * (h * 0.2);
        if (j === 0) ctx.moveTo(xx, yy); else ctx.lineTo(xx, yy);
    }
    ctx.stroke();
    return true;
};
window.DarkThemeEngine_StartFallbackVisualizer = function() {
    if (window._DT_FallbackVizRAF) cancelAnimationFrame(window._DT_FallbackVizRAF);
    var phase = 0;
    var tick = function() {
        var player = document.getElementById('music_portal_player');
        if (!player) return;
        phase += player.classList.contains('playing') ? 0.09 : 0.018;
        window.DarkThemeEngine_DrawPortalWave(null, phase);
        window._DT_FallbackVizRAF = requestAnimationFrame(tick);
    };
    tick();
};
window.DarkThemeEngine_AttachRealVisualizer = function(node) {
    if (!node) return false;
    if (window.DarkThemeEngine_StopRealVisualizer) window.DarkThemeEngine_StopRealVisualizer();
    try {
        var AC = window.AudioContext || window.webkitAudioContext;
        if (!AC) return false;
        if (!window._DT_AudioContext) window._DT_AudioContext = new AC();
        var ctx = window._DT_AudioContext;
        if (ctx.resume) ctx.resume();
        if (!node._dtVizSource) {
            node._dtVizSource = ctx.createMediaElementSource(node);
            node._dtVizSource.connect(ctx.destination);
        }
        var analyser = node._dtVizAnalyser;
        if (!analyser) {
            analyser = ctx.createAnalyser();
            analyser.fftSize = 256;
            analyser.smoothingTimeConstant = 0.66;
            node._dtVizSource.connect(analyser);
            node._dtVizAnalyser = analyser;
        }
        window._DT_Analyser = analyser;
        window._DT_VizData = new Uint8Array(analyser.fftSize);
        var player = document.getElementById('music_portal_player');
        if (player) player.classList.add('real-viz');
        var tick = function() {
            if (!window.DarkTheme_AudioNode || window.DarkTheme_AudioNode !== node || !window._DT_Analyser) {
                if (window.DarkThemeEngine_StopRealVisualizer) window.DarkThemeEngine_StopRealVisualizer();
                return;
            }
            window._DT_Analyser.getByteTimeDomainData(window._DT_VizData);
            window.DarkThemeEngine_DrawPortalWave(window._DT_VizData, 0);
            window._DT_VizRAF = requestAnimationFrame(tick);
        };
        tick();
        return true;
    } catch (e) {
        return false;
    }
};
window.DarkThemeEngine_RefreshPortalMusicPlayer = function() {
    if (window.DarkThemeEngine_EnsurePortalMusicPlayer) window.DarkThemeEngine_EnsurePortalMusicPlayer();
    if (window.DarkThemeEngine_SetCurrentMusic) window.DarkThemeEngine_SetCurrentMusic(window._DarkTheme_ActiveMusic || '');
    if (window.DarkTheme_AudioNode && !window.DarkTheme_AudioNode.paused && window.DarkThemeEngine_AttachRealVisualizer) {
        if (!window.DarkThemeEngine_AttachRealVisualizer(window.DarkTheme_AudioNode) && window.DarkThemeEngine_StartFallbackVisualizer) window.DarkThemeEngine_StartFallbackVisualizer();
    } else if (window.DarkThemeEngine_StartFallbackVisualizer && !window._DT_FallbackVizRAF) {
        window.DarkThemeEngine_StartFallbackVisualizer();
    }
};
window.DarkThemeEngine_SetCurrentMusic = function(path) {
    if (window.DarkThemeEngine_EnsurePortalMusicPlayer) window.DarkThemeEngine_EnsurePortalMusicPlayer();
    var previousMusic = window._DarkTheme_ActiveMusic;
    window._DarkTheme_ActiveMusic = path || 'None';
    var npEl = document.getElementById('music_now_playing');
    var player = document.getElementById('music_portal_player');
    var sig = document.getElementById('music_signal_label');
    var hasTrack = !!(path && path !== '');
    if (npEl) {
        npEl.textContent = hasTrack ? path.split('/').pop().replace(/\.[^/.]+$/, '') : 'NO ACTIVE TRANSMISSION';
    }
    if (player) {
        if (hasTrack) player.classList.add('playing');
        else player.classList.remove('playing');
    }
    if (sig) sig.textContent = hasTrack ? 'SIGNAL 45.6' : 'SIGNAL 00.00';
    window._DarkTheme_CurrentMusicPathJS = path || '';
    var pauseBtn = document.getElementById('music_btn_pause');
    if (pauseBtn) pauseBtn.innerHTML = window.DarkThemeEngine_Icon(hasTrack ? 'pause' : 'play');

    if (previousMusic !== path) {
        var barEl = document.getElementById('music_progress_fill');
        if (barEl) barEl.style.width = '0%';
        var lblEl = document.getElementById('music_time_label');
        if (lblEl) lblEl.textContent = '00:00 / 00:00';
    }
    if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('track', true);
};
window.DarkThemeEngine_InjectMiniPlayer = function() {};
window._DT_SetCover = function(path, coverUrl) {
    var tracks = window._DarkTheme_Music || [];
    for (var i = 0; i < tracks.length; i++) {
        if (tracks[i].path === path) {
            tracks[i].cover = coverUrl;
            break;
        }
    }
    if (window.ThemeEngineMusic) window.ThemeEngineMusic._emit('cover', true);
    var imgs = document.querySelectorAll('.music-track img');
};
window._DT_SpawnmenuSkins = [];
window.DarkThemeEngine_RenderSpawnmenuUI = function(skins, activeSkin) {
    var container = document.getElementById('misc_spawnmenu_list');
    if (!container) return;
    skins = skins || [];
    window._DT_SpawnmenuSkins = skins;
    window._DT_LastSpawnmenuActive = activeSkin;
    if (skins.length === 0) {
        container.innerHTML = '<div style="color:#64748b;font-size:0.9rem;padding:10px 0;">No spawnmenu skins detected. Install a spawnmenu theme addon.</div>';
        return;
    }
    var html = '<div id="spawn_skin_scroll" style="display:flex;flex-direction:column;gap:6px;max-height:374px;overflow-y:auto;padding-right:4px;">';
    for (var i = 0; i < skins.length; i++) {
        var s = skins[i];
        var isActive = (s.name === activeSkin);
        var safeN = s.name.replace(/'/g, "\\'");
        var wsidStr = String(s.wsid || '');
        var iconHtml = '';
        var iconStyle = 'width:48px;height:48px;border-radius:8px;object-fit:cover;flex-shrink:0;box-shadow:0 2px 8px rgba(0,0,0,0.4);';
        if (s.name === 'default') {
            iconHtml = '<img src="../materials/theme_engine/gmod_background.png" style="' + iconStyle + '" />';
        } else if (window._DarkTheme_WsidImages && window._DarkTheme_WsidImages[wsidStr]) {
            iconHtml = '<img id="spawn_icon_' + wsidStr + '" src="' + window._DarkTheme_WsidImages[wsidStr] + '" style="' + iconStyle + '" />';
        } else if (s.isLocal) {
            iconHtml = window.DarkThemeEngine_IconBox('image', 48, false, 'spawn_icon_' + wsidStr);
        } else {
            iconHtml = '<img id="spawn_icon_' + wsidStr + '" style="display:none;' + iconStyle + '" />'
                     + window.DarkThemeEngine_IconBox('image', 48, false, 'spawn_ph_' + wsidStr);
        }
        html += '<div style="display:flex;align-items:center;gap:12px;padding:10px 14px;border-radius:8px;cursor:pointer;transition:background 0.15s;flex-shrink:0;'
             + (isActive ? 'background:rgba(59,130,246,0.15);border:1px solid rgba(59,130,246,0.35);'
                         : 'background:rgba(0,0,0,0.15);border:1px solid rgba(255,255,255,0.04);')
             + '" onclick="DarkThemeEngine_LuaCall(\'DarkTheme_SetSpawnmenuSkin(\\x22' + safeN + '\\x22)\');if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">';
        html += iconHtml;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:0.95rem;font-weight:' + (isActive ? '600' : '500') + ';color:' + (isActive ? '#60a5fa' : '#e2e8f0') + ';white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + window.DarkThemeEngine_EscapeHTML(s.display || s.name) + '</div>';
        html += '<div style="font-size:0.78rem;color:#475569;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + (s.name !== 'default' ? window.DarkThemeEngine_EscapeHTML(s.addon) + ' - <code style="color:#334155;">' + window.DarkThemeEngine_EscapeHTML(s.name) + '</code>' : 'Garry\'s Mod') + '</div>';
        html += '</div>';
        if (isActive) html += '<span style="font-size:0.78rem;font-weight:600;color:#3b82f6;background:rgba(59,130,246,0.15);padding:3px 10px;border-radius:12px;flex-shrink:0;">Active</span>';
        html += '</div>';
    }
    html += '</div>';
    html += '<style>#spawn_skin_scroll::-webkit-scrollbar{width:5px}#spawn_skin_scroll::-webkit-scrollbar-track{background:rgba(255,255,255,0.03);border-radius:3px}#spawn_skin_scroll::-webkit-scrollbar-thumb{background:rgba(59,130,246,0.4);border-radius:3px}#spawn_skin_scroll::-webkit-scrollbar-thumb:hover{background:rgba(59,130,246,0.7)}</style>';
    html += '<div class="dt-inline-icon" style="margin-top:14px;padding:12px 16px;border-radius:8px;background:rgba(234,179,8,0.08);border:1px solid rgba(234,179,8,0.2);font-size:0.82rem;color:#eab308;line-height:1.5;align-items:flex-start;">' + window.DarkThemeEngine_Icon('warning') + '<span><strong>Note:</strong> Addons that replace the spawnmenu using textures (PNGs) are not compatible with Theme Engine. These addons override the default textures at engine level and cannot be controlled from Lua.</span></div>';
    html += '<div style="margin-top:10px;font-size:0.8rem;color:#475569;text-align:center;">Changes apply the next time you open the Q menu in-game.</div>';
    container.innerHTML = html;
};
window.SetDarkThemeSpawnmenuImage = function(wsid, url) {
    if (url && url.startsWith('../cache/')) url = 'asset://garrysmod/' + url.substring(3);
    window._DarkTheme_WsidImages = window._DarkTheme_WsidImages || {};
    window._DarkTheme_WsidImages[String(wsid)] = url;
    var img = document.getElementById('spawn_icon_' + wsid);
    var ph  = document.getElementById('spawn_ph_' + wsid);
    if (img) { img.src = url; img.style.display = ''; }
    if (ph)  ph.style.display = 'none';
};
window.DarkThemeEngine_SetFontSize = function(size) {
    var el = document.getElementById('dt_menu_fontsize_style');
    var slider = document.getElementById('opt_font_size');
    var label = document.getElementById('opt_font_size_label');
    if (!size || size <= 0 || size === 12) {
        if (el) el.textContent = '';
        if (slider) slider.value = 12;
        if (label) label.textContent = 'Default';
        DarkThemeEngine_LuaCall("DarkTheme_SetFontSize(0)");
        return;
    }
    if (!el) {
        el = document.createElement('style');
        el.id = 'dt_menu_fontsize_style';
        document.head.appendChild(el);
    }
    el.textContent = "body:not(.dt-theme-route-open) > *:not(#theme_options_page), body:not(.dt-theme-route-open) > *:not(#theme_options_page) * { font-size: " + size + "px !important; }";
    if (slider) slider.value = size;
    if (label) label.textContent = size + 'px';
    DarkThemeEngine_LuaCall("DarkTheme_SetFontSize(" + size + ")");
};
window.DarkThemeEngine_ApplyMenuFont = function(fontName) {
    requestAnimationFrame(function() {
        var el = document.getElementById('dt_menu_font_style');
        if (!el) {
            el = document.createElement('style');
            el.id = 'dt_menu_font_style';
            document.head.appendChild(el);
        }
        if (fontName && fontName !== '') {
            var family = "'" + window.DarkThemeEngine_EscapeCSSString(fontName) + "', sans-serif";
            el.textContent = "body:not(.dt-theme-route-open) > *:not(#theme_options_page), body:not(.dt-theme-route-open) > *:not(#theme_options_page) * { font-family: " + family + " !important; }\n"
                + "html body #theme_options_page, html body #theme_options_page * { font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif !important; }";
        } else {
            el.textContent = '';
        }
    });
};
window.DarkThemeEngine_PreviewCustomFont = function(fontName) {
    window.DarkThemeEngine_SetMenuFont(fontName || '');
};
window.DarkThemeEngine_SetMenuFont = function(fontName) {
    fontName = fontName || '';
    DarkThemeEngine_LuaCall('DarkTheme_SetMenuFont("' + window.DarkThemeEngine_SafePathForLua(fontName) + '")');
    window.DarkThemeEngine_ApplyMenuFont(fontName);
    window.DarkThemeEngine_SetFontLabel(fontName);
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
var _DT_BUILTIN_FONTS = [
    { value: '',             label: 'Default (System Font)' },
    { value: 'Segoe UI',     label: 'Segoe UI' },
    { value: 'Verdana',      label: 'Verdana' },
    { value: 'Tahoma',       label: 'Tahoma' },
    { value: 'Arial',        label: 'Arial' },
    { value: 'Impact',       label: 'Impact' },
    { value: 'Georgia',      label: 'Georgia' },
    { value: 'Courier New',  label: 'Courier New' },
    { value: 'Comic Sans MS',label: 'Comic Sans MS' },
];
var _DT_LOCAL_FONTS = [];
window.DarkThemeEngine_SetFontLabel = function(fontName) {
    window._DT_MenuFontActive = fontName || '';
    window.DarkThemeEngine_RenderFontList();
};
window.DarkThemeEngine_GetAllFonts = function() {
    var allFonts = _DT_BUILTIN_FONTS.slice();
    for (var li = 0; li < _DT_LOCAL_FONTS.length; li++) allFonts.push(_DT_LOCAL_FONTS[li]);
    return allFonts;
};
window.DarkThemeEngine_RenderFontList = function() {
    var listEl = document.getElementById('misc_font_list');
    if (!listEl) return;
    var oldScroll = listEl.scrollTop || 0;
    var active = window._DT_MenuFontActive || '';
    var allFonts = window.DarkThemeEngine_GetAllFonts();
    var html = '';
    for (var i = 0; i < allFonts.length; i++) {
        var f = allFonts[i];
        var value = f.value || '';
        var safeVal = value.replace(/'/g, "\\'");
        var isActive = value === active;
        var cssName = window.DarkThemeEngine_EscapeCSSString(value);
        var ff = value ? ("'" + cssName + "', sans-serif") : "'Segoe UI', sans-serif";
        var kind = value ? (f.local ? 'Local font' : 'System font') : "Garry's Mod default";
        html += '<div class="dt-font-row' + (isActive ? ' is-active' : '') + '" onclick="DarkThemeEngine_SetMenuFont(\'' + safeVal + '\')">';
        html += '<div class="dt-font-sample" style="font-family:' + ff + ' !important;">Aa Theme</div>';
        html += '<div style="flex:1;min-width:0;"><div class="dt-font-title" style="font-family:' + ff + ' !important;">' + window.DarkThemeEngine_EscapeHTML(f.label) + '</div>';
        html += '<div class="dt-font-meta">' + kind + '</div></div>';
        if (isActive) html += '<span class="dt-active-pill">Active</span>';
        html += '</div>';
    }
    listEl.innerHTML = html;
    listEl.scrollTop = oldScroll;
};
window.DarkThemeEngine_ToggleFontDropdown = function() {
    window.DarkThemeEngine_RenderFontList();
};
window.DarkThemeEngine_LoadLocalFonts = function(fonts) {
    var styleEl = document.getElementById('dt_local_fonts_style');
    if (!styleEl) {
        styleEl = document.createElement('style');
        styleEl.id = 'dt_local_fonts_style';
        document.head.appendChild(styleEl);
    }
    _DT_LOCAL_FONTS = [];
    var css = '';
    fonts = fonts || [];
    for (var i = 0; i < fonts.length; i++) {
        var f = fonts[i];
        css += "@font-face { font-family: '" + f.name + "'; src: url('" + f.url + "'); }\n";
        _DT_LOCAL_FONTS.push({ value: f.name, label: f.name, local: true });
    }
    styleEl.textContent = css;
    window.DarkThemeEngine_RenderFontList();
};
window.DarkThemeEngine_ShowAddCustomBg = function() {
    var old = document.getElementById('dt_addbg_popup');
    if (old) { old.remove(); return; }
    var popup = document.createElement('div');
    popup.id = 'dt_addbg_popup';
    popup.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;';
    popup.innerHTML = '<div style="background:rgba(15,23,42,0.98);border-radius:12px;padding:28px;width:420px;max-width:92vw;border:1px solid rgba(255,255,255,0.08);box-shadow:0 25px 50px rgba(0,0,0,0.6);color:#e2e8f0;">'
        + '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;">'
        + '<span style="font-size:1.1rem;font-weight:600;color:#f8fafc;">Add Custom Background</span>'
        + '<button id="dt_addbg_x" style="background:none;border:none;color:#64748b;cursor:pointer;font-size:1.2rem;">' + window.DarkThemeEngine_Icon('close') + '</button>'
        + '</div>'
        + '<div style="font-size:0.85rem;color:#64748b;margin-bottom:16px;">Image will be saved to <code style="color:#94a3b8;">data/theme_engine_backgrounds/</code> and appear in the <strong>Custom Backgrounds</strong> category.</div>'
        + '<label style="display:block;font-size:0.85rem;color:#94a3b8;margin-bottom:5px;">Image URL (.jpg or .png)</label>'
        + '<input id="dt_addbg_url" type="text" class="theme-input" placeholder="https://..." style="width:100%;box-sizing:border-box;padding:8px 12px;margin-bottom:12px;" />'
        + '<label style="display:block;font-size:0.85rem;color:#94a3b8;margin-bottom:5px;">Filename (optional)</label>'
        + '<input id="dt_addbg_name" type="text" class="theme-input" placeholder="my_background.jpg" style="width:100%;box-sizing:border-box;padding:8px 12px;margin-bottom:16px;" />'
        + '<div id="dt_addbg_status" style="font-size:0.85rem;min-height:20px;margin-bottom:12px;color:#94a3b8;"></div>'
        + '<div style="display:flex;gap:8px;">'
        + '<button id="dt_addbg_ok" class="dt-inline-icon" style="flex:1;justify-content:center;padding:9px 0;background:rgba(16,185,129,0.18);color:#34d399;border:1px solid rgba(16,185,129,0.35);border-radius:7px;cursor:pointer;font-size:0.9rem;font-weight:600;font-family:inherit;">' + window.DarkThemeEngine_Icon('download') + 'Download & Add</button>'
        + '<button id="dt_addbg_cl" style="padding:9px 14px;background:rgba(255,255,255,0.06);color:#94a3b8;border:1px solid rgba(255,255,255,0.1);border-radius:7px;cursor:pointer;font-size:0.9rem;font-family:inherit;">Cancel</button>'
        + '</div></div>';
    document.body.appendChild(popup);
    var urlEl   = document.getElementById('dt_addbg_url');
    var nameEl  = document.getElementById('dt_addbg_name');
    var statusEl= document.getElementById('dt_addbg_status');
    var okBtn   = document.getElementById('dt_addbg_ok');
    document.getElementById('dt_addbg_x').onclick  = function() { popup.remove(); };
    document.getElementById('dt_addbg_cl').onclick = function() { popup.remove(); };
    popup.onclick = function(e) { if (e.target === popup) popup.remove(); };
    window.DT_OnCustomBgDone = function(fname) {
        statusEl.style.color = '#34d399';
        statusEl.innerHTML = window.DarkThemeEngine_Icon('check') + 'Saved as ' + window.DarkThemeEngine_EscapeHTML(fname) + '. Backgrounds refreshed!';
        okBtn.disabled = false;
        okBtn.innerHTML = window.DarkThemeEngine_Icon('download') + 'Download & Add';
        setTimeout(function() { DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }, 200);
    };
    window.DT_OnCustomBgError = function(msg) {
        statusEl.style.color = '#f87171';
        statusEl.innerHTML = window.DarkThemeEngine_Icon('warning') + window.DarkThemeEngine_EscapeHTML(msg);
        okBtn.disabled = false;
        okBtn.innerHTML = window.DarkThemeEngine_Icon('download') + 'Download & Add';
    };
    okBtn.onclick = function() {
        var url  = (urlEl.value || '').trim();
        var name = (nameEl.value || '').trim();
        if (!url) { statusEl.style.color='#f59e0b'; statusEl.textContent='Please enter a URL.'; return; }
        if (!name) {
            name = url.split('/').pop().split('?')[0] || 'background.jpg';
        }
        statusEl.style.color = '#94a3b8';
        statusEl.innerHTML = window.DarkThemeEngine_Icon('timer') + 'Downloading...';
        okBtn.disabled = true;
        okBtn.innerHTML = window.DarkThemeEngine_Icon('timer') + 'Downloading...';
        var sUrl = window.DarkThemeEngine_SafePathForLua(url);
        var sName = window.DarkThemeEngine_SafePathForLua(name);
        DarkThemeEngine_LuaCall('DarkTheme_SaveCustomBackground("' + sUrl + '","' + sName + '")');
    };
    urlEl.focus();
};
window.DarkThemeEngine_SetMusicOpt = function(key, value) {
    window._DarkTheme_MusicOptions = window._DarkTheme_MusicOptions || {};
    window._DarkTheme_MusicOptions[key] = value;
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetMusicOption('" + key + "', " + (value ? "true" : "false") + ")");
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
    DarkThemeEngine_UpdateMusicFadeOptions();
};
window.DarkThemeEngine_UpdateMusicFadeOptions = function() {
    var chkEnable = document.getElementById('opt_music_enable');
    var isEnabled = !!(chkEnable && chkEnable.checked);
    var ids = ['fade_playlist', 'fade_shuffle', 'fade_volume'];
    for (var i = 0; i < ids.length; i++) {
        var el = document.getElementById(ids[i]);
        if (el) el.style.display = isEnabled ? '' : 'none';
    }
};
window.DarkThemeEngine_SetVolumeFromSlider = function(val) {
    var v = Math.max(0, Math.min(1, parseInt(val) / 100));
    window.DarkTheme_MusicVolume = v;
    window._DarkTheme_MusicOptions = window._DarkTheme_MusicOptions || {};
    window._DarkTheme_MusicOptions['Music_Volume'] = v;
    if (window.DarkTheme_AudioNode) window.DarkTheme_AudioNode.volume = v;
    var lbl = document.getElementById('music_volume_label');
    if (lbl) lbl.textContent = val + '%';
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetMusicOption('Music_Volume', " + v + ")");
};
window.DarkThemeEngine_FilterMusic = function() {
    DarkThemeEngine_RenderMusicUI();
};

window.DarkThemeEngine_RenderMusicUI = function() {
    var tracks = window._DarkTheme_Music || [];
    var disabled = window._DarkTheme_DisabledMusic || {};
    var opts = window._DarkTheme_MusicOptions || {};
    var chkEnable = document.getElementById('opt_music_enable');
    var chkPlaylist = document.getElementById('opt_music_playlist');
    var chkShuffle = document.getElementById('opt_music_shuffle');
    if (chkEnable) chkEnable.checked = !!opts.EnableMusic;
    if (chkPlaylist) chkPlaylist.checked = !!opts.Music_PlaylistMode;
    if (chkShuffle) chkShuffle.checked = !!opts.Music_Shuffle;
    DarkThemeEngine_UpdateMusicFadeOptions();
    var npEl = document.getElementById('music_now_playing');
    if (npEl) {
        var a = window._DarkTheme_ActiveMusic;
        npEl.textContent = 'Now Playing: ' + (a && a !== 'None' && a !== '' ? a.split('/').pop().replace(/\.[^/.]+$/, '') : 'None');
    }
    var filterEl = document.getElementById('music_search_input');
    var filter = filterEl ? filterEl.value.toLowerCase() : '';
    var filtered = [];
    for (var i = 0; i < tracks.length; i++) {
        var t = tracks[i];
        if (filter && (t.title || '').toLowerCase().indexOf(filter) === -1 && (t.artist || '').toLowerCase().indexOf(filter) === -1 && (t.name || '').toLowerCase().indexOf(filter) === -1) continue;
        filtered.push({ track: t, originalIndex: i });
    }
    var html = '';
    if (!opts.EnableMusic) {
        html += '<div style="display:flex;align-items:center;gap:12px;background:rgba(239,68,68,0.12);border:1px solid rgba(239,68,68,0.3);border-radius:10px;padding:14px 20px;margin-bottom:16px;color:#fca5a5;font-size:0.95rem;">';
        html += window.DarkThemeEngine_Icon('block');
        html += '<div><strong style="color:#f87171;">Music is disabled.</strong> Enable it above using the "Enable Menu Music" toggle to hear your tracks.</div>';
        html += '</div>';
    } else {
        var enabledCount = 0;
        var disabledAlbums2 = window._DarkTheme_DisabledAlbums || {};
        for (var ei = 0; ei < tracks.length; ei++) {
            if (!disabled[tracks[ei].path] && !disabledAlbums2[tracks[ei].album || '']) enabledCount++;
        }
        html += '<div style="display:flex;align-items:center;gap:12px;background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.25);border-radius:10px;padding:10px 16px;margin-bottom:14px;color:#6ee7b7;font-size:0.9rem;">';
        html += window.DarkThemeEngine_Icon('check');
        html += '<div><strong style="color:#34d399;">' + enabledCount + ' of ' + tracks.length + ' tracks enabled</strong>';
        if (enabledCount === 0) html += ' - <span style="color:#f87171;">All tracks are disabled, nothing will play.</span>';
        html += '</div></div>';
    }
    var filterEl = document.getElementById('music_search_input');
    var filter   = filterEl ? filterEl.value.toLowerCase() : '';
    if (filter) {
        var filtered = [];
        for (var i = 0; i < tracks.length; i++) {
            var t = tracks[i];
            if ((t.title || '').toLowerCase().indexOf(filter) !== -1 || (t.artist || '').toLowerCase().indexOf(filter) !== -1 || (t.name || '').toLowerCase().indexOf(filter) !== -1) {
                filtered.push({ track: t, originalIndex: i });
            }
        }
        if (filtered.length === 0) {
            html += '<div style="text-align:center;color:#94a3b8;padding:30px;background:rgba(0,0,0,0.2);border-radius:8px;">No tracks match your search.</div>';
        } else {
            html += '<div class="music-list">';
            for (var i = 0; i < filtered.length; i++) {
                var t = filtered[i].track;
                var idx = filtered[i].originalIndex;
                var isDisabled = !!disabled[t.path];
                var encodedPath = encodeURIComponent(t.path);
                html += '<div class="music-track' + (isDisabled ? ' music-disabled' : '') + '" data-path="' + encodedPath + '" onclick="window.DarkThemeEngine_ToggleTrackJS(this);if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')" oncontextmenu="event.preventDefault();DarkThemeEngine_OpenMusicPreview(' + idx + ')">';
                html += '<div class="music-track-icon">';
                if (t.cover) html += '<img src="' + t.cover + '" style="width:100%;height:100%;object-fit:cover;" />';
                else html += window.DarkThemeEngine_Icon('music');
                html += '</div>';
                html += '<div class="music-track-copy">';
                var sTitle = (t.title || 'Unknown');
                var sArtist = (t.artist || 'Unknown Artist');
                html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:1.1rem;font-weight:bold;margin-bottom:2px;color:#f8fafc;" title="' + window.DarkThemeEngine_EscapeHTML(sTitle) + '">' + window.DarkThemeEngine_EscapeHTML(sTitle) + '</span>';
                html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.85rem;color:#94a3b8;font-weight:500;" title="' + window.DarkThemeEngine_EscapeHTML(sArtist) + '">' + window.DarkThemeEngine_EscapeHTML(sArtist) + '</span>';
                html += '<span class="music-track-hint">Right-click for track info</span>';
                html += '</div>';
                if (!isDisabled) html += '<div class="music-status-label" style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);">ENABLED</div>';
                else html += '<div class="music-status-label" style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;background:rgba(148,163,184,0.1);color:#94a3b8;border:1px solid rgba(148,163,184,0.2);">DISABLED</div>';
                html += '</div>';
            }
            html += '</div>';
        }
        var trList2 = document.getElementById('music_track_list');
        var albView2 = document.getElementById('music_album_view');
        var detView2 = document.getElementById('music_album_detail_view');
        var loading2 = document.getElementById('music_loading');
        if (loading2) loading2.style.display = 'none';
        if (trList2)  { trList2.innerHTML = html; trList2.style.display = 'block'; }
        if (albView2) albView2.style.display = 'none';
        if (detView2) detView2.style.display = 'none';
    } else {
        var npEl = document.getElementById('music_now_playing');
        if (npEl) {
            var a = window._DarkTheme_ActiveMusic;
            npEl.textContent = 'Now Playing: ' + (a && a !== 'None' && a !== '' ? a.split('/').pop().replace(/\.[^/.]+$/, '') : 'None');
        }
        var statusContainer = document.getElementById('music_track_list');
        if (statusContainer) { statusContainer.innerHTML = html; statusContainer.style.display = 'block'; }

        if (window._DarkTheme_SelectedAlbum !== null) {
            window.DarkThemeEngine_ShowAlbumDetail(window._DarkTheme_SelectedAlbum);
        } else {
            window.DarkThemeEngine_RenderAlbumCards();
        }
    }
};
window.DarkThemeEngine_OpenMusicPreview = function(index) {
    var tracks = window._DarkTheme_Music || [];
    if (index < 0 || index >= tracks.length) return;
    window._MusicPreview = { visible: true, index: index };
    var modal = document.getElementById('music_preview_modal');
    if (!modal) return;
    modal.innerHTML = '';
    var overlay = document.createElement('div');
    overlay.className = 'preview-overlay';
    overlay.onclick = function() { DarkThemeEngine_CloseMusicPreview(); };
    var card = document.createElement('div');
    card.className = 'music-detail-card';
    card.onclick = function(e) { e.stopPropagation(); };
    card.id = 'music_preview_card';
    DarkThemeEngine_BuildMusicPreviewContent(card, tracks[index], index, tracks.length);
    overlay.appendChild(card);
    modal.appendChild(overlay);
    modal.style.display = 'block';
};
window.DarkThemeEngine_BuildMusicPreviewContent = function(card, track, index, total) {
    card.innerHTML = '';
    var closeBtn = document.createElement('div');
    closeBtn.style.cssText = 'position:absolute;top:12px;right:12px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#64748b;font-size:1.2rem;border-radius:50%;background:rgba(255,255,255,0.05);transition:color 0.2s,background 0.2s;border:1px solid rgba(255,255,255,0.08);';
    closeBtn.innerHTML = window.DarkThemeEngine_Icon('close');
    closeBtn.onclick = function() { DarkThemeEngine_CloseMusicPreview(); };
    closeBtn.onmouseover = function() { this.style.color='#fff'; this.style.background='rgba(239,68,68,0.3)'; };
    closeBtn.onmouseout = function() { this.style.color='#64748b'; this.style.background='rgba(255,255,255,0.05)'; };
    card.appendChild(closeBtn);
    if (track.cover) {
        var coverImg = document.createElement('img');
        coverImg.className = 'music-detail-cover';
        coverImg.src = track.cover;
        card.appendChild(coverImg);
    } else {
        var placeholder = document.createElement('div');
        placeholder.className = 'music-detail-placeholder';
        placeholder.innerHTML = window.DarkThemeEngine_Icon('music');
        card.appendChild(placeholder);
    }
    var infoDiv = document.createElement('div');
    infoDiv.style.cssText = 'text-align:center;width:100%;';
    infoDiv.innerHTML = '<div style="font-size:1.5rem;font-weight:700;color:#f8fafc;margin-bottom:4px;">' + window.DarkThemeEngine_EscapeHTML(track.title || 'Unknown') + '</div><div style="font-size:1rem;color:#94a3b8;font-weight:500;">' + window.DarkThemeEngine_EscapeHTML(track.artist || 'Unknown Artist') + '</div>';
    card.appendChild(infoDiv);
    if (track.desc) {
        var descDiv = document.createElement('div');
        descDiv.style.cssText = 'text-align:center;color:#cbd5e1;font-style:italic;font-size:0.9rem;opacity:0.8;padding:0 10px;';
        descDiv.textContent = '"' + track.desc + '"';
        card.appendChild(descDiv);
    }
    var metaDiv = document.createElement('div');
    metaDiv.style.cssText = 'display:flex;flex-direction:column;gap:8px;align-items:center;width:100%;margin-top:5px;';
    metaDiv.innerHTML = '<div style="font-size:0.8rem;color:#64748b;word-break:break-all;">' + window.DarkThemeEngine_EscapeHTML(track.path) + '</div>';
    var safeYoutube = String(track.youtube || '');
    if (/^https:\/\/(www\.youtube\.com\/watch\?v=|youtube\.com\/watch\?v=|youtu\.be\/)[A-Za-z0-9_-]+$/.test(safeYoutube)) {
        var ytBtn = document.createElement('div');
        ytBtn.className = 'yt-button';
        ytBtn.innerHTML = window.DarkThemeEngine_Icon('link') + 'Watch on YouTube';
        ytBtn.onclick = function() { DarkThemeEngine_LuaCall("if gui and gui.OpenURL then gui.OpenURL('" + safeYoutube + "') end"); };
        metaDiv.appendChild(ytBtn);
    }
    card.appendChild(metaDiv);
    var navDiv = document.createElement('div');
    navDiv.style.cssText = 'display:flex;align-items:center;justify-content:center;gap:20px;width:100%;margin-top:10px;padding-top:15px;border-top:1px solid rgba(255,255,255,0.06);';
    var prevBtn = document.createElement('div');
    prevBtn.style.cssText = 'width:40px;height:40px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#94a3b8;font-size:1.5rem;border-radius:8px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.08);transition:color 0.2s,background 0.2s;';
    prevBtn.innerHTML = window.DarkThemeEngine_Icon('prev');
    prevBtn.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_MusicPreviewPrev(); };
    prevBtn.onmouseover = function() { this.style.color='#fff'; this.style.background='rgba(59,130,246,0.2)'; };
    prevBtn.onmouseout = function() { this.style.color='#94a3b8'; this.style.background='rgba(255,255,255,0.05)'; };
    navDiv.appendChild(prevBtn);
    var counter = document.createElement('span');
    counter.style.cssText = 'font-size:0.9rem;color:#64748b;font-weight:500;';
    counter.id = 'music_preview_counter';
    counter.textContent = (index + 1) + ' / ' + total;
    navDiv.appendChild(counter);
    var nextBtn = document.createElement('div');
    nextBtn.style.cssText = 'width:40px;height:40px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#94a3b8;font-size:1.5rem;border-radius:8px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.08);transition:color 0.2s,background 0.2s;';
    nextBtn.innerHTML = window.DarkThemeEngine_Icon('next');
    nextBtn.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_MusicPreviewNext(); };
    nextBtn.onmouseover = function() { this.style.color='#fff'; this.style.background='rgba(59,130,246,0.2)'; };
    nextBtn.onmouseout = function() { this.style.color='#94a3b8'; this.style.background='rgba(255,255,255,0.05)'; };
    navDiv.appendChild(nextBtn);
    card.appendChild(navDiv);
};
window.DarkThemeEngine_CloseMusicPreview = function() {
    window._MusicPreview = { visible: false, index: 0 };
    var modal = document.getElementById('music_preview_modal');
    if (modal) { modal.innerHTML = ''; modal.style.display = 'none'; }
};
window.DarkThemeEngine_MusicPreviewNext = function() {
    var p = window._MusicPreview;
    var tracks = window._DarkTheme_Music || [];
    if (!p || tracks.length === 0) return;
    p.index = (p.index + 1) % tracks.length;
    var card = document.getElementById('music_preview_card');
    if (card) DarkThemeEngine_BuildMusicPreviewContent(card, tracks[p.index], p.index, tracks.length);
};
window.DarkThemeEngine_MusicPreviewPrev = function() {
    var p = window._MusicPreview;
    var tracks = window._DarkTheme_Music || [];
    if (!p || tracks.length === 0) return;
    p.index = (p.index - 1 + tracks.length) % tracks.length;
    var card = document.getElementById('music_preview_card');
    if (card) DarkThemeEngine_BuildMusicPreviewContent(card, tracks[p.index], p.index, tracks.length);
};
window.DarkThemeEngine_InjectLink = function() {
    if (window._DarkThemeEngine_Disabled) return;
    // Only inject on main menu page, not addons/options/servers/etc
    var hash = window.location.hash || '';
    if (hash && hash !== '#' && hash !== '#/' && hash !== '#/main/' && hash !== '#/main') {
        return;
    }
    var allLinks = document.querySelectorAll('.options a, .mainmenu a');
    if (allLinks.length === 0) {
        if (!window._DT_InjectRetry) {
            window._DT_InjectRetry = setInterval(function() {
                window.DarkThemeEngine_InjectLink();
            }, 300);
            setTimeout(function() {
                if (window._DT_InjectRetry) { clearInterval(window._DT_InjectRetry); window._DT_InjectRetry = null; }
            }, 15000);
        }
        return;
    }

    function normText(node) {
        return String((node && node.textContent) || '').replace(/\s+/g, '').toLowerCase();
    }
    function isThemeOptionsLink(node) {
        if (!node || node.tagName.toLowerCase() !== 'a') return false;
        var href = String(node.getAttribute('href') || '').toLowerCase();
        var label = normText(node);
        return href.indexOf('#/theme') !== -1 || label === 'themeoptions' || label === 'themeengineoptions';
    }
    function looksLikeOptions(node) {
        if (!node) return false;
        var localizationAttr = String(node.getAttribute('ng-tranny') || node.getAttribute('ng-Tranny') || '').toLowerCase();
        var label = normText(node);
        return localizationAttr.indexOf('options') !== -1 || label === 'options' || label === 'opciones' || label === 'option';
    }

    var optionsLink = null;
    for (var i = 0; i < allLinks.length; i++) {
        if (looksLikeOptions(allLinks[i])) { optionsLink = allLinks[i]; break; }
    }
    if (!optionsLink) {
        for (var j = 0; j < allLinks.length; j++) {
            var text = (allLinks[j].textContent || '').toLowerCase();
            if (text.indexOf('option') !== -1 || text.indexOf('opcion') !== -1) { optionsLink = allLinks[j]; break; }
        }
    }
    if (!optionsLink && allLinks.length > 0) optionsLink = allLinks[allLinks.length - 1];
    if (!optionsLink) return;

    var optionsLi = optionsLink.parentElement;
    var found = [];
    var everyLink = document.querySelectorAll('a');
    for (var k = 0; k < everyLink.length; k++) {
        if (isThemeOptionsLink(everyLink[k])) found.push(everyLink[k]);
    }

    var a = found[0] || document.createElement('a');
    for (var r = 1; r < found.length; r++) {
        var oldParent = found[r].parentElement;
        found[r].remove();
        if (oldParent && oldParent !== optionsLi && oldParent.children.length === 0 && oldParent.parentElement) oldParent.remove();
    }

    var desiredTag = optionsLi && optionsLi.tagName && optionsLi.tagName.toLowerCase() === 'li' ? 'li' : 'div';
    var li = a.parentElement && a.parentElement.tagName && a.parentElement.tagName.toLowerCase() === desiredTag ? a.parentElement : document.createElement(desiredTag);
    if (a.parentElement !== li) li.appendChild(a);

    a.id = 'theme_options_btn';
    a.removeAttribute('ng-click');
    a.removeAttribute('onclick');
    a.removeAttribute('ng-href');
    a.removeAttribute('ng-tranny');
    a.removeAttribute('ng-Tranny');
    a.href = '#/theme/';
    a.textContent = 'Theme Options';
    if (!a.className && optionsLink.className) a.className = optionsLink.className;
    if (a.className.indexOf('ui_sound_return') === -1) a.className += (a.className ? ' ' : '') + 'ui_sound_return';
    if (!a.getAttribute('style') && optionsLink.getAttribute('style')) a.setAttribute('style', optionsLink.getAttribute('style'));
    a.style.position = 'relative';

    if (!a._DTThemeHoverBound) {
        a._DTThemeHoverBound = true;
        a.addEventListener('mouseenter', function() { if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_hover.wav'); });
    }

    var newDot = document.createElement('span');
    newDot.id = 'dt_menu_new_dot';
    newDot.style.cssText = 'display:none;position:absolute;top:2px;right:-12px;width:8px;height:8px;background:#ef4444;border-radius:50%;box-shadow:0 0 8px rgba(239,68,68,0.8);pointer-events:none;';
    a.appendChild(newDot);

    if (optionsLi && optionsLi.parentElement) optionsLi.parentElement.insertBefore(li, optionsLi.nextSibling);
    if (window._DT_InjectRetry) { clearInterval(window._DT_InjectRetry); window._DT_InjectRetry = null; }
};
window.DarkThemeEngine_CleanupAllOverlays = function() {
    var c = document.querySelector('.theme-container');
    var guide = document.getElementById('dt_workshop_guide');
    if (guide) { guide.remove(); if (c) c.classList.remove('guide-open'); }
    var changelog = document.getElementById('dt_changelog_panel');
    if (changelog) changelog.remove();
    if (window.DarkThemeEngine_ClosePreview) window.DarkThemeEngine_ClosePreview();
    if (window.DarkThemeEngine_CloseMusicPreview) window.DarkThemeEngine_CloseMusicPreview();
};
window.DarkThemeEngine_Unload = function() {
    try {
        window.DarkThemeEngine_CleanupAllOverlays();
        var removable = [
            'theme_options_btn', 'dt_help_panel', 'dt_changelog_panel',
            'bg_preview_modal', 'music_preview_modal', 'dt_addbg_popup',
            'dark_theme_custom_overlay', 'dt_menu_font_style',
            'dt_menu_fontsize_style', 'dt_local_fonts_style'
        ];
        for (var i = 0; i < removable.length; i++) {
            var node = document.getElementById(removable[i]);
            if (!node) continue;
            if (removable[i] === 'theme_options_btn' && node.parentElement &&
                (node.parentElement.tagName || '').toLowerCase() === 'li') {
                node.parentElement.remove();
            } else {
                node.remove();
            }
        }

        if (document && document.body) {
            document.body.classList.remove('dark-theme-custom-active', 'dt-modal-open');
            document.body.removeAttribute('data-theme-engine-custom');
        }

        if (window._DT_InjectRetry) clearInterval(window._DT_InjectRetry);
        if (window._DarkTheme_PreviewTimer) clearInterval(window._DarkTheme_PreviewTimer);
        if (window._DarkTheme_PreviewFadeTimer) clearTimeout(window._DarkTheme_PreviewFadeTimer);
        if (window._DarkTheme_PreviewResetTimer) clearTimeout(window._DarkTheme_PreviewResetTimer);
        if (window._DarkTheme_GladosTimer) clearInterval(window._DarkTheme_GladosTimer);
        if (window._DT_ChangelogRetryTimer) clearInterval(window._DT_ChangelogRetryTimer);
        if (window._DT_ChangelogChunkTimer) clearTimeout(window._DT_ChangelogChunkTimer);
        if (window._DT_WorkshopGuardRetry) clearTimeout(window._DT_WorkshopGuardRetry);
        if (window._DT_WorkshopRefreshTimer) clearTimeout(window._DT_WorkshopRefreshTimer);
        if (window._DT_VizRAF) cancelAnimationFrame(window._DT_VizRAF);
        if (window._DT_FallbackVizRAF) cancelAnimationFrame(window._DT_FallbackVizRAF);

        if (window._DT_MenuSoundInputBound) {
            var clickHandler = window._DT_MenuSoundClickHandler;
            var hoverHandler = window._DT_MenuSoundHoverHandler;
            if (clickHandler) {
                window.removeEventListener('mousedown', clickHandler, true);
                window.removeEventListener('mouseup', clickHandler, true);
                window.removeEventListener('click', clickHandler, true);
                window.removeEventListener('keydown', clickHandler, true);
                window.removeEventListener('touchstart', clickHandler, true);
            }
            if (hoverHandler) {
                window.removeEventListener('mouseover', hoverHandler, true);
                window.removeEventListener('mousemove', hoverHandler, true);
            }
        }

        if (typeof lua !== 'undefined' && window._DT_OriginalPlaySound) {
            lua.PlaySound = window._DT_OriginalPlaySound;
        }

        if (typeof Subscriptions !== 'undefined' && Subscriptions.prototype) {
            var proto = Subscriptions.prototype;
            if (proto._DT_OriginalSubscribe) proto.Subscribe = proto._DT_OriginalSubscribe;
            if (proto._DT_OriginalUnsubscribe) proto.Unsubscribe = proto._DT_OriginalUnsubscribe;
            if (proto._DT_OriginalApplyChanges) proto.ApplyChanges = proto._DT_OriginalApplyChanges;
        }

        try {
            var injector = angular.element(document.body).injector();
            if (injector) {
                var $templateCache = injector.get('$templateCache');
                var $route = injector.get('$route');
                $templateCache.remove('template/dark_theme.html');
                delete $route.routes['/theme/'];
                delete $route.routes['/theme'];
                if (String(window.location.hash || '').indexOf('#/theme') === 0) window.location.hash = '#/';
                else if ($route.reload) $route.reload();
            }
        } catch (routeError) {}

        window._DT_MenuSoundHooked = false;
        window._DT_MenuSoundInputBound = false;
        window._DT_WorkshopGuardInstalled = false;
        window._DT_InjectRetry = null;
        window._DarkTheme_PreviewTimer = null;
        window._DarkTheme_GladosTimer = null;
        window._DT_VizRAF = null;
        window._DT_FallbackVizRAF = null;
        window._DarkTheme_IsAnniversary = false;
        window.DarkThemeEngine_InjectLink = function() {};
        window.DarkThemeEngine_InjectMiniPlayer = function() {};
    } catch (e) {}
};
window.addEventListener('hashchange', function() {
    var hash = window.location.hash;
    if (hash === '#/' || hash === '#' || hash === '') {
        setTimeout(function() { window.DarkThemeEngine_InjectLink(); if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew(); }, 50);
        setTimeout(function() { window.DarkThemeEngine_InjectLink(); if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew(); }, 200);
        setTimeout(window.DarkThemeEngine_InjectMiniPlayer, 250);
        if (window._DarkTheme_IsAnniversary) {
            setTimeout(window.DarkThemeEngine_SwapAnniLogo, 100);
            setTimeout(window.DarkThemeEngine_SwapAnniLogo, 300);
        }
    }
    window.DarkThemeEngine_CleanupAllOverlays();
    if (hash.indexOf('#/theme') === 0) {
        setTimeout(function() { if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew(); }, 100);
        setTimeout(function() { if(window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }, 120);
        setTimeout(function() { if(window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendMenuSoundPacksToJS()'); }, 140);
        setTimeout(function() { if(window.DarkThemeEngine_LuaCall) window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendGladosLinesToJS()'); }, 160);
    }
});
setTimeout(function() {
    try {
        var scope = angular.element(document.body).scope();
        if (scope && scope.$on) scope.$on('$routeChangeSuccess', function() {
            setTimeout(function() { window.DarkThemeEngine_InjectLink(); if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew(); }, 50);
            if (window._DarkTheme_IsAnniversary) setTimeout(window.DarkThemeEngine_SwapAnniLogo, 100);
            window.DarkThemeEngine_CleanupAllOverlays();
        });
    } catch(e) {}
}, 500);
]==]
DarkThemeEngine._UI.BuildRouteJS = function(templateHtml)
    local escaped = string.JavascriptSafe(templateHtml)
    return string.format([==[
(function() {
    var injector = angular.element(document.body).injector();
    if (!injector) { return; }
    var $templateCache = injector.get('$templateCache');
    $templateCache.put('template/dark_theme.html', "%s");
    var $route = injector.get('$route');
    $route.routes['/theme/'] = { templateUrl:'template/dark_theme.html', reloadOnSearch:true, keys:[], regexp:/^\/theme\/$/, originalPath:'/theme/' };
    $route.routes['/theme'] = $route.routes['/theme/'];
})();
    ]==], escaped)
end
DarkThemeEngine._UI.AnniversaryJS = [==[
(function() {
    var eatenDate = window.DarkTheme_CakeEaten_Date || '';
    var d = new Date();
    var isAnniversary = (d.getMonth() === 10 && d.getDate() === 29);
    var currentDayString = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
    if (!isAnniversary) {
        if (eatenDate !== '') {
            DarkThemeEngine_LuaCall("DarkTheme_SetCakeCookie('')");
        }
        return;
    }
    window._DarkTheme_IsAnniversary = true;
    window.DarkThemeEngine_SwapAnniLogo = function() {
        var logo = document.querySelector('.options ul li:first-child img:not(#anni_logo)');
        if (logo) {
            logo.style.display = 'none';
            if (logo.parentElement) logo.parentElement.style.minHeight = '80px';
            if (!document.getElementById('anni_logo')) {
                var anniLogo = document.createElement('img');
                anniLogo.id = 'anni_logo';
                anniLogo.src = '../materials/theme_engine/logo_anniversary.png';
                logo.parentElement.appendChild(anniLogo);
            }
        }
    };
    var logoRetry = setInterval(function() {
        var logo = document.querySelector('.options ul li:first-child img');
        if (logo) {
            clearInterval(logoRetry);
            window.DarkThemeEngine_SwapAnniLogo();
        }
    }, 200);
    if (eatenDate !== currentDayString) {
        var backdrop = document.createElement('div');
        backdrop.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(0,0,0,0.92);z-index:99998;display:flex;justify-content:center;align-items:center;transition:opacity 1.5s ease-in-out;';
        var cake = document.createElement('img');
        cake.src = '../materials/theme_engine/Cake.png';
        cake.style.cssText = 'width:400px;height:auto;cursor:pointer;z-index:99999;transition:transform 0.25s cubic-bezier(0.175,0.885,0.32,1.275),opacity 0.5s;filter:drop-shadow(0px 15px 30px rgba(0,0,0,0.8));';
        var pageUI = document.querySelector('.page');
        if (pageUI) pageUI.style.opacity = '0';
        cake.onmouseover = function() { cake.style.transform = 'scale(1.15) rotate(5deg)'; };
        cake.onmouseout = function() { cake.style.transform = 'scale(1) rotate(0deg)'; };
        cake.onclick = function() {
            var audio = new Audio('../sound/theme_engine_sound/nom.wav');
            audio.volume = 0.8;
            audio.play();
            cake.style.transform = 'scale(0) rotate(-45deg)';
            cake.style.opacity = '0';
            backdrop.style.opacity = '0';
            backdrop.style.pointerEvents = 'none';
            if (pageUI) {
                pageUI.style.transition = 'opacity 2s ease-in-out';
                pageUI.style.opacity = '1';
            }
            window.DarkTheme_CakeEaten_Date = currentDayString;
            DarkThemeEngine_LuaCall("DarkTheme_SetCakeCookie('" + currentDayString + "')");
            setTimeout(function() { backdrop.remove(); }, 2000);
        };
        backdrop.appendChild(cake);
        document.body.appendChild(backdrop);
    }
})();
]==]
