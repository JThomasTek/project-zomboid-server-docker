# Project Zomboid Server Docker — Agent Instructions

## Purpose

A Docker image for running a dedicated [Project Zomboid](https://www.projectzomboid.com/) server. It downloads/updates the server via SteamCMD, manages configuration through environment variables, and auto-starts the server.

## Repo Layout

```
Dockerfile         — Image definition
bootstrap          — Entrypoint script (updates game, starts server)
.github/workflows/ — CI: builds and pushes images on release tags
.github/ISSUE_TEMPLATE/
README.md          — User documentation
LICENSE            — MIT
```

No source tree to compile. Changes are Dockerfile edits, entrypoint shell updates, or workflow tweaks.

## Environment Variables (Runtime)

| Variable | Default | Notes |
|---|---|---|
| `PZ_SERVER_NAME` | `MyPZServer` | Server browser name |
| `PZ_ADMIN_USERNAME` | `admin` | Admin login |
| `PZ_ADMIN_PASSWORD` | `InsecurePassword` | **Must be overridden at runtime** |
| `PZ_JAVA_XMS` | `4g` | JVM min heap |
| `PZ_JAVA_XMX` | `8g` | JVM max heap |
| `PZ_STEAM_VAC` | `true` | Valve Anti-Cheat toggle |

## Building & Running Locally

```bash
docker build -t project-zomboid-server .
mkdir -p ~/pz-server

docker run -d \
  --name pzserver \
  -p 8766:8766/udp \
  -p 16261-16262:16261-16262/udp \
  -v ~/pz-server:/home/ubuntu \
  -e PZ_ADMIN_PASSWORD="secure-pass" \
  project-zomboid-server
```

First run downloads the game via SteamCMD (slow). Subsequent runs are fast.

## How Changes Are Made

### Add/modify environment variable
1. Set default with `ENV` in `Dockerfile`
2. Use variable in `bootstrap` script
3. Document in `README.md` (environment variables table)
4. Document in `AGENTS.md` (this file)

### Change entrypoint behavior
Edit the `bootstrap` script. It runs as user `ubuntu` in `/home/ubuntu`. The server files are installed to `/home/ubuntu/pzserver` by SteamCMD (app ID 380870).

### Update base image or dependencies
Edit `Dockerfile` FROM line and/or `apt-get` packages. Rebuild and test.

## CI & Publishing

Triggered by GitHub Release tags matching `v*`.

```yaml
on:
  push:
    tags: ["v*"]
```

The workflow:
1. Builds the image
2. Pushes to `docker.io/jthomastek/project-zomboid-server:latest`
3. Pushes to `docker.io/jthomastek/project-zomboid-server:<tag>`
4. Pushes to `ghcr.io/jthomastek/project-zomboid-server:latest`
5. Pushes to `ghcr.io/jthomastek/project-zomboid-server:<tag>`

Auth uses `DOCKER_USERNAME`/`DOCKER_PASSWORD`/`GHCR_USERNAME`/`GHCR_PASSWORD` secrets.

## Testing Strategy

No automated test suite. Validate changes by:
1. Building the image locally
2. Running it with a volume mount
3. Checking server startup logs
4. Connecting a client to verify functionality

For entrypoint logic, add `set -x` temporarily or `echo` debug lines.

## Conventions

- Entrypoint script is bash, not a compiled language
- No package manager for Go/Node — keep deps minimal
- Dockerfile layers should cache efficiently (ENV early, COPY late)
- All runtime config via environment variables, not CLI args
- Documentation must be updated alongside functional changes

## Agent skills

### Issue tracker

Issues live in GitHub Issues on JThomasTek/project-zomboid-server-docker (uses `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical triage labels plus five wayfinder labels (all strings match names). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (one `GLOSSARY.md` + `docs/adr/` at the repo root). See `docs/agents/domain.md`.
