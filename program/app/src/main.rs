#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod discovery;
mod installer;
mod release;

use eframe::egui::{self, Color32, RichText, Stroke};
use installer::{ActionReport, InstallState};
use std::path::PathBuf;
use std::sync::mpsc::{self, Receiver, TryRecvError};
use std::thread;
use std::time::Duration;

const LOGO: &[u8] = include_bytes!("../../branding/theme-engine-installer-logo.png");
const VERSION: &str = env!("CARGO_PKG_VERSION");
const WORKSHOP_URL: &str = "https://steamcommunity.com/sharedfiles/filedetails/?id=3765005303";

fn main() -> eframe::Result {
    let icon = load_icon();
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_title("Aperture Theme Engine Installer")
            .with_inner_size([920.0, 580.0])
            .with_min_inner_size([760.0, 520.0])
            .with_icon(icon),
        ..Default::default()
    };
    eframe::run_native(
        "Aperture Theme Engine Installer",
        options,
        Box::new(|cc| Ok(Box::new(InstallerApp::new(cc)))),
    )
}

#[derive(Clone, Copy)]
enum PendingAction {
    Install,
    Repair,
    Uninstall,
    ExampleTheme,
    OpenWorkshop,
    OpenRelease,
}

enum ReleaseStatus {
    Checking,
    Current(String),
    Available(release::ReleaseInfo),
    Unavailable(String),
}

struct InstallerApp {
    paths: Vec<PathBuf>,
    selected: Option<PathBuf>,
    path_text: String,
    inspection: Option<installer::Inspection>,
    message: String,
    report: Vec<String>,
    pending: Option<PendingAction>,
    logo: egui::TextureHandle,
    release_status: ReleaseStatus,
    release_rx: Option<Receiver<Result<release::ReleaseInfo, String>>>,
}

