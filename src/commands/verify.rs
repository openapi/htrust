use anyhow::Result;
use clap::{Args, Subcommand};

use crate::cli::VerificationLevel;
use crate::client::ApiClient;

const PROD: &str = "https://trust.openapi.com";
const SANDBOX: &str = "https://test.trust.openapi.com";

#[derive(Debug, Subcommand)]
pub enum VerifyCommands {
    Mobile(TargetWithLevel<PhoneTarget>),
    Email(TargetWithLevel<EmailTarget>),
    Ip(IpTarget),
    Url(UrlTarget),
}

#[derive(Debug, Args)]
pub struct TargetWithLevel<T: Args> {
    #[command(flatten)]
    pub target: T,

    #[arg(long, value_enum, default_value_t = VerificationLevel::Start)]
    pub level: VerificationLevel,
}

#[derive(Debug, Args)]
pub struct PhoneTarget {
    #[arg(long)]
    pub phone: String,
}

#[derive(Debug, Args)]
pub struct EmailTarget {
    #[arg(long)]
    pub email: String,
}

#[derive(Debug, Args)]
pub struct IpTarget {
    #[arg(long)]
    pub ip: String,
}

#[derive(Debug, Args)]
pub struct UrlTarget {
    #[arg(long)]
    pub url: String,
}

pub async fn execute(command: &VerifyCommands, client: &ApiClient) -> Result<()> {
    let base = client.base_url(PROD, SANDBOX);
    let body = serde_json::json!({});

    let response = match command {
        VerifyCommands::Mobile(args) => {
            let path = match args.level {
                VerificationLevel::Start => "mobile-start",
                VerificationLevel::Advanced => "mobile-advanced",
            };
            client
                .post(&format!("{}/{}/{}", base, path, args.target.phone), &body)
                .await?
        }
        VerifyCommands::Email(args) => {
            let path = match args.level {
                VerificationLevel::Start => "email-start",
                VerificationLevel::Advanced => "email-advanced",
            };
            client
                .post(&format!("{}/{}/{}", base, path, args.target.email), &body)
                .await?
        }
        VerifyCommands::Ip(args) => {
            client
                .post(&format!("{}/ip-advanced/{}", base, args.ip), &body)
                .await?
        }
        VerifyCommands::Url(args) => {
            client
                .post(&format!("{}/url-advanced/{}", base, args.url), &body)
                .await?
        }
    };

    println!("{}", serde_json::to_string_pretty(&response)?);
    Ok(())
}
