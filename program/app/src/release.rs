use serde::Deserialize;
use std::time::Duration;

const LATEST_RELEASE_URL: &str =
    "https://api.github.com/repos/Remedypp/Gmod-Theme-Engine/releases/latest";

#[derive(Clone, Debug)]
pub struct ReleaseInfo {
    pub version: String,
    pub url: String,
    pub newer: bool,
}

#[derive(Deserialize)]
struct GitHubRelease {
    tag_name: String,
    html_url: String,
}

pub fn check_latest(current: &str) -> Result<ReleaseInfo, String> {
    let config = ureq::Agent::config_builder()
        .timeout_global(Some(Duration::from_secs(8)))
        .https_only(true)
        .build();
    let agent = ureq::Agent::new_with_config(config);
    let mut response = agent
        .get(LATEST_RELEASE_URL)
        .header("Accept", "application/vnd.github+json")
        .header("User-Agent", "Aperture-Theme-Engine-Installer-Update-Check")
        .call()
        .map_err(|error| error.to_string())?;
    let release: GitHubRelease = response
        .body_mut()
        .read_json()
        .map_err(|error| error.to_string())?;
    let version = release.tag_name.trim_start_matches('v').to_owned();
    Ok(ReleaseInfo {
        newer: version_is_newer(&version, current),
        version,
        url: release.html_url,
    })
}

fn version_is_newer(candidate: &str, current: &str) -> bool {
    match (version_parts(candidate), version_parts(current)) {
        (Some(candidate), Some(current)) => candidate > current,
        _ => false,
    }
}

fn version_parts(version: &str) -> Option<(u64, u64, u64)> {
    let stable = version
        .trim()
        .trim_start_matches('v')
        .split_once('-')
        .map_or(version.trim().trim_start_matches('v'), |(head, _)| head);
    let mut parts = stable.split('.');
    let major = parts.next()?.parse().ok()?;
    let minor = parts.next().unwrap_or("0").parse().ok()?;
    let patch = parts.next().unwrap_or("0").parse().ok()?;
    Some((major, minor, patch))
}

#[cfg(test)]
mod tests {
    use super::{version_is_newer, version_parts};

    #[test]
    fn compares_semantic_versions() {
        assert!(version_is_newer("1.2.0", "1.1.9"));
        assert!(version_is_newer("v2.0.0", "1.99.99"));
        assert!(!version_is_newer("1.1.1", "1.1.1"));
        assert!(!version_is_newer("1.0.9", "1.1.0"));
    }

    #[test]
    fn ignores_prerelease_suffix_for_release_comparison() {
        assert_eq!(version_parts("v1.2.3-beta.1"), Some((1, 2, 3)));
    }
}
