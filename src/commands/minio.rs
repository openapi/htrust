use anyhow::Result;
use clap::{Args, Subcommand};

use crate::storage::MinioConfig;

#[derive(Debug, Subcommand)]
pub enum MinioCommands {
    Info,
    Init(InitArgs),
}

#[derive(Debug, Args)]
pub struct InitArgs {
    #[arg(long, default_value = "htrust")]
    pub alias: String,
}

pub fn execute(command: &MinioCommands) -> Result<()> {
    match command {
        MinioCommands::Info => {
            let minio = MinioConfig::from_env();
            println!("endpoint: {}", minio.endpoint);
            for bucket in minio.buckets() {
                println!("bucket: {}", bucket);
            }
            Ok(())
        }
        MinioCommands::Init(args) => {
            let minio = MinioConfig::from_env();
            minio.init(&args.alias)?;
            println!("initialized alias {}", args.alias);
            Ok(())
        }
    }
}
