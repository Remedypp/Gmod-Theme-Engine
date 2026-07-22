use include_dir::{Dir, DirEntry, include_dir};
use regex::Regex;
use sha2::{Digest, Sha256};
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

const LOADER: &[u8] = include_bytes!("../../installer/payload/theme_engine_master.lua");
const LOGO: &[u8] =
    include_bytes!("../../installer/payload/materials/theme_engine/loader/logo.png");
static EXAMPLE_THEME: Dir<'_> =
    include_dir!("$CARGO_MANIFEST_DIR/../example theme/theme_engine_example_light");
const INCLUDE_LINE: &str = "include( \"theme_engine_master.lua\" )";

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum InstallState {
    NotInstalled,
    Partial,
    Installed,
}

#[derive(Clone, Debug)]
pub struct Inspection {
    pub state: InstallState,
    pub details: String,
}

#[derive(Clone, Debug)]
pub struct ActionReport {
    pub headline: String,
    pub details: Vec<String>,
}

pub fn is_valid_gmod_path(path: &Path) -> bool {
    path.join("lua/includes/init.lua").is_file()
        && path.join("lua/includes/init_menu.lua").is_file()
}

pub fn inspect(path: &Path) -> Inspection {
    if !is_valid_gmod_path(path) {
        return Inspection {
            state: InstallState::NotInstalled,
            details: "Not a valid garrysmod folder".into(),
        };
    }
    let loader = path.join("lua/includes/theme_engine_master.lua");
    let logo = path.join("materials/theme_engine/loader/logo.png");
    let init = include_count(&path.join("lua/includes/init.lua"));
    let menu = include_count(&path.join("lua/includes/init_menu.lua"));
    let loader_ok = fs::read(&loader)
        .map(|bytes| bytes == LOADER)
        .unwrap_or(false);
    let logo_ok = fs::read(&logo).map(|bytes| bytes == LOGO).unwrap_or(false);
    let installed = loader_ok && logo_ok && init == 1 && menu == 1;
    let any = loader.exists() || logo.exists() || init > 0 || menu > 0;
    let state = if installed {
        InstallState::Installed
    } else if any {
        InstallState::Partial
    } else {
        InstallState::NotInstalled
    };
    let details = format!(
        "Loader: {} | Logo: {} | Startup hooks: {}/2",
        yes_no(loader_ok),
        yes_no(logo_ok),
        usize::from(init == 1) + usize::from(menu == 1)
    );
    Inspection { state, details }
}

pub fn install(path: &Path) -> Result<ActionReport, String> {
    ensure_writable_install(path)?;
    let init_paths = [
        path.join("lua/includes/init.lua"),
        path.join("lua/includes/init_menu.lua"),
    ];
    let originals = init_paths
        .iter()
        .map(|file| fs::read(file).map_err(format_io))
        .collect::<Result<Vec<_>, _>>()?;
    let loader_path = path.join("lua/includes/theme_engine_master.lua");
    let logo_path = path.join("materials/theme_engine/loader/logo.png");
    let old_loader = fs::read(&loader_path).ok();
    let old_logo = fs::read(&logo_path).ok();

    let result = (|| {
        write_owned_file(&loader_path, LOADER)?;
        write_owned_file(&logo_path, LOGO)?;
        for file in &init_paths {
            let content = fs::read_to_string(file).map_err(format_io)?;
            fs::write(file, add_include(&content)).map_err(format_io)?;
        }
        if inspect(path).state != InstallState::Installed {
            return Err("Installation verification failed".into());
        }
        Ok(())
    })();

    if let Err(error) = result {
        for (file, original) in init_paths.iter().zip(originals) {
            let _ = fs::write(file, original);
        }
        restore_optional(&loader_path, old_loader);
        restore_optional(&logo_path, old_logo);
        return Err(error);
    }

    Ok(ActionReport {
        headline: "Aperture Theme Engine is installed".into(),
        details: vec![
            "Installed the embedded startup loader and logo".into(),
            "Added one startup hook to init.lua and init_menu.lua".into(),
        ],
    })
}

