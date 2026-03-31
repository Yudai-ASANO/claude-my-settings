#!/usr/bin/env bash
# Desktop Notification — macOS notification when Claude stops
[[ "$(uname)" != "Darwin" ]] && exit 0

osascript -e 'display notification "Task completed" with title "Claude Code"' 2>/dev/null || true
