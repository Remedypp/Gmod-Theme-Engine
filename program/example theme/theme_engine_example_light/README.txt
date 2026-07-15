Theme Engine - GMod Light Example

This addon is a local editable baseline for Theme Engine full-menu themes.

Edit files in:
  addons/theme_engine_example_light/source/

Then run:
  powershell -ExecutionPolicy Bypass -File addons/theme_engine_example_light/build_theme.ps1

Theme Engine loads the compiled Workshop-ready payloads from:
  addons/theme_engine_example_light/data_static/theme_engine_full_themes/theme_engine_example_light/

For local development, the build also writes a DATA mirror that appears in Theme Engine without moving the addon:
  garrysmod/data/theme_engine_full_themes/theme_engine_example_light/data_static/theme_engine_full_themes/theme_engine_example_light/

Development loop:
1. Edit files under source/.
2. Run build_theme.ps1.
3. Select GMod Light Example in Theme Engine.
4. Press Reload Selected after every change.

Workshop publishing:
1. Build the theme once.
2. Publish this addon folder with gmpublisher.
3. The addon.json ignore list keeps editable source and build files out of the GMA.
4. Subscribers only receive the compiled data_static Theme Engine payload.

Notes:
- The Theme Options entry is injected by Theme Engine and is intentionally protected.
- Keep scripts out of menu_templates.html/full_shell.html; Theme Engine sanitizes unsafe HTML.
- Add custom assets beside this addon and reference them with mounted GAME paths.
- Keep the folder ID prefixed with theme_engine_ so mounted discovery can identify it.