impl InstallerApp {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        configure_style(&cc.egui_ctx);
        let logo_image = image::load_from_memory(LOGO)
            .expect("embedded logo")
            .to_rgba8();
        let size = [logo_image.width() as usize, logo_image.height() as usize];
        let logo = cc.egui_ctx.load_texture(
            "aperture-theme-engine-logo",
            egui::ColorImage::from_rgba_unmultiplied(size, logo_image.as_raw()),
            egui::TextureOptions::LINEAR,
        );
        let paths = discovery::discover_gmod_paths();
        let selected = paths.first().cloned();
        let path_text = selected
            .as_ref()
            .map(|path| path.display().to_string())
            .unwrap_or_default();
        let inspection = selected.as_ref().map(|path| installer::inspect(path));
        let (release_tx, release_rx) = mpsc::channel();
        thread::spawn(move || {
            let _ = release_tx.send(release::check_latest(VERSION));
        });
        Self {
            paths,
            selected,
            path_text,
            inspection,
            message: "Select your Garry's Mod installation. No administrator access is requested."
                .into(),
            report: Vec::new(),
            pending: None,
            logo,
            release_status: ReleaseStatus::Checking,
            release_rx: Some(release_rx),
        }
    }

    fn select_path(&mut self, path: PathBuf) {
        match discovery::normalize_selected_path(&path) {
            Some(game) => {
                if !self.paths.contains(&game) {
                    self.paths.push(game.clone());
                }
                self.path_text = game.display().to_string();
                self.inspection = Some(installer::inspect(&game));
                self.selected = Some(game);
                self.message = "Valid Garry's Mod installation selected.".into();
                self.report.clear();
            }
            None => {
                self.message = "That folder does not contain Garry's Mod. Select GarrysMod, garrysmod, common, steamapps, or a Steam library folder.".into();
            }
        }
    }

    fn refresh(&mut self) {
        self.paths = discovery::discover_gmod_paths();
        let selection = preferred_detected_path(&self.path_text, &self.paths);
        match selection {
            Some(path) => {
                self.select_path(path);
                self.message = format!(
                    "Detection complete. {} installation(s) available.",
                    self.paths.len()
                );
            }
            None => {
                self.selected = None;
                self.inspection = None;
                self.path_text.clear();
                self.message = "No Garry's Mod installation was found. Use Browse to select the GarrysMod or garrysmod folder.".into();
                self.report.clear();
            }
        }
    }

    fn run_action(&mut self, action: PendingAction) {
        if matches!(action, PendingAction::OpenWorkshop) {
            self.open_url(WORKSHOP_URL, "Workshop");
            return;
        }
        if matches!(action, PendingAction::OpenRelease) {
            let url = match &self.release_status {
                ReleaseStatus::Available(info) => Some(info.url.clone()),
                _ => None,
            };
            if let Some(url) = url {
                self.open_url(&url, "release");
            }
            return;
        }
        let Some(path) = self.selected.clone() else {
            self.message = "Select a valid Garry's Mod installation first.".into();
            return;
        };
        let offer_workshop = matches!(action, PendingAction::Install);
        let result = match action {
            PendingAction::Install | PendingAction::Repair => installer::install(&path),
            PendingAction::Uninstall => installer::uninstall(&path),
            PendingAction::ExampleTheme => installer::install_example_theme(&path),
            PendingAction::OpenWorkshop | PendingAction::OpenRelease => unreachable!(),
        };
        match result {
            Ok(ActionReport { headline, details }) => {
                self.message = headline;
                self.report = details;
                if offer_workshop {
                    self.pending = Some(PendingAction::OpenWorkshop);
                }
            }
            Err(error) => {
                self.message = format!("Operation failed: {error}");
                self.report = vec!["No elevation was attempted. Check that Steam and Garry's Mod are closed and that your account can write to this Steam library.".into()];
            }
        }
        self.inspection = Some(installer::inspect(&path));
    }

    fn open_url(&mut self, url: &str, label: &str) {
        match open::that(url) {
            Ok(()) => {
                self.message = format!("Opened the {label} page in your browser.");
            }
            Err(error) => {
                self.message = format!("Could not open the {label} page: {error}");
            }
        }
    }

    fn poll_release(&mut self, ctx: &egui::Context) {
        let Some(receiver) = &self.release_rx else {
            return;
        };
        match receiver.try_recv() {
            Ok(Ok(info)) => {
                if info.newer {
                    self.release_status = ReleaseStatus::Available(info);
                } else {
                    self.release_status = ReleaseStatus::Current(info.version);
                }
                self.release_rx = None;
            }
            Ok(Err(error)) => {
                self.release_status = ReleaseStatus::Unavailable(error);
                self.release_rx = None;
            }
            Err(TryRecvError::Disconnected) => {
                self.release_status =
                    ReleaseStatus::Unavailable("Update service disconnected".into());
                self.release_rx = None;
            }
            Err(TryRecvError::Empty) => {
                ctx.request_repaint_after(Duration::from_millis(250));
            }
        }
    }

    fn confirmation(&mut self, ctx: &egui::Context) {
        let Some(action) = self.pending else { return };
        let (title, body, confirm) = match action {
            PendingAction::Install => (
                "Install Theme Engine?".to_owned(),
                "The installer will add one include line to init.lua and init_menu.lua, then install the embedded loader and logo.".to_owned(),
                "Install".to_owned(),
            ),
            PendingAction::Repair => (
                "Repair installation?".to_owned(),
                "The installer will normalize duplicate hooks and replace Theme Engine-owned loader assets with this version.".to_owned(),
                "Repair".to_owned(),
            ),
            PendingAction::Uninstall => (
                "Uninstall Theme Engine?".to_owned(),
                "Only Theme Engine hooks and recognized Theme Engine-owned files will be removed. Official Garry's Mod files will not be restored from backups.".to_owned(),
                "Uninstall".to_owned(),
            ),
            PendingAction::ExampleTheme => (
                "Install example theme?".to_owned(),
                "The editable example theme will be installed in garrysmod/addons. If a copy already exists, it will be preserved in theme_engine_installer_backup before replacement.".to_owned(),
                "Install example".to_owned(),
            ),
            PendingAction::OpenWorkshop => (
                "Open Steam Workshop?".to_owned(),
                "Aperture Theme Engine needs its Workshop addon. Open the official addon page in your browser?".to_owned(),
                "Open Workshop".to_owned(),
            ),
            PendingAction::OpenRelease => {
                let version = match &self.release_status {
                    ReleaseStatus::Available(info) => info.version.as_str(),
                    _ => "latest",
                };
                (
                    "Open installer update?".to_owned(),
                    format!(
                        "Version {version} is available. Open the GitHub release page in your browser?"
                    ),
                    "Open release".to_owned(),
                )
            }
        };
        egui::Window::new(title)
            .anchor(egui::Align2::CENTER_CENTER, [0.0, 0.0])
            .collapsible(false)
            .resizable(false)
            .show(ctx, |ui| {
                ui.set_width(430.0);
                ui.label(body);
                ui.add_space(16.0);
                ui.horizontal(|ui| {
                    if ui.button("Cancel").clicked() {
                        self.pending = None;
                    }
                    if ui
                        .add(
                            egui::Button::new(RichText::new(confirm).strong())
                                .fill(Color32::from_rgb(32, 112, 142)),
                        )
                        .clicked()
                    {
                        self.pending = None;
                        self.run_action(action);
                    }
                });
            });
    }
}

impl eframe::App for InstallerApp {
    fn ui(&mut self, ui: &mut egui::Ui, _frame: &mut eframe::Frame) {
        let ctx = ui.ctx().clone();
        self.poll_release(&ctx);
        self.draw_ui(ui);
        self.confirmation(&ctx);
    }
}

