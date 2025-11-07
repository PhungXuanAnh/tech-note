#!/bin/bash

# This script scans the current branch and enables branch analysis with SonarQube Community Branch Plugin
# It will show the full analysis of the current branch (not just diff, but enables branch comparison in UI)

# Get script directory and project root
PROJECT_ROOT="$(pwd)"

# Load environment variables from script directory
ENV_FILE=$1
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | xargs)
else
    echo "Error: scan.env file not found at $ENV_FILE"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT" || exit 1

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository!"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Project root: $PROJECT_ROOT"
echo "Scanning branch: $CURRENT_BRANCH with branch analysis enabled"

~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    -Dsonar.projectKey=$PROJECT_KEY \
    -Dsonar.sources=$SOURCE_DIR \
    -Dsonar.inclusions="**/*.py" \
    -Dsonar.exclusions=".tests/**,**/tests/**,**/migrations/**,**/whitelabels/**,**/.git/**,**/.vscode/**,**/__pycache__/**,**/*.css,**/*.js,**/node_modules/**" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    -Dsonar.python.version=3.11 \
    -Dsonar.branch.name=$CURRENT_BRANCH \
    -Dsonar.branch.target=master \
    -Dsonar.scm.provider=git \
    -Dsonar.scm.revision=$(git rev-parse HEAD) \
    -Dsonar.python.coverage.reportPaths=coverage.xml
