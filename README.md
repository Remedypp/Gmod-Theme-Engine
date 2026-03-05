<div align="center">

# 🎨 Gmod Theme Engine

**A complete theme engine for the Garry's Mod main menu**

[![Steam Workshop](https://img.shields.io/badge/Steam_Workshop-Subscribe-1b2838?style=for-the-badge&logo=steam&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3679295208)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)

<br>

*Customize your Garry's Mod main menu with dark/light themes, custom backgrounds, and a full-featured music player*

</div>

---

## ✨ Features

### 🎭 Theme Presets
Switch between **Dark** and **Light** visual styles for the entire main menu UI. The theme system injects custom CSS that transforms the default GMod interface.

### 🖼️ Background Manager
- Automatically **scans and categorizes** all available menu backgrounds (local and Workshop)
- **Enable/disable** individual backgrounds from the rotation
- **Right-click preview** with fullscreen viewer and navigation arrows
- **Category view** with Workshop addon icons fetched automatically
- Animation options: **Static mode**, **Disable Zoom**, **Instant Cut**

### 🎵 Menu Music Player
- Supports **MP3**, **WAV**, and **OGG** formats
- Reads **ID3 tags** (artist, title, cover art) directly from MP3 files
- **Playlist mode** with auto-advance and **shuffle**
- Custom metadata via `addon_music_meta.json` (titles, artists, cover art, descriptions, YouTube links)
- **Right-click** any track for detailed preview with cover art and YouTube link
- Volume follows the `snd_musicvolume` ConVar

### 📖 Workshop Guide
Built-in step-by-step guide on how to create and publish your own music packs to the Steam Workshop using [gmpublisher](https://github.com/WilliamVenner/gmpublisher).

### 🎂 Anniversary Event
A special surprise appears on **November 29th** each year!

---

## 📦 Installation

### Step 1: Subscribe to the Workshop Addon
Subscribe on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3679295208).

### Step 2: Modify `menu.lua`

The Theme Engine needs a small loader added to Garry's Mod's `menu.lua` file to work.

1. **Right-click** Garry's Mod in Steam → **Manage** → **Browse Local Files**
2. Navigate to `garrysmod/lua/menu/`
3. Open `menu.lua` with any text editor (Notepad, VS Code, etc.)
4. Go to **[this Pastebin](https://pastebin.com/h9Zv6kfA)**
5. **Copy ALL** the code from the Pastebin
6. **Replace the entire content** of your `menu.lua` with the copied code
7. **Save** the file and **restart** Garry's Mod

> [!NOTE]
> After restarting, a new **"Theme Options"** button will appear in your main menu below the **"Options"** button.

---

## 🎵 Adding Custom Music

### Method 1: Local Files
Place your `.mp3`, `.wav`, or `.ogg` files directly in:
```
garrysmod/sound/theme_engine_music/
```

### Method 2: Steam Workshop
Publish your own music pack addon with this folder structure:
```
MyMusicAddon/
├── addon.json
└── sound/
    └── theme_engine_music/
        ├── song1.mp3
        ├── song2.mp3
        └── addon_music_meta.json   (optional)
```

### Custom Metadata (Optional)
Create `addon_music_meta.json` next to your audio files for rich metadata:
```json
{
  "song1.mp3": {
    "title": "Epic Theme",
    "artist": "John Smith",
    "cover": "materials/vgui/my_cover.png",
    "desc": "Perfect main menu loop",
    "youtube": "https://youtube.com/watch?v=..."
  }
}
```

> [!TIP]
> If you don't provide a JSON file, the engine will automatically read ID3 tags from MP3 files for artist and title information.

---

## 🏗️ Architecture

The Theme Engine consists of 5 core Lua files:

| File | Purpose |
|---|---|
| `theme_engine_css.lua` | CSS injection and theme stylesheet generation |
| `theme_engine_apply.lua` | Theme application logic and `CallJS` bridge |
| `theme_engine_backgrounds.lua` | Background scanning, categorization, and Workshop icon fetching |
| `theme_engine_music.lua` | Music player system with ID3 reading, playlists, and volume control |
| `theme_engine_injection.lua` | UI HTML/JS template, AngularJS route registration, and all interactive JS logic |

### How It Works

1. **`menu.lua`** detects the addon and safely loads all 5 files via `pcall`
2. **`theme_engine_css.lua`** generates CSS for the selected theme (dark/light)
3. **`theme_engine_apply.lua`** injects the CSS into GMod's Chromium-based menu via `QueueJavascript`
4. **`theme_engine_injection.lua`** registers a custom AngularJS route (`#/theme/`) and injects the Theme Options page as an HTML template with embedded JavaScript
5. The JS hooks into GMod's `lua.Run` (with idempotent guards to prevent re-hooking) to save map and server settings across sessions via `localStorage`
6. **`theme_engine_backgrounds.lua`** scans all mounted addons and local files for backgrounds
7. **`theme_engine_music.lua`** scans for music files, reads ID3 tags, and manages the HTML5 Audio player

### Safety Features

- ✅ **Idempotent JS hooks** - Global flags prevent `lua.Run`, `SetLastMap`, and `UpdateServerSettings` from being wrapped multiple times during re-injection
- ✅ **pcall-protected loading** - Each file is loaded inside `pcall()` so a single error doesn't crash the entire menu
- ✅ **Automatic overlay cleanup** - All fullscreen modals (background preview, music preview, workshop guide) are automatically removed on page navigation via `hashchange` and Angular's `$routeChangeSuccess`
- ✅ **Addon-locked loader** - The `menu.lua` loader only runs code from Workshop addon `3679295208`, preventing malicious addons from injecting code

---

<div align="center">

*Made with ❤️ by RemedyDev*

</div>