pub fn uninstall(path: &Path) -> Result<ActionReport, String> {
    if !is_valid_gmod_path(path) {
        return Err("Select the garrysmod folder that contains lua/includes/init.lua".into());
    }
    let init_paths = [
        path.join("lua/includes/init.lua"),
        path.join("lua/includes/init_menu.lua"),
    ];
    let originals = init_paths
        .iter()
        .map(|file| fs::read(file).map_err(format_io))
        .collect::<Result<Vec<_>, _>>()?;
    for file in &init_paths {
        let content = fs::read_to_string(file).map_err(format_io)?;
        if let Err(error) = fs::write(file, remove_include(&content)).map_err(format_io) {
            for (rollback, original) in init_paths.iter().zip(&originals) {
                let _ = fs::write(rollback, original);
            }
            return Err(error);
        }
    }

    let mut details =
        vec!["Removed Theme Engine startup hooks from both initialization files".into()];
    let loader = path.join("lua/includes/theme_engine_master.lua");
    if is_owned_loader(&loader) {
        fs::remove_file(&loader).map_err(format_io)?;
        details.push("Removed the recognized Theme Engine loader".into());
    } else if loader.exists() {
        details.push("Left an unrecognized theme_engine_master.lua untouched".into());
    }

    let logo = path.join("materials/theme_engine/loader/logo.png");
    if file_matches(&logo, LOGO) {
        fs::remove_file(&logo).map_err(format_io)?;
        remove_empty_parents(&logo, path.join("materials"));
        details.push("Removed the Theme Engine logo".into());
    } else if logo.exists() {
        details.push("Left a modified logo.png untouched".into());
    }

    Ok(ActionReport {
        headline: "Aperture Theme Engine was removed safely".into(),
        details,
    })
}

pub fn install_example_theme(path: &Path) -> Result<ActionReport, String> {
    if !is_valid_gmod_path(path) {
        return Err("Select a valid garrysmod folder first".into());
    }
    let addons = path.join("addons");
    let target = addons.join("theme_engine_example_light");
    let staging = addons.join(".theme_engine_example_light.installing");
    let previous = addons.join(".theme_engine_example_light.previous");
    remove_dir_if_exists(&staging)?;
    remove_dir_if_exists(&previous)?;
    fs::create_dir_all(&staging).map_err(format_io)?;
    if let Err(error) = extract_embedded_dir(&EXAMPLE_THEME, &staging) {
        let _ = fs::remove_dir_all(&staging);
        return Err(error);
    }
    if !example_theme_is_valid(&staging) {
        let _ = fs::remove_dir_all(&staging);
        return Err("The example theme could not be verified after extraction".into());
    }
    if target.exists() {
        fs::rename(&target, &previous).map_err(format_io)?;
    }
    if let Err(error) = fs::rename(&staging, &target).map_err(format_io) {
        if previous.exists() {
            let _ = fs::rename(&previous, &target);
        }
        return Err(error);
    }
    let _ = fs::remove_dir_all(&previous);
    Ok(ActionReport {
        headline: "Example theme installed".into(),
        details: vec![
            target.display().to_string(),
            "Restart Garry's Mod or reload mounted addons before selecting it".into(),
        ],
    })
}

fn example_theme_is_valid(path: &Path) -> bool {
    path.join("source/theme_manifest.json").is_file()
        && path
            .join("data_static/theme_engine_full_themes/theme_engine_example_light/theme_manifest.json")
            .is_file()
}

fn remove_dir_if_exists(path: &Path) -> Result<(), String> {
    if path.exists() {
        fs::remove_dir_all(path).map_err(format_io)?;
    }
    Ok(())
}

fn ensure_writable_install(path: &Path) -> Result<(), String> {
    if !is_valid_gmod_path(path) {
        return Err("Select the garrysmod folder that contains lua/includes/init.lua".into());
    }
    for file in [
        path.join("lua/includes/init.lua"),
        path.join("lua/includes/init_menu.lua"),
    ] {
        fs::OpenOptions::new()
            .write(true)
            .open(&file)
            .map_err(|error| {
                format!(
                    "Cannot write {}: {}. The installer does not request administrator access.",
                    file.display(),
                    error
                )
            })?;
    }
    Ok(())
}

fn add_include(content: &str) -> String {
    let newline = if content.contains("\r\n") {
        "\r\n"
    } else {
        "\n"
    };
    let cleaned = remove_include(content);
    format!(
        "{}{}{}{}",
        cleaned.trim_end_matches(['\r', '\n']),
        newline,
        newline,
        INCLUDE_LINE
    ) + newline
}

