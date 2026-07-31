#!/usr/bin/env bash
set -euo pipefail

GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
cd "$(dirname "$0")"

"$GODOT" --headless --path . --import >/dev/null
"$GODOT" --headless --path . res://tests/run_tests.tscn
