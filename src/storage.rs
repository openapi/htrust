use anyhow::{Context, Result};
use std::process::Command;

#[derive(Debug, Clone)]
pub struct MinioConfig {
    pub endpoint: String,
    pub access_key: String,
    pub secret_key: String,
    pub claims_bucket: String,
    pub evidence_bucket: String,
    pub assessments_bucket: String,
    pub artifacts_bucket: String,
}

impl MinioConfig {
    pub fn from_env() -> Self {
        Self {
            endpoint: env_or("HTRUST_MINIO_ENDPOINT", "http://127.0.0.1:9000"),
            access_key: env_or("HTRUST_MINIO_ACCESS_KEY", "minioadmin"),
            secret_key: env_or("HTRUST_MINIO_SECRET_KEY", "minioadmin"),
            claims_bucket: env_or("HTRUST_MINIO_BUCKET_CLAIMS", "htrust-claims"),
            evidence_bucket: env_or("HTRUST_MINIO_BUCKET_EVIDENCE", "htrust-evidence"),
            assessments_bucket: env_or("HTRUST_MINIO_BUCKET_ASSESSMENTS", "htrust-assessments"),
            artifacts_bucket: env_or("HTRUST_MINIO_BUCKET_ARTIFACTS", "htrust-artifacts"),
        }
    }

    pub fn buckets(&self) -> [&str; 4] {
        [
            &self.claims_bucket,
            &self.evidence_bucket,
            &self.assessments_bucket,
            &self.artifacts_bucket,
        ]
    }

    pub fn init(&self, alias: &str) -> Result<()> {
        run_mc([
            "alias",
            "set",
            alias,
            self.endpoint.as_str(),
            self.access_key.as_str(),
            self.secret_key.as_str(),
        ])?;

        for bucket in self.buckets() {
            let target = format!("{alias}/{bucket}");
            run_mc(["mb", "--ignore-existing", target.as_str()])?;
        }

        Ok(())
    }
}

fn env_or(key: &str, default: &str) -> String {
    std::env::var(key).unwrap_or_else(|_| default.to_string())
}

fn run_mc<I, S>(args: I) -> Result<()>
where
    I: IntoIterator<Item = S>,
    S: AsRef<str>,
{
    let collected: Vec<String> = args
        .into_iter()
        .map(|arg| arg.as_ref().to_string())
        .collect();
    let status = Command::new("mc")
        .args(collected.iter().map(String::as_str))
        .status()
        .with_context(|| "failed to execute `mc`; install MinIO Client and ensure it is in PATH")?;

    if !status.success() {
        anyhow::bail!("mc {} failed with status {}", collected.join(" "), status);
    }

    Ok(())
}
