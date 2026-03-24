# solfunmeme-introspector — eRDFa Stego Service

Solana transaction crawler → Fibonacci-tiered NFT series with steganographic data encoding, pastebin for team review, and wallet-signature claim system.

## What It Does

1. **Crawl** — Fetches all transactions for a token CA + author + interacting addresses via Solana RPC
2. **Rank** — Builds holder graph, ranks by tx count, assigns Fibonacci tiers (diamond/gold/silver/community)
3. **Encode** — Generates layered BitPlane6 stego NFT tiles per tier (diamond=100% data, gold=80%, silver=60%, community=40%)
4. **Serve** — HTTP server with pastebin + wallet claim endpoints

## Fibonacci Tier Boundaries

| Tier | Threshold | Data % |
|------|-----------|--------|
| Diamond | 100 | 100% |
| Gold | 500 | 80% |
| Silver | 1000 | 60% |
| Community | ∞ | 40% |

Higher tiers: fib-3=1500, fib-4=2500, fib-5=4000, fib-6=6500, fib-7=10500, ...

## Quick Start

Requires [erdfa-publish](https://github.com/meta-introspector/erdfa-publish) for the full build (Nix flake + Cargo workspace).

```bash
# Build
cd erdfa-publish
nix develop --command cargo build --release

# Crawl mainnet transactions
solfunmeme-service crawl --depth 1

# Rank holders and assign tiers
solfunmeme-service rank

# Generate NFT tile series
solfunmeme-service encode

# Start HTTP server
solfunmeme-service serve --bind 0.0.0.0:7780
```

## HTTP Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST /paste` | Submit txn data for team review |
| `GET /paste` | List all submissions |
| `GET /paste/<id>` | Get specific submission |
| `POST /claim` | Verify wallet signature → activate NFT |
| `GET /status` | Crawl state |
| `GET /tiers` | Fibonacci tier boundaries |

## Systemd

```bash
sudo cp sidechain/solfunmeme-*.service sidechain/solfunmeme-*.timer /etc/systemd/system/
sudo systemctl enable --now solfunmeme-service  # HTTP server on :7780
sudo systemctl enable --now solfunmeme-crawl.timer  # daily re-crawl
```

## Key Addresses

- **Token CA**: `BwUTq7fS6sfUmHDwAiCQZ3asSiPEapW5zDrsbwtapump`
- **Author**: `HMEKzpgzJEfyYyqoob5uGHR9P3LF6248zbm8tWgaApim`

## Architecture

```
src/ingest.rs          — Solana RPC crawler, holder graph, Fibonacci tiers,
                         NFT series generator, pastebin store, claim metadata
src/bin/solfunmeme_service.rs — CLI + HTTP service binary
sidechain/             — systemd unit files
```

Data stored in `~/.solfunmeme/` (state.json, nft-series/, pastebin/).

## Related

- [erdfa-publish](https://github.com/meta-introspector/erdfa-publish) — Full steganographic data availability layer
- PR #3 on upstream has Python introspector + Lean4 scaffolding + RPC cache

## License

GPL-3.0 (see LICENSE)
