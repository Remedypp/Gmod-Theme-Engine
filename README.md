<div align="center">

# Gmod Theme Engine

**A complete theme engine for the Garry's Mod main menu**

[![Steam Workshop](https://img.shields.io/badge/Steam_Workshop-Subscribe-1b2838?style=for-the-badge&logo=steam&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3679295208)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)

</div>

---

## Features

- Switch between **Dark** and **Light** visual themes for the entire main menu UI
- **Background manager** - enable/disable backgrounds by category, add custom images via URL, control slideshow speed and overlay dim level
- Automatically detects and categorizes backgrounds from all mounted Workshop addons
- **Music player** - plays MP3 and WAV files from local folders or Workshop addons, with playlist mode, shuffle, and volume control
- **Album system** - organize tracks into subfolders, each subfolder becomes a toggleable album
- Reads **ID3 tags** (artist, title, cover art) automatically from MP3 files
- Custom metadata via `data_static/te_music_meta.json` (Workshop) or `data/theme_engine_music/te_music_meta.json` (local)
- **Spawnmenu skin manager** - switch between installed Derma skin addons from within the Theme Engine UI
- **Custom font picker** - override the menu font with built-in presets or locally installed `.ttf` files
- Dark theme applied to the **map loading screen**
- Background and music **preview modals** with right-click
- Built-in **Help system** with categorized documentation for all features

---

## Installation

### Step 1: Subscribe to the Workshop Addon

Subscribe on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3679295208).

### Step 2: Modify `menu.lua`

The Theme Engine requires a loader to be added to Garry's Mod's `menu.lua`.

1. Right-click Garry's Mod in Steam → **Manage** → **Browse Local Files**
2. Navigate to `garrysmod/lua/menu/`
3. Open `menu.lua` with any text editor
4. Go to **[this Pastebin](https://pastebin.com/h9Zv6kfA)**
5. Copy ALL the code from the Pastebin
6. Replace the entire content of `menu.lua` with the copied code
7. Save and restart Garry's Mod

A new **Theme Options** button will appear below the Options button in the main menu.

---

## Architecture

### `menu.lua` (loader)

The entry point. On startup it scans for all `theme_engine/*.lua` files from the Workshop addon or local `LUA` path, then loads them in alphabetical order with `theme_engine_injection.lua` forced last. Each file is wrapped in `pcall` so a single error does not crash the menu. A `GameContentChanged` hook handles hot-reloading when the addon is enabled or disabled at runtime.

### `theme_engine_apply.lua`

Provides `DarkThemeEngine.CallJS()`, the bridge between Lua and the CEF menu panel. Also contains `ApplyTheme()` which injects or removes the dark/light CSS stylesheets, and `ApplyLoadingCSS()` which styles the map loading screen.

### `theme_engine_css.lua`

Defines all CSS strings for the dark theme (menu, navbar, new game, server browser, workshop), the light mode extra, and the loading screen dark style. Editing this file changes the visual output of the theme without touching any logic.

### `theme_engine_backgrounds.lua`

Scans all mounted addons and local paths for background images, builds a categorized list, and caches it to `data/theme_engine_data/backgrounds_cache.json` for fast startup. Manages per-background and per-category enable/disable state. Overrides GMod's `DrawBackground`, `ChangeBackground`, and `AddBackgroundImage` globals to take control of the background rendering loop.

### `theme_engine_music.lua`

Scans `sound/theme_engine_music/` (GAME and MOD paths) and `data/theme_engine_music/` for audio files. Reads ID3 tags from MP3 files. Loads metadata from `te_music_meta.json`. Sends the track list to the JS player via `SendMusicToJS()`. Polls in-game state every second to pause music when a map is loaded and resume when returning to the menu.

### `theme_engine_misc.lua`

Handles the Miscellaneous tab: spawnmenu skin detection (scans Lua files for `derma.DefineSkin` calls), custom background downloads via `http.Fetch`, and font loading from `data/theme_engine_fonts/`.

### `theme_engine_changelog.lua`

Defines `DarkThemeEngine.Changelog` and `DarkThemeEngine.Credits` tables. Edit this file to add new changelog entries - the in-game Changelog modal reads directly from it.

### `theme_engine_html.lua`

Contains `DarkThemeEngine._UI.HTML` - the full HTML/CSS template for the Theme Options page. This is the Angular template registered at the `#/theme/` route.

### `theme_engine_js.lua`

Contains `DarkThemeEngine._UI.JS` - all client-side JavaScript logic for the UI: tab switching, background/music/spawnmenu/font rendering, preview modals, the Help system, and the Changelog panel. Also contains `BuildRouteJS()` which registers the Angular route, and `AnniversaryJS` for the November 29 event.

### `theme_engine_injection.lua`

The final file loaded. Hooks `pnlMainMenu.HTML.OnDocumentReady` to inject the JS, CSS, route registration, and initial data in the correct order. Falls back to a 1-second retry via `MenuStart` if the hook fires too early.

### `theme_engine_spawnmenu.lua` (clientside)

Loaded via `autorun/theme_engine_loader.lua`. Reads the selected spawnmenu skin from `settings.json` and applies it in-game by overriding the `ForceDermaSkin` hook. Polls every 2 seconds to pick up changes made in the Theme Engine UI.

---

## Safety

- Each file is loaded inside `pcall` - a single error does not crash the menu
- All JS hooks (`lua.Run`, `SetLastMap`, `UpdateServerSettings`) are wrapped with idempotent guards to prevent double-hooking on re-injection
- All fullscreen modals are removed automatically on page navigation
- `DarkThemeEngine.SaveSettings()` is wrapped in `pcall` - a disk error does not crash the addon

---

<div align="center">

*Made with ❤️ by RemedyDev*

</div>
