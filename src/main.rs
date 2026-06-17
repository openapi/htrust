mod cli;
mod client;
mod commands;
mod config;

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
        Commands::Mobile(args) => {
            run_trust(commands::trust::ClaimKind::Mobile, args, cli.sandbox).await
        }
        Commands::Email(args) => {
            run_trust(commands::trust::ClaimKind::Email, args, cli.sandbox).await
        }
        Commands::Ip(args) => run_trust(commands::trust::ClaimKind::Ip, args, cli.sandbox).await,
        Commands::Url(args) => run_trust(commands::trust::ClaimKind::Url, args, cli.sandbox).await,
    }
}

async fn run_trust(
    kind: commands::trust::ClaimKind,
    args: &commands::trust::TrustCommand,
    sandbox: bool,
) -> Result<()> {
    let config = Config::load(sandbox)?;
    let client = ApiClient::new(config)?;
    commands::trust::execute(kind, args, &client).await
}
