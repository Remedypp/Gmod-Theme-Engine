DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}
DarkThemeEngine._UI.JS = [==[
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
        if (window._DarkTheme_BgDirty) { window._DarkTheme_BgDirty = false; DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }
        else if (window.DarkThemeEngine_RenderBackgroundsUI) { window.DarkThemeEngine_RenderBackgroundsUI(); }
    }
    if (tabName === 'music') {
        if (window._DarkTheme_MusicDirty) { window._DarkTheme_MusicDirty = false; DarkThemeEngine_LuaCall('DarkThemeEngine.SendMusicToJS()'); }
        else if (window.DarkThemeEngine_RenderMusicUI) { window.DarkThemeEngine_RenderMusicUI(); }
    }
    if (tabName === 'misc') {
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
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetMode('" + mode + "')");
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_UpdateUI = function() {
    var mode = window._DarkThemeEngine_SavedMode || 'light';
    var items = { light: document.getElementById('theme_item_light'), dark: document.getElementById('theme_item_dark') };
    for (var k in items) { if (items[k]) { if (k === mode) items[k].classList.add('active-theme'); else items[k].classList.remove('active-theme'); } }
};
window.DarkThemeEngine_LuaCall = function(code) { if (typeof lua !== 'undefined' && lua.Run) lua.Run(code); };
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
    if (window.DarkThemeEngine_UpdateMusicFadeOptions) window.DarkThemeEngine_UpdateMusicFadeOptions();
};
window._DarkTheme_Backgrounds = [];
window._DarkTheme_DisabledBgs = {};
window._DarkTheme_ActiveBg = 'None';
window._DarkTheme_BgOptions = {};
window._DarkTheme_SelectedCategory = null;
window._DarkTheme_Categories = [];
window.SetCurrentDarkThemeBackground = function(bgPath) {
    window._DarkTheme_ActiveBg = bgPath || 'None';
    var el = document.getElementById('bg_now_playing');
    if (el) el.textContent = 'Now Playing: ' + (bgPath && bgPath !== 'None' ? bgPath.split('/').pop() : 'None');
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
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_UpdateFadeOptions = function(isStatic) {
    var fadeFade = document.getElementById('fade_nofade');
    var fadeInterval = document.getElementById('fade_interval');
    if (fadeFade) fadeFade.style.display = isStatic ? 'none' : '';
    if (fadeInterval) fadeInterval.style.display = isStatic ? 'none' : '';
};
window.DarkThemeEngine_ShowAddMusicGuide = function() { window.DarkThemeEngine_ShowHelp('music'); };
window.DarkThemeEngine_ShowHelp = function(section) {
    var existing = document.getElementById('dt_help_panel');
    if (existing) { existing.remove(); return; }
    var SECTIONS = [
        { id: 'music', icon: '🎵', title: 'Menu Music', content:
            '<p style="color:#94a3b8;margin-top:0;">Add custom music to your GMod main menu.</p>'
            + '<div class="dt-guide-step"><strong>Local files (easiest)</strong><br>Drop <code>.mp3</code> or <code>.wav</code> files into:<br><code>garrysmod/data/theme_engine_music/</code><br>No addon needed. Music appears immediately.</div>'
            + '<div class="dt-guide-step"><strong>Subfolders = Albums</strong><br>Create subfolders inside <code>theme_engine_music/</code> to organise tracks into albums:<br><code>data/theme_engine_music/MyAlbum/track1.mp3</code></div>'
            + '<div class="dt-guide-step"><strong>Custom metadata (titles, artist, cover art)</strong><br>Create <code>te_music_meta.json</code> in <code>data/theme_engine_music/</code>. Each song is a key matching the filename exactly. To add more songs, just add more entries:<div style="background:rgba(0,0,0,0.5);padding:10px;border-radius:6px;margin-top:8px;font-family:Consolas,monospace;font-size:0.78rem;color:#a5b4fc;white-space:pre;overflow-x:auto;">{\n  "song.mp3": {\n    "title": "My Track",\n    "artist": "Artist Name",\n    "desc": "A cool track",\n    "youtube": "https://youtu.be/..."\n  },\n  "another_song.mp3": {\n    "title": "Another Track",\n    "artist": "Someone Else",\n    "desc": "Another cool track"\n  }\n}</div><div style="font-size:0.8rem;color:#64748b;margin-top:6px;">All fields are optional. If a field is missing, the engine reads it from the MP3 ID3 tag automatically.</div></div>'
            + '<div class="dt-guide-step"><strong>Workshop addon</strong><br>Put audio in <code>sound/theme_engine_music/</code>, metadata in <code>data_static/te_music_meta.json</code>. Use <a href="https://github.com/WilliamVenner/gmpublisher" style="color:#3b82f6;">gmpublisher</a> to publish.</div>'
        },
        { id: 'backgrounds', icon: '🖼️', title: 'Backgrounds', content:
            '<p style="color:#94a3b8;margin-top:0;">Manage background images shown in the main menu.</p>'
            + '<div class="dt-guide-step"><strong>Adding custom backgrounds</strong><br>Use the <em>+ Add Image</em> button to download any image URL directly into the <em>Custom Backgrounds</em> category.<br>Or drop <code>.jpg</code> / <code>.png</code> files manually into <code>garrysmod/data/theme_engine_backgrounds/</code>.</div>'
            + '<div class="dt-guide-step"><strong>Where backgrounds come from</strong><br>The engine scans all mounted addons for <code>backgrounds/*.jpg|png</code> and per-gamemode backgrounds.<br>Subscribe to background addons on the Workshop and they appear automatically.</div>'
            + '<div class="dt-guide-step"><strong>Controls</strong><br>• Click a category to see its backgrounds<br>• Click a background to enable/disable it<br>• Right-click a background for a full preview<br>• Use <em>Disable All / Enable All</em> buttons to toggle an entire category</div>'
            + '<div class="dt-guide-step"><strong>Animation options</strong><br>• <strong>Static</strong>: No automatic rotation<br>• <strong>Disable Zoom</strong>: Remove the slow zoom effect<br>• <strong>Instant Cut</strong>: No fade between backgrounds<br>• <strong>Speed</strong>: How often it changes (5–120s)<br>• <strong>Dim</strong>: Darken the background (0–70%)</div>'
        },
        { id: 'spawnmenu', icon: '🎮', title: 'Spawnmenu Skin', content:
            '<p style="color:#94a3b8;margin-top:0;">Change the visual theme of the in-game Q menu.</p>'
            + '<div class="dt-guide-step"><strong>How it works</strong><br>Install a spawnmenu skin addon from the Workshop, then select it here. The change applies the next time you open the Q menu in-game.</div>'
            + '<div class="dt-guide-step"><strong>Singleplayer</strong><br>Works fully — skin applies as soon as you open the Q menu.</div>'
            + '<div class="dt-guide-step"><strong>Multiplayer servers</strong><br>⚠ Only works if the server has the Theme Engine addon mounted. If the server doesn\'t have it, the default spawnmenu will show regardless of your selection.</div>'
            + '<div class="dt-guide-step"><strong>Reverting</strong><br>Select <em>Default GMod</em> to restore the original spawnmenu appearance. All skin addon hooks are removed cleanly.</div>'
        },
        { id: 'fonts', icon: '🔤', title: 'Custom Fonts', content:
            '<p style="color:#94a3b8;margin-top:0;">Change the font used throughout the main menu.</p>'
            + '<div class="dt-guide-step"><strong>Built-in fonts</strong><br>Pick any font from the dropdown. Previews update instantly. Click Reset to go back to the default.</div>'
            + '<div class="dt-guide-step"><strong>Type any font name</strong><br>If you know a font installed on your system, type its name in the text field and click Apply.</div>'
            + '<div class="dt-guide-step"><strong>Local .ttf fonts</strong><br>Drop <code>.ttf</code> font files into:<br><code>garrysmod/data/theme_engine_fonts/</code><br>They will appear in the dropdown automatically after reloading the menu.</div>'
        },
    ];
    var panel = document.createElement('div');
    panel.id = 'dt_help_panel';
    panel.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.65);z-index:9999;display:flex;align-items:center;justify-content:center;';
    var activeSection = section || 'music';
    function renderHelp() {
        var sec = null;
        for (var i = 0; i < SECTIONS.length; i++) { if (SECTIONS[i].id === activeSection) { sec = SECTIONS[i]; break; } }
        if (!sec) sec = SECTIONS[0];
        var tabs = '';
        for (var i = 0; i < SECTIONS.length; i++) {
            var s = SECTIONS[i];
            var isActive = s.id === activeSection;
            tabs += '<button onclick="window._DT_HelpSection=\'' + s.id + '\';document.getElementById(\'dt_help_panel\').remove();window.DarkThemeEngine_ShowHelp(window._DT_HelpSection);" style="display:flex;align-items:center;gap:8px;width:100%;padding:10px 14px;background:' + (isActive ? 'rgba(59,130,246,0.15)' : 'transparent') + ';border:none;border-radius:8px;color:' + (isActive ? '#60a5fa' : '#94a3b8') + ';font-size:0.9rem;font-weight:' + (isActive ? '600' : '400') + ';cursor:pointer;text-align:left;font-family:inherit;transition:background 0.15s;">' + s.icon + ' ' + s.title + '</button>';
        }
        var inner = '<div style="display:flex;width:720px;max-width:94vw;height:75vh;max-height:560px;background:rgba(15,23,42,0.98);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border-radius:14px;border:1px solid rgba(255,255,255,0.08);box-shadow:0 30px 60px rgba(0,0,0,0.7);overflow:hidden;">'
            + '<div style="width:185px;flex-shrink:0;padding:20px 12px;border-right:1px solid rgba(255,255,255,0.06);display:flex;flex-direction:column;gap:4px;overflow-y:auto;">'
            + '<div style="font-size:0.75rem;font-weight:700;color:#475569;text-transform:uppercase;letter-spacing:0.8px;padding:4px 14px 10px;">Help Topics</div>'
            + tabs
            + '</div>'
            + '<div style="flex:1;padding:24px 28px;overflow-y:auto;color:#e2e8f0;font-size:0.92rem;line-height:1.6;">'
            + '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;padding-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.07);">'
            + '<span style="font-size:1.2rem;font-weight:700;color:#f8fafc;">' + sec.icon + ' ' + sec.title + '</span>'
            + '<button id="dt_help_x" style="background:none;border:none;color:#64748b;cursor:pointer;font-size:1.2rem;padding:4px;">✕</button>'
            + '</div>'
            + sec.content
            + '</div>'
            + '</div>';
        panel.innerHTML = inner;
        document.body.appendChild(panel);
        document.getElementById('dt_help_x').onclick = function() { panel.remove(); };
        panel.onclick = function(e) { if (e.target === panel) panel.remove(); };
    }
    renderHelp();
};
window.DarkThemeEngine_ShowChangelog = function() {
    var existing = document.getElementById('dt_changelog_panel');
    if (existing) { existing.remove(); return; }
    var panel = document.createElement('div');
    panel.id = 'dt_changelog_panel';
    panel.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;';

    var logs = window._DarkThemeChangelog || [];

    var inner = '<style>'
        + '#dt_changelog_inner::-webkit-scrollbar{width:6px}'
        + '#dt_changelog_inner::-webkit-scrollbar-track{background:rgba(255,255,255,0.03);border-radius:3px}'
        + '#dt_changelog_inner::-webkit-scrollbar-thumb{background:rgba(59,130,246,0.5);border-radius:3px}'
        + '#dt_changelog_inner::-webkit-scrollbar-thumb:hover{background:rgba(59,130,246,0.8)}'
        + '</style>';
    inner += '<div id="dt_changelog_inner" style="width:620px;max-width:92vw;max-height:72vh;overflow-y:auto;background:rgba(15,23,42,0.98);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);padding:30px;border-radius:12px;border:1px solid rgba(255,255,255,0.08);box-shadow:0 25px 50px -12px rgba(0,0,0,0.7);color:#e2e8f0;font-size:0.95rem;line-height:1.5;">';
    inner += '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding-bottom:15px;border-bottom:1px solid rgba(255,255,255,0.08);">';
    inner += '<span style="font-size:1.3rem;font-weight:600;color:#f8fafc;">Changelog</span>';
    inner += '<button id="dt_changelog_x" style="background:none;border:none;color:#94a3b8;cursor:pointer;font-size:1.2rem;">\u2715</button>';
    inner += '</div>';
    for (var i = 0; i < logs.length; i++) {
        var entry = logs[i];
        inner += '<div style="margin-bottom:20px;' + (i < logs.length-1 ? 'padding-bottom:20px;border-bottom:1px solid rgba(255,255,255,0.05);' : '') + '">';
        inner += '<div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">';
        inner += '<span style="font-weight:700;color:#60a5fa;font-size:1.05rem;">v' + entry.ver + '</span>';
        if (entry.tag) inner += '<span style="font-size:0.7rem;padding:2px 8px;background:rgba(59,130,246,0.15);color:#60a5fa;border:1px solid rgba(59,130,246,0.3);border-radius:4px;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">' + entry.tag + '</span>';
        inner += '</div>';
        for (var j = 0; j < entry.changes.length; j++) {
            inner += '<div style="padding:6px 0 6px 14px;color:#cbd5e1;font-size:0.9rem;border-left:2px solid rgba(255,255,255,0.06);margin-left:4px;">';
            inner += '<span style="color:#475569;margin-right:8px;">&#8226;</span>' + entry.changes[j];
            inner += '</div>';
        }
        inner += '</div>';
    }
    var credits = window._DarkThemeCredits || [];
    if (credits.length > 0) {
        inner += '<div style="margin-top:10px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.08);">';
        for (var cv = 0; cv < credits.length; cv++) {
            var cver = credits[cv];
            inner += '<div style="font-size:0.8rem;font-weight:700;color:#475569;text-transform:uppercase;letter-spacing:0.8px;margin-bottom:10px;">Credits — v' + cver.ver + '</div>';
            var cent = cver.entries || [];
            for (var ci = 0; ci < cent.length; ci++) {
                inner += '<div style="display:flex;gap:10px;margin-bottom:6px;font-size:0.88rem;">';
                inner += '<span style="color:#475569;min-width:130px;">' + cent[ci].role + '</span>';
                inner += '<span style="color:#94a3b8;">' + cent[ci].name + '</span>';
                inner += '</div>';
            }
        }
        inner += '</div>';
    }
    inner += '</div>';
    panel.innerHTML = inner;
    panel.onclick = function(e) { if (e.target === panel) panel.remove(); };
    document.body.appendChild(panel);
    try { localStorage.setItem('DarkTheme_LastSeenChangelog', logs[0].ver); } catch(e) {}
    var dot = document.getElementById('dt_changelog_new');
    if (dot) dot.style.display = 'none';
    document.getElementById('dt_changelog_x').onclick = function() { panel.remove(); };
};
window.DarkThemeEngine_CheckChangelogNew = function() {
    var currentVer = (window._DarkThemeChangelog && window._DarkThemeChangelog[0]) ? window._DarkThemeChangelog[0].ver : '';
    var seen = '';
    try { seen = localStorage.getItem('DarkTheme_LastSeenChangelog') || ''; } catch(e) {}
    var btn = document.getElementById('dt_changelog_btn');
    var dot = document.getElementById('dt_changelog_new');
    if (seen !== currentVer) {
        if (btn) {
            btn.style.background = 'rgba(239,68,68,0.18)';
            btn.style.color = '#fca5a5';
            btn.style.borderColor = 'rgba(239,68,68,0.4)';
            btn.style.fontWeight = '600';
            btn.title = 'New update: ' + currentVer;
        }
        if (dot) dot.style.display = 'block';
    } else {
        if (btn) {
            btn.style.background = '';
            btn.style.color = '';
            btn.style.borderColor = '';
            btn.style.fontWeight = '';
            btn.title = '';
        }
        if (dot) dot.style.display = 'none';
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
    if (chkStatic) chkStatic.checked = !!opts.BG_Static;
    if (chkNoZoom) chkNoZoom.checked = !!opts.BG_NoZoom;
    if (chkNoFade) chkNoFade.checked = !!opts.BG_NoFade;
    DarkThemeEngine_UpdateFadeOptions(!!opts.BG_Static);
    var npEl = document.getElementById('bg_now_playing');
    if (npEl) npEl.textContent = 'Now Playing: ' + (window._DarkTheme_ActiveBg !== 'None' ? window._DarkTheme_ActiveBg.split('/').pop() : 'None');
    var cats = window.DarkThemeEngine_BuildCategories(bgs);
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
            iconHtml = '<div style="width:80px;height:80px;border-radius:8px;background:rgba(255,255,255,0.05);display:flex;align-items:center;justify-content:center;font-size:2.5rem;color:#94a3b8;border:1px solid rgba(255,255,255,0.1);flex-shrink:0;min-width:80px;">📁</div>';
        } else if (cat.wsid && cat.wsid !== '' && cat.wsid !== '0') {
            iconHtml = '<img id="cat_icon_' + cat.wsid + '" style="display:none;width:80px;height:80px;border-radius:8px;object-fit:cover;box-shadow:0 4px 10px rgba(0,0,0,0.4);flex-shrink:0;min-width:80px;" />';
            iconHtml += '<div id="cat_placeholder_' + cat.wsid + '" style="width:80px;height:80px;border-radius:8px;background:rgba(59,130,246,0.1);display:flex;align-items:center;justify-content:center;font-size:2.5rem;color:#3b82f6;border:1px solid rgba(59,130,246,0.2);flex-shrink:0;min-width:80px;">☁️</div>';
        } else {
            iconHtml = '<div style="width:80px;height:80px;border-radius:8px;background:rgba(255,255,255,0.05);display:flex;align-items:center;justify-content:center;font-size:2.5rem;color:#94a3b8;border:1px solid rgba(255,255,255,0.1);flex-shrink:0;min-width:80px;">🎮</div>';
        }
        html += '<div class="cat-card" onclick="DarkThemeEngine_ShowCategoryDetail(\'' + cat.name.replace(/'/g, "\\'") + '\')">';
        html += iconHtml;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:1.15rem;font-weight:600;color:#f8fafc;margin-bottom:4px;white-space:pre-wrap;word-break:break-word;">' + cat.name + '</div>';
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
    html += '<div style="display:flex;align-items:center;gap:15px;margin-bottom:20px;background:rgba(0,0,0,0.25);padding:12px 18px;border-radius:12px;border-left:4px solid #3b82f6;backdrop-filter:blur(5px);">';
    html += '<button class="theme-btn" style="padding:10px 14px;margin-right:10px;background:rgba(255,255,255,0.1);border:none;" onclick="DarkThemeEngine_RenderBackgroundsUI();if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">← Back</button>';
    if (catObj.imageUrl) {
        html += '<img src="' + catObj.imageUrl + '" style="width:54px;height:54px;border-radius:8px;object-fit:cover;box-shadow:0 4px 10px rgba(0,0,0,0.4);" />';
    } else if (catObj.isLocal) {
        html += '<div style="width:54px;height:54px;border-radius:8px;background:rgba(255,255,255,0.05);display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:#94a3b8;border:1px solid rgba(255,255,255,0.1);">📁</div>';
    } else if (catObj.wsid) {
        html += '<div style="width:54px;height:54px;border-radius:8px;background:rgba(59,130,246,0.1);display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:#3b82f6;border:1px solid rgba(59,130,246,0.2);">☁️</div>';
    }
    html += '<div style="flex:1;">';
    html += '<div style="font-size:1.15rem;font-weight:600;color:#f8fafc;margin-bottom:2px;">' + catObj.name + '</div>';
    html += '<div style="font-size:0.85rem;color:#94a3b8;display:flex;align-items:center;gap:10px;">';
    html += '<span>' + catBgs.length + ' Backgrounds</span>';
    if (catObj.wsid && catObj.wsid !== '' && catObj.wsid !== '0') {
        html += '<span style="color:#60a5fa;cursor:pointer;font-weight:500;" onclick="event.stopPropagation();DarkThemeEngine_LuaCall(\'if gui and gui.OpenURL then gui.OpenURL(\\\'https://steamcommunity.com/sharedfiles/filedetails/?id=' + catObj.wsid + '\\\') end\')">↗ View on Steam</span>';
    }
    html += '</div>';
    html += '<div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:10px;">';
    var escapedCat = catName.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    html += '<button class="theme-btn" style="font-size:0.8rem;padding:6px 12px;background:rgba(239,68,68,0.15);color:#f87171;border-color:rgba(239,68,68,0.3);" onclick="event.stopPropagation();DarkThemeEngine_DisableCategory(\'' + escapedCat + '\')">🚫 Disable All</button>';
    html += '<button class="theme-btn" style="font-size:0.8rem;padding:6px 12px;background:rgba(16,185,129,0.15);color:#34d399;border-color:rgba(16,185,129,0.3);" onclick="event.stopPropagation();DarkThemeEngine_EnableCategory(\'' + escapedCat + '\')">✓ Enable All</button>';
    html += '</div>';
    html += '</div></div>';
    html += '<div class="bg-grid">';
    for (var i = 0; i < catBgs.length; i++) {
        var bg = catBgs[i];
        var isDisabled = !!disabled[bg.path];
        var filename = bg.path.split('/').pop();
        var escapedPath = bg.path.replace(/'/g, "\\'");
        html += '<div class="bg-card' + (isDisabled ? ' bg-disabled' : '') + '" ';
        html += 'onclick="DarkThemeEngine_ToggleBg(\'' + escapedPath + '\', this)" ';
        html += 'oncontextmenu="event.preventDefault();DarkThemeEngine_OpenBgPreview(\'' + escapedPath + '\',\'' + catName.replace(/'/g, "\\'") + '\')" ';
        html += '>';
        html += '<img src="../' + bg.path + '" loading="lazy" />';
        html += '<div class="bg-name">' + filename + '</div>';
        html += '<div class="bg-disabled-badge">DISABLED</div>';
        html += '</div>';
    }
    html += '</div>';
    var catView = document.getElementById('bg_categories_view');
    var detView = document.getElementById('bg_detail_view');
    if (catView) catView.style.display = 'none';
    if (detView) { detView.innerHTML = html; detView.style.display = 'block'; }
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_ToggleBg = function(bgPath, cardEl) {
    if (window._DarkTheme_DisabledBgs[bgPath]) delete window._DarkTheme_DisabledBgs[bgPath];
    else window._DarkTheme_DisabledBgs[bgPath] = true;
    DarkThemeEngine_LuaCall("DarkThemeEngine_ToggleBackground('" + bgPath.replace(/'/g, "\\'") + "')");
    if (cardEl) {
        if (window._DarkTheme_DisabledBgs[bgPath]) cardEl.classList.add('bg-disabled');
        else cardEl.classList.remove('bg-disabled');
    }
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
    var safeName = catName.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    DarkThemeEngine_LuaCall("DarkThemeEngine_DisableCategoryBackgrounds('" + safeName + "')");
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
    var safeName = catName.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    DarkThemeEngine_LuaCall("DarkThemeEngine_EnableCategoryBackgrounds('" + safeName + "')");
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
    modal.innerHTML = '';
    var overlay = document.createElement('div');
    overlay.className = 'preview-overlay';
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
    closeBtn.textContent = '✕';
    closeBtn.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_ClosePreview(); };
    overlay.appendChild(closeBtn);
    var leftArrow = document.createElement('div');
    leftArrow.className = 'preview-arrow left';
    leftArrow.textContent = '‹';
    leftArrow.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_PreviewPrev(); };
    overlay.appendChild(leftArrow);
    var rightArrow = document.createElement('div');
    rightArrow.className = 'preview-arrow right';
    rightArrow.textContent = '›';
    rightArrow.onclick = function(e) { e.stopPropagation(); DarkThemeEngine_PreviewNext(); };
    overlay.appendChild(rightArrow);
    var previewImg = document.createElement('img');
    previewImg.className = 'preview-bg-image';
    previewImg.id = 'preview_main_img';
    previewImg.src = '../' + cur.path;
    previewImg.onclick = function(e) { e.stopPropagation(); };
    overlay.appendChild(previewImg);
    var nameLabel = document.createElement('div');
    nameLabel.className = 'preview-bg-name';
    nameLabel.id = 'preview_name_label';
    nameLabel.textContent = cur.path.split('/').pop() + ' — ' + (startIdx + 1) + ' / ' + allBgs.length;
    overlay.appendChild(nameLabel);
    modal.appendChild(overlay);
    modal.style.display = 'block';
};
window.DarkThemeEngine_UpdatePreview = function() {
    var p = window._BgPreview;
    if (!p || !p.visible || p.list.length === 0) return;
    var cur = p.list[p.index];
    var img = document.getElementById('preview_main_img');
    var nameLabel = document.getElementById('preview_name_label');
    var catImg = document.getElementById('preview_cat_img');
    var catText = document.getElementById('preview_cat_text');
    if (img) img.src = '../' + cur.path;
    if (nameLabel) nameLabel.textContent = cur.path.split('/').pop() + ' — ' + (p.index + 1) + ' / ' + p.list.length;
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
        var safeKey = alb.key.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
        var icon = alb.key === ''
            ? '<div style="width:70px;height:70px;border-radius:8px;background:rgba(59,130,246,0.12);display:flex;align-items:center;justify-content:center;font-size:2rem;flex-shrink:0;border:1px solid rgba(59,130,246,0.2);">🎵</div>'
            : '<div style="width:70px;height:70px;border-radius:8px;background:rgba(16,185,129,0.1);display:flex;align-items:center;justify-content:center;font-size:2rem;flex-shrink:0;border:1px solid rgba(16,185,129,0.2);">💿</div>';
        html += '<div class="cat-card" style="' + (isAlbumDisabled ? 'opacity:0.5;' : '') + '" onclick="DarkThemeEngine_ShowAlbumDetail(\'' + safeKey + '\')">';
        html += icon;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + alb.display + '</div>';
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
window.DarkThemeEngine_ToggleTrackJS = function(elem, path) {
    if (!window._DarkTheme_DisabledMusic) window._DarkTheme_DisabledMusic = {};
    var disabled = window._DarkTheme_DisabledMusic;
    var isDisabled = !!disabled[path];
    var statusDiv = elem.querySelector('.music-status-label');
    if (isDisabled) {
        disabled[path] = false;
        delete disabled[path];
        elem.classList.remove('music-disabled');
        if (statusDiv) {
            statusDiv.textContent = 'ENABLED';
            statusDiv.style.background = 'rgba(16,185,129,0.15)';
            statusDiv.style.color = '#34d399';
            statusDiv.style.border = '1px solid rgba(16,185,129,0.3)';
        }
    } else {
        disabled[path] = true;
        elem.classList.add('music-disabled');
        if (statusDiv) {
            statusDiv.textContent = 'DISABLED';
            statusDiv.style.background = 'rgba(148,163,184,0.1)';
            statusDiv.style.color = '#94a3b8';
            statusDiv.style.border = '1px solid rgba(148,163,184,0.2)';
        }
    }
    DarkThemeEngine_LuaCall('DarkThemeEngine_ToggleMusic("' + path.replace(/"/g, '\\"') + '")');
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
    var safeKey = albumKey.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    var html = '';
    html += '<div style="display:flex;align-items:center;gap:15px;margin-bottom:20px;background:rgba(0,0,0,0.25);padding:12px 18px;border-radius:12px;border-left:4px solid #3b82f6;backdrop-filter:blur(5px);">';
    html += '<button class="theme-btn" style="padding:10px 14px;background:rgba(255,255,255,0.1);border:none;" onclick="DarkThemeEngine_RenderAlbumCards();if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">← Back</button>';
    html += '<div style="flex:1;">';
    html += '<div style="font-size:1.1rem;font-weight:600;color:#f8fafc;margin-bottom:8px;">' + albObj.display + '</div>';
    html += '<div style="display:flex;gap:8px;">';
    if (isAlbumDisabled) {
        html += '<button class="theme-btn" style="font-size:0.8rem;padding:6px 12px;background:rgba(16,185,129,0.15);color:#34d399;border-color:rgba(16,185,129,0.3);" onclick="window._DarkTheme_DisabledAlbums[\'' + safeKey + '\']=false;delete window._DarkTheme_DisabledAlbums[\'' + safeKey + '\'];DarkThemeEngine_LuaCall(\'DarkThemeEngine_EnableAlbum(\\x22' + safeKey + '\\x22)\');DarkThemeEngine_ShowAlbumDetail(\'' + safeKey + '\')">✓ Enable Album</button>';
    } else {
        html += '<button class="theme-btn" style="font-size:0.8rem;padding:6px 12px;background:rgba(239,68,68,0.15);color:#f87171;border-color:rgba(239,68,68,0.3);" onclick="window._DarkTheme_DisabledAlbums[\'' + safeKey + '\']=true;DarkThemeEngine_LuaCall(\'DarkThemeEngine_DisableAlbum(\\x22' + safeKey + '\\x22)\');DarkThemeEngine_ShowAlbumDetail(\'' + safeKey + '\')">🚫 Disable Album</button>';
    }
    html += '</div></div></div>';
    html += '<div class="music-list">';
    var allTracks = window._DarkTheme_Music || [];
    for (var i = 0; i < albObj.tracks.length; i++) {
        var t = albObj.tracks[i];
        var isDisabled = isAlbumDisabled || !!disabled[t.path];
        var safePath = t.path.replace(/'/g, "\\'").replace(/"/g, '');
        var globalIdx = allTracks.indexOf(t);
        html += '<div class="music-track' + (isDisabled ? ' music-disabled' : '') + '"';
        html += ' onclick="window.DarkThemeEngine_ToggleTrackJS(this, \'' + safePath.replace(/"/g, '') + '\');if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')"';
        html += ' oncontextmenu="event.preventDefault();DarkThemeEngine_OpenMusicPreview(' + globalIdx + ')">';
        html += '<div style="width:48px;height:48px;background:rgba(0,0,0,0.4);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;overflow:hidden;border:1px solid rgba(255,255,255,0.05);">';
        if (t.cover) html += '<img src="' + t.cover + '" style="width:100%;height:100%;object-fit:cover;" />';
        else html += '<span style="font-size:24px;color:#94a3b8;">🎵</span>';
        html += '</div>';
        html += '<div style="flex:1;overflow:hidden;display:flex;flex-direction:column;justify-content:center;">';
        html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:1rem;font-weight:bold;color:#f8fafc;">' + (t.title || t.name || 'Unknown') + '</span>';
        html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.85rem;color:#94a3b8;">' + (t.artist || 'Unknown Artist') + '</span>';
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
window.DarkThemeEngine_SetCurrentMusic = function(path) {
    var previousMusic = window._DarkTheme_ActiveMusic;
    window._DarkTheme_ActiveMusic = path || 'None';
    var npEl = document.getElementById('music_now_playing');
    if (npEl) {
        npEl.textContent = 'Now Playing: ' + (path && path !== '' ? path.split('/').pop().replace(/\.[^/.]+$/, '') : 'None');
    }
    window._DarkTheme_CurrentMusicPathJS = path || '';
    
    if (previousMusic !== path) {
        var barEl = document.getElementById('music_progress_fill');
        if (barEl) barEl.style.width = '0%';
        var lblEl = document.getElementById('music_time_label');
        if (lblEl) lblEl.textContent = '00:00 / 00:00';
    }
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
            iconHtml = '<div id="spawn_icon_' + wsidStr + '" style="width:48px;height:48px;border-radius:8px;background:rgba(255,255,255,0.05);display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;border:1px solid rgba(255,255,255,0.08);">📁</div>';
        } else {
            iconHtml = '<img id="spawn_icon_' + wsidStr + '" style="display:none;' + iconStyle + '" />'
                     + '<div id="spawn_ph_' + wsidStr + '" style="width:48px;height:48px;border-radius:8px;background:rgba(59,130,246,0.08);display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;border:1px solid rgba(59,130,246,0.15);">☁️</div>';
        }
        html += '<div style="display:flex;align-items:center;gap:12px;padding:10px 14px;border-radius:8px;cursor:pointer;transition:background 0.15s;flex-shrink:0;'
             + (isActive ? 'background:rgba(59,130,246,0.15);border:1px solid rgba(59,130,246,0.35);'
                         : 'background:rgba(0,0,0,0.15);border:1px solid rgba(255,255,255,0.04);')
             + '" onclick="DarkThemeEngine_LuaCall(\'DarkTheme_SetSpawnmenuSkin(\\x22' + safeN + '\\x22)\');if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')">';
        html += iconHtml;
        html += '<div style="flex:1;overflow:hidden;">';
        html += '<div style="font-size:0.95rem;font-weight:' + (isActive ? '600' : '500') + ';color:' + (isActive ? '#60a5fa' : '#e2e8f0') + ';white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + (s.display || s.name) + '</div>';
        html += '<div style="font-size:0.78rem;color:#475569;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + (s.name !== 'default' ? s.addon + ' · <code style="color:#334155;">' + s.name + '</code>' : 'Garry\'s Mod') + '</div>';
        html += '</div>';
        if (isActive) html += '<span style="font-size:0.78rem;font-weight:600;color:#3b82f6;background:rgba(59,130,246,0.15);padding:3px 10px;border-radius:12px;flex-shrink:0;">Active</span>';
        html += '</div>';
    }
    html += '</div>';
    html += '<style>#spawn_skin_scroll::-webkit-scrollbar{width:5px}#spawn_skin_scroll::-webkit-scrollbar-track{background:rgba(255,255,255,0.03);border-radius:3px}#spawn_skin_scroll::-webkit-scrollbar-thumb{background:rgba(59,130,246,0.4);border-radius:3px}#spawn_skin_scroll::-webkit-scrollbar-thumb:hover{background:rgba(59,130,246,0.7)}</style>';
    html += '<div style="margin-top:14px;padding:12px 16px;border-radius:8px;background:rgba(234,179,8,0.08);border:1px solid rgba(234,179,8,0.2);font-size:0.82rem;color:#eab308;line-height:1.5;">⚠️ <strong>Note:</strong> Addons that replace the spawnmenu using textures (PNGs) are not compatible with Theme Engine. These addons override the default textures at engine level and cannot be controlled from Lua.</div>';
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
window.DarkThemeEngine_ApplyMenuFont = function(fontName) {
    var prev = document.getElementById('misc_font_preview');
    if (prev) prev.style.fontFamily = (fontName && fontName !== '') ? ("'" + fontName + "', sans-serif") : '';
    requestAnimationFrame(function() {
        var el = document.getElementById('dt_menu_font_style');
        if (!el) {
            el = document.createElement('style');
            el.id = 'dt_menu_font_style';
            document.head.appendChild(el);
        }
        if (fontName && fontName !== '') {
            el.textContent = "* { font-family: '" + fontName + "', sans-serif !important; }";
        } else {
            el.textContent = '';
        }
    });
};
window.DarkThemeEngine_PreviewCustomFont = function(fontName) {
    var prev = document.getElementById('misc_font_preview');
    if (prev) prev.style.fontFamily = fontName ? ("'" + fontName + "', sans-serif") : '';
};
window.DarkThemeEngine_SetMenuFont = function(fontName) {
    DarkThemeEngine_LuaCall("DarkTheme_SetMenuFont('" + (fontName || '').replace(/'/g, "\\'") + "')");
    window.DarkThemeEngine_ApplyMenuFont(fontName);
    window.DarkThemeEngine_SetFontLabel(fontName || '');
    var listEl = document.getElementById('misc_font_list');
    if (listEl) listEl.style.display = 'none';
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
    var lbl = document.getElementById('misc_font_label');
    if (!lbl) return;
    if (!fontName) { lbl.textContent = 'Default (System Font)'; lbl.style.fontFamily = ''; return; }
    lbl.textContent = fontName;
    lbl.style.fontFamily = "'" + fontName + "', sans-serif";
};
window.DarkThemeEngine_ToggleFontDropdown = function() {
    var listEl = document.getElementById('misc_font_list');
    if (!listEl) return;
    if (listEl.style.display !== 'none') {
        listEl.style.display = 'none';
        var tc = document.querySelector('.theme-container');
        if (tc) tc.style.overflow = '';
        return;
    }
    var tc = document.querySelector('.theme-container');
    if (tc) tc.style.overflow = 'visible';
    var allFonts = _DT_BUILTIN_FONTS.slice();
    if (_DT_LOCAL_FONTS.length > 0) {
        allFonts.push({ value: null, label: '── Local Fonts ──', disabled: true });
        for (var li = 0; li < _DT_LOCAL_FONTS.length; li++) allFonts.push(_DT_LOCAL_FONTS[li]);
    }
    var html = '';
    for (var i = 0; i < allFonts.length; i++) {
        var f = allFonts[i];
        if (f.disabled) {
            html += '<div style="padding:6px 12px;font-size:0.75rem;color:#475569;user-select:none;">' + f.label + '</div>';
        } else {
            var safeVal = (f.value || '').replace(/'/g, "\\'");
            var ff = f.value ? ("'" + f.value + "', sans-serif") : 'inherit';
            html += '<div onclick="DarkThemeEngine_SetMenuFont(\'' + safeVal + '\')" style="padding:9px 14px;font-size:0.9rem;cursor:pointer;color:#e2e8f0;font-family:' + ff + ';transition:background 0.1s;" onmouseover="this.style.background=\'rgba(59,130,246,0.15)\'" onmouseout="this.style.background=\'\'">' + f.label + '</div>';
        }
    }
    listEl.innerHTML = html;
    listEl.style.display = 'block';
    setTimeout(function() {
        document.addEventListener('click', function _close(e) {
            var dd = document.getElementById('misc_font_dropdown');
            if (dd && !dd.contains(e.target)) {
                var l = document.getElementById('misc_font_list');
                if (l) l.style.display = 'none';
                var tc = document.querySelector('.theme-container');
                if (tc) tc.style.overflow = '';
            }
            document.removeEventListener('click', _close);
        });
    }, 10);
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
    for (var i = 0; i < fonts.length; i++) {
        var f = fonts[i];
        css += "@font-face { font-family: '" + f.name + "'; src: url('" + f.url + "'); }\n";
        _DT_LOCAL_FONTS.push({ value: f.name, label: f.name + ' (local)' });
    }
    styleEl.textContent = css;
};
window.DarkThemeEngine_ShowAddCustomBg = function() {
    var old = document.getElementById('dt_addbg_popup');
    if (old) { old.remove(); return; }
    var popup = document.createElement('div');
    popup.id = 'dt_addbg_popup';
    popup.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;';
    popup.innerHTML = '<div style="background:rgba(15,23,42,0.98);backdrop-filter:blur(16px);border-radius:12px;padding:28px;width:420px;max-width:92vw;border:1px solid rgba(255,255,255,0.08);box-shadow:0 25px 50px rgba(0,0,0,0.6);color:#e2e8f0;">'
        + '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;">'
        + '<span style="font-size:1.1rem;font-weight:600;color:#f8fafc;">Add Custom Background</span>'
        + '<button id="dt_addbg_x" style="background:none;border:none;color:#64748b;cursor:pointer;font-size:1.2rem;">✕</button>'
        + '</div>'
        + '<div style="font-size:0.85rem;color:#64748b;margin-bottom:16px;">Image will be saved to <code style="color:#94a3b8;">data/theme_engine_backgrounds/</code> and appear in the <strong>Custom Backgrounds</strong> category.</div>'
        + '<label style="display:block;font-size:0.85rem;color:#94a3b8;margin-bottom:5px;">Image URL (.jpg or .png)</label>'
        + '<input id="dt_addbg_url" type="text" class="theme-input" placeholder="https://..." style="width:100%;box-sizing:border-box;padding:8px 12px;margin-bottom:12px;" />'
        + '<label style="display:block;font-size:0.85rem;color:#94a3b8;margin-bottom:5px;">Filename (optional)</label>'
        + '<input id="dt_addbg_name" type="text" class="theme-input" placeholder="my_background.jpg" style="width:100%;box-sizing:border-box;padding:8px 12px;margin-bottom:16px;" />'
        + '<div id="dt_addbg_status" style="font-size:0.85rem;min-height:20px;margin-bottom:12px;color:#94a3b8;"></div>'
        + '<div style="display:flex;gap:8px;">'
        + '<button id="dt_addbg_ok" style="flex:1;padding:9px 0;background:rgba(16,185,129,0.18);color:#34d399;border:1px solid rgba(16,185,129,0.35);border-radius:7px;cursor:pointer;font-size:0.9rem;font-weight:600;font-family:inherit;">⬇ Download & Add</button>'
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
        statusEl.textContent = '✓ Saved as ' + fname + '. Backgrounds refreshed!';
        okBtn.disabled = false;
        okBtn.textContent = '⬇ Download & Add';
        setTimeout(function() { DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }, 200);
    };
    window.DT_OnCustomBgError = function(msg) {
        statusEl.style.color = '#f87171';
        statusEl.textContent = '✗ ' + msg;
        okBtn.disabled = false;
        okBtn.textContent = '⬇ Download & Add';
    };
    okBtn.onclick = function() {
        var url  = (urlEl.value || '').trim();
        var name = (nameEl.value || '').trim();
        if (!url) { statusEl.style.color='#f59e0b'; statusEl.textContent='Please enter a URL.'; return; }
        if (!name) {
            name = url.split('/').pop().split('?')[0] || 'background.jpg';
        }
        statusEl.style.color = '#94a3b8';
        statusEl.textContent = '⏳ Downloading...';
        okBtn.disabled = true;
        okBtn.textContent = '⏳ Downloading...';
        DarkThemeEngine_LuaCall("DarkTheme_SaveCustomBackground('" + url.replace(/'/g,"\\'") + "','" + name.replace(/'/g,"\\'") + "')");
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
        html += '<span style="font-size:1.8rem;flex-shrink:0;">🔇</span>';
        html += '<div><strong style="color:#f87171;">Music is disabled.</strong> Enable it above using the "Enable Menu Music" toggle to hear your tracks.</div>';
        html += '</div>';
    } else {
        var enabledCount = 0;
        var disabledAlbums2 = window._DarkTheme_DisabledAlbums || {};
        for (var ei = 0; ei < tracks.length; ei++) {
            if (!disabled[tracks[ei].path] && !disabledAlbums2[tracks[ei].album || '']) enabledCount++;
        }
        html += '<div style="display:flex;align-items:center;gap:12px;background:rgba(16,185,129,0.1);border:1px solid rgba(16,185,129,0.25);border-radius:10px;padding:10px 16px;margin-bottom:14px;color:#6ee7b7;font-size:0.9rem;">';
        html += '<span style="font-size:1.4rem;flex-shrink:0;">🎵</span>';
        html += '<div><strong style="color:#34d399;">' + enabledCount + ' of ' + tracks.length + ' tracks enabled</strong>';
        if (enabledCount === 0) html += ' — <span style="color:#f87171;">All tracks are disabled, nothing will play.</span>';
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
                var safePath = t.path.replace(/'/g, "\\'");
                html += '<div class="music-track' + (isDisabled ? ' music-disabled' : '') + '" onclick="window.DarkThemeEngine_ToggleTrackJS(this, \'' + safePath.replace(/"/g, '') + '\');if(typeof lua!==\'undefined\'&&lua.PlaySound)lua.PlaySound(\'garrysmod/ui_click.wav\')" oncontextmenu="event.preventDefault();DarkThemeEngine_OpenMusicPreview(' + idx + ')">';
                html += '<div style="width:48px;height:48px;background:rgba(0,0,0,0.4);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;overflow:hidden;border:1px solid rgba(255,255,255,0.05);">';
                if (t.cover) html += '<img src="' + t.cover + '" style="width:100%;height:100%;object-fit:cover;" />';
                else html += '<span style="font-size:24px;color:#94a3b8;">🎵</span>';
                html += '</div>';
                html += '<div style="flex:1;overflow:hidden;display:flex;flex-direction:column;justify-content:center;">';
                html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:1.1rem;font-weight:bold;margin-bottom:2px;color:#f8fafc;" title="' + (t.title || '').replace(/"/g, '&quot;') + '">' + (t.title || 'Unknown') + '</span>';
                html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.85rem;color:#94a3b8;font-weight:500;" title="' + (t.artist || '').replace(/"/g, '&quot;') + '">' + (t.artist || 'Unknown Artist') + '</span>';
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
    closeBtn.style.cssText = 'position:absolute;top:12px;right:12px;width:32px;height:32px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#64748b;font-size:1.2rem;border-radius:50%;background:rgba(255,255,255,0.05);transition:all 0.2s;border:1px solid rgba(255,255,255,0.08);';
    closeBtn.textContent = '✕';
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
        placeholder.textContent = '🎵';
        card.appendChild(placeholder);
    }
    var infoDiv = document.createElement('div');
    infoDiv.style.cssText = 'text-align:center;width:100%;';
    infoDiv.innerHTML = '<div style="font-size:1.5rem;font-weight:700;color:#f8fafc;margin-bottom:4px;">' + (track.title || 'Unknown') + '</div><div style="font-size:1rem;color:#94a3b8;font-weight:500;">' + (track.artist || 'Unknown Artist') + '</div>';
    card.appendChild(infoDiv);
    if (track.desc) {
        var descDiv = document.createElement('div');
        descDiv.style.cssText = 'text-align:center;color:#cbd5e1;font-style:italic;font-size:0.9rem;opacity:0.8;padding:0 10px;';
        descDiv.textContent = '"' + track.desc + '"';
        card.appendChild(descDiv);
    }
    var metaDiv = document.createElement('div');
    metaDiv.style.cssText = 'display:flex;flex-direction:column;gap:8px;align-items:center;width:100%;margin-top:5px;';
    metaDiv.innerHTML = '<div style="font-size:0.8rem;color:#64748b;word-break:break-all;">' + track.path + '</div>';
    if (track.youtube && (track.youtube.indexOf('youtube.com') !== -1 || track.youtube.indexOf('youtu.be') !== -1)) {
        var ytBtn = document.createElement('div');
        ytBtn.className = 'yt-button';
        ytBtn.textContent = '▶ Watch on YouTube';
        ytBtn.onclick = function() { DarkThemeEngine_LuaCall("if gui and gui.OpenURL then gui.OpenURL('" + track.youtube + "') end"); };
        metaDiv.appendChild(ytBtn);
    }
    card.appendChild(metaDiv);
    var navDiv = document.createElement('div');
    navDiv.style.cssText = 'display:flex;align-items:center;justify-content:center;gap:20px;width:100%;margin-top:10px;padding-top:15px;border-top:1px solid rgba(255,255,255,0.06);';
    var prevBtn = document.createElement('div');
    prevBtn.style.cssText = 'width:40px;height:40px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#94a3b8;font-size:1.5rem;border-radius:8px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.08);transition:all 0.2s;';
    prevBtn.textContent = '‹';
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
    nextBtn.style.cssText = 'width:40px;height:40px;display:flex;align-items:center;justify-content:center;cursor:pointer;color:#94a3b8;font-size:1.5rem;border-radius:8px;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.08);transition:all 0.2s;';
    nextBtn.textContent = '›';
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
    if (document.getElementById('theme_options_btn')) {
        if (window._DT_InjectRetry) { clearInterval(window._DT_InjectRetry); window._DT_InjectRetry = null; }
        return;
    }
    var allLinks = document.querySelectorAll('.options a');
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
    if (window._DT_InjectRetry) { clearInterval(window._DT_InjectRetry); window._DT_InjectRetry = null; }
    var optionsLink = null;
    for (var i = 0; i < allLinks.length; i++) {
        var tranny = allLinks[i].getAttribute('ng-tranny') || allLinks[i].getAttribute('ng-Tranny');
        if (tranny && tranny.indexOf('options') !== -1) { optionsLink = allLinks[i]; break; }
    }
    if (!optionsLink && allLinks.length > 0) optionsLink = allLinks[allLinks.length - 1];
    if (optionsLink) {
        var li = document.createElement('li');
        var a = document.createElement('a');
        a.id = 'theme_options_btn'; a.href = '#/theme/'; a.className = 'ui_sound_return'; a.textContent = 'Theme Options';
        a.addEventListener('mouseenter', function() { if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_hover.wav'); });
        li.appendChild(a);
        var optionsLi = optionsLink.parentElement;
        if (optionsLi && optionsLi.parentElement) optionsLi.parentElement.insertBefore(li, optionsLi.nextSibling);
    }
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
window.addEventListener('hashchange', function() {
    var hash = window.location.hash;
    if (hash === '#/' || hash === '#' || hash === '') {
        setTimeout(window.DarkThemeEngine_InjectLink, 50);
        setTimeout(window.DarkThemeEngine_InjectLink, 200);
        setTimeout(window.DarkThemeEngine_InjectMiniPlayer, 250);
        if (window._DarkTheme_IsAnniversary) {
            setTimeout(window.DarkThemeEngine_SwapAnniLogo, 100);
            setTimeout(window.DarkThemeEngine_SwapAnniLogo, 300);
        }
    }
    window.DarkThemeEngine_CleanupAllOverlays();
});
setTimeout(function() {
    try {
        var scope = angular.element(document.body).scope();
        if (scope && scope.$on) scope.$on('$routeChangeSuccess', function() {
            setTimeout(window.DarkThemeEngine_InjectLink, 50);
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
        backdrop.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(0,0,0,0.9);backdrop-filter:blur(10px);z-index:99998;display:flex;justify-content:center;align-items:center;transition:opacity 1.5s ease-in-out;';
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
