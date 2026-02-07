#!/bin/bash

# Only run in remote environments
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

echo "Installing Maven dependencies for remote execution..."

# Navigate to the backend directory
cd back || exit 1

# Check if Maven is available
if ! command -v mvn &> /dev/null; then
  echo "Error: Maven is not installed or not in PATH"
  exit 1
fi

# Install dependencies
echo "Running: mvn dependency:resolve"
mvn dependency:resolve -q

if [ $? -eq 0 ]; then
  echo "Maven dependencies installed successfully"
else
  echo "Warning: Maven dependency installation encountered issues"
fi
