#!/bin/bash

# This script scans both Python and JavaScript/React code in a single SonarQube scan
# It supports branch analysis with SonarQube Community Branch Plugin
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
echo "Scanning branch: $CURRENT_BRANCH with multi-language analysis enabled"
echo "Python source: viralize_web"
echo "JavaScript/React source: components/src"

# Build coverage paths parameter
COVERAGE_PATHS=""
if [ ! -z "$PYTHON_COVERAGE_PATH" ]; then
    COVERAGE_PATHS="$PYTHON_COVERAGE_PATH"
fi
if [ ! -z "$JS_COVERAGE_PATH" ]; then
    if [ ! -z "$COVERAGE_PATHS" ]; then
        COVERAGE_PATHS="$COVERAGE_PATHS,$JS_COVERAGE_PATH"
    else
        COVERAGE_PATHS="$JS_COVERAGE_PATH"
    fi
fi


s
# Run SonarQube scanner with multi-language support
# The sonar-project.properties file contains exclusion patterns
~/Downloads/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner \
    `# SonarQube server settings` \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token=$TOKEN \
    `# Git/Branch settings` \
    -Dsonar.branch.name=$CURRENT_BRANCH \
    -Dsonar.branch.target=master \
    -Dsonar.scm.revision="$(git rev-parse HEAD)"

echo ""
echo "Scan completed! View results at: http://localhost:9000/dashboard?id=$PROJECT_KEY&branch=$CURRENT_BRANCH"
