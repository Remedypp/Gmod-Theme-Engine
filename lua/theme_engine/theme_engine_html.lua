DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}
DarkThemeEngine._UI.HTML = [==[
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
    max-height: calc(100vh - 90px); overflow-y: auto;
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
<div id="theme_options_page" style="position:absolute;left:0;right:0;top:0;bottom:50px;overflow-y:auto;padding:20px;display:flex;align-items:flex-start;justify-content:center;">
    <div class="theme-container">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
            <h2 class="theme-header" style="margin-bottom:0;">Theme Engine</h2>
            <div style="display:flex;gap:8px;">
                <button class="theme-btn" style="background:rgba(255,255,255,0.05);color:#94a3b8;border:1px solid rgba(255,255,255,0.08);font-size:0.85rem;padding:6px 14px;" onclick="DarkThemeEngine_ShowHelp()">❓ Help</button>
                <button id="dt_changelog_btn" class="theme-btn" style="position:relative;background:rgba(255,255,255,0.05);color:#94a3b8;border:1px solid rgba(255,255,255,0.08);font-size:0.85rem;padding:6px 14px;" onclick="DarkThemeEngine_ShowChangelog()">Changelog<span id="dt_changelog_new" style="display:none;position:absolute;top:-4px;right:-4px;width:10px;height:10px;background:#ef4444;border-radius:50%;box-shadow:0 0 6px rgba(239,68,68,0.6);"></span></button>
            </div>
        </div>
        <div class="theme-tabs">
            <button class="theme-tab active" onclick="DarkThemeEngine_SwitchTab('main',this)">Colors & Theme</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('backgrounds',this)">Backgrounds</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('music',this)">Menu Music</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('misc',this)">Miscellaneous</button>
        </div>
        <div id="tab_main" class="tab-content active">
            <div style="font-size:1.2rem;font-weight:600;color:#f8fafc;margin-bottom:5px;">Theme Presets</div>
            <div style="color:#cbd5e1;margin-bottom:15px;font-size:0.95rem;">Select the visual style for the Garry's Mod main menu UI.</div>
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
            <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:18px 20px;margin-bottom:16px;border:1px solid rgba(255,255,255,0.05);">
                <div style="display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:14px;">
                    <div class="active-bg-banner">
                        <span style="display:inline-block;width:8px;height:8px;background:#10b981;border-radius:50%;box-shadow:0 0 8px #10b981;flex-shrink:0;"></span>
                        <span id="bg_now_playing" style="font-weight:600;font-size:0.9rem;">Now Playing: None</span>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <input type="text" class="theme-input" placeholder="🔍 Search categories..." id="bg_search_input" oninput="DarkThemeEngine_FilterBgs()" style="width:200px;padding:8px 12px;font-size:0.88rem;">
                        <button class="theme-btn" style="font-size:0.82rem;padding:7px 13px;background:rgba(16,185,129,0.12);color:#34d399;border-color:rgba(16,185,129,0.3);white-space:nowrap;" onclick="DarkThemeEngine_ShowAddCustomBg()">+ Add Image</button>
                    </div>
                </div>
                <div style="height:1px;background:rgba(255,255,255,0.05);margin-bottom:14px;"></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                    <div style="background:rgba(0,0,0,0.15);border-radius:8px;padding:12px 14px;border:1px solid rgba(255,255,255,0.04);">
                        <div style="font-size:0.78rem;font-weight:600;color:#64748b;text-transform:uppercase;letter-spacing:0.6px;margin-bottom:10px;">Rotation</div>
                        <div style="display:flex;flex-direction:column;gap:8px;">
                            <label class="switch-label" style="font-size:0.9rem;"><div class="switch"><input type="checkbox" id="opt_bg_static" onchange="DarkThemeEngine_SetBgOpt('BG_Static',this.checked);DarkThemeEngine_UpdateFadeOptions(this.checked)"><span class="slider"></span></div>Static background <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(no slideshow)</span></label>
                            <div id="fade_interval" style="display:flex;align-items:center;gap:10px;padding-left:2px;">
                                <span style="font-size:0.88rem;color:#94a3b8;white-space:nowrap;min-width:85px;">⏱ Swap every</span>
                                <input type="range" id="opt_bg_interval" min="5" max="120" step="5" value="20" oninput="DarkThemeEngine_SetBgOpt('BG_SwapInterval',parseInt(this.value));document.getElementById('opt_bg_interval_label').textContent=this.value+'s'" style="flex:1;accent-color:#3b82f6;cursor:pointer;">
                                <span id="opt_bg_interval_label" style="font-size:0.85rem;color:#60a5fa;font-weight:600;min-width:30px;text-align:right;">20s</span>
                            </div>
                        </div>
                    </div>
                    <div style="background:rgba(0,0,0,0.15);border-radius:8px;padding:12px 14px;border:1px solid rgba(255,255,255,0.04);">
                        <div style="font-size:0.78rem;font-weight:600;color:#64748b;text-transform:uppercase;letter-spacing:0.6px;margin-bottom:10px;">Visual</div>
                        <div style="display:flex;flex-direction:column;gap:8px;">
                            <div style="display:flex;gap:16px;flex-wrap:wrap;">
                                <label class="switch-label" style="font-size:0.9rem;"><div class="switch"><input type="checkbox" id="opt_bg_nozoom" onchange="DarkThemeEngine_SetBgOpt('BG_NoZoom',this.checked)"><span class="slider"></span></div>No zoom</label>
                                <label class="switch-label fade-option" id="fade_nofade" style="font-size:0.9rem;"><div class="switch"><input type="checkbox" id="opt_bg_nofade" onchange="DarkThemeEngine_SetBgOpt('BG_NoFade',this.checked)"><span class="slider"></span></div>Instant cut</label>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px;padding-left:2px;">
                                <span style="font-size:0.88rem;color:#94a3b8;white-space:nowrap;min-width:85px;">🌑 Overlay dim</span>
                                <input type="range" id="opt_bg_overlay" min="0" max="70" step="5" value="0" oninput="DarkThemeEngine_SetBgOpt('BG_Overlay',parseInt(this.value)/100);document.getElementById('opt_bg_overlay_label').textContent=this.value+'%'" style="flex:1;accent-color:#3b82f6;cursor:pointer;">
                                <span id="opt_bg_overlay_label" style="font-size:0.85rem;color:#60a5fa;font-weight:600;min-width:30px;text-align:right;">0%</span>
                            </div>
                        </div>
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
                        <div class="active-bg-banner" style="background:rgba(59,130,246,0.15);border:1px solid rgba(59,130,246,0.3);width:100%;max-width:400px;display:flex;flex-direction:column;gap:8px;padding:10px 14px;">
                            <div style="display:flex;align-items:center;gap:8px;">
                                <span style="display:inline-block;width:10px;height:10px;background:#3b82f6;border-radius:50%;box-shadow:0 0 8px #3b82f6;flex-shrink:0;"></span>
                                <span id="music_now_playing" style="color:#60a5fa;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">Now Playing: None</span>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px;width:100%;">
                                <span id="music_time_label" style="font-size:0.75rem;color:#94a3b8;font-variant-numeric:tabular-nums;min-width:70px;text-align:right;">00:00 / 00:00</span>
                                <div id="music_progress_track" style="flex:1;height:4px;background:rgba(255,255,255,0.1);border-radius:2px;overflow:hidden;position:relative;">
                                    <div id="music_progress_fill" style="width:0%;height:100%;background:#3b82f6;border-radius:2px;transition:width 0.1s linear;"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <input type="text" class="theme-input" placeholder="Search..." id="music_search_input" oninput="DarkThemeEngine_FilterMusic()" style="width:180px;padding:10px 14px;font-size:0.9rem;">
                        <button class="theme-btn" style="background:rgba(59,130,246,0.15);color:#60a5fa;border:1px solid rgba(59,130,246,0.3);" onclick="DarkThemeEngine_ShowHelp('music')">❓ Help</button>
                    </div>
                </div>
                <div style="height:1px;background:rgba(255,255,255,0.05);margin:20px 0;"></div>
                <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:15px;">
                    <span style="font-weight:600;color:#f8fafc;font-size:0.95rem;">Playback Options</span>
                    <div style="display:flex;gap:20px;align-items:center;flex-wrap:wrap;">
                        <label class="switch-label"><div class="switch"><input type="checkbox" id="opt_music_enable" onchange="DarkThemeEngine_SetMusicOpt('EnableMusic',this.checked)"><span class="slider"></span></div><span style="font-weight:600;color:#f8fafc;">Enable Menu Music</span></label>
                        <label class="switch-label fade-option" id="fade_playlist"><div class="switch"><input type="checkbox" id="opt_music_playlist" onchange="DarkThemeEngine_SetMusicOpt('Music_PlaylistMode',this.checked)"><span class="slider"></span></div>Playlist Mode <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(Auto-advance)</span></label>
                        <label class="switch-label fade-option" id="fade_shuffle"><div class="switch"><input type="checkbox" id="opt_music_shuffle" onchange="DarkThemeEngine_SetMusicOpt('Music_Shuffle',this.checked)"><span class="slider"></span></div>Shuffle</label>
                        <label class="switch-label fade-option" id="fade_volume" style="gap:8px;">
                            <span style="font-size:0.9rem;color:#cbd5e1;white-space:nowrap;">🔊 Volume</span>
                            <input type="range" id="music_volume_slider" min="0" max="100" step="1" value="60" oninput="DarkThemeEngine_SetVolumeFromSlider(this.value)" style="width:90px;accent-color:#3b82f6;cursor:pointer;">
                            <span id="music_volume_label" style="font-size:0.85rem;color:#94a3b8;min-width:32px;text-align:right;">60%</span>
                        </label>
                    </div>
                </div>
            </div>
            <div id="music_album_view"></div>
            <div id="music_album_detail_view" style="display:none;"></div>
            <div id="music_track_list" style="display:none;"></div>
            <div id="music_loading" style="text-align:center;padding:40px;color:#94a3b8;">Loading music...</div>
        </div>
        <div id="tab_misc" class="tab-content">
            <div style="display:flex;flex-direction:column;gap:16px;">
                <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:18px 20px;border:1px solid rgba(255,255,255,0.05);">
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;flex-wrap:wrap;">
                        <div>
                            <div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:3px;">Spawnmenu Skin</div>
                            <div style="font-size:0.85rem;color:#64748b;">Choose a visual theme for the in-game Q menu. Requires the skin addon to be installed. <span style="color:#f59e0b;">⚠ Applies on next game join.</span></div>
                        </div>
                        <button class="theme-btn" style="font-size:0.82rem;padding:6px 14px;background:rgba(59,130,246,0.1);color:#60a5fa;border:1px solid rgba(59,130,246,0.25);" onclick="DarkThemeEngine_LuaCall('DarkThemeEngine.InvalidateSpawnmenuCache(); DarkThemeEngine.SendSpawnmenuToJS()')">🔄 Refresh</button>
                    </div>
                    <div id="misc_spawnmenu_list"><div style="text-align:center;color:#94a3b8;padding:20px;">Loading...</div></div>
                </div>
                <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:18px 20px;border:1px solid rgba(255,255,255,0.05);">
                    <div style="margin-bottom:14px;">
                        <div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:3px;">Menu Font</div>
                        <div style="font-size:0.85rem;color:#64748b;">Override the font used in the main menu interface.</div>
                    </div>
                    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:10px;">
                        <div id="misc_font_dropdown" style="position:relative;min-width:200px;z-index:100;">
                            <div id="misc_font_btn" onclick="DarkThemeEngine_ToggleFontDropdown()" style="background:rgba(15,23,42,0.9);border:1px solid rgba(255,255,255,0.12);color:#e2e8f0;padding:8px 32px 8px 12px;border-radius:6px;cursor:pointer;font-size:0.9rem;font-family:inherit;user-select:none;position:relative;">
                                <span id="misc_font_label">Default (System Font)</span>
                                <span style="position:absolute;right:10px;top:50%;transform:translateY(-50%);color:#64748b;font-size:0.75rem;">▼</span>
                            </div>
                            <div id="misc_font_list" style="display:none;position:absolute;top:calc(100% + 4px);left:0;min-width:200px;background:rgba(15,23,42,0.98);border:1px solid rgba(255,255,255,0.1);border-radius:8px;z-index:9999;max-height:220px;overflow-y:auto;box-shadow:0 10px 30px rgba(0,0,0,0.6);"></div>
                        </div>
                        <button class="theme-btn" style="font-size:0.82rem;padding:6px 14px;background:rgba(148,163,184,0.1);color:#94a3b8;border:1px solid rgba(148,163,184,0.2);" onclick="DarkThemeEngine_SetMenuFont('')">Reset</button>
                        <span id="misc_font_preview" style="font-size:0.95rem;color:#60a5fa;padding:6px 12px;background:rgba(59,130,246,0.08);border-radius:6px;border:1px solid rgba(59,130,246,0.15);">Preview Text Aa</span>
                    </div>
                    <div style="font-size:0.78rem;color:#475569;margin-top:6px;">To add custom fonts locally, place <code style="color:#94a3b8;">.ttf</code> files in <code style="color:#94a3b8;">garrysmod/data/theme_engine_fonts/</code></div>
                </div>
            </div>
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
    if (window.DarkThemeEngine_CleanupAllOverlays) window.DarkThemeEngine_CleanupAllOverlays();
})();
</script>
]==]
