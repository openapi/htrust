use anyhow::Result;

use crate::storage::MinioConfig;

pub fn execute(sandbox: bool) -> Result<()> {
    let token_key = if sandbox {
        "OPENAPI_SANDBOX_TOKEN"
    } else {
        "OPENAPI_TOKEN"
    };
    let token_status = match std::env::var(token_key) {
        Ok(value) if !value.is_empty() => "set",
        _ => "missing",
    };

    let minio = MinioConfig::from_env();

    println!("htrust runtime");
    println!("  sandbox: {}", sandbox);
    println!("  token env: {} ({})", token_key, token_status);
    println!("  minio endpoint: {}", minio.endpoint);
    for bucket in minio.buckets() {
        println!("  bucket: {}", bucket);
    }

    Ok(())
}
