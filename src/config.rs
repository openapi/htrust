use anyhow::{Result, bail};

#[derive(Debug, Clone)]
pub struct Config {
    pub token: String,
    pub sandbox: bool,
}

impl Config {
    pub fn load(sandbox: bool) -> Result<Self> {
        let token = if sandbox {
            std::env::var("OPENAPI_SANDBOX_TOKEN").map_err(|_| {
                anyhow::anyhow!("OPENAPI_SANDBOX_TOKEN environment variable not set")
            })?
        } else {
            std::env::var("OPENAPI_TOKEN")
                .map_err(|_| anyhow::anyhow!("OPENAPI_TOKEN environment variable not set"))?
        };

        if token.is_empty() {
            bail!("Token cannot be empty");
        }

        Ok(Self { token, sandbox })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;
    use std::sync::Mutex;

    static ENV_LOCK: Mutex<()> = Mutex::new(());

    #[test]
    fn load_fails_when_production_token_is_missing() {
        let _lock = ENV_LOCK.lock().unwrap();
        unsafe {
            env::remove_var("OPENAPI_TOKEN");
            env::remove_var("OPENAPI_SANDBOX_TOKEN");
        }
        assert!(Config::load(false).is_err());
    }

    #[test]
    fn load_fails_when_sandbox_token_is_missing() {
        let _lock = ENV_LOCK.lock().unwrap();
        unsafe {
            env::remove_var("OPENAPI_TOKEN");
            env::remove_var("OPENAPI_SANDBOX_TOKEN");
        }
        assert!(Config::load(true).is_err());
    }

    #[test]
    fn load_fails_when_token_is_empty() {
        let _lock = ENV_LOCK.lock().unwrap();
        unsafe {
            env::set_var("OPENAPI_TOKEN", "");
        }
        assert!(Config::load(false).is_err());
    }

    #[test]
    fn load_succeeds_with_valid_token() {
        let _lock = ENV_LOCK.lock().unwrap();
        unsafe {
            env::set_var("OPENAPI_TOKEN", "test-token");
        }
        let config = Config::load(false).unwrap();
        assert_eq!(config.token, "test-token");
        assert!(!config.sandbox);
    }

    #[test]
    fn load_succeeds_with_valid_sandbox_token() {
        let _lock = ENV_LOCK.lock().unwrap();
        unsafe {
            env::set_var("OPENAPI_SANDBOX_TOKEN", "sandbox-token");
        }
        let config = Config::load(true).unwrap();
        assert_eq!(config.token, "sandbox-token");
        assert!(config.sandbox);
    }
}
