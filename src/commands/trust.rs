use std::net::IpAddr;
use std::process::exit;
use std::sync::LazyLock;

use anyhow::{Result, bail};
use clap::Args;
use regex::Regex;
use url::Url;

use crate::client::ApiClient;

const PROD: &str = "https://trust.openapi.com";
const SANDBOX: &str = "https://test.trust.openapi.com";

static MOBILE_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"^\+[1-9]\d{1,14}$").expect("mobile regex"));
static EMAIL_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").expect("email regex"));

#[derive(Clone, Copy, Debug)]
pub enum ClaimKind {
    Mobile,
    Email,
    Ip,
    Url,
}

#[derive(Debug, Args)]
pub struct TrustCommand {
    pub value: String,

    #[arg(long, visible_alias = "details", help = "Use the advanced/detail API endpoint")]
    pub detail: bool,

    #[arg(long, help = "Output the full API response as JSON")]
    pub json: bool,

    #[arg(long, help = "Alias for --json")]
    pub full: bool,
}

pub async fn execute(kind: ClaimKind, args: &TrustCommand, client: &ApiClient) -> Result<()> {
    validate(kind, &args.value)?;

    let base = client.base_url(PROD, SANDBOX);
    let path = endpoint(kind, args.detail);
    let encoded = urlencoding::encode(&args.value);
    let body = serde_json::json!({});
    let response = client
        .post(&format!("{}/{}/{}", base, path, encoded), &body)
        .await?;

    if args.json || args.full {
        println!("{}", serde_json::to_string_pretty(&response)?);
        return Ok(());
    }

    let status = response["data"]["status"].as_str().unwrap_or("unknown");
    println!("{}", status);
    match status {
        "valid" | "verified" => Ok(()),
        "risky" | "invalid" => exit(1),
        _ => Ok(()),
    }
}

pub fn validate(kind: ClaimKind, value: &str) -> Result<()> {
    let ok = match kind {
        ClaimKind::Mobile => MOBILE_RE.is_match(value),
        ClaimKind::Email => EMAIL_RE.is_match(value),
        ClaimKind::Ip => value.parse::<IpAddr>().is_ok(),
        ClaimKind::Url => Url::parse(value)
            .map(|u| matches!(u.scheme(), "http" | "https"))
            .unwrap_or(false),
    };

    if ok {
        Ok(())
    } else {
        bail!("invalid {} format: {}", kind_name(kind), value)
    }
}

fn kind_name(kind: ClaimKind) -> &'static str {
    match kind {
        ClaimKind::Mobile => "mobile",
        ClaimKind::Email => "email",
        ClaimKind::Ip => "ip",
        ClaimKind::Url => "url",
    }
}

fn endpoint(kind: ClaimKind, detail: bool) -> &'static str {
    match (kind, detail) {
        (ClaimKind::Mobile, false) => "mobile-start",
        (ClaimKind::Mobile, true) => "mobile-advanced",
        (ClaimKind::Email, false) => "email-start",
        (ClaimKind::Email, true) => "email-advanced",
        (ClaimKind::Ip, _) => "ip-advanced",
        (ClaimKind::Url, _) => "url-advanced",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mobile_endpoint_default() {
        assert_eq!(endpoint(ClaimKind::Mobile, false), "mobile-start");
    }

    #[test]
    fn mobile_endpoint_detail() {
        assert_eq!(endpoint(ClaimKind::Mobile, true), "mobile-advanced");
    }

    #[test]
    fn email_endpoint_default() {
        assert_eq!(endpoint(ClaimKind::Email, false), "email-start");
    }

    #[test]
    fn email_endpoint_detail() {
        assert_eq!(endpoint(ClaimKind::Email, true), "email-advanced");
    }

    #[test]
    fn ip_endpoint_is_always_advanced() {
        assert_eq!(endpoint(ClaimKind::Ip, false), "ip-advanced");
        assert_eq!(endpoint(ClaimKind::Ip, true), "ip-advanced");
    }

    #[test]
    fn url_endpoint_is_always_advanced() {
        assert_eq!(endpoint(ClaimKind::Url, false), "url-advanced");
        assert_eq!(endpoint(ClaimKind::Url, true), "url-advanced");
    }

    #[test]
    fn validate_accepts_valid_mobile() {
        assert!(validate(ClaimKind::Mobile, "+393331234567").is_ok());
    }

    #[test]
    fn validate_rejects_invalid_mobile() {
        assert!(validate(ClaimKind::Mobile, "393331234567").is_err());
        assert!(validate(ClaimKind::Mobile, "+").is_err());
        assert!(validate(ClaimKind::Mobile, "+abc123").is_err());
    }

    #[test]
    fn validate_accepts_valid_email() {
        assert!(validate(ClaimKind::Email, "info@example.com").is_ok());
    }

    #[test]
    fn validate_rejects_invalid_email() {
        assert!(validate(ClaimKind::Email, "not-an-email").is_err());
        assert!(validate(ClaimKind::Email, "info@").is_err());
    }

    #[test]
    fn validate_accepts_valid_ip() {
        assert!(validate(ClaimKind::Ip, "8.8.8.8").is_ok());
        assert!(validate(ClaimKind::Ip, "::1").is_ok());
    }

    #[test]
    fn validate_rejects_invalid_ip() {
        assert!(validate(ClaimKind::Ip, "999.999.999.999").is_err());
        assert!(validate(ClaimKind::Ip, "hello").is_err());
    }

    #[test]
    fn validate_accepts_valid_url() {
        assert!(validate(ClaimKind::Url, "https://example.com").is_ok());
        assert!(validate(ClaimKind::Url, "http://localhost:8080").is_ok());
    }

    #[test]
    fn validate_rejects_invalid_url() {
        assert!(validate(ClaimKind::Url, "not-a-url").is_err());
        assert!(validate(ClaimKind::Url, "ftp://example.com").is_err());
    }
}
