use anyhow::Result;
use reqwest::header::{AUTHORIZATION, CONTENT_TYPE, HeaderMap, HeaderValue};
use serde_json::Value;

use crate::config::Config;

pub struct ApiClient {
    http: reqwest::Client,
    pub sandbox: bool,
}

impl ApiClient {
    pub fn new(config: Config) -> Result<Self> {
        let mut headers = HeaderMap::new();
        headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
        headers.insert(
            AUTHORIZATION,
            HeaderValue::from_str(&format!("Bearer {}", config.token))?,
        );

        let http = reqwest::Client::builder()
            .default_headers(headers)
            .build()?;
        Ok(Self {
            http,
            sandbox: config.sandbox,
        })
    }

    pub fn base_url<'a>(&self, production: &'a str, sandbox: &'a str) -> &'a str {
        if self.sandbox { sandbox } else { production }
    }

    pub async fn post(&self, url: &str, body: &Value) -> Result<Value> {
        let response = self.http.post(url).json(body).send().await?;
        let status = response.status();
        let body: Value = response.json().await?;
        if !status.is_success() {
            anyhow::bail!("API error ({}): {}", status, body);
        }
        Ok(body)
    }
}
