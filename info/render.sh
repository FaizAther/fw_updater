#!/usr/bin/env bash
# Create venv (once), install deps, render .mmd → .png/.svg
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install -q --upgrade pip
python -m pip install -q -r requirements.txt
python -m playwright install chromium
python scripts/render_diagrams.py --all
