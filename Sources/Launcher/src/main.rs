#![windows_subsystem = "windows"]

use std::env;
use std::os::windows::process::CommandExt;
use std::path::Path;
use std::process::Command;

fn main() {
    let exe_path = env::current_exe().expect("Failed to determine path");
    let install_dir = exe_path.parent().unwrap_or(Path::new("."));
    let farcry_exe_path = install_dir.join("Bin32").join("FarCry.exe");

    let pass_on_args: Vec<String> = env::args().skip(1).collect();

    let args = vec![
        "-MOD:CryVR",
    ];

    let mut process = Command::new(farcry_exe_path)
        .args(pass_on_args)
        .args(&args)
        .env("DXVK_ASYNC", "0")
        .env("DXVK_GPLASYNCCACHE", "0")
        .env("DXVK_STARTOPENVR", "1")
        .current_dir(install_dir.join("Bin32"))
        .creation_flags(0x200)
        .spawn()
        .expect("Failed to launch Far Cry");

    if let Ok(value) = env::var("FCVR_WAIT") {
        if value == "1" {
            process.wait().unwrap();
        }
    }
}