impl InstallerApp {
    fn draw_ui(&mut self, ui: &mut egui::Ui) {
        ui.add_space(18.0);
        ui.horizontal(|ui| {
            ui.image((self.logo.id(), egui::vec2(92.0, 92.0)));
            ui.vertical(|ui| {
                ui.add_space(12.0);
                ui.label(
                    RichText::new("APERTURE LABORATORIES")
                        .size(12.0)
                        .strong()
                        .color(Color32::from_rgb(104, 203, 237)),
                );
                ui.label(
                    RichText::new("Theme Engine Installer")
                        .size(31.0)
                        .color(Color32::from_rgb(232, 238, 241)),
                );
                ui.label(
                    RichText::new(format!("Version {VERSION}  |  Windows, Linux and macOS"))
                        .color(Color32::from_rgb(139, 158, 168)),
                );
            });
        });
        ui.add_space(12.0);
        ui.separator();
        ui.add_space(14.0);

        egui::Frame::new()
            .fill(Color32::from_rgb(8, 18, 24))
            .stroke(Stroke::new(1.0, Color32::from_rgb(32, 73, 88)))
            .inner_margin(18.0)
            .show(ui, |ui| {
                ui.set_min_width(ui.available_width());
                ui.label(
                    RichText::new("GARRY'S MOD INSTALLATION")
                        .size(12.0)
                        .strong()
                        .color(Color32::from_rgb(104, 203, 237)),
                );
                ui.add_space(8.0);
                ui.horizontal(|ui| {
                    let response = ui.add_sized(
                        [ui.available_width() - 190.0, 34.0],
                        egui::TextEdit::singleline(&mut self.path_text).hint_text(
                            "Select GarrysMod, garrysmod, common, steamapps, or a Steam library",
                        ),
                    );
                    if response.changed() {
                        self.selected = None;
                        self.inspection = None;
                    }
                    if response.lost_focus()
                        && ui.input(|input| input.key_pressed(egui::Key::Enter))
                    {
                        self.select_path(PathBuf::from(self.path_text.trim()));
                    }
                    if ui
                        .add_sized([82.0, 34.0], egui::Button::new("Browse"))
                        .clicked()
                        && let Some(folder) = rfd::FileDialog::new()
                            .set_title("Select Garry's Mod or a Steam library")
                            .pick_folder()
                    {
                        self.select_path(folder);
                    }
                    if ui
                        .add_sized([82.0, 34.0], egui::Button::new("Detect"))
                        .clicked()
                    {
                        self.refresh();
                    }
                });
                if self.paths.len() > 1 {
                    egui::ComboBox::from_label("Detected installations")
                        .selected_text(
                            self.selected
                                .as_ref()
                                .map(|path| path.display().to_string())
                                .unwrap_or_default(),
                        )
                        .show_ui(ui, |ui| {
                            let paths = self.paths.clone();
                            for path in paths {
                                if ui
                                    .selectable_label(
                                        self.selected.as_ref() == Some(&path),
                                        path.display().to_string(),
                                    )
                                    .clicked()
                                {
                                    self.select_path(path);
                                }
                            }
                        });
                }
            });

        ui.add_space(14.0);
        egui::Frame::new()
            .fill(Color32::from_rgb(10, 21, 27))
            .stroke(Stroke::new(1.0, Color32::from_rgb(30, 61, 72)))
            .inner_margin(18.0)
            .show(ui, |ui| {
                ui.set_min_width(ui.available_width());
                let (label, color) =
                    match self.inspection.as_ref().map(|inspection| inspection.state) {
                        Some(InstallState::Installed) => {
                            ("INSTALLED", Color32::from_rgb(82, 196, 145))
                        }
                        Some(InstallState::Partial) => {
                            ("REPAIR REQUIRED", Color32::from_rgb(235, 183, 70))
                        }
                        _ => ("NOT INSTALLED", Color32::from_rgb(173, 188, 195)),
                    };
                ui.horizontal(|ui| {
                    ui.label(
                        RichText::new("INSTALLATION STATUS")
                            .size(12.0)
                            .strong()
                            .color(Color32::from_rgb(104, 203, 237)),
                    );
                    ui.label(RichText::new(label).strong().color(color));
                });
                if let Some(inspection) = &self.inspection {
                    ui.label(
                        RichText::new(&inspection.details).color(Color32::from_rgb(149, 168, 177)),
                    );
                }
                ui.add_space(14.0);
                ui.horizontal(|ui| {
                    let state = self
                        .inspection
                        .as_ref()
                        .map(|inspection| inspection.state)
                        .unwrap_or(InstallState::NotInstalled);
                    if state == InstallState::NotInstalled
                        && ui
                            .add_sized(
                                [150.0, 38.0],
                                egui::Button::new(RichText::new("Install").strong())
                                    .fill(Color32::from_rgb(25, 111, 151)),
                            )
                            .clicked()
                    {
                        self.pending = Some(PendingAction::Install);
                    }
                    if state != InstallState::NotInstalled
                        && ui
                            .add_sized(
                                [150.0, 38.0],
                                egui::Button::new(RichText::new("Repair").strong())
                                    .fill(Color32::from_rgb(25, 111, 151)),
                            )
                            .clicked()
                    {
                        self.pending = Some(PendingAction::Repair);
                    }
                    if state != InstallState::NotInstalled
                        && ui
                            .add_sized([150.0, 38.0], egui::Button::new("Uninstall"))
                            .clicked()
                    {
                        self.pending = Some(PendingAction::Uninstall);
                    }
                    if ui
                        .add_sized([180.0, 38.0], egui::Button::new("Install example theme"))
                        .clicked()
                    {
                        self.pending = Some(PendingAction::ExampleTheme);
                    }
                });
            });

        ui.add_space(14.0);
        egui::Frame::new()
            .fill(Color32::from_rgb(7, 15, 20))
            .stroke(Stroke::new(1.0, Color32::from_rgb(25, 53, 63)))
            .inner_margin(16.0)
            .show(ui, |ui| {
                ui.set_min_width(ui.available_width());
                ui.label(
                    RichText::new(&self.message)
                        .strong()
                        .color(Color32::from_rgb(215, 225, 229)),
                );
                for line in &self.report {
                    ui.label(
                        RichText::new(format!("- {line}")).color(Color32::from_rgb(144, 163, 172)),
                    );
                }
            });

        ui.with_layout(egui::Layout::bottom_up(egui::Align::LEFT), |ui| {
            ui.horizontal(|ui| {
                if ui.link("Open Workshop page").clicked() {
                    self.pending = Some(PendingAction::OpenWorkshop);
                }
                ui.separator();
                match &self.release_status {
                    ReleaseStatus::Checking => {
                        ui.label(
                            RichText::new("Checking for installer updates...")
                                .color(Color32::from_rgb(117, 136, 145)),
                        );
                    }
                    ReleaseStatus::Current(version) => {
                        ui.label(
                            RichText::new(format!("Latest installer: {version}"))
                                .color(Color32::from_rgb(117, 136, 145)),
                        );
                    }
                    ReleaseStatus::Available(info) => {
                        if ui
                            .link(
                                RichText::new(format!("Installer {} available", info.version))
                                    .strong()
                                    .color(Color32::from_rgb(104, 203, 237)),
                            )
                            .clicked()
                        {
                            self.pending = Some(PendingAction::OpenRelease);
                        }
                    }
                    ReleaseStatus::Unavailable(error) => {
                        ui.label(
                            RichText::new("Update check unavailable")
                                .color(Color32::from_rgb(117, 136, 145)),
                        )
                        .on_hover_text(error);
                    }
                }
                ui.separator();
                ui.label(
                    RichText::new("No files are changed until you confirm an action.")
                        .color(Color32::from_rgb(117, 136, 145)),
                );
            });
        });
    }
}

