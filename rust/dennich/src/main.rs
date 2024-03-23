use serde::{Serialize, Deserialize};
use serde_json;
use std::fs::File;
use std::io::{self, Read, Write};
use std::path::PathBuf;
use dirs::home_dir;

#[derive(Serialize, Deserialize)]
struct Config {
    work_mode: String,
}

const CONFIG_FILE: &str = ".config/dennich/dennich.json";

fn main() -> io::Result<()> {
    let config_path = get_config_path()?;
    let mut config = read_config(&config_path)?;

    match config.work_mode.as_str() {
        "private" => config.work_mode = "work".to_string(),
        "work" => config.work_mode = "private".to_string(),
        _ => eprintln!("Unknown work_mode value."),
    }

    write_config(&config_path, &config)?; // Write the updated configuration back to the file
    println!("Toggled work_mode to {}", config.work_mode);
    Ok(())
}

fn get_config_path() -> io::Result<PathBuf> {
    home_dir()
        .map(|path| path.join(CONFIG_FILE))
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "Could not find home directory"))
}

fn read_config(path: &PathBuf) -> io::Result<Config> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    let config: Config = serde_json::from_str(&contents)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e.to_string()))?;
    Ok(config)
}

fn write_config(path: &PathBuf, config: &Config) -> io::Result<()> {
    let contents = serde_json::to_string_pretty(config)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e.to_string()))?;
    let mut file = File::create(path)?;
    file.write_all(contents.as_bytes())?;
    Ok(())
}
