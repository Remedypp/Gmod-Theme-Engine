include( "mount/mount.lua" )
include( "getmaps.lua" )
include( "loading.lua" )
include( "mainmenu.lua" )
include( "video.lua" )
include( "demo_to_video.lua" )

include( "menu_save.lua" )
include( "menu_demo.lua" )
include( "menu_addon.lua" )
include( "menu_dupe.lua" )
include( "errors.lua" )
include( "problems/problems.lua" )

include( "motionsensor.lua" )
include( "util.lua" )

local THEME_ENGINE_WSID = "3679295208"

local function DiscoverThemeFiles()
	local found = {}
	local added = {}

	local luaFiles = file.Find( "theme_engine/*.lua", "LUA" ) or {}
	for _, name in ipairs( luaFiles ) do
		if not added[name] then
			table.insert( found, name )
			added[name] = true
		end
	end

	local gameFiles = file.Find( "lua/theme_engine/*.lua", "GAME" ) or {}
	for _, name in ipairs( gameFiles ) do
		if not added[name] then
			table.insert( found, name )
			added[name] = true
		end
	end

	local injectionFile = "theme_engine_injection.lua"
	for i, name in ipairs( found ) do
		if name == injectionFile and i ~= #found then
			table.remove( found, i )
			table.insert( found, injectionFile )
			break
		end
	end

	return found
end

local function SafeLoadFile( name )
	local path = "theme_engine/" .. name
	local ok, err

	if file.Exists( path, "LUA" ) then
		ok, err = pcall( include, path )
	else
		local code = file.Read( "lua/" .. path, "GAME" )
		if code then
			ok, err = pcall( RunString, code, path )
		else
			return false, "File not found: " .. path
		end
	end

	if not ok then
		MsgC( Color( 255, 100, 100 ), "[ThemeEngine] Error loading " .. name .. ": " .. tostring( err ) .. "\n" )
		return false, err
	end

	return true
end

local function ThemeEngineLoader( forceReload )
	if _G.ThemeEngineLoaded and not forceReload then return end

	local addons = engine.GetAddons()
	local isMounted = false
	local isSubscribed = false
	local updatedTime = 0

	for _, v in ipairs( addons ) do
		if v.wsid == THEME_ENGINE_WSID then
			isSubscribed = true
			if v.mounted then
				isMounted = true
				updatedTime = v.updated or 0
			end
			break
		end
	end

	local localTime = file.Time( "theme_engine/theme_engine_css.lua", "LUA" )
	if not isMounted and localTime then
		isMounted = true
		updatedTime = localTime
	elseif localTime and localTime > updatedTime then
		updatedTime = localTime
	end

	if not isMounted then
		if isSubscribed then
			MsgC( Color( 255, 200, 100 ), "[ThemeEngine] Addon is subscribed but disabled. Enable it in the Addons menu.\n" )
		end
		return
	end

	local themeFiles = DiscoverThemeFiles()
	if #themeFiles == 0 then return end

	if forceReload and DarkThemeEngine then
		DarkThemeEngine._ForceReload = true
	end

	local allOk = true
	MsgC( Color( 100, 200, 100 ), "[ThemeEngine] Loading " .. #themeFiles .. " files...\n" )

	for i, name in ipairs( themeFiles ) do
		MsgC( Color( 100, 200, 100 ), "[ThemeEngine] (" .. i .. "/" .. #themeFiles .. ") " .. name .. "\n" )
		local ok, err = SafeLoadFile( name )
		if not ok then allOk = false end
	end

	if allOk then
		_G.ThemeEngineLoaded = true
		_G.ThemeEngineLastUpdate = updatedTime
		if DarkThemeEngine and DarkThemeEngine.CallJS then
			DarkThemeEngine.CallJS("window._DarkThemeEngine_Disabled = false;")
		end
		MsgC( Color( 100, 200, 100 ), "[ThemeEngine] All files loaded successfully!\n" )
	else
		MsgC( Color( 255, 200, 100 ), "[ThemeEngine] Loaded with some errors. Check above.\n" )
	end
end

hook.Add( "GameContentChanged", "ThemeEngine_Retry", function()
	local addons = engine.GetAddons()
	local isMounted = false
	for _, v in ipairs( addons ) do
		if v.wsid == THEME_ENGINE_WSID and v.mounted then
			isMounted = true
			break
		end
	end

	if _G.ThemeEngineLoaded then
		if not isMounted then
			if DarkThemeEngine and DarkThemeEngine.RemoveAllCSS then
				DarkThemeEngine.RemoveAllCSS()
			end
			if DarkThemeEngine and DarkThemeEngine.CallJS then
				DarkThemeEngine.CallJS([[
					window._DarkThemeEngine_Disabled = true;
					if (window.DarkTheme_AudioNode) {
						window.DarkTheme_AudioNode.pause();
						window.DarkTheme_AudioNode.src = '';
						window.DarkTheme_AudioNode = null;
					}
					if (window.DarkThemeEngine_CleanupAllOverlays) window.DarkThemeEngine_CleanupAllOverlays();
					var btn = document.getElementById('theme_options_btn');
					if (btn && btn.parentElement) btn.parentElement.remove();
				]])
			end
			hook.Remove( "MenuPaint", "DarkThemeCustomBG" )
			hook.Remove( "MenuStart", "ThemeEngineReinject" )
			if IsValid( pnlMainMenu ) then
				pnlMainMenu:UpdateBackgroundImages()
			end
			_G.ThemeEngineLoaded = false
			MsgC( Color( 255, 200, 100 ), "[ThemeEngine] Addon disabled. All theme data removed.\n" )
		else
			for _, v in ipairs( addons ) do
				if v.wsid == THEME_ENGINE_WSID and v.mounted then
					if _G.ThemeEngineLastUpdate and ( v.updated or 0 ) > _G.ThemeEngineLastUpdate then
						ThemeEngineLoader( true )
					end
					break
				end
			end
		end
	else
		if isMounted then
			ThemeEngineLoader()
		end
	end
end )

timer.Create( "ThemeEngine_DevReload", 3, 0, function()
	if not _G.ThemeEngineLoaded then return end
	local localTime = file.Time( "theme_engine/theme_engine_css.lua", "LUA" )
	if localTime and _G.ThemeEngineLastUpdate and localTime > _G.ThemeEngineLastUpdate then
		ThemeEngineLoader( true )
	end
end )

ThemeEngineLoader()

end)
if not _te_ok then
	MsgC( Color( 255, 100, 100 ), "[ThemeEngine] Failed to initialize: " .. tostring( _te_err ) .. "\n" )
end