fn configure_style(ctx: &egui::Context) {
    let mut visuals = egui::Visuals::dark();
    visuals.panel_fill = Color32::from_rgb(5, 12, 16);
    visuals.window_fill = Color32::from_rgb(8, 18, 24);
    visuals.widgets.inactive.bg_fill = Color32::from_rgb(16, 31, 39);
    visuals.widgets.inactive.bg_stroke = Stroke::new(1.0, Color32::from_rgb(38, 76, 90));
    visuals.widgets.hovered.bg_fill = Color32::from_rgb(24, 67, 84);
    visuals.widgets.active.bg_fill = Color32::from_rgb(31, 111, 143);
    visuals.selection.bg_fill = Color32::from_rgb(31, 111, 143);
    ctx.set_visuals(visuals);
}

fn load_icon() -> egui::IconData {
    let image = image::load_from_memory(LOGO)
        .expect("embedded icon")
        .to_rgba8();
    egui::IconData {
        width: image.width(),
        height: image.height(),
        rgba: image.into_raw(),
    }
}

fn preferred_detected_path(path_text: &str, discovered: &[PathBuf]) -> Option<PathBuf> {
    discovery::normalize_selected_path(PathBuf::from(path_text.trim()).as_path())
        .or_else(|| discovered.first().cloned())
}

#[cfg(test)]
mod tests {
    use super::preferred_detected_path;
    use std::path::PathBuf;

    #[test]
    fn empty_path_uses_first_detected_installation() {
        let detected = vec![
            PathBuf::from("/steam/one/garrysmod"),
            PathBuf::from("/steam/two/garrysmod"),
        ];
        assert_eq!(
            preferred_detected_path("", &detected),
            Some(detected[0].clone())
        );
    }
}
