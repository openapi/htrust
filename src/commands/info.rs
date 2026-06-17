use anyhow::Result;

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

    println!("htrust runtime");
    println!("  sandbox: {}", sandbox);
    println!("  token env: {} ({})", token_key, token_status);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn info_runs_without_environment_tokens() {
        // info does not depend on env vars; just verify it returns Ok.
        assert!(execute(false).is_ok());
        assert!(execute(true).is_ok());
    }
}