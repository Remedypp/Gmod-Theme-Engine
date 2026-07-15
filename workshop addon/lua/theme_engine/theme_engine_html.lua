DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine._UI = DarkThemeEngine._UI or {}
DarkThemeEngine._UI.HTML = [==[
<style>
#theme_options_page {
    font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
    color: #d9e5ee;
    --primary: #39a8ff;
    --primary-hover: #7bd0ff;
    --portal-orange: #d7b75a;
    --signal: #d7b75a;
    --muted-blue: #8fb6c9;
    --bg-dark: rgba(8, 15, 22, 0.98);
    --bg-panel: rgba(16, 25, 34, 0.88);
    --border: rgba(139, 189, 219, 0.16);
    --danger: #ef4444;
    --success: #10b981;
    background:
        radial-gradient(circle at 12% 8%, rgba(215,183,90,0.08), transparent 26%),
        radial-gradient(circle at 86% 18%, rgba(57,168,255,0.18), transparent 28%),
        linear-gradient(rgba(91,132,155,0.08) 1px, transparent 1px),
        linear-gradient(90deg, rgba(91,132,155,0.08) 1px, transparent 1px),
        linear-gradient(180deg, #071019 0%, #0b151d 55%, #05090d 100%);
    background-size: auto, auto, 34px 34px, 34px 34px, auto;
    box-sizing: border-box;
}
.theme-container {
    width: min(1540px, calc(100vw - 44px)); max-width: 100%;
    height: calc(100vh - 92px); max-height: calc(100vh - 92px); overflow: hidden;
    background:
        linear-gradient(115deg, rgba(19,31,42,0.98), rgba(8,14,20,0.98) 58%, rgba(17,23,28,0.98)),
        repeating-linear-gradient(90deg, rgba(255,255,255,0.025) 0, rgba(255,255,255,0.025) 1px, transparent 1px, transparent 13px);
    padding: clamp(16px, 1.9vw, 30px); border-radius: 4px;
    border: 1px solid rgba(126,188,220,0.22);
    box-shadow: 0 30px 80px rgba(0,0,0,0.62), inset 0 1px 0 rgba(255,255,255,0.05);
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    transition: transform 0.4s cubic-bezier(0.16,1,0.3,1), margin 0.4s cubic-bezier(0.16,1,0.3,1);
}
.theme-container.guide-open {
    transform: translateX(-220px);
}
.theme-header { display:flex; align-items:center; gap:12px; font-size:clamp(1.65rem, 2.1vw, 2.5rem); font-weight:300; letter-spacing:0; margin-bottom:15px; color:#f6fbff; text-shadow:0 2px 12px rgba(57,168,255,0.25); }
.theme-header-copy { display:flex; flex-direction:column; line-height:1.05; }
.theme-header-copy::before { content:'APERTURE LABORATORIES'; font-size:0.64rem; color:#7bd0ff; letter-spacing:3px; font-weight:700; margin-bottom:4px; opacity:0.85; text-shadow:0 0 10px rgba(57,168,255,0.35); }
.dt-header-actions { display:flex; gap:8px; align-items:center; }
.dt-action-btn { position:relative; height:34px; min-width:116px; display:inline-flex; align-items:center; justify-content:flex-start; padding:0 14px 0 42px; border-radius:3px; border:1px solid rgba(126,188,220,0.2); background:linear-gradient(180deg, rgba(17,31,41,0.88), rgba(6,12,18,0.94)); color:#a9c4d4; cursor:pointer; font-family:inherit; font-size:0.76rem; font-weight:800; letter-spacing:1px; text-transform:uppercase; box-shadow:inset 0 1px 0 rgba(255,255,255,0.04), 0 8px 18px rgba(0,0,0,0.26); transition:color 0.18s, border-color 0.18s, background 0.18s, box-shadow 0.18s, transform 0.18s; }
.dt-action-btn::before { content:''; position:absolute; left:13px; top:50%; width:18px; height:18px; display:block; border-radius:2px; border:1px solid rgba(123,208,255,0.32); background:linear-gradient(180deg, rgba(57,168,255,0.12), rgba(4,10,15,0.72)); box-shadow:inset 0 0 12px rgba(57,168,255,0.08); transform:translateY(-50%); }
.dt-action-btn.help::after { content:'?'; position:absolute; left:23px; top:50%; color:#7bd0ff; font-size:0.78rem; font-weight:900; text-shadow:0 0 8px rgba(123,208,255,0.5); transform:translate(-50%,-52%); }
.dt-action-btn.changelog::after { content:''; position:absolute; left:18px; top:50%; width:9px; height:6px; border-top:2px solid #d7b75a; border-bottom:2px solid #d7b75a; box-shadow:0 4px 0 rgba(215,183,90,0.75); opacity:0.95; transform:translateY(-68%); }
.dt-action-btn:hover { color:#f6fbff; border-color:rgba(123,208,255,0.46); background:linear-gradient(180deg, rgba(27,48,62,0.94), rgba(7,15,22,0.98)); box-shadow:0 0 18px rgba(57,168,255,0.18), inset 0 1px 0 rgba(255,255,255,0.07); transform:translateY(-1px); }
.dt-action-btn.has-new { color:#f6fbff; border-color:rgba(215,183,90,0.46); box-shadow:0 0 18px rgba(215,183,90,0.16), inset 0 1px 0 rgba(255,255,255,0.07); }
.dt-action-btn .dt-action-dot { display:none; position:absolute; top:-4px; right:-4px; width:10px; height:10px; background:#ef4444; border-radius:50%; box-shadow:0 0 6px rgba(239,68,68,0.6); }
.dt-modal-open #theme_options_page .aperture-mark,
.dt-modal-open #theme_options_page .core-eye,
.dt-modal-open #theme_options_page .core-eye::after,
.dt-modal-open #theme_options_page .tab-content.active,
.dt-modal-open #theme_options_page .dt-bg-preview img,
.dt-modal-open #theme_options_page .portal-viz canvas { animation-play-state:paused !important; }
.dt-modal-open #theme_options_page .tab-content.active { visibility:hidden; pointer-events:none; }
.aperture-mark { width:64px; height:64px; border-radius:50%; position:relative; flex:0 0 auto; overflow:hidden; background:#071019; box-shadow:0 0 22px rgba(57,168,255,0.12), inset 0 0 0 2px rgba(178,220,238,0.24), inset 0 -18px 22px rgba(0,0,0,0.62); animation:dtCoreBody 6.5s ease-in-out infinite; }
.aperture-mark, .aperture-mark *, .aperture-mark::before, .aperture-mark::after { box-sizing:border-box; }
.aperture-mark i { display:none; }
.aperture-mark .core-eye { position:absolute; left:15px; top:15px; width:34px; height:34px; border-radius:50%; overflow:hidden; background:radial-gradient(circle at 50% 50%, #f8ffd2 0%, #e4f6a4 28%, #a4b867 56%, #2a351f 100%); box-shadow:0 0 13px rgba(222,239,142,0.76), 0 0 26px rgba(183,214,93,0.26), inset 0 0 0 2px rgba(246,255,196,0.44), inset 0 0 13px rgba(30,41,18,0.78); z-index:4; animation:dtCoreLensGlow 4.4s ease-in-out infinite; }
.aperture-mark .core-eye::before { content:''; position:absolute; left:4px; top:4px; width:26px; height:26px; border-radius:50%; background:linear-gradient(rgba(28,39,17,0.18) 1px, transparent 1px), linear-gradient(90deg, rgba(28,39,17,0.16) 1px, transparent 1px); background-size:4px 4px; box-shadow:inset 0 0 0 1px rgba(246,255,196,0.18), inset 0 0 8px rgba(246,255,196,0.18); opacity:0.82; }
.aperture-mark .core-eye::after { content:''; position:absolute; left:4px; top:3px; width:26px; height:11px; border-radius:50%; background:linear-gradient(180deg, rgba(232,238,226,0.46), rgba(180,190,176,0.12) 52%, transparent); box-shadow:0 0 9px rgba(225,236,210,0.24); animation:dtCoreGlass 5.2s ease-in-out infinite; }
.aperture-mark b { position:absolute; left:7px; top:7px; width:50px; height:50px; border-radius:50%; border:1px solid rgba(157,219,255,0.22); background:radial-gradient(circle at 50% 50%, transparent 0%, transparent 36%, rgba(28,37,41,0.95) 42%, rgba(7,11,14,0.98) 60%, rgba(132,145,146,0.26) 64%, transparent 69%), linear-gradient(135deg, rgba(220,226,220,0.14), transparent 28%, transparent 70%, rgba(0,0,0,0.52)); box-shadow:inset 0 0 0 2px rgba(174,196,194,0.07), inset 0 0 18px rgba(128,209,255,0.05); z-index:3; }
.aperture-mark::before { content:''; position:absolute; left:3px; top:3px; width:58px; height:58px; border-radius:50%; border:1px solid rgba(155,178,174,0.26); background:radial-gradient(circle at 50% 50%, rgba(124,146,144,0.1) 0%, rgba(124,146,144,0.1) 61%, rgba(10,17,20,0.82) 64%, rgba(4,8,11,0.94) 75%, rgba(93,116,118,0.2) 79%, transparent 84%); box-shadow:inset 0 0 0 3px rgba(5,9,12,0.54), inset 0 0 16px rgba(0,0,0,0.54), 0 0 12px rgba(57,168,255,0.08); z-index:2; pointer-events:none; }
.aperture-mark::after { content:''; position:absolute; left:17px; top:8px; width:30px; height:13px; border-radius:50%; background:linear-gradient(180deg, rgba(232,236,226,0.42), rgba(170,178,170,0.08) 58%, transparent); z-index:5; pointer-events:none; }
@keyframes dtCoreBody { 0%,100%{filter:brightness(0.94)} 48%{filter:brightness(1.04)} 70%{filter:brightness(0.99)} }
@keyframes dtCoreLensGlow { 0%,100%{filter:brightness(0.94)} 45%{filter:brightness(1.18)} 68%{filter:brightness(1.02)} }
@keyframes dtCoreGlass { 0%,100%{opacity:0.62; transform:translateY(0)} 48%{opacity:0.86; transform:translateY(1px)} }
.theme-tabs { display:flex; gap:8px; border-bottom:1px solid var(--border); margin-bottom:18px; padding-bottom:0; overflow:visible; flex-shrink:0; }
.theme-tab { padding:11px 15px; font-size:clamp(0.86rem, 1vw, 1rem); color:#93a9b9; position:relative; transition:color 0.2s, background 0.2s; cursor:pointer; background:rgba(255,255,255,0.025); border:1px solid transparent; border-bottom:none; font-family:inherit; text-transform:uppercase; letter-spacing:0; white-space:nowrap; }
.theme-tab:hover { color:#eaf7ff; background:rgba(57,168,255,0.08); }
.theme-tab.active { color:#fff; font-weight:700; background:rgba(57,168,255,0.12); border-color:rgba(57,168,255,0.22); }
.theme-tab::after { content:''; position:absolute; bottom:-1px; left:0; right:0; height:2px; background:linear-gradient(90deg,var(--primary-hover),var(--signal)); border-radius:0; transform:scaleX(0); transition:transform 0.25s cubic-bezier(0.4,0,0.2,1); transform-origin:center; }
.theme-tab.active::after { transform:scaleX(1); }
@keyframes tabFadeIn { 0%{opacity:0;transform:translateY(10px)} 100%{opacity:1;transform:translateY(0)} }
.tab-content { display:none; min-height:0; }
.tab-content.active { display:block; animation:tabFadeIn 0.25s cubic-bezier(0.16,1,0.3,1) forwards; will-change:opacity,transform; overflow:hidden; min-height:0; padding-right:0; }
.theme-container > .tab-content.active { flex:1; }
#tab_backgrounds.active { display:block; min-height:0; overflow-y:auto; overscroll-behavior:contain; padding-right:6px; }
#tab_misc.active { overflow-y:auto; padding-right:6px; }
#theme_options_page ::-webkit-scrollbar, .dt-scrollable::-webkit-scrollbar { width:8px; height:8px; }
#theme_options_page ::-webkit-scrollbar-track, .dt-scrollable::-webkit-scrollbar-track { background:rgba(2,8,12,0.48); border-radius:4px; border:1px solid rgba(126,188,220,0.06); }
#theme_options_page ::-webkit-scrollbar-thumb, .dt-scrollable::-webkit-scrollbar-thumb { background:linear-gradient(180deg, rgba(123,208,255,0.62), rgba(57,168,255,0.34)); border-radius:4px; border:1px solid rgba(123,208,255,0.24); box-shadow:0 0 10px rgba(57,168,255,0.14); }
#theme_options_page ::-webkit-scrollbar-thumb:hover, .dt-scrollable::-webkit-scrollbar-thumb:hover { background:linear-gradient(180deg, rgba(144,222,255,0.82), rgba(57,168,255,0.56)); }
#theme_options_page input[type="range"] { -webkit-appearance:none; appearance:none; height:5px; border-radius:999px; background:linear-gradient(90deg, rgba(123,208,255,0.74), rgba(215,183,90,0.66)); border:1px solid rgba(126,188,220,0.16); box-shadow:inset 0 0 0 1px rgba(0,0,0,0.22); cursor:pointer; }
#theme_options_page input[type="range"]::-webkit-slider-thumb { -webkit-appearance:none; appearance:none; width:15px; height:15px; border-radius:50%; background:#eaf7ff; border:1px solid rgba(123,208,255,0.84); box-shadow:0 0 0 3px rgba(57,168,255,0.14), 0 0 12px rgba(123,208,255,0.36); }
#theme_options_page input[type="range"]:hover::-webkit-slider-thumb { box-shadow:0 0 0 4px rgba(57,168,255,0.2), 0 0 16px rgba(123,208,255,0.52); }
#tab_misc.active::-webkit-scrollbar { width:8px; }
#tab_misc.active::-webkit-scrollbar-track { background:rgba(2,8,12,0.48); border-radius:4px; }
#tab_misc.active::-webkit-scrollbar-thumb { background:linear-gradient(180deg, rgba(123,208,255,0.62), rgba(57,168,255,0.34)); border-radius:4px; }
#bg_categories_view, #bg_detail_view { min-height:360px; max-height:560px; overflow-y:auto; overscroll-behavior:contain; padding-right:6px; }
#bg_categories_view::-webkit-scrollbar, #bg_detail_view::-webkit-scrollbar { width:8px; }
#bg_categories_view::-webkit-scrollbar-track, #bg_detail_view::-webkit-scrollbar-track { background:rgba(2,8,12,0.48); border-radius:4px; }
#bg_categories_view::-webkit-scrollbar-thumb, #bg_detail_view::-webkit-scrollbar-thumb { background:linear-gradient(180deg, rgba(123,208,255,0.62), rgba(57,168,255,0.34)); border-radius:4px; }
.theme-list { display:flex; flex-direction:column; gap:12px; margin-top:15px; }
.theme-list-item { background:linear-gradient(180deg, rgba(19,31,42,0.86), rgba(7,12,18,0.88)); border:1px solid var(--border); border-radius:3px; padding:15px 20px; cursor:pointer; transition:background 0.2s, border-color 0.2s, transform 0.2s; display:flex; align-items:center; justify-content:space-between; }
.theme-list-item:hover:not(.disabled) { background:rgba(30,46,58,0.94); border-color:rgba(123,208,255,0.34); transform:translateY(-1px); }
.theme-list-item.active-theme { border-color:var(--primary); background:linear-gradient(90deg, rgba(57,168,255,0.2), rgba(10,18,27,0.9)); box-shadow:inset 3px 0 0 var(--primary); }
.theme-list-item.disabled { opacity:0.5; cursor:default; }
.theme-title { font-size:1.1rem; font-weight:bold; color:#f8fafc; }
.theme-desc { font-size:0.9rem; color:#94a3b8; margin-top:4px; }
.theme-check { position:relative; width:20px; height:20px; opacity:0; transition:opacity 0.2s, transform 0.2s; flex:0 0 auto; }
.theme-check::before { content:''; position:absolute; left:5px; top:2px; width:7px; height:13px; border-right:2px solid var(--primary-hover); border-bottom:2px solid var(--primary-hover); transform:rotate(42deg); box-shadow:0 0 10px rgba(123,208,255,0.4); }
.theme-list-item.active-theme .theme-check { opacity:1; }
#tab_main.active { overflow-y:auto; padding-right:6px; }
.dt-main-section { margin-bottom:22px; }
.dt-section-heading { display:flex; align-items:flex-end; justify-content:space-between; gap:14px; margin-bottom:12px; }
.dt-section-kicker { font-size:0.68rem; font-weight:800; color:#7bd0ff; letter-spacing:2px; text-transform:uppercase; margin-bottom:4px; }
.dt-section-title { font-size:1.18rem; font-weight:800; color:#f6fbff; }
.dt-section-desc { color:#8fa4b4; font-size:0.9rem; line-height:1.45; max-width:720px; }
.dt-theme-catalog-head { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:10px; }
.dt-theme-head-actions { display:flex; align-items:center; justify-content:flex-end; gap:8px; flex-wrap:wrap; }
.dt-reload-theme-btn { min-height:34px; display:inline-flex; align-items:center; justify-content:center; gap:7px; border:1px solid rgba(215,183,90,0.32); border-radius:3px; background:linear-gradient(180deg, rgba(36,32,20,0.78), rgba(10,10,8,0.94)); color:#f7d878; cursor:pointer; padding:0 14px; font-family:inherit; font-size:0.74rem; font-weight:900; letter-spacing:1px; text-transform:uppercase; box-shadow:0 0 18px rgba(215,183,90,0.08), inset 0 1px 0 rgba(255,255,255,0.05); transition:transform 0.18s, box-shadow 0.18s, border-color 0.18s, color 0.18s; }
.dt-reload-theme-btn:hover { transform:translateY(-1px); color:#fff4c4; border-color:rgba(247,216,120,0.58); box-shadow:0 0 22px rgba(215,183,90,0.18), inset 0 1px 0 rgba(255,255,255,0.08); }
.dt-theme-category { margin-top:14px; }
.dt-category-label { font-size:0.72rem; font-weight:800; color:#7892a3; letter-spacing:1.4px; text-transform:uppercase; margin-bottom:8px; }
.dt-theme-grid { display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:10px; }
.dt-theme-card { --hover:#39a8ff; position:relative; min-height:104px; padding:15px 16px 15px 64px; border:1px solid rgba(126,188,220,0.14); border-radius:3px; background:linear-gradient(180deg, rgba(15,25,34,0.88), rgba(5,10,15,0.9)); cursor:pointer; overflow:hidden; transition:transform 0.18s, border-color 0.18s, background 0.18s, box-shadow 0.18s; }
.dt-theme-card::before { content:attr(data-icon); position:absolute; left:15px; top:17px; width:34px; height:34px; display:flex; align-items:center; justify-content:center; border:1px solid rgba(126,188,220,0.18); border-radius:3px; color:var(--hover); font-size:0.88rem; font-weight:900; letter-spacing:0.5px; background:rgba(255,255,255,0.035); box-shadow:inset 0 0 16px rgba(255,255,255,0.03); }
.dt-theme-card::after { content:''; position:absolute; inset:0; background:linear-gradient(100deg, rgba(57,168,255,0.16), transparent 58%); opacity:0; transition:opacity 0.18s; pointer-events:none; }
.dt-theme-card:hover { transform:translateY(-2px); border-color:var(--hover); box-shadow:0 14px 30px rgba(0,0,0,0.28), 0 0 24px rgba(57,168,255,0.16); background:linear-gradient(180deg, rgba(24,38,49,0.94), rgba(5,10,15,0.94)); }
.dt-theme-card:hover::after { opacity:1; }
.dt-theme-card.active-theme { border-color:var(--hover); box-shadow:inset 3px 0 0 var(--hover), 0 0 20px rgba(57,168,255,0.16); }
.dt-theme-card .theme-check { position:absolute; right:16px; top:14px; color:var(--hover); }
.dt-theme-card.disabled { opacity:0.5; cursor:default; }
.dt-theme-card.disabled:hover { transform:none; box-shadow:none; border-color:rgba(126,188,220,0.14); background:linear-gradient(180deg, rgba(15,25,34,0.88), rgba(5,10,15,0.9)); }
.dt-theme-card.disabled:hover::after { opacity:0; }
.dt-theme-card.exported { cursor:pointer; }
.dt-theme-card.exported .theme-desc { word-break:break-all; }
.dt-ico { --ico:currentColor; position:relative; display:inline-block; width:18px; height:18px; flex:0 0 18px; vertical-align:-4px; color:var(--ico); }
.dt-ico::before, .dt-ico::after { content:''; position:absolute; box-sizing:border-box; }
.dt-ico-search::before { left:2px; top:2px; width:10px; height:10px; border:2px solid var(--ico); border-radius:50%; box-shadow:0 0 8px rgba(123,208,255,0.2); }
.dt-ico-search::after { left:11px; top:11px; width:7px; height:2px; background:var(--ico); transform:rotate(45deg); transform-origin:left center; border-radius:2px; }
.dt-ico-timer::before { left:2px; top:3px; width:14px; height:14px; border:2px solid var(--ico); border-radius:50%; }
.dt-ico-timer::after { left:8px; top:6px; width:5px; height:5px; border-left:2px solid var(--ico); border-bottom:2px solid var(--ico); transform:rotate(-25deg); transform-origin:left bottom; }
.dt-ico-overlay::before { left:1px; top:1px; width:16px; height:16px; border-radius:50%; background:radial-gradient(circle at 50% 50%, rgba(215,183,90,0.72), rgba(123,208,255,0.16) 42%, transparent 45%); border:1px solid rgba(123,208,255,0.38); }
.dt-ico-overlay::after { left:4px; top:4px; width:10px; height:10px; border-radius:50%; border:1px solid rgba(255,255,255,0.38); }
.dt-ico-image::before { inset:2px; border:1px solid rgba(123,208,255,0.66); background:linear-gradient(180deg, rgba(57,168,255,0.18), rgba(57,168,255,0.04) 48%, rgba(215,183,90,0.08)); box-shadow:inset 0 0 10px rgba(57,168,255,0.08), 0 0 8px rgba(123,208,255,0.08); }
.dt-ico-image::after { left:4px; bottom:4px; width:10px; height:7px; background:linear-gradient(135deg, transparent 0 30%, rgba(215,183,90,0.95) 31% 55%, transparent 56%), linear-gradient(45deg, transparent 0 38%, var(--ico) 39% 70%, transparent 71%); opacity:0.92; }
.dt-ico-backgrounds::before { left:2px; top:5px; width:13px; height:10px; border:1px solid var(--ico); background:linear-gradient(180deg, rgba(123,208,255,0.16) 0 45%, rgba(7,16,25,0.92) 46%); box-shadow:3px -3px 0 -1px #071019, 3px -3px 0 0 rgba(215,183,90,0.78); transition:transform 0.2s ease, box-shadow 0.2s ease; }
.dt-ico-backgrounds::after { left:4px; top:8px; width:9px; height:5px; background:radial-gradient(circle at 78% 20%, #f0c85b 0 1px, transparent 1.5px), linear-gradient(145deg, transparent 0 28%, #5fa9cb 29% 54%, transparent 55%), linear-gradient(35deg, transparent 0 36%, #d7b75a 37% 64%, transparent 65%); opacity:0.95; transition:transform 0.2s ease; }
.dt-help-tab:hover .dt-ico-backgrounds::before, .dt-help-tab.active .dt-ico-backgrounds::before { transform:translate(-1px,1px); box-shadow:5px -5px 0 -1px #071019, 5px -5px 0 0 rgba(215,183,90,0.92); }
.dt-help-tab:hover .dt-ico-backgrounds::after, .dt-help-tab.active .dt-ico-backgrounds::after { transform:translate(-1px,1px); }
.dt-ico-warning::before { left:2px; top:2px; width:14px; height:14px; background:linear-gradient(135deg, rgba(215,183,90,0.95), rgba(255,229,142,0.8)); clip-path:polygon(50% 0,100% 100%,0 100%); box-shadow:0 0 10px rgba(215,183,90,0.22); }
.dt-ico-warning::after { left:8px; top:6px; width:2px; height:7px; background:#111820; box-shadow:0 8px 0 #111820; }
.dt-ico-refresh::before { left:2px; top:2px; width:14px; height:14px; border:2px solid var(--ico); border-right-color:transparent; border-radius:50%; }
.dt-ico-refresh::after { right:0; top:1px; width:6px; height:6px; border-top:2px solid var(--ico); border-right:2px solid var(--ico); transform:rotate(20deg); }
.dt-ico-check::before { left:5px; top:1px; width:7px; height:13px; border-right:2px solid var(--ico); border-bottom:2px solid var(--ico); transform:rotate(42deg); }
.dt-ico-block::before { left:2px; top:2px; width:14px; height:14px; border:2px solid var(--ico); border-radius:50%; }
.dt-ico-block::after { left:4px; top:8px; width:10px; height:2px; background:var(--ico); transform:rotate(38deg); border-radius:2px; }
.dt-ico-link::before { left:1px; top:5px; width:9px; height:7px; border:2px solid var(--ico); border-radius:6px; transform:rotate(-28deg); }
.dt-ico-link::after { right:1px; top:5px; width:9px; height:7px; border:2px solid var(--ico); border-radius:6px; transform:rotate(-28deg); }
.dt-ico-volume::before { left:2px; top:6px; width:7px; height:7px; background:var(--ico); clip-path:polygon(0 30%,45% 30%,100% 0,100% 100%,45% 70%,0 70%); }
.dt-ico-volume::after { left:11px; top:4px; width:5px; height:10px; border-right:2px solid var(--ico); border-radius:50%; opacity:0.8; }
.dt-ico-play::before { left:5px; top:3px; width:0; height:0; border-top:6px solid transparent; border-bottom:6px solid transparent; border-left:9px solid var(--ico); filter:drop-shadow(0 0 6px rgba(123,208,255,0.22)); }
.dt-ico-pause::before { left:5px; top:3px; width:3px; height:12px; background:var(--ico); box-shadow:6px 0 0 var(--ico); border-radius:1px; }
.dt-ico-next::before { left:2px; top:3px; width:0; height:0; border-top:6px solid transparent; border-bottom:6px solid transparent; border-left:8px solid var(--ico); box-shadow:6px 0 0 var(--ico); }
.dt-ico-next::after { right:1px; top:3px; width:2px; height:12px; background:var(--ico); }
.dt-ico-music-next::before, .dt-ico-music-next::after { top:5px; width:7px; height:7px; border-right:1px solid var(--ico); border-bottom:1px solid var(--ico); transform:rotate(-45deg); }
.dt-ico-music-next::before { left:1px; }
.dt-ico-music-next::after { left:7px; }
.dt-ico-download::before { left:8px; top:2px; width:2px; height:10px; background:var(--ico); box-shadow:0 0 8px rgba(123,208,255,0.18); }
.dt-ico-download::after { left:4px; top:8px; width:10px; height:8px; border-left:2px solid var(--ico); border-bottom:2px solid var(--ico); transform:rotate(-45deg); }
.dt-ico-expand::before { left:2px; top:2px; width:14px; height:14px; border:1px solid rgba(123,208,255,0.5); }
.dt-ico-expand::after { left:5px; top:5px; width:8px; height:8px; border-top:2px solid var(--ico); border-right:2px solid var(--ico); transform:rotate(45deg); }
.dt-ico-collapse::before { left:2px; top:2px; width:14px; height:14px; border:1px solid rgba(123,208,255,0.5); }
.dt-ico-collapse::after { left:4px; top:8px; width:10px; height:2px; background:var(--ico); border-radius:2px; }
.dt-ico-back::before { left:3px; top:8px; width:12px; height:2px; background:var(--ico); border-radius:2px; }
.dt-ico-back::after { left:3px; top:5px; width:7px; height:7px; border-left:2px solid var(--ico); border-bottom:2px solid var(--ico); transform:rotate(45deg); }
.dt-ico-music::before { left:6px; top:2px; width:9px; height:10px; border-top:2px solid var(--ico); border-right:2px solid var(--ico); transform:skewY(-10deg); transform-origin:right top; filter:drop-shadow(0 0 5px rgba(215,183,90,0.24)); }
.dt-ico-music::after { left:2px; top:11px; width:6px; height:5px; border-radius:50%; background:var(--ico); box-shadow:9px -2px 0 var(--ico); }
.dt-ico-gamepad::before { left:1px; top:6px; width:16px; height:9px; border:2px solid var(--ico); border-radius:8px 8px 6px 6px; background:linear-gradient(180deg, rgba(123,208,255,0.08), rgba(0,0,0,0.12)); }
.dt-ico-gamepad::after { left:5px; top:10px; width:2px; height:2px; background:var(--ico); box-shadow:-3px 0 0 var(--ico), 3px 0 0 var(--ico), 8px -1px 0 rgba(215,183,90,0.86), 11px -1px 0 rgba(215,183,90,0.62); border-radius:50%; }
.dt-ico-font::before { content:'A'; left:2px; top:0; width:14px; height:15px; color:var(--ico); font-size:16px; font-weight:900; line-height:16px; text-align:center; font-family:Arial, sans-serif; text-shadow:0 0 8px rgba(123,208,255,0.24); }
.dt-ico-font::after { left:3px; bottom:2px; width:12px; height:2px; background:rgba(215,183,90,0.78); border-radius:2px; }
.dt-ico-palette::before { left:2px; top:3px; width:14px; height:12px; border:2px solid var(--ico); border-radius:55% 48% 52% 58%; transform:rotate(-12deg); box-shadow:0 0 8px rgba(123,208,255,0.14); }
.dt-ico-palette::after { left:5px; top:6px; width:3px; height:3px; border-radius:50%; background:#7bd0ff; box-shadow:5px -1px 0 #d7b75a, 7px 4px 0 #8bbf9a, 1px 5px 0 #c9d7dc; }
.dt-ico-cog::before { left:3px; top:3px; width:12px; height:12px; border:2px solid var(--ico); border-radius:50%; box-shadow:0 -4px 0 -2px var(--ico), 0 4px 0 -2px var(--ico), 4px 0 0 -2px var(--ico), -4px 0 0 -2px var(--ico); }
.dt-ico-cog::after { left:7px; top:7px; width:4px; height:4px; background:rgba(215,183,90,0.82); border-radius:50%; box-shadow:0 0 8px rgba(215,183,90,0.18); }
.dt-ico-close::before { left:4px; top:8px; width:10px; height:2px; background:var(--ico); transform:rotate(45deg); border-radius:2px; }
.dt-ico-close::after { left:4px; top:8px; width:10px; height:2px; background:var(--ico); transform:rotate(-45deg); border-radius:2px; }
.dt-ico-prev::before { left:7px; top:3px; width:9px; height:12px; background:var(--ico); clip-path:polygon(0 50%, 100% 0, 100% 100%); }
.dt-ico-prev::after { left:2px; top:3px; width:2px; height:12px; background:var(--ico); }
.dt-ico-pulse { animation:dtIconPulse 0.36s cubic-bezier(0.16,1,0.3,1); }
@keyframes dtIconPulse { 0%{transform:scale(1)} 45%{transform:scale(1.2); filter:drop-shadow(0 0 10px rgba(123,208,255,0.48))} 100%{transform:scale(1)} }
.dt-inline-icon { display:inline-flex; align-items:center; gap:7px; }
.theme-btn .dt-ico, .dt-icon-button .dt-ico, .dt-inline-icon .dt-ico, .dt-help-tab .dt-ico, .dt-subpage-title .dt-ico, .dt-reload-theme-btn .dt-ico { --ico:currentColor; }
.dt-icon-box { display:flex; align-items:center; justify-content:center; background:linear-gradient(135deg, rgba(57,168,255,0.1), rgba(215,183,90,0.07)); border:1px solid rgba(126,188,220,0.16); color:#7bd0ff; box-shadow:inset 0 0 18px rgba(57,168,255,0.04); }
.dt-icon-box .dt-ico { --ico:#7bd0ff; width:18px; height:18px; flex-basis:18px; transform:scale(1.45); transform-origin:center; }
.dt-icon-box.is-warm .dt-ico { --ico:#d7b75a; }
.dt-search-field { position:relative; display:flex; align-items:center; }
.dt-search-field .dt-ico { position:absolute; left:11px; top:50%; transform:translateY(-50%); pointer-events:none; opacity:0.72; z-index:1; }
.dt-search-field .theme-input { padding-left:36px !important; width:clamp(170px, 18vw, 240px) !important; }
.dt-icon-button { width:28px; height:28px; border:1px solid rgba(126,188,220,0.18); border-radius:4px; background:linear-gradient(180deg, rgba(17,31,41,0.84), rgba(5,11,16,0.92)); color:#94a3b8; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:color 0.18s, background 0.18s, border-color 0.18s, transform 0.18s; }
.dt-icon-button:hover { color:#eaf7ff; border-color:rgba(123,208,255,0.4); background:rgba(57,168,255,0.1); transform:translateY(-1px); }
.dt-music-now-playing { background:rgba(215,183,90,0.1) !important; border-color:rgba(215,183,90,0.3) !important; }
.dt-music-now-playing #music_now_playing { color:#e3c86f !important; }
.dt-music-now-playing .dt-playing-light { background:#d7b75a !important; box-shadow:0 0 9px rgba(215,183,90,0.72) !important; }
.dt-music-control { color:#d7b75a; border-color:rgba(215,183,90,0.25); }
.dt-music-control:hover { color:#fff0b5; border-color:rgba(215,183,90,0.52); background:rgba(215,183,90,0.1); }
.switch-label { display:inline-flex; align-items:center; align-self:flex-start; width:auto; max-width:100%; gap:10px; cursor:pointer; font-size:0.95rem; color:#cbd5e1; user-select:none; }
.fade-option { transition:opacity 0.3s, transform 0.3s; opacity:1; transform:translateX(0) scaleX(1); transform-origin:left; overflow:hidden; white-space:nowrap; }
.fade-option.is-hidden { opacity:0; transform:translateX(-15px) scaleX(0); pointer-events:none; }
.switch { position:relative; display:inline-block; width:44px; height:24px; flex-shrink:0; }
.switch input { opacity:0; width:0; height:0; }
.slider { position:absolute; cursor:pointer; top:0;left:0;right:0;bottom:0; background:rgba(255,255,255,0.1); transition:background 0.3s, border-color 0.3s; border-radius:24px; border:1px solid var(--border); }
.slider:before { position:absolute; content:""; height:18px; width:18px; left:2px; bottom:2px; background:#94a3b8; transition:transform 0.3s, background 0.3s; border-radius:50%; }
input:checked + .slider { background:var(--primary); border-color:var(--primary); }
input:checked + .slider:before { transform:translateX(20px); background:white; }
.dt-toolbar { display:flex; align-items:center; justify-content:space-between; gap:12px; padding:10px 12px; margin-bottom:12px; border:1px solid rgba(126,188,220,0.14); background:rgba(5,10,15,0.45); border-radius:3px; flex-wrap:wrap; }
.dt-bg-layout { display:grid; grid-template-columns:minmax(220px, 285px) minmax(0, 1fr); gap:14px; min-height:0; }
.dt-bg-side { display:flex; flex-direction:column; gap:10px; min-width:0; }
.dt-panel { background:linear-gradient(180deg, rgba(22,34,43,0.9), rgba(7,12,18,0.88)); border:1px solid rgba(126,188,220,0.14); border-radius:3px; padding:12px; box-shadow:inset 0 1px 0 rgba(255,255,255,0.03); }
.dt-panel-title { font-size:0.76rem; font-weight:700; color:#7bd0ff; text-transform:uppercase; letter-spacing:1.4px; margin-bottom:10px; }
.dt-bg-main { display:grid; grid-template-rows:minmax(250px, 38vh) minmax(0, 1fr); gap:12px; min-height:0; }
.dt-bg-preview { position:relative; height:300px; min-height:300px; border:1px solid rgba(126,188,220,0.18); border-radius:3px; overflow:hidden; background:#05090d; box-shadow:inset 0 0 0 1px rgba(255,255,255,0.025); transition:height 0.38s cubic-bezier(0.16,1,0.3,1), min-height 0.38s cubic-bezier(0.16,1,0.3,1), box-shadow 0.22s, border-color 0.22s; }
#tab_backgrounds.bg-preview-expanded .dt-bg-preview { height:520px; min-height:520px; border-color:rgba(123,208,255,0.32); box-shadow:0 18px 46px rgba(0,0,0,0.38), inset 0 0 0 1px rgba(255,255,255,0.035), 0 0 30px rgba(57,168,255,0.12); }
.dt-bg-preview::after { content:''; position:absolute; inset:0; pointer-events:none; z-index:3; background:linear-gradient(180deg, transparent 0%, rgba(0,0,0,0.35) 100%); }
.dt-bg-preview img { position:absolute; left:0; top:0; width:100%; height:100%; object-fit:cover; object-position:center center; display:block; filter:saturate(0.92) contrast(1.03); transform-origin:center center; transition:transform 0.42s cubic-bezier(0.16,1,0.3,1), filter 0.42s ease, object-fit 0.2s; }
.dt-bg-preview.dt-preview-contain img.dt-preview-current,
.dt-bg-preview.dt-preview-contain img.dt-preview-outgoing { object-fit:contain; background:radial-gradient(circle at 50% 50%, rgba(57,168,255,0.08), rgba(0,0,0,0.86)); }
.dt-bg-preview img.dt-preview-current { z-index:1; opacity:1; }
.dt-bg-preview img.dt-preview-outgoing { z-index:2; opacity:0; transition:opacity 0.9s ease-in-out; }
.dt-bg-preview.no-fade img.dt-preview-outgoing { display:none !important; transition:none; }
.dt-bg-preview img.dt-preview-animate { animation:dtPreviewDrift var(--dt-bg-preview-duration, 20s) linear forwards; }
.dt-bg-preview img.dt-preview-static { animation:dtPreviewStatic 60s ease-in-out infinite alternate; }
.dt-bg-preview img.dt-preview-reset { animation:none !important; transform:scale(1) rotate(0deg) translate3d(0,0,0) !important; transition:transform 0.42s cubic-bezier(0.16,1,0.3,1), filter 0.42s ease !important; filter:saturate(0.96) contrast(1.02) brightness(1.04); }
.dt-bg-preview.dt-real-background img { object-fit:fill; transform-origin:center center; animation:none !important; transition:transform 0.065s linear, opacity 0.065s linear, filter 0.2s ease; will-change:transform,opacity; }
.dt-bg-preview.bg-no-zoom img.dt-preview-current { animation:none !important; }
.dt-bg-preview.bg-option-pulse { animation:dtBgOptionPulse 0.34s cubic-bezier(0.16,1,0.3,1); }
@keyframes dtPreviewDrift { 0%{transform:scale(1) rotate(0deg) translate3d(0,0,0)} 100%{transform:scale(1.22) rotate(-3.5deg) translate3d(0,0,0)} }
@keyframes dtPreviewStatic { 0%{transform:scale(1) rotate(0deg) translate3d(0,0,0)} 50%{transform:scale(1.15) rotate(0deg) translate3d(0,0,0)} 100%{transform:scale(1) rotate(0deg) translate3d(0,0,0)} }
@keyframes dtBgOptionPulse { 0%{border-color:rgba(126,188,220,0.18)} 45%{border-color:rgba(215,183,90,0.54); box-shadow:0 0 28px rgba(215,183,90,0.14), inset 0 0 0 1px rgba(255,255,255,0.035)} 100%{border-color:rgba(126,188,220,0.18)} }
.dt-bg-preview-empty { position:absolute; left:0; top:0; z-index:1; width:100%; height:100%; display:flex; align-items:center; justify-content:center; color:#658294; background:linear-gradient(135deg, rgba(57,168,255,0.06), rgba(215,183,90,0.05)); }
.dt-bg-preview-dim { position:absolute; left:0; top:0; width:100%; height:100%; z-index:3; pointer-events:none; background:#000; opacity:0; }
.dt-bg-preview-nav { position:absolute; top:50%; transform:translateY(-50%); z-index:4; width:40px; height:56px; display:flex; align-items:center; justify-content:center; border:1px solid rgba(126,188,220,0.24); background:rgba(4,9,13,0.7); color:#eaf7ff; cursor:pointer; font-size:1.8rem; line-height:1; box-shadow:0 8px 24px rgba(0,0,0,0.38); }
.dt-bg-preview-nav:hover { background:rgba(25,44,58,0.86); border-color:rgba(123,208,255,0.46); }
.dt-bg-preview-nav.prev { left:12px; }
.dt-bg-preview-nav.next { right:12px; }
.dt-bg-preview-expand { position:absolute; top:12px; right:12px; z-index:4; height:32px; padding:0 12px; display:inline-flex; align-items:center; gap:8px; border:1px solid rgba(126,188,220,0.26); border-radius:3px; background:rgba(4,9,13,0.72); color:#eaf7ff; cursor:pointer; font-size:0.76rem; font-weight:800; letter-spacing:1px; text-transform:uppercase; box-shadow:0 8px 24px rgba(0,0,0,0.34); transition:background 0.18s,border-color 0.18s,transform 0.18s; }
.dt-bg-preview-expand:hover { background:rgba(25,44,58,0.9); border-color:rgba(123,208,255,0.48); transform:translateY(-1px); }
.dt-bg-preview-meta { position:absolute; left:14px; right:14px; bottom:12px; z-index:4; display:flex; align-items:flex-end; justify-content:space-between; gap:12px; }
.dt-bg-preview-title { color:#f6fbff; font-size:clamp(1rem, 1.4vw, 1.35rem); font-weight:700; text-shadow:0 2px 10px rgba(0,0,0,0.75); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.dt-bg-preview-sub { color:#9fb7c7; font-size:0.82rem; margin-top:2px; text-transform:uppercase; letter-spacing:0.8px; }
.dt-workshop-count { color:#d7b75a; font-weight:700; font-size:0.82rem; border:1px solid rgba(215,183,90,0.22); background:rgba(215,183,90,0.08); padding:5px 8px; border-radius:2px; white-space:nowrap; }
.bg-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:12px; max-height:none; overflow:visible; padding:2px 8px 14px 0; }
.bg-grid::-webkit-scrollbar { width:8px; }
.bg-grid::-webkit-scrollbar-track { background:rgba(2,8,12,0.48); border-radius:4px; }
.bg-grid::-webkit-scrollbar-thumb { background:linear-gradient(180deg, rgba(123,208,255,0.62), rgba(57,168,255,0.34)); border-radius:4px; }
.bg-card { position:relative; border-radius:3px; overflow:hidden; cursor:pointer; height:132px; min-height:132px; border:1px solid rgba(126,188,220,0.12); transition:transform 0.18s cubic-bezier(0.4,0,0.2,1), border-color 0.18s, box-shadow 0.18s; box-shadow:0 10px 20px rgba(0,0,0,0.28); background:#000 center center / cover no-repeat; will-change:transform; }
.bg-card:hover { transform:translateY(-2px); z-index:10; border-color:rgba(123,208,255,0.42); box-shadow:0 18px 34px rgba(0,0,0,0.38), 0 0 0 1px rgba(57,168,255,0.12); }
.bg-card img { position:absolute; left:0; top:0; right:0; bottom:0; width:100%; height:100%; display:block; object-fit:cover; transition:opacity 0.3s; z-index:1; }
.bg-name { position:absolute; bottom:0; left:0; right:0; z-index:2; background:linear-gradient(transparent,rgba(0,0,0,0.92)); color:white; padding:26px 10px 9px; font-size:0.82rem; text-align:left; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; pointer-events:none; }
.bg-card.bg-disabled { border-color:var(--danger); }
.bg-card.bg-disabled img { opacity:0.35; filter:grayscale(80%); }
.bg-disabled-badge { position:absolute; top:8px; right:8px; z-index:3; background:rgba(239,68,68,0.9); color:white; padding:4px 8px; border-radius:2px; font-size:0.72rem; font-weight:bold; letter-spacing:1px; box-shadow:0 2px 10px rgba(0,0,0,0.5); pointer-events:none; opacity:0; transition:opacity 0.2s; }
.bg-card.bg-disabled .bg-disabled-badge { opacity:1; }
.cat-card { position:relative; background:rgba(0,0,0,0.25); border:1px solid rgba(126,188,220,0.12); border-radius:3px; padding:0; display:block; cursor:pointer; transition:background 0.2s, border-color 0.2s, transform 0.2s, box-shadow 0.2s; min-height:180px; overflow:hidden; }
.cat-card:hover { background:rgba(23,39,52,0.84); border-color:rgba(123,208,255,0.35); transform:translateY(-2px); box-shadow:0 18px 34px rgba(0,0,0,0.38); }
.cat-card img, .cat-thumb { width:100%; height:132px; object-fit:cover; display:block; background:#05090d; }
.cat-body { padding:11px 12px 12px; background:linear-gradient(180deg, rgba(10,16,23,0.88), rgba(8,13,18,0.98)); }
.cat-title { font-size:1rem; font-weight:700; color:#f8fafc; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.cat-meta { font-size:0.8rem; color:#93a9b9; margin-top:3px; display:flex; justify-content:space-between; gap:8px; }
.cat-chip { color:#d7b75a; font-weight:700; }
.cat-card > img:first-child,
.cat-card > div:first-child:not(.cat-body),
.cat-card > img:first-child[style*="display:none"] + div { width:100% !important; height:132px !important; min-width:0 !important; border-radius:0 !important; object-fit:cover !important; box-shadow:none !important; border:none !important; background:linear-gradient(135deg, rgba(57,168,255,0.08), rgba(215,183,90,0.08)) !important; }
.cat-card > div:last-child { padding:11px 12px 12px !important; background:linear-gradient(180deg, rgba(10,16,23,0.88), rgba(8,13,18,0.98)) !important; }
body.dt-theme-route-open #NavBar { height:50px !important; background:linear-gradient(90deg, rgba(3,7,10,0.96), rgba(10,19,27,0.98), rgba(3,7,10,0.96)) !important; border-top:1px solid rgba(126,188,220,0.2) !important; box-shadow:0 -16px 45px rgba(0,0,0,0.58), inset 0 1px 0 rgba(255,255,255,0.04) !important; }
body.dt-theme-route-open #NavBar .group.center { display:-webkit-box !important; visibility:hidden !important; pointer-events:none !important; -webkit-box-flex:1 !important; -webkit-box-pack:end !important; margin:0 10% !important; }
body.dt-theme-route-open #NavBar .button { height:40px !important; margin-top:5px !important; margin-right:3px !important; background:linear-gradient(180deg, rgba(20,31,39,0.96), rgba(7,11,16,0.96)) !important; border:1px solid rgba(126,188,220,0.22) !important; border-radius:3px !important; color:#dceaf2 !important; text-shadow:0 1px 2px rgba(0,0,0,0.65) !important; box-shadow:inset 0 1px 0 rgba(255,255,255,0.06), 0 7px 18px rgba(0,0,0,0.34) !important; box-sizing:border-box !important; }
body.dt-theme-route-open #NavBar .button:hover { background:linear-gradient(180deg, rgba(34,54,69,0.98), rgba(10,18,26,0.98)) !important; border-color:rgba(123,208,255,0.42) !important; color:#fff !important; box-shadow:0 0 18px rgba(123,208,255,0.18), inset 0 1px 0 rgba(255,255,255,0.08) !important; }
body.dt-theme-route-open #NavBar .button span { color:#dceaf2 !important; }
body.dt-theme-route-open #BackToMenu { min-width:168px !important; }
body.dt-theme-route-open #BackToMenu::before { content:none !important; display:none !important; }
body.dt-theme-creator-open #NavBar .group.center,
body.dt-theme-creator-open #NavBar .group.right { display:none !important; visibility:hidden !important; pointer-events:none !important; }
body.dt-theme-creator-open #BackToMenu { min-width:192px !important; }
body.dt-theme-route-open #NavBar .group.right .button { overflow:visible !important; }
body.dt-theme-route-open #NavBar number, body.dt-theme-route-open #NavBar .count { background:#ffcf2f !important; color:#101418 !important; border-radius:3px !important; box-shadow:0 0 10px rgba(255,207,47,0.35) !important; }
.theme-btn { background:rgba(255,255,255,0.1); color:white; border:1px solid var(--border); padding:8px 16px; border-radius:6px; cursor:pointer; transition:background 0.2s, transform 0.2s; font-size:0.9rem; font-weight:500; font-family:inherit; }
.theme-btn:hover { background:rgba(255,255,255,0.2); transform:translateY(-1px); }
.theme-input { background:linear-gradient(180deg, rgba(8,16,23,0.94), rgba(3,8,12,0.96)); border:1px solid rgba(126,188,220,0.18); color:#eaf7ff; padding:8px 12px; border-radius:3px; outline:none; font-family:inherit; box-shadow:inset 0 1px 0 rgba(255,255,255,0.035); transition:border-color 0.2s, box-shadow 0.2s, background 0.2s; }
.theme-input:focus { border-color:rgba(123,208,255,0.56); box-shadow:0 0 0 2px rgba(57,168,255,0.16), inset 0 1px 0 rgba(255,255,255,0.05); background:linear-gradient(180deg, rgba(13,26,36,0.98), rgba(4,10,15,0.98)); }
.theme-input::placeholder { color:#7892a3; opacity:1; }
.active-bg-banner { display:inline-flex; align-items:center; gap:8px; background:rgba(16,185,129,0.15); color:#34d399; padding:6px 12px; border-radius:6px; border:1px solid rgba(16,185,129,0.3); font-size:0.9rem; font-weight:500; }
.dt-control-strip { display:flex; align-items:center; gap:10px; margin-bottom:12px; padding:10px 12px; border:1px solid rgba(126,188,220,0.18); background:linear-gradient(180deg, rgba(9,18,25,0.72), rgba(4,9,13,0.74)); border-radius:4px; }
.dt-control-label { font-size:0.78rem; color:#7bd0ff; font-weight:700; text-transform:uppercase; letter-spacing:1px; white-space:nowrap; }
.dt-control-value { font-size:0.82rem; color:#d7b75a; font-weight:700; min-width:36px; text-align:right; }
.dt-sound-row { display:flex; align-items:center; gap:12px; padding:10px 14px; border-radius:4px; cursor:pointer; background:rgba(0,0,0,0.16); border:1px solid rgba(126,188,220,0.08); transition:background 0.16s, border-color 0.16s, box-shadow 0.16s; }
.dt-sound-row:hover { background:rgba(25,44,58,0.64); border-color:rgba(123,208,255,0.28); }
.dt-sound-row.is-active { background:linear-gradient(90deg, rgba(57,168,255,0.16), rgba(5,11,16,0.72)); border-color:rgba(123,208,255,0.36); box-shadow:inset 3px 0 0 var(--primary); }
.dt-sound-thumb { width:38px; height:38px; border-radius:4px; object-fit:cover; border:1px solid rgba(126,188,220,0.2); background:rgba(0,0,0,0.22); display:flex; align-items:center; justify-content:center; color:#7bd0ff; font-weight:700; flex:0 0 auto; }
.dt-sound-title { font-size:0.95rem; font-weight:600; color:#e2e8f0; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.dt-sound-row.is-active .dt-sound-title { color:#eaf7ff; }
.dt-sound-meta { font-size:0.78rem; color:#7892a3; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.dt-font-row { display:flex; align-items:center; gap:12px; padding:10px 14px; border-radius:4px; cursor:pointer; background:rgba(0,0,0,0.16); border:1px solid rgba(126,188,220,0.08); transition:background 0.16s, border-color 0.16s, box-shadow 0.16s; }
.dt-font-row:hover { background:rgba(25,44,58,0.64); border-color:rgba(123,208,255,0.28); }
.dt-font-row.is-active { background:linear-gradient(90deg, rgba(57,168,255,0.16), rgba(5,11,16,0.72)); border-color:rgba(123,208,255,0.36); box-shadow:inset 3px 0 0 var(--primary); }
.dt-font-sample { min-width:116px; max-width:170px; color:#eaf7ff; font-size:1.05rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.dt-font-title { color:#e2e8f0; font-size:0.92rem; font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.dt-font-meta { color:#7892a3; font-size:0.76rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.dt-active-pill { display:inline-flex; align-items:center; font-size:0.72rem; font-weight:700; color:#d7b75a; background:rgba(215,183,90,0.11); border:1px solid rgba(215,183,90,0.22); padding:3px 9px; border-radius:999px; text-transform:uppercase; letter-spacing:0.7px; }
.portal-player { position:relative; width:100%; max-width:620px; min-height:138px; padding:14px 16px 13px; color:#b77d2d; border:1px solid rgba(183,125,45,0.25); background:linear-gradient(180deg, rgba(9,12,12,0.96), rgba(4,6,6,0.98)); box-shadow:inset 0 0 0 1px rgba(183,125,45,0.045), inset 0 0 24px rgba(183,125,45,0.035), 0 10px 24px rgba(0,0,0,0.3); font-family:Consolas, "Courier New", monospace; overflow:hidden; }
.portal-player::before { content:''; position:absolute; left:9px; right:9px; top:9px; bottom:9px; border:1px dashed rgba(215,154,57,0.2); pointer-events:none; }
.portal-player::after { content:''; position:absolute; left:0; right:0; top:0; bottom:0; background:linear-gradient(rgba(215,154,57,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(215,154,57,0.025) 1px, transparent 1px); background-size:18px 18px; opacity:0.6; pointer-events:none; }
.portal-player * { position:relative; z-index:1; box-sizing:border-box; }
.portal-topline { display:flex; justify-content:space-between; gap:10px; font-size:0.7rem; letter-spacing:0.9px; text-transform:uppercase; color:#d79a39; opacity:0.88; margin-bottom:8px; border-bottom:1px solid rgba(215,154,57,0.18); padding-bottom:6px; }
.portal-track-row { display:grid; grid-template-columns:105px minmax(0,1fr); gap:10px; align-items:baseline; margin-bottom:9px; }
.portal-track-label { font-size:0.68rem; color:#8f6428; letter-spacing:1.1px; text-transform:uppercase; }
.portal-track-name { color:#e2aa59; font-size:0.95rem; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; text-shadow:0 0 8px rgba(215,154,57,0.16); }
.portal-viz { position:relative; height:44px; padding:6px 8px; border:1px solid rgba(183,125,45,0.14); background:linear-gradient(180deg, rgba(0,0,0,0.34), rgba(12,8,3,0.38)); overflow:hidden; }
.portal-viz canvas { width:100%; height:100%; display:block; opacity:0.5; filter:drop-shadow(0 0 3px rgba(183,125,45,0.2)); }
.portal-player.playing .portal-viz canvas { opacity:0.78; }
.portal-player .portal-controls { display:flex; align-items:center; gap:10px; margin-top:9px; }
.portal-player .portal-button { width:30px; height:26px; border:1px solid rgba(215,154,57,0.24); background:rgba(0,0,0,0.28); color:#d79a39; cursor:pointer; font-family:inherit; font-size:0.78rem; display:flex; align-items:center; justify-content:center; }
.portal-player .portal-button:hover { background:rgba(215,154,57,0.12); border-color:rgba(226,170,89,0.46); color:#ffd08a; }
.portal-player #music_time_label { color:#d79a39 !important; font-family:Consolas, "Courier New", monospace; }
.portal-progress-track { flex:1; height:5px; background:rgba(215,154,57,0.09); border:1px solid rgba(215,154,57,0.18); overflow:hidden; }
.portal-progress-fill { width:0%; height:100%; background:linear-gradient(90deg, #d79a39, #f0b15d); box-shadow:0 0 10px rgba(215,154,57,0.35); transition:width 0.1s linear; }
.preview-overlay { position:fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.92); z-index:10000; display:flex; align-items:center; justify-content:center; animation:modalFadeIn 0.2s ease-out; will-change:opacity; }
.preview-overlay.dt-live-expanded .preview-bg-image { animation:dtExpandedPreviewIn 0.38s cubic-bezier(0.16,1,0.3,1) both; }
@keyframes dtExpandedPreviewIn { from{ transform:scale(0.96); opacity:0.18; filter:saturate(0.8) brightness(0.7); } to{ transform:scale(1); opacity:1; filter:saturate(1) brightness(1); } }
@keyframes modalFadeIn { from{opacity:0} to{opacity:1} }
.preview-close { position:absolute; top:20px; right:30px; font-size:2rem; color:#94a3b8; cursor:pointer; background:rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.1); border-radius:50%; width:48px; height:48px; display:flex; align-items:center; justify-content:center; transition:color 0.2s, background 0.2s, border-color 0.2s; z-index:10001; }
.preview-close:hover { color:#fff; background:rgba(239,68,68,0.4); border-color:rgba(239,68,68,0.6); }
.preview-arrow { position:absolute; top:50%; transform:translateY(-50%); font-size:2.5rem; color:#cbd5e1; cursor:pointer; background:rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.1); border-radius:12px; width:56px; height:80px; display:flex; align-items:center; justify-content:center; transition:color 0.2s, background 0.2s, border-color 0.2s; z-index:10001; user-select:none; }
.preview-arrow:hover { color:#fff; background:rgba(59,130,246,0.3); border-color:rgba(59,130,246,0.5); }
.preview-arrow.left { left:25px; }
.preview-arrow.right { right:25px; }
.preview-bg-image { max-width:85vw; max-height:80vh; border-radius:12px; box-shadow:0 30px 60px rgba(0,0,0,0.6); object-fit:contain; will-change:contents; }
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
.music-track { display:flex; align-items:center; gap:15px; padding:12px 20px; background:linear-gradient(180deg, rgba(15,26,35,0.72), rgba(7,13,18,0.86)); border:1px solid rgba(126,188,220,0.13); border-radius:4px; cursor:pointer; transition:background 0.2s, border-color 0.2s, transform 0.2s, box-shadow 0.2s; margin-bottom:8px; }
.music-track:hover { background:linear-gradient(180deg, rgba(25,43,55,0.92), rgba(9,18,25,0.94)); border-color:rgba(123,208,255,0.32); transform:translateY(-1px); box-shadow:0 12px 22px rgba(0,0,0,0.22), inset 3px 0 0 rgba(215,183,90,0.55); }
.music-track.music-disabled { opacity:0.5; }
.music-track-icon { width:48px;height:48px;background:linear-gradient(135deg, rgba(57,168,255,0.12), rgba(215,183,90,0.06));border-radius:4px;display:flex;align-items:center;justify-content:center;flex-shrink:0;overflow:hidden;border:1px solid rgba(126,188,220,0.16);box-shadow:inset 0 0 18px rgba(57,168,255,0.04); }
.music-track-icon .dt-ico { --ico:#d7b75a; transform:scale(1.25); }
.music-track-copy { flex:1;overflow:hidden;display:flex;flex-direction:column;justify-content:center;min-width:0; }
.music-track-hint { white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:0.74rem;color:#5f7688;text-transform:uppercase;letter-spacing:0.7px;margin-top:2px; }
.music-track:hover .music-track-hint { color:#9edfff; }
@keyframes modalCardIn { from{opacity:0;transform:scale(0.9) translateY(20px)} to{opacity:1;transform:scale(1) translateY(0)} }
.music-detail-card { background:var(--bg-dark); border-radius:16px; padding:35px; max-width:450px; width:90vw; border:1px solid rgba(255,255,255,0.08); box-shadow:0 30px 60px rgba(0,0,0,0.5); display:flex; flex-direction:column; align-items:center; gap:20px; animation:modalCardIn 0.3s cubic-bezier(0.16,1,0.3,1); }
.music-detail-cover { width:200px; height:200px; border-radius:12px; object-fit:cover; box-shadow:0 15px 35px rgba(0,0,0,0.5); border:1px solid rgba(255,255,255,0.05); }
.music-detail-placeholder { width:200px; height:200px; border-radius:12px; background:linear-gradient(145deg, rgba(31,29,22,0.96), rgba(12,15,18,0.98)); display:flex; align-items:center; justify-content:center; font-size:5rem; color:#d7b75a; border:1px solid rgba(215,183,90,0.18); }
.music-detail-placeholder .dt-ico { width:38px; height:38px; flex-basis:38px; transform:scale(2.2); }
.yt-button { display:inline-flex; align-items:center; gap:8px; padding:10px 22px; background:rgba(255,0,0,0.15); color:#ff4444; border:1px solid rgba(255,0,0,0.3); border-radius:8px; cursor:pointer; font-size:0.95rem; font-weight:600; transition:background 0.2s, border-color 0.2s, color 0.2s, transform 0.2s; }
.yt-button:hover { background:rgba(255,0,0,0.3); border-color:rgba(255,0,0,0.5); color:#ff6666; transform:translateY(-1px); }
@keyframes guideSlideIn { from{opacity:0;transform:translateX(30px)} to{opacity:1;transform:translateX(0)} }
.dt-guide-step { background:rgba(0,0,0,0.2); padding:12px; border-radius:8px; margin-bottom:12px; border-left:3px solid #3b82f6; }
.dt-guide-step code { background:rgba(0,0,0,0.4); padding:2px 6px; border-radius:4px; color:#38bdf8; font-family:Consolas,monospace; font-size:0.85rem; }
.dt-guide-list { margin:8px 0 0; padding:0; list-style:none; display:flex; flex-direction:column; gap:6px; }
.dt-guide-list li { position:relative; padding-left:15px; color:#c7d6df; }
.dt-guide-list li::before { content:''; position:absolute; left:0; top:0.72em; width:6px; height:1px; background:#7bd0ff; box-shadow:0 0 7px rgba(123,208,255,0.32); }
.dt-subpage-overlay { position:fixed; left:0; top:0; width:100vw; height:100vh; background:radial-gradient(circle at 50% 42%, rgba(8,18,26,0.84), rgba(1,5,9,0.94) 70%); z-index:9999; display:-webkit-box; display:flex; -webkit-box-align:center; -webkit-box-pack:center; align-items:center; justify-content:center; }
.dt-subpage-shell { margin:auto; background:linear-gradient(115deg, rgba(19,31,42,0.99), rgba(8,14,20,0.99) 58%, rgba(17,23,28,0.99)); border:1px solid rgba(126,188,220,0.22); border-radius:4px; box-shadow:0 30px 80px rgba(0,0,0,0.72), inset 0 1px 0 rgba(255,255,255,0.05); color:#d9e5ee; overflow:hidden; }
.dt-subpage-title { color:#f6fbff; font-weight:700; letter-spacing:0; text-shadow:0 2px 12px rgba(57,168,255,0.18); }
.dt-subpage-kicker { color:#7bd0ff; font-size:0.7rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; }
.dt-subpage-close { width:34px; height:34px; border:1px solid rgba(126,188,220,0.24); border-radius:3px; background:rgba(255,255,255,0.04); color:#9fb7c7; cursor:pointer; font-size:1rem; }
.dt-subpage-close:hover { color:#fff; border-color:rgba(123,208,255,0.42); background:rgba(57,168,255,0.1); }
.dt-help-tab { display:flex; align-items:center; gap:10px; width:100%; padding:11px 12px; background:transparent; border:1px solid transparent; border-radius:3px; color:#93a9b9; font-size:0.9rem; cursor:pointer; text-align:left; font-family:inherit; text-transform:uppercase; letter-spacing:0; }
.dt-help-tab.active { background:rgba(57,168,255,0.12); border-color:rgba(57,168,255,0.28); color:#f6fbff; box-shadow:inset 3px 0 0 var(--primary); font-weight:700; }
.dt-help-tab:hover { color:#eaf7ff; background:rgba(57,168,255,0.08); }
.dt-changelog-entry { margin-bottom:16px; padding:14px; background:rgba(5,10,15,0.42); border:1px solid rgba(126,188,220,0.12); border-radius:3px; }
.dt-changelog-entry:hover { border-color:rgba(123,208,255,0.22); background:rgba(8,16,23,0.54); }
.dt-version-badge { font-weight:700; color:#7bd0ff; font-size:1.05rem; }
.dt-tag-badge { font-size:0.7rem; padding:2px 8px; background:rgba(57,168,255,0.12); color:#9edfff; border:1px solid rgba(57,168,255,0.26); border-radius:3px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; }
.dt-change-section { margin-top:14px; }
.dt-change-section:first-of-type { margin-top:2px; }
.dt-change-section-title { margin:0 0 5px 4px; color:#d7b75a; font-size:0.74rem; font-weight:900; letter-spacing:1.2px; text-transform:uppercase; }
.dt-change-line { padding:6px 0 6px 14px; color:#cbd5e1; font-size:0.9rem; border-left:2px solid rgba(126,188,220,0.08); margin-left:4px; }
.dt-change-line span { color:#d7b75a; margin-right:8px; }
.dt-credits-block { margin-top:10px; padding-top:20px; border-top:1px solid rgba(126,188,220,0.14); }
.dt-credits-title { font-size:0.76rem; font-weight:700; color:#7892a3; text-transform:uppercase; letter-spacing:1px; margin-bottom:10px; }
.dt-credit-row { display:flex; gap:10px; margin-bottom:6px; font-size:0.88rem; }
.dt-credit-row span { color:#7892a3; min-width:130px; }
.dt-credit-row strong { color:#cbd5e1; font-weight:600; }
.dt-loading-line { padding:18px 4px; color:#7892a3; font-size:0.86rem; letter-spacing:0.4px; }
#dt_help_panel, #dt_changelog_panel { background:rgba(1,5,9,0.76) !important; }
#dt_changelog_inner { width:720px !important; max-height:76vh !important; overflow:hidden !important; background:linear-gradient(115deg, rgba(19,31,42,0.99), rgba(8,14,20,0.99) 58%, rgba(17,23,28,0.99)) !important; border:1px solid rgba(126,188,220,0.22) !important; border-radius:4px !important; box-shadow:0 30px 80px rgba(0,0,0,0.72), inset 0 1px 0 rgba(255,255,255,0.05) !important; color:#d9e5ee !important; }
#dt_changelog_content::-webkit-scrollbar { width:8px; }
#dt_changelog_content::-webkit-scrollbar-track { background:rgba(255,255,255,0.03); border-radius:4px; }
#dt_changelog_content::-webkit-scrollbar-thumb { background:rgba(57,168,255,0.42); border-radius:4px; }
#dt_help_x, #dt_changelog_x { width:34px !important; height:34px !important; border:1px solid rgba(126,188,220,0.24) !important; border-radius:3px !important; background:rgba(255,255,255,0.04) !important; color:#9fb7c7 !important; cursor:pointer !important; font-size:1rem !important; padding:0 !important; }
#dt_help_x:hover, #dt_changelog_x:hover { color:#fff !important; border-color:rgba(123,208,255,0.42) !important; background:rgba(57,168,255,0.1) !important; }
@media (max-width: 980px) {
    .theme-container { width:calc(100vw - 20px); height:calc(100vh - 70px); max-height:calc(100vh - 70px); padding:12px; }
    .dt-bg-layout { grid-template-columns:1fr; }
    .dt-bg-side { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); }
    .dt-bg-main { grid-template-rows:minmax(190px, 30vh) minmax(0,1fr); }
    .bg-grid { grid-template-columns:repeat(auto-fill,minmax(160px,1fr)); }
    .dt-theme-grid { grid-template-columns:1fr; }
}
@media (max-width: 640px) {
    .theme-tabs { gap:4px; }
    .theme-tab { padding:10px 9px; }
    .dt-toolbar { align-items:stretch; }
    .dt-toolbar > * { width:100%; }
    .dt-bg-side { grid-template-columns:1fr; }
    .bg-grid { grid-template-columns:repeat(auto-fill,minmax(140px,1fr)); }
    .cat-card { min-height:150px; }
    .cat-card img, .cat-thumb { height:104px; }
    .dt-theme-catalog-head, .dt-section-heading { align-items:flex-start; flex-direction:column; }
}
</style>
<div id="theme_options_page" style="position:absolute;left:0;right:0;top:0;bottom:50px;overflow:hidden;padding:20px;display:flex;align-items:center;justify-content:center;">
    <div class="theme-container">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
            <h2 class="theme-header" style="margin-bottom:0;"><span class="aperture-mark"><span class="core-eye"></span><b></b></span><span class="theme-header-copy">Theme Engine</span></h2>
            <div class="dt-header-actions">
                <button id="dt_help_btn" class="dt-action-btn help" onclick="DarkThemeEngine_ShowHelp()">Help</button>
                <button id="dt_changelog_btn" class="dt-action-btn changelog" onclick="DarkThemeEngine_ShowChangelog()">Changelog<span id="dt_changelog_new" class="dt-action-dot"></span></button>
            </div>
        </div>
        <div class="theme-tabs">
            <button class="theme-tab active" onclick="DarkThemeEngine_SwitchTab('main',this)">Themes</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('backgrounds',this)">Backgrounds</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('music',this)">Menu Music</button>
            <button class="theme-tab" onclick="DarkThemeEngine_SwitchTab('misc',this)">Miscellaneous</button>
        </div>
        <div id="tab_main" class="tab-content active">
            <div id="dt_theme_main_page">
                <div class="dt-main-section">
                    <div class="dt-theme-catalog-head">
                        <div>
                            <div class="dt-section-kicker">Theme Library</div>
                            <div class="dt-section-title">Themes</div>
                            <div class="dt-section-desc">Themes are grouped so community packs can add their own category later.</div>
                        </div>
                        <div class="dt-theme-head-actions">
                            <button class="dt-reload-theme-btn" title="Reload the selected theme from mounted files" onclick="DarkThemeEngine_LuaCall('DarkThemeEngine_ReloadSelectedTheme()')"><span class="dt-ico dt-ico-refresh"></span>Reload Selected</button>
                        </div>
                    </div>
                    <div class="dt-theme-category">
                        <div class="dt-category-label">Installed Defaults</div>
                        <div class="dt-theme-grid">
                            <div id="theme_item_light" class="dt-theme-card" data-icon="GM" style="--hover:#60a5fa;" onclick="DarkThemeEngine_UISelect('light')">
	                    <div><div class="theme-title">Light Theme</div><div class="theme-desc">The classic default Garry's Mod main menu.</div></div>
                    <div class="theme-check"></div>
                </div>
                            <div id="theme_item_dark" class="dt-theme-card" data-icon="DT" style="--hover:#7bd0ff;" onclick="DarkThemeEngine_UISelect('dark')">
	                    <div><div class="theme-title">Dark Theme</div><div class="theme-desc">A darker Source-style interface tuned for this engine.</div></div>
                    <div class="theme-check"></div>
                </div>
                        </div>
                    </div>
                    <div class="dt-theme-category">
                        <div class="dt-category-label">Community Themes</div>
                        <div id="dt_community_theme_grid" class="dt-theme-grid">
                            <div class="dt-theme-card disabled" data-icon="TE" style="--hover:#d7b75a;">
	                    <div><div class="theme-title">Custom Theme</div><div class="theme-desc">Install the editable GMod Light example with the setup program, or mount a Workshop pack under data_static/theme_engine_full_themes/.</div></div>
                    <div class="theme-check"></div>
                </div>
                        </div>
                    </div>
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
                        <div class="dt-search-field"><span class="dt-ico dt-ico-search"></span><input type="text" class="theme-input" placeholder="Search categories..." id="bg_search_input" oninput="DarkThemeEngine_FilterBgs()" style="font-size:0.88rem;"></div>
                    </div>
                </div>
                <div style="height:1px;background:rgba(255,255,255,0.05);margin-bottom:14px;"></div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                    <div style="background:rgba(0,0,0,0.15);border-radius:8px;padding:12px 14px;border:1px solid rgba(255,255,255,0.04);">
                        <div style="font-size:0.78rem;font-weight:600;color:#64748b;text-transform:uppercase;letter-spacing:0.6px;margin-bottom:10px;">Rotation</div>
                        <div style="display:flex;flex-direction:column;gap:8px;">
                            <label class="switch-label" style="font-size:0.9rem;"><div class="switch"><input type="checkbox" id="opt_bg_static" onchange="DarkThemeEngine_SetBgOpt('BG_Static',this.checked);DarkThemeEngine_UpdateFadeOptions(this.checked)"><span class="slider"></span></div>Static background <span style="font-size:0.8rem;color:#64748b;margin-left:4px;">(no slideshow)</span></label>
                            <div id="fade_interval" style="display:flex;align-items:center;gap:10px;padding-left:2px;">
                                <span class="dt-inline-icon" style="font-size:0.88rem;color:#94a3b8;white-space:nowrap;min-width:102px;"><span class="dt-ico dt-ico-timer"></span>Swap every</span>
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
                                <span class="dt-inline-icon" style="font-size:0.88rem;color:#94a3b8;white-space:nowrap;min-width:102px;"><span class="dt-ico dt-ico-overlay" style="--ico:#d7b75a;"></span>Overlay dim</span>
                                <input type="range" id="opt_bg_overlay" min="0" max="70" step="5" value="0" oninput="DarkThemeEngine_SetBgOpt('BG_Overlay',parseInt(this.value)/100);document.getElementById('opt_bg_overlay_label').textContent=this.value+'%'" style="flex:1;accent-color:#3b82f6;cursor:pointer;">
                                <span id="opt_bg_overlay_label" style="font-size:0.85rem;color:#60a5fa;font-weight:600;min-width:30px;text-align:right;">0%</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="dt-bg-preview" id="dt_bg_live_preview" style="margin-bottom:12px;">
                <div class="dt-bg-preview-empty" id="dt_bg_preview_empty">No background selected</div>
                <img id="dt_bg_preview_prev_img" class="dt-preview-outgoing" style="display:none;" />
                <img id="dt_bg_preview_img" style="display:none;" />
                <div class="dt-bg-preview-dim" id="dt_bg_preview_dim"></div>
                <button class="dt-bg-preview-nav prev" onclick="DarkThemeEngine_PreviewStep(-1)" title="Previous background"><span class="dt-ico dt-ico-prev"></span></button>
                <button class="dt-bg-preview-nav next" onclick="DarkThemeEngine_PreviewStep(1)" title="Next background"><span class="dt-ico dt-ico-next"></span></button>
                <button class="dt-bg-preview-expand" id="dt_bg_expand_btn" onclick="DarkThemeEngine_ExpandLiveBackground()" title="Expand current background"><span class="dt-ico dt-ico-expand"></span><span>Expand</span></button>
                <div class="dt-bg-preview-meta">
                    <div style="min-width:0;">
                        <div class="dt-bg-preview-title" id="dt_bg_preview_title">No background selected</div>
                        <div class="dt-bg-preview-sub" id="dt_bg_preview_sub">Theme Engine preview</div>
                    </div>
                    <div class="dt-workshop-count" id="dt_bg_preview_count">0 items</div>
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
                        <div style="color:#cbd5e1;font-size:0.95rem;line-height:1.5;margin-bottom:15px;">Customize your menu music. Click on any track to <strong>disable</strong> or <strong>enable</strong> it. Disabled tracks will not be played.<br><span class="dt-inline-icon" style="font-size:0.85rem;color:#94a3b8;display:inline-flex;margin-top:5px;"><span class="dt-ico dt-ico-music" style="--ico:#d7b75a;"></span>Add local files to: <code style="background:rgba(0,0,0,0.3);padding:2px 6px;border-radius:4px;color:#cbd5e1;">sound/theme_engine_music/</code></span></div>
                        <div class="portal-player" id="music_portal_player">
                            <div class="portal-topline"><span>Forms FORM-29827281-12-2:</span><span id="music_signal_label">SIGNAL 00.00</span></div>
                            <div class="portal-track-row"><div class="portal-track-label">Now playing</div><div class="portal-track-name" id="music_now_playing">NO ACTIVE TRANSMISSION</div></div>
                            <div class="portal-viz" id="music_visualizer"><canvas id="music_visualizer_canvas" width="560" height="48"></canvas></div>
                            <div class="portal-controls">
                                <button class="portal-button" id="music_btn_pause" onclick="DarkThemeEngine_TogglePause()" title="Pause/Resume"><span class="dt-ico dt-ico-play"></span></button>
                                <button class="portal-button" onclick="DarkThemeEngine_SkipTrack()" title="Next Track"><span class="dt-ico dt-ico-music-next"></span></button>
                                <span id="music_time_label" style="font-size:0.75rem;font-variant-numeric:tabular-nums;min-width:84px;text-align:right;">00:00 / 00:00</span>
                                <div id="music_progress_track" class="portal-progress-track"><div id="music_progress_fill" class="portal-progress-fill"></div></div>
                            </div>
                        </div>
                    </div>
                    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                        <div class="dt-search-field"><span class="dt-ico dt-ico-search"></span><input type="text" class="theme-input" placeholder="Search..." id="music_search_input" oninput="DarkThemeEngine_FilterMusic()" style="font-size:0.9rem;"></div>
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
                            <span class="dt-inline-icon" style="font-size:0.9rem;color:#cbd5e1;white-space:nowrap;"><span class="dt-ico dt-ico-volume"></span>Volume</span>
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
                            <div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:3px;">Menu Sounds</div>
                            <div style="font-size:0.85rem;color:#64748b;">Choose a sound pack for menu clicks, hover, return, and button releases.</div>
                        </div>
                        <button class="theme-btn dt-inline-icon" style="font-size:0.82rem;padding:6px 14px;background:rgba(57,168,255,0.1);color:#9edfff;border:1px solid rgba(57,168,255,0.25);" onclick="DarkThemeEngine_LuaCall('DarkThemeEngine.InvalidateMenuSoundCache(); DarkThemeEngine.SendMenuSoundPacksToJS()')"><span class="dt-ico dt-ico-refresh"></span>Refresh</button>
                    </div>
                    <div id="misc_menusounds_list"><div style="text-align:center;color:#94a3b8;padding:20px;">Loading...</div></div>
                </div>
                <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:18px 20px;border:1px solid rgba(255,255,255,0.05);">
                    <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;flex-wrap:wrap;">
                        <div>
                            <div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:3px;">Spawnmenu Skin</div>
                            <div style="font-size:0.85rem;color:#64748b;">Choose a visual theme for the in-game Q menu. Requires the skin addon to be installed. <span class="dt-inline-icon" style="color:#f59e0b;"><span class="dt-ico dt-ico-warning" style="--ico:#f59e0b;"></span>Applies on next game join.</span></div>
                        </div>
                        <button class="theme-btn dt-inline-icon" style="font-size:0.82rem;padding:6px 14px;background:rgba(59,130,246,0.1);color:#60a5fa;border:1px solid rgba(59,130,246,0.25);" onclick="DarkThemeEngine_LuaCall('DarkThemeEngine.InvalidateSpawnmenuCache(); DarkThemeEngine.SendSpawnmenuToJS()')"><span class="dt-ico dt-ico-refresh"></span>Refresh</button>
                    </div>
                    <div id="misc_spawnmenu_list"><div style="text-align:center;color:#94a3b8;padding:20px;">Loading...</div></div>
                </div>
                <div style="background:rgba(0,0,0,0.25);border-radius:12px;padding:18px 20px;border:1px solid rgba(255,255,255,0.05);">
                    <div style="margin-bottom:14px;">
                        <div style="font-size:1rem;font-weight:600;color:#f8fafc;margin-bottom:3px;">Menu Font</div>
                        <div style="font-size:0.85rem;color:#64748b;">Override the font used in the main menu interface.</div>
                    </div>
                    <div id="misc_font_list" class="dt-scrollable" style="display:flex;flex-direction:column;gap:6px;max-height:238px;overflow-y:auto;padding-right:4px;margin-bottom:12px;"></div>
                    <div style="display:flex;align-items:center;gap:10px;margin-top:10px;">
                        <span style="font-size:0.85rem;color:#94a3b8;white-space:nowrap;">Font Size:</span>
                        <input type="range" id="opt_font_size" min="8" max="20" value="12" step="1" style="flex:1;max-width:180px;accent-color:#3b82f6;cursor:pointer;" oninput="DarkThemeEngine_SetFontSize(parseInt(this.value))">
                        <span id="opt_font_size_label" style="font-size:0.82rem;color:#60a5fa;font-weight:600;min-width:32px;">12px</span>
                        <button class="theme-btn" style="font-size:0.75rem;padding:4px 10px;background:rgba(148,163,184,0.1);color:#94a3b8;border:1px solid rgba(148,163,184,0.2);" onclick="DarkThemeEngine_SetFontSize(0)">Default</button>
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
    if (window.DarkThemeEngine_RenderFontList) setTimeout(window.DarkThemeEngine_RenderFontList, 70);
    if (window.DarkThemeEngine_LuaCall) setTimeout(function() { window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendBackgroundsToJS()'); }, 80);
    if (window.DarkThemeEngine_LuaCall) setTimeout(function() { window.DarkThemeEngine_LuaCall('DarkThemeEngine.SendGladosLinesToJS()'); }, 120);
    if (window.DarkThemeEngine_CleanupAllOverlays) window.DarkThemeEngine_CleanupAllOverlays();
})();
</script>
]==]
