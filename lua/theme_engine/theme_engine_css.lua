DarkThemeCSS = DarkThemeCSS or {}
DarkThemeCSS.Menu = [==[
BODY { overflow:hidden; background-color:transparent; font-family:"Helvetica Neue",Helvetica,Arial,sans-serif; -webkit-user-select:none; margin:0; padding:0; font-size:12px; -webkit-font-smoothing:antialiased; outline:none; }
INPUT { -webkit-user-select:auto; font-size:12px; }
INPUT.searchbox, INPUT.gm_search { border:1px solid #555; background-color:#2a2a2a; color:#e0e0e0; border-radius:3px; height:24px; margin-top:6px; padding:4px; }
INPUT.searchbox { float:right; margin-right:320px; width:15%; }
INPUT.gm_search { width:100%; margin-bottom:5px; }
INPUT[type="text"], INPUT[type="number"] { border:1px solid #555; background-color:#2a2a2a; color:#e0e0e0; border-radius:2px; outline-color:#08f; }
A { text-decoration:none; color:#6cf; }
A:not(:disabled) { cursor:pointer; }
UL.category LI:first-child { color:#e0e0e0; }
UL.category LI:first-child small { color:#999; }
.topnav { background-color:#222; padding:5px; border-radius:3px; font-size:11px; }
.topnav A { color:#fff; margin:0 2px; background-color:#0af; padding:1px 5px; border-radius:2px; text-shadow:1px 1px 0 #666; }
.topnav A:hover { text-shadow:none; }
.whiterounded { background-color:#1a1a1a; border-radius:4px; }
DIV.gridicon name { color:#ccc; background-color:rgba(26,26,26,0.9); }
DIV.disabled name { color:#ff5555; }
pagination { color:#e0e0e0; }
#version { color:#aaa; background-color:rgba(0,0,0,1.0); }
.btn-primary { -webkit-box-shadow:inset 0 1px 0 rgba(255,255,255,0.2), 0 1px 2px rgba(0,0,0,0.5); }
.btn-primary-disabled { border-color:#424242; background-image:-webkit-gradient(linear,0 0,0 100%,from(#555),to(#333)); }
.news_item { background:#222; border:1px solid #333; box-shadow:0 0 10px 1px rgba(0,0,0,0.8); border-radius:8px; }
.news_item div { background:rgba(0,0,0,0.8); }
.news_item div span:hover { color:#ffa; }
.news_buttons div { background:#666; box-shadow:0 0 10px 1px rgba(0,0,0,0.6); }
.news_buttons div.new { background:#A33; }
.news_buttons div.selected.new { background:#D55; }
.news_buttons div.selected { background:#aaa; }
div.centermessage { background:#2a2a2a; }
div.centermessage span { color:#e0e0e0; }
div.centermessage a { color:#e0e0e0; background:#444; }
div.centermessage a:hover { background:#555; }
div.centermessage a:active { background:#333; }
]==]
DarkThemeCSS.AlwaysOn = [==[
#theme_options_btn { color:#56d8ff !important; text-shadow:0 0 12px rgba(86,216,255,0.6),0 0 30px rgba(86,216,255,0.15); transition:all 0.3s ease; letter-spacing:0.5px; }
#theme_options_btn:hover { color:#8eeaff !important; text-shadow:0 0 16px rgba(142,234,255,0.8),0 0 40px rgba(86,216,255,0.4),0 0 60px rgba(86,216,255,0.15); transform:translateX(4px); }
]==]
DarkThemeCSS.NavBar = [==[
#NavBar { background-color:rgba(0,0,0,0.7); }
#NavBar .button, UL.popup LI { background-color:#222; color:#e0e0e0; border:1px solid #444; border-radius:4px; }
#NavBar .button:hover { box-shadow:0 0 15px rgba(255,255,255,0.2); background-color:#333; }
#NavBar .button SPAN, UL.gamemode_list LI SPAN, UL.language_list LI SPAN { color:#e0e0e0; }
#NavBar number { background:#555; color:#eee; }
#NavBar number.severity1 { background:#ccaa00; color:#222; }
#NavBar number.severity2 { background:#cc3300; color:white; }
.popup { background-color:#1a1a1a; border:1px solid #333; }
.popup HR { border-color:#444; }
UL.games_list { border:3px solid #111; background-color:#222; }
UL.games_list LI { background-color:transparent; color:#e0e0e0; }
UL.games_list LI span { color:#e0e0e0; }
UL.games_list LI:hover { background-color:#333; }
.game-item.notowned, .game-item.notinstalled { opacity:0.5; }
UL.gamemode_list { border:3px solid #111; }
UL.gamemode_list LI { background-color:#333; }
UL.gamemode_list LI:hover { background-color:#444; }
UL.language_list { background-color:#222; border:3px solid #111; }
UL.language_list LI IMG { border:1px solid #555; }
UL.language_list LI:hover { background-color:#444; }
.kinect_settings { border:3px solid #111; background-color:#222; }
::-webkit-scrollbar { width:10px; height:8px; background:rgba(0,0,0,0.5); border-left:1px solid rgba(255,255,255,0.05); }
::-webkit-scrollbar-thumb { background:#115c9e; border-radius:5px; box-shadow:inset 0 0 5px rgba(0,0,0,0.5); }
::-webkit-scrollbar-thumb:hover { background:#2387ed; }
]==]
DarkThemeCSS.NewGame = [==[
UL.category LI.mapicon { color:#e0e0e0; }
UL.category LI.mapicon.selected { background-color:#2b4b73; border-radius:3px; }
.maplist { background-color:#1a1a1a; color:#e0e0e0; border-radius:5px; box-shadow:inset 0 0 10px rgba(0,0,0,0.5); }
gamesettings { background-color:#1a1a1a; color:#e0e0e0; border-radius:5px; box-shadow:inset 0 0 10px rgba(0,0,0,0.5); }
gamesettings select { border:1px solid #444; background-color:#2a2a2a; color:#e0e0e0; }
.dropdown .label { background-image:-webkit-gradient(linear,0 0,0 100%,from(#444),to(#222)); border:1px solid #555; color:white; -webkit-box-shadow:inset 0 1px 0 rgba(255,255,255,0.1),0 1px 2px rgba(0,0,0,0.5); }
.dropdown .label:hover { background-image:-webkit-gradient(linear,0 0,0 100%,from(#555),to(#333)); }
.dropdown .contents { background-color:#222; color:#e0e0e0; border:1px solid #555; -webkit-box-shadow:2px 2px 8px rgba(0,0,0,0.8); }
.dropdown .contents div:hover { background-color:#2b4b73; }
.caret { border-top:5px solid #bbb; }
gamesettings .control LABEL { color:#aaa; }
gamesettings .control input[type=text] { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #444; }
.controls .search input[type=text] { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #444; }
.controls LI.category { background-color:#333; color:#ccc; }
.controls LI.category:hover { background-color:#444; }
.controls LI.active { background-color:#2b4b73 !important; color:#eee; }
.controls LI.category .count { background-color:#222; color:#888; }
UL.category LI.mapicon.selected { background-color:#005a9e !important; color:white !important; }
]==]
DarkThemeCSS.Servers = [==[
.gamemode { background-color:#222; background-image:-webkit-linear-gradient(bottom,rgb(30,30,30) 1%,rgb(40,40,40) 99%); }
.gamemode:hover { background-image:-webkit-linear-gradient(bottom,rgb(50,50,50) 1%,rgb(60,60,60) 99%); }
.gamemode .name { color:#e0e0e0; }
.gamemode .name tag { background:#115c9e; color:#fff; }
.gamemode .stats { color:#aaa; }
H1 small { color:#aaa; }
.serverlist { background-color:#1e1e1e; }
.serverlist .server { background-color:#2a2a2a; color:#e0e0e0; border-bottom:1px solid #333; }
.serverlist .server:nth-child(odd) { background-color:#222; }
.serverlist .empty { color:#888; }
.serverlist .missingmap map { color:#d66; }
.serverlist .empty players { color:#d66; }
.serverlist .server:hover { background-color:#384252; }
.serverlist .header { background-color:#115c9e; }
.serverlist .header ping, .serverlist .header maxplayers, .serverlist .header players, .serverlist .header map, .serverlist .header name, .serverlist .header rank { color:#fff; }
.serverlist name tag { background:#4a2a2a; color:#e0e0e0; }
.serverlist name tag.future { background:#333; color:#bbb; }
H1.menuheader { color:white; text-shadow:2px 2px 1px black; }
H1.menuheader small { color:white; text-shadow:1px 1px 1px black; }
A.bglink { background-color:#115c9e; color:white; }
A.bglink:hover { background-color:#2387ed; }
.serverinfo { background-color:#222; }
.serverinfo .closebtn { background:#115c9e; }
.serverinfo .closebtn:hover { background-color:#2387ed; }
.serverinfo name { color:#e0e0e0; }
.serverinfo address { color:#ccc; }
.serverinfo subinfo { color:#aaa; }
.serverinfo players { background-color:#1a1a1a; color:#e0e0e0; border:1px solid #333; }
.serverinfo footer input[type=password] { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #444; }
.activeserver { background-color:#555 !important; }
DIV.installgamemode { background-color:#115c9e; border:2px solid #555; background:#115c9e url('../../img/gm_install32.png') no-repeat 6px center; }
DIV.installgamemode:hover { background-color:#2387ed; }
SPAN.installgamemode { background:#115c9e url('../../img/gm_install16.png') no-repeat 13px center; }
SPAN.installgamemode:hover { background-color:#2387ed; }
.server_gamemodes { border:5px solid #222; }
.add_fav_server { background-color:#222; }
.add_fav_server button { background-color:#115c9e; color:white; }
.add_fav_server button:hover { background-color:#2387ed; }
.add_fav_server input { border:1px solid #444; background-color:#2a2a2a; color:#e0e0e0; }
.add_fav_server div.header { color:#e0e0e0; }
DIV.page DIV.options UL LI.sb_filter_sep { border-top:1px solid #444; box-shadow:1px 1px 1px rgba(0,0,0,0.5); }
.smalltextbox { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #444; }
.flags_filter { background:#333; }
.flags_filter .flag { background:#444; }
.flags_filter .flag.prefer { background:#115c9e; }
.flags_filter .flag.avoid { background:#a33; }
.controls .searchbox { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #444; }
]==]
DarkThemeCSS.Workshop = [==[
workshopicon { background-color:#222; -webkit-box-shadow:0 0 5px 1px rgba(0,0,0,0.8); border:3px solid #444; }
workshopicon name { background-color:rgba(26,26,26,0.95); color:#e0e0e0; }
workshopicon author, workshopicon votes, workshopicon size { color:#ccc; background-color:#222; }
workshopicon votes { color:#6a6; }
workshopicon votes.negative { color:#e55; }
workshopicon description { background-color:rgba(30,80,130,0.95); color:#eee; }
workshopmessage { color:#999; }
workshopcontainer { background-color:#1a1a1a; color:#e0e0e0; }
controls control { background-color:#6677aa; color:white; -webkit-box-shadow:1px 1px 2px rgba(0,0,0,0.8); }
controls control:hover { background-color:#8899cc; }
controls control.disabled { background-color:#444; color:#888; }
.ugc_settings_button { background:#115c9e; }
.ugc_settings_button:hover { background:#2387ed; }
.ugc_settings { background:#2a2a2a; color:#e0e0e0; }
.ugc_settings a { color:#e0e0e0; background:#444; }
.ugc_settings a:hover { background:#555; }
.ugc_settings a:active { background:#333; }
pagination { background-color:#222; }
pagination .back, pagination .next { background-color:#115c9e; }
pagination .back:hover, pagination .next:hover { background-color:#2387ed; }
workshopicon.installed { border-color:#8dae4f; }
workshopicon.installed name, workshopicon.installed author, workshopicon.installed votes, workshopicon.installed size { background:#2a3a14; }
workshopicon.disabled { border-color:#818a70; }
workshopicon.disabled name, workshopicon.disabled author, workshopicon.disabled votes, workshopicon.disabled size { background:#393f2f; }
workshopicon.invalid { border-color:#a22; }
workshopicon.invalid name, workshopicon.invalid author, workshopicon.invalid votes, workshopicon.invalid size { background:#622; color:#fff; }
workshopicon.invalid.disabled { border-color:#722; }
workshopicon.invalid.disabled name, workshopicon.invalid.disabled author, workshopicon.invalid.disabled size { background:#422; color:#aaa; }
.preset_list { background:#222; border:1px solid #444; }
.preset_list font:hover { background:#333; }
.preset_list font.active { background:#444; }
.preset_side input[type="text"] { background-color:#2a2a2a; color:#e0e0e0; border:1px solid #555; }
]==]
DarkThemeCSS.LightExtra = [==[
body, html, .page { background-color: transparent !important; background-image: none !important; }
]==]
