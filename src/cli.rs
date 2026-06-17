use clap::{Parser, Subcommand};

use crate::commands::trust::TrustCommand;

#[derive(Debug, Parser)]
#[command(name = "htrust", about = "Open Source Trust for Humans", version)]
pub struct Cli {
    #[arg(short = 'S', long, global = true)]
    pub sandbox: bool,

    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    Info,
    Mobile(TrustCommand),
    Email(TrustCommand),
    Ip(TrustCommand),
    Url(TrustCommand),
}
