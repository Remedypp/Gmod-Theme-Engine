use regex::Regex;
use std::collections::BTreeSet;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use sysinfo::Disks;

use crate::installer::is_valid_gmod_path;

pub fn normalize_selected_path(path: &Path) -> Option<PathBuf> {
    let candidates = [
        path.to_path_buf(),
        path.join("garrysmod"),
        path.join("GarrysMod").join("garrysmod"),
        path.join("common").join("GarrysMod").join("garrysmod"),
        path.join("steamapps")
            .join("common")
            .join("GarrysMod")
            .join("garrysmod"),
    ];
    candidates
        .into_iter()
        .find(|candidate| is_valid_gmod_path(candidate))
}

pub fn discover_gmod_paths() -> Vec<PathBuf> {
    let mut steam_roots = BTreeSet::new();
    let mut candidates = BTreeSet::new();

    add_executable_ancestors(&mut candidates);
    add_platform_steam_roots(&mut steam_roots);
    add_mount_candidates(&mut steam_roots, &mut candidates);

    let initial_roots: Vec<_> = steam_roots.iter().cloned().collect();
    for root in initial_roots {
        add_vdf_libraries(&root, &mut steam_roots);
    }

    for root in steam_roots {
        candidates.insert(
            root.join("steamapps")
                .join("common")
                .join("GarrysMod")
                .join("garrysmod"),
        );
    }

    candidates
        .into_iter()
        .filter(|candidate| is_valid_gmod_path(candidate))
        .map(|candidate| fs::canonicalize(&candidate).unwrap_or(candidate))
        .map(clean_path)
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect()
}

fn clean_path(path: PathBuf) -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        let raw = path.to_string_lossy();
        if let Some(rest) = raw.strip_prefix(r"\\?\UNC\") {
            return PathBuf::from(format!(r"\\{rest}"));
        }
        if let Some(rest) = raw.strip_prefix(r"\\?\") {
            return PathBuf::from(rest);
        }
    }
    path
}

fn add_executable_ancestors(candidates: &mut BTreeSet<PathBuf>) {
    let Ok(exe) = env::current_exe() else { return };
    for parent in exe.ancestors() {
        if let Some(path) = normalize_selected_path(parent) {
            candidates.insert(path);
        }
    }
}

fn add_platform_steam_roots(roots: &mut BTreeSet<PathBuf>) {
    #[cfg(target_os = "windows")]
    {
        roots.insert(PathBuf::from(r"C:\Program Files (x86)\Steam"));
        roots.insert(PathBuf::from(r"C:\Program Files\Steam"));
    }

    #[cfg(any(target_os = "linux", target_os = "macos"))]
    if let Some(base) = directories::BaseDirs::new() {
        #[cfg(target_os = "linux")]
        {
            let home = base.home_dir();
            roots.insert(home.join(".steam").join("steam"));
            roots.insert(home.join(".local").join("share").join("Steam"));
            roots.insert(
                home.join(".var")
                    .join("app")
                    .join("com.valvesoftware.Steam")
                    .join(".local")
                    .join("share")
                    .join("Steam"),
            );
        }
        #[cfg(target_os = "macos")]
        roots.insert(
            base.home_dir()
                .join("Library")
                .join("Application Support")
                .join("Steam"),
        );
    }

    #[cfg(target_os = "windows")]
    add_windows_registry_roots(roots);
}

#[cfg(target_os = "windows")]
fn add_windows_registry_roots(roots: &mut BTreeSet<PathBuf>) {
    use winreg::RegKey;
    use winreg::enums::{
        HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE, KEY_READ, KEY_WOW64_32KEY, KEY_WOW64_64KEY,
    };

    let locations = [
        (HKEY_CURRENT_USER, r"Software\Valve\Steam", KEY_READ),
        (
            HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Valve\Steam",
            KEY_READ | KEY_WOW64_32KEY,
        ),
        (
            HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Valve\Steam",
            KEY_READ | KEY_WOW64_64KEY,
        ),
    ];
    for (hive, key_path, flags) in locations {
        let hive = RegKey::predef(hive);
        let Ok(key) = hive.open_subkey_with_flags(key_path, flags) else {
            continue;
        };
        for name in ["SteamPath", "InstallPath"] {
            if let Ok(value) = key.get_value::<String, _>(name) {
                roots.insert(PathBuf::from(value.replace('/', "\\")));
            }
        }
    }
}

fn add_mount_candidates(roots: &mut BTreeSet<PathBuf>, candidates: &mut BTreeSet<PathBuf>) {
    let disks = Disks::new_with_refreshed_list();
    for disk in disks.list() {
        let mount = disk.mount_point();
        for suffix in [
            "SteamLibrary",
            "Steam",
            r"Program Files (x86)\Steam",
            r"Program Files\Steam",
        ] {
            roots.insert(mount.join(suffix));
        }
        candidates.insert(
            mount
                .join("steamapps")
                .join("common")
                .join("GarrysMod")
                .join("garrysmod"),
        );
        candidates.insert(mount.join("common").join("GarrysMod").join("garrysmod"));
    }
}

fn add_vdf_libraries(steam_root: &Path, roots: &mut BTreeSet<PathBuf>) {
    let vdf = steam_root.join("steamapps").join("libraryfolders.vdf");
    let Ok(raw) = fs::read_to_string(vdf) else {
        return;
    };
    let Ok(pattern) = Regex::new(r#"(?i)"path"\s+"([^"]+)""#) else {
        return;
    };
    for captures in pattern.captures_iter(&raw) {
        let decoded = captures[1].replace("\\\\", "\\");
        if !decoded.trim().is_empty() {
            roots.insert(PathBuf::from(decoded));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{clean_path, normalize_selected_path};
    use std::fs;
    #[cfg(target_os = "windows")]
    use std::path::PathBuf;
    use tempfile::tempdir;

    #[test]
    fn accepts_garrysmod_parent_folder() {
        let root = tempdir().unwrap();
        let game = root.path().join("GarrysMod").join("garrysmod");
        fs::create_dir_all(game.join("lua").join("includes")).unwrap();
        fs::write(game.join("lua/includes/init.lua"), "").unwrap();
        fs::write(game.join("lua/includes/init_menu.lua"), "").unwrap();
        assert_eq!(normalize_selected_path(root.path()), Some(game));
    }

    #[cfg(target_os = "windows")]
    #[test]
    fn removes_windows_verbatim_prefix() {
        assert_eq!(
            clean_path(PathBuf::from(r"\\?\E:\SteamLibrary\steamapps")),
            PathBuf::from(r"E:\SteamLibrary\steamapps")
        );
    }
}
