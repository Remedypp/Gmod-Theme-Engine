
local THEME_PAGE_HTML = [==[
<style>
#theme_options_page {
    font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
    color: #e2e8f0;
    --primary: #3b82f6;
    --primary-hover: #60a5fa;
    --bg-dark: rgba(15, 23, 42, 0.85);
    --bg-panel: rgba(30, 41, 59, 0.75);
    --border: rgba(255, 255, 255, 0.1);
    --danger: #ef4444;
    --success: #10b981;
}
.theme-container {
    width: 950px; max-width: 100%;
    background: var(--bg-dark);
    backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
    padding: 20px 30px; border-radius: 12px;
    border: 1px solid rgba(255,255,255,0.05);
    box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
    margin: 0 auto;
    transition: transform 0.4s cubic-bezier(0.16,1,0.3,1), margin 0.4s cubic-bezier(0.16,1,0.3,1);
}
.theme-container.guide-open {
    transform: translateX(-220px);
}
.theme-header { font-size:2rem; font-weight:300; letter-spacing:-0.5px; margin-bottom:15px; color:#fff; text-shadow:0 2px 4px rgba(0,0,0,0.5); }
.theme-tabs { display:flex; gap:20px; border-bottom:2px solid var(--border); margin-bottom:25px; padding-bottom:0; }
.theme-tab { padding:10px 5px; font-size:1.1rem; color:#94a3b8; position:relative; transition:color 0.2s; cursor:pointer; background:none; border:none; font-family:inherit; }
.theme-tab:hover { color:#e2e8f0; }
.theme-tab.active { color:#fff; font-weight:600; }
.theme-tab::after { content:''; position:absolute; bottom:-2px; left:0; right:0; height:2px; background:var(--primary); border-radius:2px 2px 0 0; transform:scaleX(0); transition:transform 0.3s cubic-bezier(0.4,0,0.2,1); transform-origin:center; }
.theme-tab.active::after { transform:scaleX(1); }
@keyframes tabFadeIn { 0%{opacity:0;transform:translateY(10px)} 100%{opacity:1;transform:translateY(0)} }
.tab-content { display:none; }
.tab-content.active { display:block; animation:tabFadeIn 0.3s cubic-bezier(0.16,1,0.3,1) forwards; }
.theme-list { display:flex; flex-direction:column; gap:12px; margin-top:15px; }
.theme-list-item { background:rgba(15,23,42,0.6); border:1px solid var(--border); border-radius:8px; padding:15px 20px; cursor:pointer; transition:all 0.2s cubic-bezier(0.4,0,0.2,1); display:flex; align-items:center; justify-content:space-between; }
.theme-list-item:hover:not(.disabled) { background:rgba(30,41,59,0.9); border-color:rgba(255,255,255,0.3); }
.theme-list-item.active-theme { border-color:var(--primary); background:rgba(59,130,246,0.1); }
.theme-list-item.disabled { opacity:0.5; cursor:default; }
.theme-title { font-size:1.1rem; font-weight:bold; color:#f8fafc; }
.theme-desc { font-size:0.9rem; color:#94a3b8; margin-top:4px; }
.theme-check { font-size:1.5rem; color:var(--primary); font-weight:bold; opacity:0; transition:opacity 0.2s; }
.theme-list-item.active-theme .theme-check { opacity:1; }
.switch-label { display:flex; align-items:center; gap:10px; cursor:pointer; font-size:0.95rem; color:#cbd5e1; user-select:none; }
.fade-option { transition:all 0.3s cubic-bezier(0.4,0,0.2,1); opacity:1; transform:translateX(0); max-width:300px; margin-left:0; overflow:hidden; white-space:nowrap; }
.fade-option.is-hidden { opacity:0; transform:translateX(-15px); max-width:0; margin-left:-30px; pointer-events:none; }
.switch { position:relative; display:inline-block; width:44px; height:24px; flex-shrink:0; }
.switch input { opacity:0; width:0; height:0; }
.slider { position:absolute; cursor:pointer; top:0;left:0;right:0;bottom:0; background:rgba(255,255,255,0.1); transition:.3s; border-radius:24px; border:1px solid var(--border); }
.slider:before { position:absolute; content:""; height:18px; width:18px; left:2px; bottom:2px; background:#94a3b8; transition:.3s; border-radius:50%; }
input:checked + .slider { background:var(--primary); border-color:var(--primary); }
input:checked + .slider:before { transform:translateX(20px); background:white; }
.bg-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(210px,1fr)); gap:16px; max-height:480px; overflow-y:auto; overscroll-behavior:contain; padding:5px 10px 15px 0; }
.bg-grid::-webkit-scrollbar { width:8px; }
.bg-grid::-webkit-scrollbar-track { background:rgba(0,0,0,0.1); border-radius:4px; }
.bg-grid::-webkit-scrollbar-thumb { background:rgba(255,255,255,0.2); border-radius:4px; }
.bg-card { position:relative; border-radius:8px; overflow:hidden; cursor:pointer; height:125px; border:2px solid transparent; transition:all 0.2s cubic-bezier(0.4,0,0.2,1); box-shadow:0 4px 6px -1px rgba(0,0,0,0.3); background:#000; }
.bg-card:hover { transform:translateY(-3px) scale(1.02); box-shadow:0 10px 15px -3px rgba(0,0,0,0.5); z-index:10; }
.bg-card img { width:100%; height:100%; object-fit:cover; transition:opacity 0.3s, filter 0.3s; }
.bg-name { position:absolute; bottom:0; left:0; right:0; background:linear-gradient(transparent,rgba(0,0,0,0.9)); color:white; padding:15px 10px 8px; font-size:0.8rem; text-align:center; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; pointer-events:none; }
.bg-card.bg-disabled { border-color:var(--danger); }
.bg-card.bg-disabled img { opacity:0.4; filter:grayscale(80%) blur(1px); }
.bg-disabled-badge { position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); background:rgba(239,68,68,0.9); color:white; padding:4px 12px; border-radius:20px; font-size:0.8rem; font-weight:bold; letter-spacing:1px; box-shadow:0 2px 10px rgba(0,0,0,0.5); pointer-events:none; opacity:0; transition:opacity 0.2s; }
.bg-card.bg-disabled .bg-disabled-badge { opacity:1; }
.cat-card { background:rgba(0,0,0,0.25); border:1px solid rgba(255,255,255,0.05); border-radius:8px; padding:15px; display:flex; align-items:center; gap:15px; cursor:pointer; transition:all 0.2s; min-height:90px; }
.cat-card:hover { background:rgba(30,41,59,0.7); border-color:rgba(255,255,255,0.15); transform:translateY(-2px); }
.theme-btn { background:rgba(255,255,255,0.1); color:white; border:1px solid var(--border); padding:8px 16px; border-radius:6px; cursor:pointer; transition:all 0.2s; font-size:0.9rem; font-weight:500; font-family:inherit; }
.theme-btn:hover { background:rgba(255,255,255,0.2); transform:translateY(-1px); }
.theme-input { background:rgba(15,23,42,0.9); border:1px solid var(--border); color:white; padding:8px 12px; border-radius:6px; outline:none; font-family:inherit; transition:all 0.2s; }
.theme-input:focus { border-color:var(--primary); box-shadow:0 0 0 2px rgba(59,130,246,0.3); }
.active-bg-banner { display:inline-flex; align-items:center; gap:8px; background:rgba(16,185,129,0.15); color:#34d399; padding:6px 12px; border-radius:6px; border:1px solid rgba(16,185,129,0.3); font-size:0.9rem; font-weight:500; }
.preview-overlay { position:fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.88); backdrop-filter:blur(15px); z-index:10000; display:flex; align-items:center; justify-content:center; animation:modalFadeIn 0.25s ease-out; }
@keyframes modalFadeIn { from{opacity:0} to{opacity:1} }
.preview-close { position:absolute; top:20px; right:30px; font-size:2rem; color:#94a3b8; cursor:pointer; background:rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.1); border-radius:50%; width:48px; height:48px; display:flex; align-items:center; justify-content:center; transition:all 0.2s; z-index:10001; }
.preview-close:hover { color:#fff; background:rgba(239,68,68,0.4); border-color:rgba(239,68,68,0.6); }
.preview-arrow { position:absolute; top:50%; transform:translateY(-50%); font-size:2.5rem; color:#cbd5e1; cursor:pointer; background:rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.1); border-radius:12px; width:56px; height:80px; display:flex; align-items:center; justify-content:center; transition:all 0.2s; z-index:10001; user-select:none; }
.preview-arrow:hover { color:#fff; background:rgba(59,130,246,0.3); border-color:rgba(59,130,246,0.5); }
.preview-arrow.left { left:25px; }
.preview-arrow.right { right:25px; }
.preview-bg-image { max-width:85vw; max-height:80vh; border-radius:12px; box-shadow:0 30px 60px rgba(0,0,0,0.6); object-fit:contain; }
.preview-bg-name { position:absolute; bottom:25px; left:50%; transform:translateX(-50%); background:rgba(0,0,0,0.7); color:#e2e8f0; padding:8px 20px; border-radius:8px; font-size:0.9rem; border:1px solid rgba(255,255,255,0.1); }
.preview-cat-label { position:absolute; top:20px; left:50%; transform:translateX(-50%); background:rgba(0,0,0,0.7); color:#60a5fa; padding:8px 20px; border-radius:8px; font-size:1rem; font-weight:600; border:1px solid rgba(59,130,246,0.3); z-index:10001; display:flex; align-items:center; gap:10px; }
.empty-tab-placeholder { text-align:center; padding:60px 20px; background:rgba(0,0,0,0.15); border-radius:12px; border:1px dashed rgba(255,255,255,0.1); }
.empty-tab-placeholder .icon { font-size:3rem; margin-bottom:15px; opacity:0.5; }
.empty-tab-placeholder .title { font-size:1.2rem; font-weight:600; color:#f8fafc; margin-bottom:8px; }
.empty-tab-placeholder .desc { font-size:0.9rem; color:#94a3b8; max-width:400px; margin:0 auto; }
.music-list { display:flex; flex-direction:column; gap:0; max-height:380px; overflow-y:auto; overscroll-behavior:contain; padding-right:10px; }
.music-list::-webkit-scrollbar { width:8px; }
.music-list::-webkit-scrollbar-track { background:rgba(0,0,0,0.1); border-radius:4px; }
.music-list::-webkit-scrollbar-thumb { background:rgba(255,255,255,0.2); border-radius:4px; }
.music-track { display:flex; align-items:center; gap:15px; padding:12px 20px; background:rgba(15,23,42,0.6); border:1px solid var(--border); border-radius:8px; cursor:pointer; transition:all 0.2s cubic-bezier(0.4,0,0.2,1); margin-bottom:8px; }
.music-track:hover { background:rgba(30,41,59,0.9); border-color:rgba(255,255,255,0.3); }
.music-track.music-disabled { opacity:0.5; }
@keyframes modalCardIn { from{opacity:0;transform:scale(0.9) translateY(20px)} to{opacity:1;transform:scale(1) translateY(0)} }
.music-detail-card { background:var(--bg-dark); border-radius:16px; padding:35px; max-width:450px; width:90vw; border:1px solid rgba(255,255,255,0.08); box-shadow:0 30px 60px rgba(0,0,0,0.5); display:flex; flex-direction:column; align-items:center; gap:20px; animation:modalCardIn 0.3s cubic-bezier(0.16,1,0.3,1); }
.music-detail-cover { width:200px; height:200px; border-radius:12px; object-fit:cover; box-shadow:0 15px 35px rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.05); }
.music-detail-placeholder { width:200px; height:200px; border-radius:12px; background:rgba(30,41,59,0.9); display:flex; align-items:center; justify-content:center; font-size:5rem; color:#475569; border:1px solid rgba(255,255,255,0.05); }
.yt-button { display:inline-flex; align-items:center; gap:8px; padding:10px 22px; background:rgba(255,0,0,0.15); color:#ff4444; border:1px solid rgba(255,0,0,0.3); border-radius:8px; cursor:pointer; font-size:0.95rem; font-weight:600; transition:all 0.2s; }
.yt-button:hover { background:rgba(255,0,0,0.3); border-color:rgba(255,0,0,0.5); color:#ff6666; transform:translateY(-1px); }
@keyframes guideSlideIn { from{opacity:0;transform:translateX(30px)} to{opacity:1;transform:translateX(0)} }
.dt-guide-step { background:rgba(0,0,0,0.2); padding:12px; border-radius:8px; margin-bottom:12px; border-left:3px solid #3b82f6; }
.dt-guide-step code { background:rgba(0,0,0,0.4); padding:2px 6px; border-radius:4px; color:#38bdf8; font-family:Consolas,monospace; font-size:0.85rem; }
</style>
<div id="theme_options_page" style="position:absolute;left:0;right:0;top:0;bottom:50px;overflow:hidden;padding:20px;display:flex;align-items:flex-start;justify-content:center;">
    <div class="theme-container">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
            <h2 class="theme-header" style="margin-bottom:0;">Theme Engine</h2>
            <button id="dt_changelog_btn" class="theme-btn" style="position:relative;background:rgba(255,255,255,0.05);color:#94a3b8;border:1px solid rgba(255,255,255,0.08);font-size:0.85rem;padding:6px 14px;" onclick="DarkThemeEngine_ShowChangelog()">Changelog<span id="dt_changelog_new" style="display:none;position:absolute;top:-4px;right:-4px;width:10px;height:10px;background:#ef4444;border-radius:50%;box-shadow:0 0 6px rgba(239,68,68,0.6);"></span></button>
        </div>
        <div class="theme-tabs">
            <button class="theme-tab active" onclick="DarkThemeEngine_SwitchTab('main',this)">Colors & Theme</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('backgrounds',this)">Backgrounds</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('music',this)">Menu Music</button>
        </div>
        <div id="tab_main" class="tab-content active">
            <div style="font-size:1.2rem;font-weight:600;color:#f8fafc;margin-bottom:5px;">Theme Presets</div>
            <div style="color:#cbd5e1;margin-bottom:20px;font-size:0.95rem;">Select the visual style for the Garry's Mod main menu UI.</div>
            <div class="theme-list">
                <div id="theme_item_light" class="theme-list-item" onclick="DarkThemeEngine_UISelect('light')">
                    <div><div class="theme-title">Light Theme</div><div class="theme-desc">The classic, default Garry's Mod bright blue menu.</div></div>
                    <div class="theme-check">✓</div>
                </div>
                <div id="theme_item_dark" class="theme-list-item" onclick="DarkThemeEngine_UISelect('dark')">
                    <div><div class="theme-title">Dark Theme</div><div class="theme-desc">Transforms the default Gmod theme into a sleek dark version.</div></div>
                    <div class="theme-check">✓</div>
                </div>
                <div class="theme-list-item disabled">
                    <div><div class="theme-title">Custom Theme</div><div class="theme-desc" style="color:#60a5fa;">In future updates, you will be able to create custom themes directly within GMod.</div></div>
                    <div class="theme-check">✓</div>
                </div>
            </div>
        </div>
        <div id="tab_backgrounds" class="tab-content">
            <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:20px;margin-bottom:20px;border:1px solid rgba(255,255,255,0.05);">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:20px;flex-wrap:wrap;">
                    <div style="flex:1;min-width:300px;">
                        <div style="color:#cbd5e1;font-size:0.95rem;line-height:1.5;margin-bottom:15px;">Customize your main menu rotation. Click on any background to <strong>disable</strong> or <strong>enable</strong> it. Disabled backgrounds will not be shown.</div>
                        <div class="active-bg-banner"><span style="display:inline-block;width:10px;height:10px;background:#10b981;border-radius:50%;box-shadow:0 0 8px #10b981;"></span><span id="bg_now_playing" style="font-weight:600;">Now Playing: None</span></div>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <input type="text" class="theme-input" placeholder="Search..." id="bg_search_input" oninput="DarkThemeEngine_FilterBgs()" style="width:180px;padding:10px 14px;font-size:0.9rem;">
                    </div>
                </div>
                <div style="height:1px;background:rgba(255,255,255,0.05);margin:20px 0;"></div>
                <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:15px;">
                    <span style="font-weight:600;color:#f8fafc;font-size:0.95rem;">Animation Options</span>
                    <div style="display:flex;gap:30px;align-items:center;flex-wrap:wrap;">
                        <label class="switch-label"><div class="switch"><input type="checkbox" id="opt_bg_static" onchange="DarkThemeEngine_SetBgOpt('BG_Static',this.checked);DarkThemeEngine_UpdateFadeOptions(this.checked)"><span class="slider"></span></div>Static <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(No Timer)</span></label>
                        <label class="switch-label"><div class="switch"><input type="checkbox" id="opt_bg_nozoom" onchange="DarkThemeEngine_SetBgOpt('BG_NoZoom',this.checked)"><span class="slider"></span></div>Disable Zoom</label>
                        <label class="switch-label fade-option" id="fade_nofade"><div class="switch"><input type="checkbox" id="opt_bg_nofade" onchange="DarkThemeEngine_SetBgOpt('BG_NoFade',this.checked)"><span class="slider"></span></div>Instant Cut</label>
                    </div>
                </div>
            </div>
            <div id="bg_categories_view"></div>
            <div id="bg_detail_view" style="display:none;"></div>
            <div id="bg_loading" style="text-align:center;padding:40px;color:#94a3b8;">Loading backgrounds...</div>
        </div>
        <div id="tab_music" class="tab-content">
            <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:20px;margin-bottom:20px;border:1px solid rgba(255,255,255,0.05);">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:20px;flex-wrap:wrap;">
                    <div style="flex:1;min-width:300px;">
                        <div style="color:#cbd5e1;font-size:0.95rem;line-height:1.5;margin-bottom:15px;">Customize your menu music. Click on any track to <strong>disable</strong> or <strong>enable</strong> it. Disabled tracks will not be played.<br><span style="font-size:0.85rem;color:#94a3b8;display:inline-block;margin-top:5px;">🎵 Add local files to: <code style="background:rgba(0,0,0,0.3);padding:2px 6px;border-radius:4px;color:#cbd5e1;">sound/theme_engine_music/</code></span></div>
                        <div class="active-bg-banner" style="background:rgba(59,130,246,0.15);border:1px solid rgba(59,130,246,0.3);">
                            <span style="display:inline-block;width:10px;height:10px;background:#3b82f6;border-radius:50%;box-shadow:0 0 8px #3b82f6;"></span>
                            <span id="music_now_playing" style="color:#60a5fa;font-weight:600;">Now Playing: None</span>
                        </div>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <input type="text" class="theme-input" placeholder="Search..." id="music_search_input" oninput="DarkThemeEngine_FilterMusic()" style="width:180px;padding:10px 14px;font-size:0.9rem;">
                        <button class="theme-btn" style="background:rgba(59,130,246,0.15);color:#60a5fa;border:1px solid rgba(59,130,246,0.3);" onclick="DarkThemeEngine_ShowAddMusicGuide()">📖 Workshop Guide</button>
                    </div>
                </div>
                <div style="height:1px;background:rgba(255,255,255,0.05);margin:20px 0;"></div>
                <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:15px;">
                    <span style="font-weight:600;color:#f8fafc;font-size:0.95rem;">Playback Options</span>
                    <div style="display:flex;gap:30px;align-items:center;flex-wrap:wrap;">
                        <label class="switch-label"><div class="switch"><input type="checkbox" id="opt_music_enable" onchange="DarkThemeEngine_SetMusicOpt('EnableMusic',this.checked)"><span class="slider"></span></div><span style="font-weight:600;color:#f8fafc;">Enable Menu Music</span></label>
                        <label class="switch-label fade-option" id="fade_playlist"><div class="switch"><input type="checkbox" id="opt_music_playlist" onchange="DarkThemeEngine_SetMusicOpt('Music_PlaylistMode',this.checked)"><span class="slider"></span></div>Playlist Mode <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(Auto-advance)</span></label>
                        <label class="switch-label fade-option" id="fade_shuffle"><div class="switch"><input type="checkbox" id="opt_music_shuffle" onchange="DarkThemeEngine_SetMusicOpt('Music_Shuffle',this.checked)"><span class="slider"></span></div>Shuffle <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(Randomize)</span></label>
                    </div>
                </div>
            </div>
            <div id="music_track_list"></div>
            <div id="music_loading" style="text-align:center;padding:40px;color:#94a3b8;">Loading music...</div>
        </div>
    </div>
    <div id="bg_preview_modal" style="display:none;"></div>
    <div id="music_preview_modal" style="display:none;"></div>
</div>
<script>
//-----------------------------------------------------------------------------
// IDEMPOTENT INIT: Guards prevent re-hooking on template re-loads
//-----------------------------------------------------------------------------
(function() {
    // Guard: Only hook SetLastMap once :x
    if (!window._DT_SetLastMapHooked) {
        window._DT_SetLastMapHooked = true;
        var _orig_SetLastMap = window.SetLastMap;
        window.SetLastMap = function(map, category) {
            try {
                var lm = localStorage.getItem('dt_lastMap');
                var lc = localStorage.getItem('dt_lastCat');
                if (lm && lc && !window._dtLastMapUsed) {
                    map = lm; category = lc; window._dtLastMapUsed = true;
                }
            } catch(e) {}
            if (_orig_SetLastMap) return _orig_SetLastMap(map, category);
            else { window.savedMapName = map; window.savedMapCategory = category; }
        };
    }
    if (!window._DT_UpdateSSHooked) {
        window._DT_UpdateSSHooked = true;
        var _orig_USS = window.UpdateServerSettings;
        window.UpdateServerSettings = function(sttngs) {
            try {
                var saved = localStorage.getItem('dt_cvar_save');
                if (saved && sttngs) {
                    saved = JSON.parse(saved);
                    if (sttngs.settings) {
                        for (var key in sttngs.settings) {
                            var cvarName = sttngs.settings[key].name;
                            if (saved[cvarName] !== undefined) sttngs.settings[key].Value = saved[cvarName];
                        }
                    }
                    if (saved['sv_lan'] !== undefined) sttngs.sv_lan = saved['sv_lan'];
                    if (saved['p2p_enabled'] !== undefined) sttngs.p2p_enabled = saved['p2p_enabled'];
                    if (saved['p2p_friendsonly'] !== undefined) sttngs.p2p_friendsonly = saved['p2p_friendsonly'];
                }
            } catch(e) {}
            if (_orig_USS) return _orig_USS.apply(this, arguments);
        };
    }
    // Guard: Only hook lua.Run ONCE - this was causing the menu freeze -.-
    if (!window._DT_LuaRunHooked && window.lua && window.lua.Run) {
        window._DT_LuaRunHooked = true;
        window._DT_OriginalLuaRun = window.lua.Run;
        window.lua.Run = function() {
            try {
                var code = arguments[0];
                if (typeof code === 'string' && (code.indexOf('StartGame()') !== -1 || code.indexOf('SaveLastMap') !== -1 || code.indexOf('progress_enable') !== -1)) {
                    try {
                        var inj = angular.element(document.body).injector();
                        if (inj) {
                            var rs = inj.get('$rootScope');
                            if (rs) {
                                if (rs.Map) {
                                    localStorage.setItem('dt_lastMap', rs.Map);
                                    localStorage.setItem('dt_lastCat', rs.LastCategory || 'Sandbox');
                                    window._dtLastMapUsed = false;
                                }
                                if (rs.ServerSettings) {
                                    var saved = {};
                                    var ss = rs.ServerSettings;
                                    if (ss.settings) {
                                        for (var k in ss.settings) saved[ss.settings[k].name] = ss.settings[k].Value;
                                    }
                                    saved['sv_lan'] = ss.sv_lan ? "1" : "0";
                                    saved['p2p_enabled'] = ss.p2p_enabled ? "1" : "0";
                                    saved['p2p_friendsonly'] = ss.p2p_friendsonly ? "1" : "0";
                                    localStorage.setItem('dt_cvar_save', JSON.stringify(saved));
                                }
                            }
                        }
                    } catch(e) {}
                }
            } catch(e) {}
            return window._DT_OriginalLuaRun.apply(this, arguments);
        };
    } else if (!window._DT_LuaRunHooked) {
        // lua.Run not ready yet, try once more after delay
        setTimeout(function() {
            if (!window._DT_LuaRunHooked && window.lua && window.lua.Run) {
                window._DT_LuaRunHooked = true;
                window._DT_OriginalLuaRun = window.lua.Run;
                window.lua.Run = function() {
                    try {
                        var code = arguments[0];
                        if (typeof code === 'string' && (code.indexOf('StartGame()') !== -1 || code.indexOf('SaveLastMap') !== -1 || code.indexOf('progress_enable') !== -1)) {
                            try {
                                var inj = angular.element(document.body).injector();
                                if (inj) {
                                    var rs = inj.get('$rootScope');
                                    if (rs && rs.Map) {
                                        localStorage.setItem('dt_lastMap', rs.Map);
                                        localStorage.setItem('dt_lastCat', rs.LastCategory || 'Sandbox');
                                        window._dtLastMapUsed = false;
                                    }
                                }
                            } catch(e) {}
                        }
                    } catch(e) {}
                    return window._DT_OriginalLuaRun.apply(this, arguments);
                };
            }
        }, 500);
    }
})();
// Show back button and refresh UI
(function() {
    try {
        var injector = angular.element(document.body).injector();
        if (injector) {
            var $rootScope = injector.get('$rootScope');
            if ($rootScope) $rootScope.$evalAsync(function() { $rootScope.ShowBack = true; });
        }
    } catch(e) {}
    setTimeout(function() {
        var b = document.getElementById('BackToMenu');
        if (b) b.classList.remove('ng-hide');
    }, 100);
    if (window.DarkThemeEngine_UpdateUI) setTimeout(window.DarkThemeEngine_UpdateUI, 50);
    // Clean up any stale overlays from previous page visit
    if (window.DarkThemeEngine_CleanupAllOverlays) window.DarkThemeEngine_CleanupAllOverlays();
})();
</script>
]==]
------------------------------------------------------------
-- JS: Complete UI logic
------------------------------------------------------------
local THEME_UI_JS = [==[
//-----------------------------------------------------------------------------
// Purpose: Tab Switching & Main UI Logic
//-----------------------------------------------------------------------------
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
    var musicEnable = document.getElementById('opt_music_enable');
    var musicPlaylist = document.getElementById('opt_music_playlist');
    var musicShuffle = document.getElementById('opt_music_shuffle');
    if (musicEnable) musicEnable.checked = !!opts.EnableMusic;
    if (musicPlaylist) musicPlaylist.checked = !!opts.Music_PlaylistMode;
    if (musicShuffle) musicShuffle.checked = !!opts.Music_Shuffle;
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
};
window.DarkThemeEngine_SetBgOpt = function(key, value) {
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetBGOption('" + key + "', " + (value ? "true" : "false") + ")");
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
};
window.DarkThemeEngine_UpdateFadeOptions = function(isStatic) {
    var fadeFade = document.getElementById('fade_nofade');
    if (fadeFade) { if (isStatic) fadeFade.classList.add('is-hidden'); else fadeFade.classList.remove('is-hidden'); }
};
window.DarkThemeEngine_ShowAddMusicGuide = function() {
    var existing = document.getElementById('dt_workshop_guide');
    var container = document.querySelector('.theme-container');
    if (existing) {
        existing.remove();
        if (container) container.classList.remove('guide-open');
        return;
    }
    if (container) container.classList.add('guide-open');
    var guide = document.createElement('div');
    guide.id = 'dt_workshop_guide';
    guide.style.cssText = 'position:fixed;top:20px;right:20px;width:420px;max-width:40vw;max-height:calc(100vh - 40px);overflow-y:auto;background:rgba(15,23,42,0.95);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);padding:25px;border-radius:12px;border:1px solid rgba(255,255,255,0.05);box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);color:#e2e8f0;font-size:0.95rem;line-height:1.5;z-index:9999;animation:guideSlideIn 0.4s cubic-bezier(0.16,1,0.3,1) forwards;';
    guide.innerHTML = ''
        + '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">'
        + '<h2 style="margin:0;font-size:1.3rem;font-weight:500;color:white;">\ud83c\udfb5 Workshop Guide</h2>'
        + '<button id="dt_guide_x" style="background:none;border:none;color:#94a3b8;cursor:pointer;font-size:1.2rem;">\u2715</button>'
        + '</div>'
        + '<p style="color:#94a3b8;margin-top:0;margin-bottom:20px;">Learn how to publish your own Menu Music to the Steam Workshop using <strong>gmpublisher</strong>!</p>'
        + '<div class="dt-guide-step"><span style="color:white;font-weight:600;display:block;margin-bottom:5px;">1. File Structure</span>'
        + 'Create a folder anywhere on your PC (e.g., <code>MyMusicAddon</code>). Inside it, create this exact folder path:<br><code>sound/theme_engine_music/</code></div>'
        + '<div class="dt-guide-step"><span style="color:white;font-weight:600;display:block;margin-bottom:5px;">2. Add Audio</span>'
        + 'Place your <code>.mp3</code> or <code>.wav</code> files inside the <code>theme_engine_music</code> folder. The engine reads MP3 ID3 tags naturally for Artists/Titles!</div>'
        + '<div class="dt-guide-step"><span style="color:white;font-weight:600;display:block;margin-bottom:5px;">3. (Optional) Custom JSON Data</span>'
        + 'Want HD Cover Art and custom descriptions? Create <code>addon_music_meta.json</code> next to your MP3s!'
        + '<div style="background:rgba(0,0,0,0.5);padding:12px;border-radius:6px;margin-top:8px;font-family:Consolas,monospace;font-size:0.8rem;color:#a5b4fc;white-space:pre;overflow-x:auto;">{\n  "song.mp3": {\n    "title": "Epic Theme",\n    "artist": "John Smith",\n    "cover": "materials/vgui/my_cover.png",\n    "desc": "Perfect main menu loop",\n    "youtube": "https://youtube.com/..."\n  }\n}</div></div>'
        + '<div class="dt-guide-step"><span style="color:white;font-weight:600;display:block;margin-bottom:5px;">4. Generate addon.json</span>'
        + 'Inside your main <code>MyMusicAddon</code> folder, create an <code>addon.json</code> file with your title and type "Server Content".</div>'
        + '<div class="dt-guide-step"><span style="color:white;font-weight:600;display:block;margin-bottom:5px;">5. Use gmpublisher</span>'
        + 'Download <a href="https://github.com/WilliamVenner/gmpublisher" style="color:#3b82f6;text-decoration:none;" target="_blank">gmpublisher</a>. Open it, click "Create new addon", drag your folder in, add an icon, and hit <strong>Publish</strong>.</div>'
        + '<div style="margin-top:20px;text-align:center;"><button id="dt_guide_gotit" style="width:100%;padding:10px 24px;background:rgba(59,130,246,0.2);color:#60a5fa;border:1px solid rgba(59,130,246,0.4);border-radius:8px;cursor:pointer;font-size:0.95rem;font-weight:600;font-family:inherit;">Got it!</button></div>';
    document.body.appendChild(guide);
    var closeGuide = function() {
        guide.remove();
        var c = document.querySelector('.theme-container');
        if (c) c.classList.remove('guide-open');
    };
    document.getElementById('dt_guide_x').onclick = closeGuide;
    document.getElementById('dt_guide_gotit').onclick = closeGuide;
};
window.DarkThemeEngine_ShowChangelog = function() {
    var existing = document.getElementById('dt_changelog_panel');
    if (existing) { existing.remove(); return; }
    var panel = document.createElement('div');
    panel.id = 'dt_changelog_panel';
    panel.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:9999;display:flex;align-items:center;justify-content:center;';

    // =============================================
    // CHANGELOG ENTRIES - Add new versions at top
    // =============================================
    var logs = [
        { ver: '0.1.2-beta', changes: [
            'Updated menu.lua pastebin',
            'Theme Engine now loads after the menu is fully ready (deferred loading)',
            'This should fix the loading screen freeze for all users'
        ]},
        { ver: '0.1.1-beta', changes: [
            'Updated menu.lua pastebin with latest fixes',
            'Fixed game getting stuck on loading screen when using modified menu.lua',
            'Improved addon enable/disable detection and cleanup',
            'Sorry for the issues, I\x27m working hard to make it stable'
        ]},
        { ver: '0.1.0-beta', changes: [
            'Updated menu.lua pastebin with latest loader code',
            'Fixed potential crash on x86-64 branch',
            'Added Changelog panel'
        ]}
    ];
    // =============================================

    var inner = '<div style="width:480px;max-width:90vw;max-height:70vh;overflow-y:auto;background:rgba(15,23,42,0.98);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);padding:30px;border-radius:12px;border:1px solid rgba(255,255,255,0.08);box-shadow:0 25px 50px -12px rgba(0,0,0,0.7);color:#e2e8f0;font-size:0.95rem;line-height:1.5;">';
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
    inner += '</div>';
    panel.innerHTML = inner;
    panel.onclick = function(e) { if (e.target === panel) panel.remove(); };
    document.body.appendChild(panel);
    // Mark as seen
    try { localStorage.setItem('DarkTheme_LastSeenChangelog', logs[0].ver); } catch(e) {}
    var dot = document.getElementById('dt_changelog_new');
    if (dot) dot.style.display = 'none';
    document.getElementById('dt_changelog_x').onclick = function() { panel.remove(); };
};
window.DarkThemeEngine_CheckChangelogNew = function() {
    var currentVer = '0.1.2-beta';
    var seen = '';
    try { seen = localStorage.getItem('DarkTheme_LastSeenChangelog') || ''; } catch(e) {}
    var dot = document.getElementById('dt_changelog_new');
    if (dot && seen !== currentVer) dot.style.display = 'block';
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
//-----------------------------------------------------------------------------
// Purpose: Backgrounds System Core & UI
//-----------------------------------------------------------------------------
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
    html += '</div></div></div>';
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
//-----------------------------------------------------------------------------
// Purpose: Backgrounds Preview Modal
//-----------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------
// Purpose: Music System Core
//-----------------------------------------------------------------------------
window.DarkThemeEngine_ReceiveMusic = function(tracks, disabled, opts, currentTrack) {
    window._DarkTheme_Music = tracks || [];
    window._DarkTheme_DisabledMusic = disabled || {};
    window._DarkTheme_MusicOptions = opts || {};
    window._DarkTheme_ActiveMusic = currentTrack || 'None';
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
    DarkThemeEngine_RenderMusicUI();
};
window.DarkThemeEngine_SetCurrentMusic = function(path) {
    window._DarkTheme_ActiveMusic = path || 'None';
    var npEl = document.getElementById('music_now_playing');
    if (npEl) {
        npEl.textContent = 'Now Playing: ' + (path && path !== '' ? path.split('/').pop().replace(/\.[^/.]+$/, '') : 'None');
    }
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetCurrentMusicFromJS('" + (path || '') + "')");
};
window.DarkThemeEngine_SetMusicOpt = function(key, value) {
    DarkThemeEngine_LuaCall("DarkThemeEngine_SetMusicOption('" + key + "', " + (value ? "true" : "false") + ")");
    if (typeof lua !== 'undefined' && lua.PlaySound) lua.PlaySound('garrysmod/ui_click.wav');
    DarkThemeEngine_UpdateMusicFadeOptions();
};
window.DarkThemeEngine_UpdateMusicFadeOptions = function() {
    var chkEnable = document.getElementById('opt_music_enable');
    var chkPlaylist = document.getElementById('opt_music_playlist');
    var fadePlaylist = document.getElementById('fade_playlist');
    var fadeShuffle = document.getElementById('fade_shuffle');
    var isEnabled = chkEnable && chkEnable.checked;
    var isPlaylist = chkPlaylist && chkPlaylist.checked;
    if (fadePlaylist) { if (!isEnabled) fadePlaylist.classList.add('is-hidden'); else fadePlaylist.classList.remove('is-hidden'); }
    if (fadeShuffle) { if (!isEnabled) fadeShuffle.classList.add('is-hidden'); else fadeShuffle.classList.remove('is-hidden'); }
};
window.DarkThemeEngine_FilterMusic = function() {
    DarkThemeEngine_RenderMusicUI();
};

//-----------------------------------------------------------------------------
// Purpose: Music System UI
//-----------------------------------------------------------------------------
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
    if (filtered.length === 0) {
        html = '<div style="text-align:center;color:#94a3b8;padding:30px;background:rgba(0,0,0,0.2);border-radius:8px;">No music tracks found.<br>Add files to the <code style="color:#f8fafc;">sound/theme_engine_music/</code> folder.</div>';
    } else {
        html = '<div class="music-list">';
        for (var i = 0; i < filtered.length; i++) {
            var t = filtered[i].track;
            var idx = filtered[i].originalIndex;
            var isDisabled = !!disabled[t.path];
            var safePath = t.path.replace(/'/g, "\\'");
            html += '<div class="music-track' + (isDisabled ? ' music-disabled' : '') + '" onclick="DarkThemeEngine_LuaCall(\'DarkThemeEngine_ToggleMusic(\\x22' + safePath.replace(/"/g, '') + '\\x22)\');setTimeout(function(){DarkThemeEngine_LuaCall(\'DarkThemeEngine.SendMusicToJS()\')},200)" oncontextmenu="event.preventDefault();DarkThemeEngine_OpenMusicPreview(' + idx + ')">';
            html += '<div style="width:48px;height:48px;background:rgba(0,0,0,0.4);border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0;overflow:hidden;position:relative;border:1px solid rgba(255,255,255,0.05);box-shadow:0 4px 6px rgba(0,0,0,0.3);">';
            if (t.cover) {
                html += '<img src="' + t.cover + '" style="width:100%;height:100%;object-fit:cover;position:absolute;inset:0;" />';
            } else {
                html += '<span style="font-size:24px;color:#94a3b8;filter:drop-shadow(0px 2px 4px rgba(0,0,0,0.5));z-index:1;">🎵</span>';
            }
            html += '<div style="position:absolute;top:0;left:0;background:rgba(0,0,0,0.65);color:#e2e8f0;font-size:0.7rem;font-weight:bold;padding:2px 6px;border-bottom-right-radius:6px;z-index:2;backdrop-filter:blur(2px);">' + (idx + 1) + '</div>';
            html += '</div>';
            html += '<div style="flex:1;overflow:hidden;display:flex;flex-direction:column;justify-content:center;">';
            html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:1.1rem;font-weight:bold;margin-bottom:2px;color:#f8fafc;" title="' + (t.title || '').replace(/"/g, '&quot;') + '">' + (t.title || 'Unknown') + '</span>';
            html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.85rem;color:#94a3b8;font-weight:500;" title="' + (t.artist || '').replace(/"/g, '&quot;') + '">' + (t.artist || 'Unknown Artist') + '</span>';
            if (t.desc) {
                html += '<span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.8rem;color:#cbd5e1;margin-top:4px;font-style:italic;opacity:0.8;" title="' + t.desc.replace(/"/g, '&quot;') + '">"' + t.desc + '"</span>';
            }
            html += '</div>';
            if (!isDisabled) {
                html += '<div style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;letter-spacing:0.5px;background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);">ENABLED</div>';
            } else {
                html += '<div style="font-size:0.8rem;font-weight:bold;padding:6px 12px;border-radius:6px;letter-spacing:0.5px;background:rgba(148,163,184,0.1);color:#94a3b8;border:1px solid rgba(148,163,184,0.2);">DISABLED</div>';
            }
            html += '</div>';
        }
        html += '</div>';
    }
    var container = document.getElementById('music_track_list');
    if (container) container.innerHTML = html;
    var loading = document.getElementById('music_loading');
    if (loading) loading.style.display = 'none';
};
//-----------------------------------------------------------------------------
// Purpose: Music Preview Modal
//-----------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------
// Purpose: Theme Options Link Injection & Setup
//-----------------------------------------------------------------------------
window.DarkThemeEngine_InjectLink = function() {
    if (window._DarkThemeEngine_Disabled) return;
    if (document.getElementById('theme_options_btn')) { return; }
    var allLinks = document.querySelectorAll('.options a');
    if (allLinks.length === 0) return;
    var optionsLink = null;
    for (var i = 0; i < allLinks.length; i++) {
        var tranny = allLinks[i].getAttribute('ng-tranny') || allLinks[i].getAttribute('ng-Tranny');
        if (tranny && tranny.indexOf('options') !== -1) { optionsLink = allLinks[i]; break; }
    }
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
------------------------------------------------------------
-- JS: Register AngularJS route
------------------------------------------------------------
local function BuildRegisterRouteJS(templateHtml)
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
------------------------------------------------------------
-- ANNIVERSARY EVENT
------------------------------------------------------------
function DarkTheme_SetCakeCookie(dateString)
    DarkThemeEngine.Settings.CakeEatenDate = dateString
    DarkThemeEngine.SaveSettings()
end
local ANNIVERSARY_JS = [==[
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
------------------------------------------------------------
-- MAIN INJECTION
------------------------------------------------------------
local hasInjected = false
local function InjectThemeIntoMenu()
    if hasInjected then return end
    local mode = (DarkThemeEngine.Settings.ThemeOptions or {}).Mode or "dark"
    DarkThemeEngine.ApplyTheme(mode)
    DarkThemeEngine.CallJS(THEME_UI_JS)
    DarkThemeEngine.CallJS(string.format("window._DarkThemeEngine_SavedMode = '%s';", string.JavascriptSafe(mode)))
    DarkThemeEngine.CallJS(BuildRegisterRouteJS(THEME_PAGE_HTML))
    DarkThemeEngine.CallJS("window.DarkThemeEngine_InjectLink();")
    -- Anniversary event
    local eatenDate = DarkThemeEngine.Settings.CakeEatenDate or ""
    DarkThemeEngine.CallJS(string.format("window.DarkTheme_CakeEaten_Date = '%s';", string.JavascriptSafe(eatenDate)))
    DarkThemeEngine.CallJS(ANNIVERSARY_JS)
    DarkThemeEngine.SendBackgroundsToJS()
    DarkThemeEngine.SendMusicToJS()
    local themeOpts = DarkThemeEngine.Settings.ThemeOptions or {}
    DarkThemeEngine.CallJS(string.format(
        "if(window.DarkThemeEngine_InitSettingsUI) window.DarkThemeEngine_InitSettingsUI(%s);",
        util.TableToJSON(themeOpts)
    ))
    DarkThemeEngine.CallJS("if(window.DarkThemeEngine_CheckChangelogNew) window.DarkThemeEngine_CheckChangelogNew();")
    hasInjected = true
end
local function TryInject()
    if hasInjected and not IsValid(pnlMainMenu) then
        hasInjected = false
    end
    if hasInjected then return end
    -- Wait for all dependencies to be loaded
    if not DarkThemeEngine.SendMusicToJS then
        timer.Simple(0.5, TryInject)
        return
    end
    if IsValid(pnlMainMenu) and pnlMainMenu.menuLoaded then
        InjectThemeIntoMenu()
    else
        timer.Simple(0.5, TryInject)
    end
end

hook.Add( "MenuStart", "ThemeEngineReinject", function()
    hasInjected = false
    TryInject()
end )
TryInject()
