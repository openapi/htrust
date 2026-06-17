mod cli;
mod client;
mod commands;
mod config;
mod storage;

use anyhow::Result;
use clap::{CommandFactory, Parser};

use cli::{Cli, Commands};
use client::ApiClient;
use config::Config;

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    let Some(command) = &cli.command else {
        Cli::command().print_help()?;
        println!();
        return Ok(());
    };

    match command {
        Commands::Info => commands::info::execute(cli.sandbox),
        Commands::Verify { command } => {
            let config = Config::load(cli.sandbox)?;
            let client = ApiClient::new(config)?;
            commands::verify::execute(command, &client).await
        }
        Commands::Minio { command } => commands::minio::execute(command),
    }
}
