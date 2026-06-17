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

#[cfg(test)]
mod tests {
    use super::*;
    use clap::Parser;

    #[test]
    fn parse_info_command() {
        let cli = Cli::parse_from(["htrust", "info"]);
        assert!(matches!(cli.command, Some(Commands::Info)));
        assert!(!cli.sandbox);
    }

    #[test]
    fn parse_sandbox_flag() {
        let cli = Cli::parse_from(["htrust", "--sandbox", "info"]);
        assert!(cli.sandbox);
    }

    #[test]
    fn parse_mobile_command() {
        let cli = Cli::parse_from(["htrust", "mobile", "+393331234567"]);
        match cli.command {
            Some(Commands::Mobile(args)) => {
                assert_eq!(args.value, "+393331234567");
                assert!(!args.detail);
            }
            _ => panic!("expected Mobile command"),
        }
    }

    #[test]
    fn parse_mobile_command_with_detail() {
        let cli = Cli::parse_from(["htrust", "mobile", "+393331234567", "--detail"]);
        match cli.command {
            Some(Commands::Mobile(args)) => {
                assert_eq!(args.value, "+393331234567");
                assert!(args.detail);
            }
            _ => panic!("expected Mobile command"),
        }
    }

    #[test]
    fn parse_email_command() {
        let cli = Cli::parse_from(["htrust", "email", "info@example.com"]);
        assert!(matches!(cli.command, Some(Commands::Email(_))));
    }

    #[test]
    fn parse_ip_command() {
        let cli = Cli::parse_from(["htrust", "ip", "8.8.8.8"]);
        assert!(matches!(cli.command, Some(Commands::Ip(_))));
    }

    #[test]
    fn parse_url_command() {
        let cli = Cli::parse_from(["htrust", "url", "https://example.com"]);
        assert!(matches!(cli.command, Some(Commands::Url(_))));
    }
}