# SonarQube Upgrade to 25.9.0 - COMPLETE ✅

**Date**: November 5-6, 2025

> 📖 **For daily usage**, see `Readme.md`  
> 🔧 **For container restart issue details**, see `FIX_CONTAINER_RESTART_ISSUE.md`

## Upgrade Summary

Successfully upgraded from SonarQube 10.6.0 to 25.9.0 with matching Community Branch Plugin!

### What Changed

| Component | Old Version | New Version |
|-----------|-------------|-------------|
| **SonarQube** | 10.6.0-community | **25.9.0.112764-community** |
| **Community Branch Plugin** | 1.23.0 | **25.9.0** |
| **WebApp (Frontend)** | Default | **Modified (with branch UI)** ✅ |
| **Status** | ✅ Running | ✅ Running |

### Files Modified

1. **docker-compose.yml**
   - Updated image: `sonarqube:25.9.0.112764-community`
   - Updated Java agent: `sonarqube-community-branch-plugin-25.9.0.jar`
   - **Added webapp volume mount**: `./webapp:/opt/sonarqube/web` ✅ **PERSISTED**

2. **plugins/ directory**
   - Removed: `sonarqube-community-branch-plugin-1.23.0.jar`
   - Added: `sonarqube-community-branch-plugin-25.9.0.jar` (6.3 MB)

3. **webapp/ directory** ✅ **NEW - PERSISTED**
   - Source: `sonarqube-webapp.zip` from [plugin release 25.9.0](https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-webapp.zip)
   - Size: 8.9 MB (zip) → 30.1 MB (extracted)
   - **Mounted to**: `/opt/sonarqube/web/` in container
   - **Why**: Required for branch dropdown to appear in UI
   - **Status**: ✅ Now persisted on host - survives container recreation

4. **Database**
   - Reset PostgreSQL volume (required for major version upgrade)
   - Fresh database with schema version compatible with 25.9.0

## Installation Steps Performed

### 1. Plugin JAR
```bash
cd .vscode/local_files/sonarqube/plugins
curl -L -o sonarqube-community-branch-plugin-25.9.0.jar \
  "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-community-branch-plugin-25.9.0.jar"
```

### 2. Modified WebApp
```bash
cd .vscode/local_files/sonarqube
curl -L -o sonarqube-webapp.zip \
  "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-webapp.zip"
unzip -q sonarqube-webapp.zip -d webapp
```

### 3. Docker Compose Configuration
Updated `docker-compose.yml` with:
- New image version
- Java agent paths
- WebApp volume mount

### 4. Database Reset
```bash
docker compose --project-name sona_viralize down -v
docker compose --project-name sona_viralize up -d
```

### 5. Initial Setup
- Changed admin password to `Sona@1234567`
- Generated new scanner token
- Updated `scan.env` with new token
- Scanned master and feature branches
- Configured New Code period for branch comparison

## Version Compatibility Reference

According to [sonarqube-community-branch-plugin documentation](https://github.com/mc1arke/sonarqube-community-branch-plugin):

> **The plugin major and minor versions match the SonarQube version it is compatible with**

| SonarQube Version | Plugin Version | Released |
|-------------------|----------------|----------|
| 25.9.x | 25.9.0 | Sep 2025 ✅ **Current** |
| 25.8.x | 25.8.0 | Sep 2025 |
| 25.7.x | 25.7.0 | Aug 2025 |
| 10.6.x | 1.23.0 | Dec 2024 (previous) |

## Verification Results

```bash
# SonarQube Status
curl -s "http://localhost:9000/api/system/status"
# {"id":"E3ADF47B-AZpXWFqVumioLuhjBG8m","version":"25.9.0.112764","status":"UP"}

# Plugin Loaded
docker logs sona_viralize-sonarqube-1 2>&1 | grep "Community Branch"
# "Loaded core extensions: Community Branch Plugin"
# "Deploy Community Branch Plugin / 25.9.0"

# Branches Registered
curl -s -u admin:Sona@1234567 "http://localhost:9000/api/project_branches/list?project=viralize"
# Shows: master, PLT-3946-CTV-Discovery-cache-time

# New Code Metrics Working
curl -s -u admin:Sona@1234567 \
  "http://localhost:9000/api/measures/component?component=viralize&branch=PLT-3946-CTV-Discovery-cache-time&metricKeys=new_lines"
# {"metric": "new_lines", "period": {"value": "33"}}
```

## What's New in SonarQube 25.9

Improvements from 10.6.0 to 25.9.0:
- Latest security fixes and bug patches
- Improved performance and analysis speed
- Better UI/UX with modern interface
- Enhanced branch analysis capabilities
- Latest language analyzer updates (Python, JavaScript, etc.)
- Improved quality gate and metrics reporting
- Better CI/CD integration

## Issues Encountered & Resolved

### 1. Slack Notifier Plugin Incompatibility (Nov 5)
- **Error**: `ClassNotFoundException: org.sonar.api.i18n.I18n`
- **Fix**: Removed `cks-slack-notifier-2.1.2.jar` (incompatible with SonarQube 25.x)

### 2. Branch Dropdown Missing in UI (Nov 5)
- **Cause**: Modified webapp component not installed
- **Fix**: Downloaded and extracted `sonarqube-webapp.zip` to `webapp/` directory

### 3. Container Restart Failed (Nov 6)
- **Error**: "The version of SonarQube you are trying to upgrade from is too old"
- **Cause**: Old database schema + webapp not persisted
- **Fix**: See `FIX_CONTAINER_RESTART_ISSUE.md` for detailed solution

### 4. No New Code Differences (Nov 6)
- **Cause**: New Code period set to PREVIOUS_VERSION instead of REFERENCE_BRANCH
- **Fix**: Changed to REFERENCE_BRANCH=master for feature branch

## Summary

✅ **Upgrade Complete**: SonarQube 25.9.0 + Plugin 25.9.0 running  
✅ **WebApp Persisted**: Survives container restarts via volume mount  
✅ **Branch Comparison**: Working with master as reference baseline  
✅ **New Code Metrics**: Computed correctly (33 new lines, 0 issues)

**System Status**: Production-ready for development team 🎉
