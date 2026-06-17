use clap::{Parser, Subcommand, ValueEnum};

use crate::commands::{minio::MinioCommands, verify::VerifyCommands};

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
    #[command(alias = "check", alias = "v", alias = "c")]
    Verify {
        #[command(subcommand)]
        command: VerifyCommands,
    },
    Minio {
        #[command(subcommand)]
        command: MinioCommands,
    },
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub enum VerificationLevel {
    Start,
    Advanced,
}
