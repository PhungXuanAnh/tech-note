SonarQube Setup Guide
---

**Current Version**: SonarQube 25.9.0.112764-community + Community Branch Plugin 25.9.0
**Access**: http://localhost:9000 (admin / Sona@1234567)


# 1. Quick Start

```bash
~/repo/tech-note/devops/sonarqube/scripts/start.sh
```

# 2. Scanning

## 2.1. Update scan environment variables

```bash
cat scripts/scan.env.sample
# PROJECT_KEY=project_name  # create a new project in sona and set its name here
# SOURCE_DIR=source_code_directory   # source code folder that you want to scan
# TOKEN=squ_946f273e6da974677cf8f8a668fcce6059d0473b  # see next section to generate token
# PYTHON_VERION=3.11
```

Generate Token

```bash
# Option A: Via API (fastest)
# Without expiration:
curl -s -u admin:Sona@1234567 -X POST \
  "http://localhost:9000/api/user_tokens/generate?name=my-token&type=USER_TOKEN" \
  | jq -r '.token'

# Option B: Via UI
# 1. Login at http://localhost:9000
# 2. My Account → Security → Generate Token
```

## 2.2. Branch Scan (Full Analysis)
```bash
./scripts/scan_branch.sh path/to/scan.env
```
- Scans entire codebase
- Enables branch comparison in UI
- Required for "New Code" tab to show differences

## 2.3. Diff-Only Scan (Fast)
```bash
./scripts/scan_diff_only.sh path/to/scan.env
```
- Scans only changed files vs master
- Quick feedback during development

## 2.4. View Results
- **UI**: http://localhost:9000 → Select branch from dropdown → Click "New Code" tab
- **API**: `curl -u admin:Sona@1234567 "http://localhost:9000/api/project_branches/list?project=project_name"`

# 3. Community Branch Plugin Setup

## 3.2. Components Required
1. **Backend JAR**: `sonarqube-community-branch-plugin-25.9.0.jar` in `plugins/` directory
2. **Frontend WebApp**: Modified webapp in `webapp/` directory (enables branch dropdown in UI)

## 3.3. Installation Steps (Already Done)

> 💡 These files are already installed. This section documents what was done during the upgrade.
> 
> **For upgrade history and detailed steps**, see `UPGRADE_TO_25.9_COMPLETE.md`

**Download Plugin JAR**:
```bash
curl -L -o plugins/sonarqube-community-branch-plugin-25.9.0.jar \
https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-community-branch-plugin-25.9.0.jar
```

**Modified WebApp**:
```bash
cd .vscode/local_files/sonarqube
curl -L -o sonarqube-webapp.zip \
  "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/25.9.0/sonarqube-webapp.zip"
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

## 3.4. Version Compatibility

| SonarQube Version | Plugin Version | Status |
|-------------------|----------------|---------|
| 25.9.x | 25.9.0 | ✅ Current |
| 25.8.x | 25.8.0 | ✅ Compatible |
| 10.6.x | 1.23.0 | ✅ Legacy |

**Rule**: Plugin major.minor version must match SonarQube version (e.g., Plugin 25.9.0 for SonarQube 25.9.x)

## 4. Troubleshooting

> 🔧 **For detailed troubleshooting**, see:
> - Container restart issues: `FIX_CONTAINER_RESTART_ISSUE.md`
> - Upgrade-related issues: `UPGRADE_TO_25.9_COMPLETE.md`

### 4.2. Branch Dropdown Missing in UI

**Symptoms**: API shows branches but UI doesn't show dropdown

**Cause**: Modified webapp not installed or lost

**Check**:
```bash
# Verify webapp files exist
ls -lh webapp/
# Verify mounted in container
docker exec sonarqube ls -lh /opt/sonarqube/web/
```

**Fix**: If webapp missing, re-download and restart (see Installation section above)

### 4.3. Plugin Not Loaded

**Check logs**:
```bash
docker logs sonarqube | grep "Community Branch"
# Expected: "Loaded core extensions: Community Branch Plugin"
```

**Fix**: Verify files exist and restart
```bash
ls -lh plugins/sonarqube-community-branch-plugin-25.9.0.jar
docker compose restart sonarqube
```

### 4.4. No New Code Differences Between Branches

**Cause**: New Code period not configured for branch comparison

**Fix**: Set reference branch
```bash
curl -u admin:Sona@1234567 -X POST \
  "http://localhost:9000/api/new_code_periods/set?project=project_name&branch=YOUR_BRANCH&type=REFERENCE_BRANCH&value=master"

# Re-scan branch
./scripts/scan_branch.sh
```

# 5. References

- **Plugin Repository**: https://github.com/mc1arke/sonarqube-community-branch-plugin
- **Plugin Release 25.9.0**: https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/tag/25.9.0