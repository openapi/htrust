# htrust

Open Source Trust for Humans.

`htrust` is a Rust CLI for Linux sysadmins, shell scripts, and agentic tooling that need to check whether real-world information can be trusted before acting on it.

The interface is intentionally flat: one command per claim type, one positional value to check, JSON on stdout.

## Initial commands

```bash
htrust info
htrust mobile +393331234567
htrust mobile +393331234567 --detail
htrust email info@example.com
htrust ip 8.8.8.8
htrust url https://example.com
```

`--detail` selects the richer endpoint where the underlying API exposes both a base and an advanced check.

## Environment

```bash
export OPENAPI_TOKEN=your-production-token
export OPENAPI_SANDBOX_TOKEN=your-sandbox-token
```

## Scope

This first cut still wraps the current `trust.openapi.com` subset already available in `openapi-cli`:

- `mobile-start`
- `mobile-advanced`
- `email-start`
- `email-advanced`
- `ip-advanced`
- `url-advanced`

The long-term shape can expand to commands like `htrust iban ...` or `htrust vat ...`, but those endpoints are not wired in this first baseline yet.
