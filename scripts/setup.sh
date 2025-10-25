#!/usr/bin/env bash

set -euo pipefail

# working dir independent
cd "$(git rev-parse --show-toplevel)"

echo "
Configuring Git hooks..."
git config core.hooksPath ./scripts/githooks
echo "Git hooks path configured."

echo "
Running tests to verify setup..."
./scripts/test.sh

echo "
Development environment setup complete!"
