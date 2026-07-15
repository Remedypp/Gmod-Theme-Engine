# Aperture Theme Engine

Aperture Theme Engine is a complete customization system for the Garry's Mod main menu. It manages themes, backgrounds, music, menu sounds, fonts, spawnmenu skins, and supported VGUI resources through a built-in Theme Engine Options panel.

## Features

- Switch between the included Light and Dark themes or install complete community themes.
- Discover background packs from mounted Workshop addons and control rotation, fades, zoom, timing, static mode, and dim level.
- Preview backgrounds using the same state and transitions as the main menu.
- Organize menu music into albums with metadata, duration-aware playback, volume controls, and a waveform visualizer.
- Select compatible Workshop menu-sound packs and adjust their volume separately.
- Manage supported spawnmenu skins, menu fonts, loading screens, and VGUI themes.
- Reload the selected theme while developing without restarting Garry's Mod.
- Keep Theme Engine Options isolated from community-theme styling and menu replacements.
- Access categorized Help and Changelog pages directly inside the menu.

## Installation

1. Subscribe to [Aperture Theme Engine on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3765005303).
2. Download the latest setup ZIP from [GitHub Releases](https://github.com/Remedypp/Gmod-Theme-Engine/releases/latest).
3. Extract the ZIP and run `Install Theme Engine.bat`.
4. Review the detected Garry's Mod folder and confirm the installation.
5. Restart Garry's Mod after Steam finishes downloading the Workshop addon.

The installer adds `theme_engine_master.lua`, the startup logo, and one include line to both `init.lua` and `init_menu.lua`. It never stores or restores complete copies of those official files.

When Theme Engine is already installed, the program offers **Fix** and **Uninstall**. No files are installed, removed, or replaced without confirmation.

Do not replace `menu.lua`. The old Pastebin installation method is no longer used.

## Creating themes

The setup program includes **Install example theme**, which creates an editable GMod Light theme inside:

```text
garrysmod/addons/theme_engine_example_light/
```

Edit the files under `source/`, run `build_theme.ps1`, select the theme inside Theme Engine, and use **Reload Selected** while testing. The builder creates the Workshop-ready payload under `data_static/theme_engine_full_themes/`.

## Support

- [Bug reports and technical issues](https://steamcommunity.com/workshop/filedetails/discussion/3765005303/569291960381097533/)
- [Suggestions and feature requests](https://steamcommunity.com/workshop/filedetails/discussion/3765005303/569291960381097537/)
- [Steam Workshop addon](https://steamcommunity.com/sharedfiles/filedetails/?id=3765005303)

## Development

Edit the Workshop package in `workshop addon/`. The external loader is installed by the setup program because Workshop addons cannot place files in `lua/includes/`.

The loader owns the startup overlay. It remains visible while Steam downloads or mounts the Workshop addon and fades after the menu integration is ready.



## Technical documentation

## Startup loader

`theme engine loader.lua` is installed as `lua/includes/theme_engine_master.lua`. It waits for the Workshop package, displays the startup screen, discovers mounted Theme Engine modules, and loads them in a controlled order.

## Workshop modules

- `theme_engine_apply.lua` sends CSS and JavaScript changes to the GMod menu.
- `theme_engine_injection.lua` connects Theme Engine to menu document lifecycle events.
- `theme_engine_html.lua`, `theme_engine_css.lua`, and `theme_engine_js.lua` define the protected options interface.
- `theme_engine_backgrounds.lua` discovers background packs and synchronizes the main background with its options preview.
- `theme_engine_music.lua` manages mounted music, metadata, duration, playback, and visualization state.
- `theme_engine_menusounds.lua` discovers and selects compatible menu-sound packs.
- `theme_engine_spawnmenu.lua` applies supported spawnmenu skins and VGUI behavior.
- `theme_engine_vgui.lua` exposes supported Source/VGUI theme values.
- `theme_engine_misc.lua` manages fonts and additional menu settings.
- `theme_engine_changelog.lua` and the Help data provide user documentation inside the options interface.

The `lua/autorun/client/aperture_theme_spawnmenu_client.lua` entry point loads spawnmenu support when the Workshop addon is mounted in client contexts where the main-menu loader is not active.

## Theme loading

Community themes are mounted data packages. The loader validates their manifest, accepted paths, file sizes, and supported content before applying menu templates or assets. Theme Engine Options remains outside community-theme styling.

## Installer

- `theme_engine_installer.ps1` initializes paths, version data, and dependencies.
- `theme_engine_installer_core.ps1` performs path detection, installation, theme-example setup, and Native UI resource operations.
- `theme_engine_installer_ui.ps1` contains the Windows Forms interface and confirmation flow.

Install and Fix copy the loader and startup logo, then add one include line to each GMod initialization file. Uninstall removes only those include lines and Theme Engine-owned files. Complete copies of the official initialization files are never stored or restored.

Native UI installation is separate. It copies only selected `resource/*.res` and font files after confirmation and keeps backups of the replaced destination resources for explicit restore.

<div align="center">

*Made with ❤️ by RemedyDev*

</div>
