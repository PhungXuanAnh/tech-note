# SonarQube Setup Guide

**Current Version**: SonarQube 25.9.0.112764-community + Community Branch Plugin 25.9.0

**Access**: http://localhost:9000 (admin / Sona@1234567)

> 📖 **Detailed Documentation**:
> - Upgrade history: See `UPGRADE_TO_25.9_COMPLETE.md`
> - Container restart fix details: See `FIX_CONTAINER_RESTART_ISSUE.md`

## Quick Start

### 1. Start SonarQube

```bash
# Fix vm.max_map_count if needed (first time only)
sudo sysctl -w vm.max_map_count=262144

# Start services
make sonarqube-start
```

### 2. Generate Token

```bash
# Option A: Via API (fastest)
curl -s -u admin:Sona@1234567 -X POST \
  "http://localhost:9000/api/user_tokens/generate?name=viralize-scanner" \
  | jq -r '.token'

# Option B: Via UI
# 1. Login at http://localhost:9000
# 2. My Account → Security → Generate Token
```

### 3. Update Token

```bash
# Edit scan.env and replace TOKEN value
nano .vscode/local_files/sonarqube/scripts/scan.env
```

### 4. Scan Branch

```bash
cd /home/xuananh/work/viralize
./.vscode/local_files/sonarqube/scripts/scan_branch.sh
```

## Community Branch Plugin Setup

### Current Status
✅ SonarQube 25.9.0 + Plugin 25.9.0 with full branch support

### Components Required
1. **Backend JAR**: `sonarqube-community-branch-plugin-25.9.0.jar` in `plugins/` directory
2. **Frontend WebApp**: Modified webapp in `webapp/` directory (enables branch dropdown in UI)

### Installation (Already Done)

> 💡 These files are already installed. This section documents what was done during the upgrade.
> 
> **For upgrade history and detailed steps**, see `UPGRADE_TO_25.9_COMPLETE.md`

**Plugin JAR** (6.3 MB):
```bash
cd .vscode/local_files/sonarqube/plugins
# Download from: https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-community-branch-plugin-25.9.0.jar
```

**Modified WebApp** (30.1 MB extracted):
```bash
cd .vscode/local_files/sonarqube

# Download webapp (8.9 MB) from plugin release
curl -L -o sonarqube-webapp.zip \
  "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-webapp.zip"

# Extract to webapp directory
unzip -q sonarqube-webapp.zip -d webapp
```

**docker-compose.yml** configuration:
```yaml
environment:
  SONAR_WEB_JAVAADDITIONALOPTS: "-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-25.9.0.jar=web"
  SONAR_CE_JAVAADDITIONALOPTS: "-javaagent:/opt/sonarqube/extensions/plugins/sonarqube-community-branch-plugin-25.9.0.jar=ce"
volumes:
  - ./plugins:/opt/sonarqube/extensions/plugins
  - ./webapp:/opt/sonarqube/web  # Persists modified webapp
```

### Version Compatibility

| SonarQube Version | Plugin Version | Status |
|-------------------|----------------|---------|
| 25.9.x | 25.9.0 | ✅ Current |
| 25.8.x | 25.8.0 | ✅ Compatible |
| 10.6.x | 1.23.0 | ✅ Legacy |

**Rule**: Plugin major.minor version must match SonarQube version (e.g., Plugin 25.9.0 for SonarQube 25.9.x)

## Scanning

### Branch Scan (Full Analysis)
```bash
./.vscode/local_files/sonarqube/scripts/scan_branch.sh
```
- Scans entire codebase
- Enables branch comparison in UI
- Required for "New Code" tab to show differences

### Diff-Only Scan (Fast)
```bash
./.vscode/local_files/sonarqube/scripts/scan_diff_only.sh
```
- Scans only changed files vs master
- Quick feedback during development

### View Results
- **UI**: http://localhost:9000 → Select branch from dropdown → Click "New Code" tab
- **API**: `curl -u admin:Sona@1234567 "http://localhost:9000/api/project_branches/list?project=viralize"`

## Troubleshooting

> 🔧 **For detailed troubleshooting**, see:
> - Container restart issues: `FIX_CONTAINER_RESTART_ISSUE.md`
> - Upgrade-related issues: `UPGRADE_TO_25.9_COMPLETE.md`

### Container Start Fails

**Error**: "The version of SonarQube you are trying to upgrade from is too old"

**Cause**: Old database schema from previous version

**Fix**: Reset database and restart
```bash
cd .vscode/local_files/sonarqube
docker compose --project-name sona_viralize down -v  # Remove old data
make sonarqube-start  # Fresh start
```

### Branch Dropdown Missing in UI

**Symptoms**: API shows branches but UI doesn't show dropdown

**Cause**: Modified webapp not installed or lost

**Check**:
```bash
# Verify webapp files exist
ls -lh .vscode/local_files/sonarqube/webapp/

# Verify mounted in container
docker exec sona_viralize-sonarqube-1 ls -lh /opt/sonarqube/web/
```

**Fix**: If webapp missing, re-download and restart (see Installation section above)

### Plugin Not Loaded

**Check logs**:
```bash
docker logs sona_viralize-sonarqube-1 | grep "Community Branch"
# Expected: "Loaded core extensions: Community Branch Plugin"
```

**Fix**: Verify files exist and restart
```bash
ls -lh .vscode/local_files/sonarqube/plugins/sonarqube-community-branch-plugin-25.9.0.jar
docker compose --project-name sona_viralize restart sonarqube
```

### No New Code Differences Between Branches

**Cause**: New Code period not configured for branch comparison

**Fix**: Set reference branch
```bash
curl -u admin:Sona@1234567 -X POST \
  "http://localhost:9000/api/new_code_periods/set?project=viralize&branch=YOUR_BRANCH&type=REFERENCE_BRANCH&value=master"

# Re-scan branch
./.vscode/local_files/sonarqube/scripts/scan_branch.sh
```

## Container Management

```bash
# Start
make sonarqube-start

# Stop
cd .vscode/local_files/sonarqube
docker compose --project-name sona_viralize down

# Restart
docker compose --project-name sona_viralize restart sonarqube

# Logs
docker logs sona_viralize-sonarqube-1 --tail 50

# Status
curl http://localhost:9000/api/system/status
```

## References

- **Plugin Repository**: https://github.com/mc1arke/sonarqube-community-branch-plugin
- **Plugin Release 25.9.0**: https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/tag/25.9.0
- **Detailed Upgrade Log**: `UPGRADE_TO_25.9_COMPLETE.md`
- **Container Restart Fix**: `FIX_CONTAINER_RESTART_ISSUE.md`
    