fn remove_include(content: &str) -> String {
    let newline = if content.contains("\r\n") {
        "\r\n"
    } else {
        "\n"
    };
    let pattern =
        Regex::new(r#"(?i)^\s*include\s*\(\s*["']theme_engine_master\.lua["']\s*\)\s*(?:--.*)?$"#)
            .unwrap();
    let kept = content
        .lines()
        .filter(|line| !pattern.is_match(line))
        .collect::<Vec<_>>();
    kept.join(newline).trim_end_matches(['\r', '\n']).to_owned() + newline
}

fn include_count(path: &Path) -> usize {
    fs::read_to_string(path)
        .ok()
        .map(|text| {
            let pattern =
                Regex::new(r#"(?im)^\s*include\s*\(\s*["']theme_engine_master\.lua["']\s*\)"#)
                    .unwrap();
            pattern.find_iter(&text).count()
        })
        .unwrap_or(0)
}

fn write_owned_file(path: &Path, bytes: &[u8]) -> Result<(), String> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).map_err(format_io)?;
    }
    fs::write(path, bytes).map_err(format_io)
}

fn is_owned_loader(path: &Path) -> bool {
    fs::read_to_string(path)
        .map(|content| content.contains("THEME_ENGINE_WSID") && content.contains("[ThemeEngine]"))
        .unwrap_or(false)
}

fn file_matches(path: &Path, expected: &[u8]) -> bool {
    fs::read(path)
        .map(|bytes| Sha256::digest(bytes) == Sha256::digest(expected))
        .unwrap_or(false)
}

fn restore_optional(path: &Path, content: Option<Vec<u8>>) {
    match content {
        Some(bytes) => {
            let _ = fs::write(path, bytes);
        }
        None => {
            let _ = fs::remove_file(path);
        }
    }
}

fn remove_empty_parents(path: &Path, stop: PathBuf) {
    let mut current = path.parent();
    while let Some(dir) = current {
        if dir == stop
            || fs::read_dir(dir)
                .ok()
                .and_then(|mut entries| entries.next())
                .is_some()
        {
            break;
        }
        let _ = fs::remove_dir(dir);
        current = dir.parent();
    }
}

fn extract_embedded_dir(dir: &Dir<'_>, target: &Path) -> Result<(), String> {
    for entry in dir.entries() {
        match entry {
            DirEntry::Dir(child) => {
                let child_target = target.join(
                    child
                        .path()
                        .file_name()
                        .ok_or("Invalid embedded directory")?,
                );
                fs::create_dir_all(&child_target).map_err(format_io)?;
                extract_embedded_dir(child, &child_target)?;
            }
            DirEntry::File(file) => {
                let destination =
                    target.join(file.path().file_name().ok_or("Invalid embedded file")?);
                fs::write(destination, file.contents()).map_err(format_io)?;
            }
        }
    }
    Ok(())
}

fn format_io(error: io::Error) -> String {
    error.to_string()
}

fn yes_no(value: bool) -> &'static str {
    if value {
        "ready"
    } else {
        "missing or outdated"
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    fn fake_game() -> tempfile::TempDir {
        let root = tempdir().unwrap();
        fs::create_dir_all(root.path().join("lua/includes")).unwrap();
        fs::write(root.path().join("lua/includes/init.lua"), "print('init')\n").unwrap();
        fs::write(
            root.path().join("lua/includes/init_menu.lua"),
            "print('menu')\r\n",
        )
        .unwrap();
        root
    }

    #[test]
    fn include_is_idempotent_and_case_insensitive() {
        let source = "x\nInClUdE ( 'theme_engine_master.lua' ) -- old\ny\n";
        let once = add_include(source);
        let twice = add_include(&once);
        assert_eq!(once, twice);
        assert_eq!(once.matches(INCLUDE_LINE).count(), 1);
    }

    #[test]
    fn install_and_uninstall_touch_only_owned_content() {
        let game = fake_game();
        install(game.path()).unwrap();
        assert_eq!(inspect(game.path()).state, InstallState::Installed);
        uninstall(game.path()).unwrap();
        assert_eq!(inspect(game.path()).state, InstallState::NotInstalled);
        assert!(
            fs::read_to_string(game.path().join("lua/includes/init.lua"))
                .unwrap()
                .contains("print('init')")
        );
    }

    #[test]
    fn uninstaller_preserves_unrecognized_loader() {
        let game = fake_game();
        let loader = game.path().join("lua/includes/theme_engine_master.lua");
        fs::write(&loader, "user file").unwrap();
        uninstall(game.path()).unwrap();
        assert_eq!(fs::read_to_string(loader).unwrap(), "user file");
    }
}
