#!/usr/bin/env bash

set -euo pipefail

# working dir independent
cd "$(git rev-parse --show-toplevel)"

gleam run -m lucide_lustre/add "$1" 

