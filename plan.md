# Project Zomboid Server Docker - Improvement Plan

## Context & Requirements

This plan outlines the improvements for the Project Zomboid server Docker image based on user preferences:

- **Backup destination:** Local/NAS storage focus
- **Idle monitoring:** RCON-based approach preferred
- **Base image:** Switch to `ubuntu:24.04-slim` but with separate Dockerfile to reduce risk
- **Implementation priority:** Following the order below

---

## Implementation Priority Order

### Phase 1 - Quick Wins (High Impact, Low Effort)

**1.1 Create `.dockerignore`**
- Exclude `.git`, `README.md`, `*.md`, logs, temporary files
- Keep only essential runtime files

**1.2 Add Healthcheck**
- Use RCON or simple TCP check on server port
- Example: `HEALTHCHECK --interval=30s --timeout=10s CMD nc -z localhost 8766 || exit 1`

**1.3 Optimize Dockerfile layers**
- Reorder: base image + env vars first (rarely change)
- Then apt installs
- Then COPY bootstrap (changes most often)
- This maximizes Docker cache reuse

**1.4 Clean unnecessary files**
- Remove man pages: `rm -rf /usr/share/doc /usr/share/man /usr/share/locale/*`
- Keep only necessary locales

---

### Phase 2 - Enhanced Backups (Local/NAS Focus)

**2.1 Add backup verification**
- Generate SHA256 checksum after each backup
- Store checksum alongside backup: `pz_backup_YYYYMMDD_HHMMSS.tar.gz.sha256`
- Optional: verify on restore

**2.2 Add compression options**
- Support `gzip` (current) and `zstd` (better ratio/speed)
- Add `PZ_BACKUP_COMPRESSION=gzip|zstd` environment variable

**2.3 Add backup metadata**
- Store backup info: timestamp, size, compression type, checksum
- JSON format: `pz_backup_YYYYMMDD_HHMMSS.info.json`

**2.4 Disk usage based cleanup**
- Add `PZ_BACKUP_MAX_SIZE` (e.g., "10G", "50G")
- Clean oldest backups when total backup size exceeds limit

**2.5 Restore functionality**
- Add `restore_backup.sh` script
- CLI: `restore_backup.sh <backup_file>`
- Restore from latest automatically if no arg provided

---

### Phase 3 - RCON-based Idle Monitoring

**3.1 Implementation Strategy**
- Sidecar approach: Keep main container as-is, add optional idle-monitor container
- OR: Enhanced bootstrap with optional monitoring thread
- **Recommend:** Enhanced bootstrap (simpler, single container)

**3.2 Features**
- `PZ_IDLE_TIMEOUT` (default: 0 = disabled)
- `PZ_IDLE_CHECK_INTERVAL` (default: 60s)
- Check player count every interval via RCON
- Graceful shutdown if no players for timeout duration
- Log idle state changes

**3.3 RCON Integration**
- Leverage existing RCON configuration from server
- Add RCON client check in bootstrap
- Handle RCON connection failures gracefully

**3.4 Safety features**
- Minimum uptime requirement (don't stop if server up < 5 minutes)
- Configurable grace period
- "Do not disturb" window (e.g., don't stop between 8PM-8AM)

---

### Phase 4 - Separate Dockerfile for ubuntu:24.04-slim

**4.1 Create `Dockerfile.slim`**
- Keep original `Dockerfile` unchanged
- Create `Dockerfile.slim` with slim base
- Add to CI/CD workflow as separate build target

**4.2 Test strategy**
- Build both versions
- Compare sizes
- Test same workloads on both
- Document differences in README

---

## Questions for Clarification

Before implementation, these questions need answers:

### Q1: RCON Details
- Should the idle monitor reuse the existing RCON configuration from `Server/MyPZServer.ini`?
- Or require separate `RCON_HOST`, `RCON_PORT`, `RCON_PASSWORD` environment variables?

### Q2: Backup Storage
- For NAS/local storage, should I add support for mounting backup directory separately?
- Example: `PZ_BACKUP_MOUNT` to allow backups to go to different volume than server data?

### Q3: Idle Monitoring Triggers
- What player count threshold should trigger the idle timer?
- Options: `0` (no players), `1` (last player disconnected), or configurable?

### Q4: Backup Compression Performance
- zstd is faster/better but adds ~5MB to image size
- Should I make compression tool selection configurable via environment variable, or hardcode one option?

### Q5: Docker Compose Examples
- Should I add example Compose files showing:
  - Basic setup (current)
  - With backups enabled
  - With idle timeout enabled
  - With separate backup volume

---

## Current State Analysis

### Files Examined:
- `/Dockerfile` - 66 lines
- `/bootstrap` - 59 lines
- `/README.md` - 183 lines
- CI/CD workflows in `.github/workflows/`

### Current Features:
- Ubuntu 24.04 base image
- SteamCMD for server installation
- Backup functionality (basic tar.gz)
- Environment variable configuration
- RCON support (configured via server ini files)

### Known Limitations:
- No healthcheck instruction
- No `.dockerignore` file
- Basic backup with no verification
- No compression options
- No idle timeout functionality
- No restore capability

---

## Planned Changes Summary

| Feature | Status | Priority |
|---------|--------|----------|
| .dockerignore | Phase 1 | High |
| Healthcheck | Phase 1 | High |
| Dockerfile optimization | Phase 1 | High |
| Clean unnecessary files | Phase 1 | High |
| Backup checksums | Phase 2 | Medium |
| Compression options | Phase 2 | Medium |
| Backup metadata | Phase 2 | Medium |
| Disk usage cleanup | Phase 2 | Medium |
| Restore script | Phase 2 | Medium |
| Idle monitoring | Phase 3 | Medium |
| Slim Dockerfile | Phase 4 | Low |

---

## Next Steps

1. Wait for answers to 5 clarifying questions
2. Implement Phase 1 changes
3. Implement Phase 2 changes
4. Implement Phase 3 changes
5. Create and test Slim Dockerfile
6. Update documentation
7. Update CI/CD workflows for new features

---

## Additional Considerations

### Security
- Use non-root user (ubuntu) - already implemented ✓
- Scan for vulnerabilities with trivy/snyk
- Add `--read-only` support for runtime
- Security best practices documentation

### Reliability
- Add signal handling for graceful shutdown (partially implemented)
- Add restart policies documentation
- Add startup verification

### Documentation
- Add example for healthcheck
- Document idle timeout feature
- Add troubleshooting section
- Add performance tuning recommendations

### Multi-architecture
- Already supported in CI/CD - good! ✓

---

*Last Updated: 2026-02-06*
