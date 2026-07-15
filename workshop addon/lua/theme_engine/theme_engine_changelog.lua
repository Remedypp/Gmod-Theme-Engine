DarkThemeEngine = DarkThemeEngine or {}

DarkThemeEngine.Credits = {
    { ver = "1.0.0", entries = {
        { role = "Creator & Developer", name = "Remedy" },
        { role = "Ideas, Testing & Reports", name = "Theme Engine Community" },
        { role = "Original Menu Platform", name = "Facepunch Studios / Valve" },
    }},
    { ver = "0.2.5-beta", entries = {
        { role = "Developer",          name = "Remedy" },
        { role = "Ideas & Suggestions", name = "Mugtoast, Noobas, senvy, Marcina15" },
        { role = "Bug Reports",        name = "Community (Steam Workshop Comments)" },
    }},
    { ver = "0.2.0-beta", entries = {
        { role = "Developer",          name = "Remedy" },
        { role = "Ideas & Suggestions", name = "CMBD, Goshan, Mugtoast, Riggs, Sr.Bleatz, SillySpaceCat, Lord²" },
        { role = "Bug Reports",        name = "Community (Steam Workshop Comments)" },
    }},
}

DarkThemeEngine.Changelog = {
    { ver = "1.0.0", tag = "major", sections = {
        { title = "Release & Installation", items = {
            "Theme Engine returns as a complete 1.0 release with the legacy Pastebin bootstrap retired.",
            "Runtime modules now come from the subscribed Workshop addon and the open GitHub Release loader.",
            "A new Windows setup program detects Garry's Mod and provides Install, Fix, Uninstall, backups, and update checks.",
        }},
        { title = "Startup Menu", items = {
            "A responsive Aperture startup screen covers the main menu while Theme Engine becomes ready.",
            "The screen reports when the Workshop addon is required, downloading, mounting, loading, or ready.",
            "Steam downloads are detected automatically, and Quit remains available throughout startup.",
        }},
        { title = "Theme Library & Creation", items = {
            "Community themes can customize the complete Garry's Mod menu with page CSS, HTML templates, shell overlays, manifests, and mounted assets.",
            "Workshop themes use encrypted data_static payloads and are discovered automatically when mounted.",
            "Reload Selected updates the active theme from mounted files without restarting Garry's Mod.",
            "The installer includes an editable GMod Light example and Theme Engine includes publishing documentation for authors.",
            "Theme Engine Options remains protected and readable regardless of the selected community theme.",
        }},
        { title = "Theme Engine Interface", items = {
            "Theme Engine Options has been rebuilt as a responsive Aperture-inspired interface.",
            "Controls, status indicators, animated branding, and icons use a unified code-drawn visual system.",
            "Help and Changelog use fixed navigation with independently scrollable content.",
        }},
        { title = "Backgrounds", items = {
            "The preview is synchronized with the real main-menu background controller instead of using a separate slideshow.",
            "Fade, zoom, rotation, overlay, timing, static mode, instant cut, and manual navigation are shown live.",
            "The preview can expand while categories and background collections remain independently scrollable.",
        }},
        { title = "Menu Music & Sounds", items = {
            "Menu Music now includes a Portal terminal waveform visualizer with duration-aware playback information.",
            "Tracks expose richer metadata and contextual information while retaining album, volume, pause, and skip controls.",
            "Mounted Workshop menu-sound packs can be selected separately with their own volume and a true Default GMod option.",
        }},
        { title = "Additional Customization", items = {
            "VGUI themes can style supported native panels and the Problems interface.",
            "Spawnmenu skins, custom fonts, menu sounds, loading screens, and full-menu themes are managed from one place.",
            "Custom menu fonts never alter the protected Theme Engine Options interface.",
        }},
        { title = "Performance & Safety", items = {
            "Modules load in stages and repeated addon, background, music, and filesystem discovery is cached.",
            "Frequently updated interfaces use targeted refreshes and lightweight transitions.",
            "Theme files are allowlisted, size-limited, path-checked, and HTML overlays are sanitized before injection.",
        }},
    }},
    { ver = "0.2.6-beta", tag = "patch", changes = {
        "Fixed music playing two songs at once when enabling/disabling tracks (#71)",
        "Fixed game becoming unresponsive when all custom tracks fail to load",
        "Fixed changelog 'new' indicator not showing (DOM race condition)",
        "Fixed game freezing when opening the Backgrounds tab",
        "Fixed custom music from data/ folder not playing (fallback URL system)",
    }},
    { ver = "0.2.5-beta", changes = {
        "NEW: Pause/Resume and Skip buttons for menu music",
        "NEW: Font Size slider in Miscellaneous tab",
        "NEW: Console commands 'theme_engine' / 'theme_engine_open' to open settings",
        "NEW: Music fades out smoothly when entering a game instead of cutting abruptly",
        "NEW: Miscellaneous section in Help with data folders, commands, and tips",
        "FIX: Changelog 'new' indicator now works reliably (fixed race condition with DOM)",
        "FIX: Background tab no longer freezes the game (removed unnecessary filesystem rescans)",
        "FIX: Custom music from data/ folder now uses fallback URLs if primary path fails",
        "OPTIMIZED: Removed all backdrop-filter blur effects (major GPU performance gain)",
        "OPTIMIZED: Replaced all 'transition: all' with specific properties (13 instances)",
        "OPTIMIZED: Spawnmenu skin no longer polls disk every 2 seconds",
        "OPTIMIZED: Toggling music tracks/albums no longer rebuilds the entire playlist",
        "OPTIMIZED: Adding a custom background no longer rescans the entire filesystem",
        "OPTIMIZED: Reduced timer frequencies and removed unnecessary continuous timers",
        "OPTIMIZED: Background preview preloads image before showing animation",
    }},
    { ver = "0.2.1-beta", tag = "patch", changes = {
        "Fixed music not working with special characters in song names",
        "Fixed blue flash between background transitions",
        "Fixed game freezing when switching tabs in Theme Options",
        "Optimized music and background loading performance",
        "Spawnmenu skin list is now scrollable",
        "Removed incompatible texture-only skin detection",
    }},
    { ver = "0.2.0-beta", changes = {
        "NEW: Music Packs / Albums — organize tracks into subfolders inside data/theme_engine_music/",
        "NEW: Custom Font picker in Miscellaneous tab — includes local .ttf support",
        "NEW: Spawnmenu Skin manager in Miscellaneous tab",
        "NEW: Background Dim slider (0–70%) and Swap Speed slider (5–120s)",
        "NEW: Dark Theme applied to the map loading screen",
        "NEW: Add Image button in Backgrounds tab — download any image URL as a custom background",
        "NEW: Help button with categorized documentation for all features",
        "NEW: Credits section in Changelog",
        "NEW: music metadata via data_static/te_music_meta.json (gmpublisher-safe) or data/theme_engine_music/te_music_meta.json (local)",
        "FIX: Music volume 0 now correctly silences audio",
        "FIX: Enable Music toggle state persists when switching tabs",
        "FIX: Background zoom no longer persists when switching to Static mode",
        "FIX: Menu startup time reduced — backgrounds load from cache on first open",
        "FIX: Spawnmenu skin applies correctly after opening Q menu",
        "FIX: crash when addon.json was missing from legacy addon folders",
        "REMOVED: OGG support (unreliable in GMod CEF — use MP3 or WAV)",
        "INTERNAL: Codebase split into html / js / misc / changelog files",
    }},
    { ver = "0.1.3-beta", changes = {
        'Fixed errors and bugs related to the music and some parts of the code -.- (Update with some new things coming soon)',
    }},
    { ver = "0.1.2-beta", changes = {
        "Updated menu.lua pastebin",
        "Theme Engine now loads after the menu is fully ready (deferred loading)",
        "This should fix the loading screen freeze for all users",
    }},
    { ver = "0.1.1-beta", changes = {
        "Updated menu.lua pastebin with latest fixes",
        "Fixed game getting stuck on loading screen when using modified menu.lua",
        "Improved addon enable/disable detection and cleanup",
    }},
    { ver = "0.1.0-beta", changes = {
        "Updated menu.lua pastebin with latest loader code",
        "Fixed potential crash on x86-64 branch",
        "Added Changelog panel",
    }},
}
