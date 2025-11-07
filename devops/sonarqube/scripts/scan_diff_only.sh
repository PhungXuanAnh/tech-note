#!/bin/bash

# This script scans only the changed files (diff) in the current branch compared to master
# It uses the SonarQube Community Branch Plugin to enable branch analysis

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# Load environment variables from script directory
ENV_FILE="$SCRIPT_DIR/scan.env"
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
    exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get list of changed files compared to master
CHANGED_FILES=$(git diff --name-only origin/master...HEAD | grep "\.py$" | tr '\n' ',')

if [ -z "$CHANGED_FILES" ]; then
    echo "No Python files changed compared to master branch."
    exit 0
fi

echo "Project root: $PROJECT_ROOT"
echo "Scanning changed files in branch: $CURRENT_BRANCH"
echo "Changed files: $CHANGED_FILES"

~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    -Dsonar.projectKey=$PROJECT_KEY \
    -Dsonar.sources=$SOURCE_DIR \
    -Dsonar.inclusions="**/*.py" \
    -Dsonar.exclusions="**/tests/**, **/migrations/**,  **/whitelabels/**, **/.*/**, **/*.css, **/*.js" \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    -Dsonar.python.version=3.11 \
    -Dsonar.branch.name=$CURRENT_BRANCH \
    -Dsonar.branch.target=master \
    -Dsonar.scm.provider=git
