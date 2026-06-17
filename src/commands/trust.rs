use anyhow::Result;
use clap::Args;

use crate::client::ApiClient;

const PROD: &str = "https://trust.openapi.com";
const SANDBOX: &str = "https://test.trust.openapi.com";

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

    #[arg(long)]
    pub detail: bool,
}

pub async fn execute(kind: ClaimKind, args: &TrustCommand, client: &ApiClient) -> Result<()> {
    let base = client.base_url(PROD, SANDBOX);
    let path = endpoint(kind, args.detail);
    let body = serde_json::json!({});
    let response = client
        .post(&format!("{}/{}/{}", base, path, args.value), &body)
        .await?;

    println!("{}", serde_json::to_string_pretty(&response)?);
    Ok(())
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
}
