# htrust

Open Source Trust for Humans.

`htrust` is a Rust CLI for Linux sysadmins, shell scripts, and agentic tooling that need to check whether real-world information can be trusted before acting on it.

The first cut is intentionally small:

- reuse the `trust.openapi.com` subset from `openapi-cli`
- expose a clean CLI surface for automation
- support `verify` and `check` as synonyms, plus `v` and `c`
- prepare MinIO bucket conventions for claims, evidence, assessments, and artifacts
- keep the local `openapi-cli` checkout out of Git

## Initial commands

```bash
htrust info
htrust verify mobile --phone +393331234567
htrust check mobile --phone +393331234567 --level advanced
htrust v email --email info@example.com
htrust c ip --ip 8.8.8.8
htrust verify url --url https://example.com
htrust minio info
htrust minio init
```

## Environment

```bash
export OPENAPI_TOKEN=your-production-token
export OPENAPI_SANDBOX_TOKEN=your-sandbox-token
export HTRUST_MINIO_ENDPOINT=http://127.0.0.1:9000
export HTRUST_MINIO_ACCESS_KEY=minioadmin
export HTRUST_MINIO_SECRET_KEY=minioadmin
```

## MinIO layout

- `htrust-claims`: incoming claims to verify
- `htrust-evidence`: raw evidence collected during verification
- `htrust-assessments`: normalized trust outputs
- `htrust-artifacts`: reports and exported files

`htrust minio init` uses the `mc` client already available on the system to create the required buckets.
