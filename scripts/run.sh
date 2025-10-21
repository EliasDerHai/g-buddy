#!/usr/bin/env bash

set -euo pipefail

# working dir independent
ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

watchexec --restart --watch src --exts gleam -- gleam run -m lustre/dev start
