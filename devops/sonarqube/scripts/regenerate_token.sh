#!/bin/bash

# This script regenerates a SonarQube token and updates the configuration file

set -e

SONAR_URL="http://localhost:9000"
ADMIN_USER="admin"
ADMIN_PASS="${SONAR_ADMIN_PASSWORD:-admin}"
TOKEN_NAME="scanner-token"
ENV_FILE="${1:-.vscode/local_files/sona_scan.env}"

echo "Checking SonarQube connection..."
if ! curl -s -f "$SONAR_URL/api/system/status" > /dev/null; then
    echo "Error: Cannot connect to SonarQube at $SONAR_URL"
    echo "Make sure SonarQube is running (./sonarqube/scripts/start.sh)"
    exit 1
fi

# Create project if it doesn't exist
echo "Ensuring project 'viralize' exists..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$SONAR_URL/api/projects/create?project=viralize&name=viralize" > /dev/null 2>&1 || true

# Revoke old token if exists
echo "Revoking old token if exists..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$SONAR_URL/api/user_tokens/revoke?name=$TOKEN_NAME" > /dev/null 2>&1 || true

# Generate new token
echo "Generating new token..."
RESPONSE=$(curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$SONAR_URL/api/user_tokens/generate?name=$TOKEN_NAME")

NEW_TOKEN=$(echo "$RESPONSE" | jq -r '.token')

if [ -z "$NEW_TOKEN" ] || [ "$NEW_TOKEN" = "null" ]; then
    echo "Error: Failed to generate token"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "New token generated: $NEW_TOKEN"

# Update the environment file
if [ -f "$ENV_FILE" ]; then
    echo "Updating token in $ENV_FILE..."
    sed -i "s/^TOKEN=.*/TOKEN=$NEW_TOKEN/" "$ENV_FILE"
    echo "✅ Token updated successfully!"
    echo ""
    echo "Updated file content:"
    cat "$ENV_FILE"
else
    echo "Warning: Environment file not found at $ENV_FILE"
    echo "Please create it manually with:"
    echo ""
    echo "PROJECT_KEY=viralize"
    echo "SOURCE_DIR=viralize"
    echo "TOKEN=$NEW_TOKEN"
    echo "PYTHON_VERION=3.11"
fi
