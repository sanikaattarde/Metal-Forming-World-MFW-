#!/bin/sh
# SPIKE helper (DEC-003 is OPEN). Runs a command with the environment the local
# emulators need, without changing the shell profile or installing anything global.
#
#   sh scripts/run-with-env.sh firebase emulators:exec ...
#
# 1. Emulator downloads stay inside this folder's ignored node_modules, not in the
#    home directory (firebase-tools reads FIREBASE_EMULATORS_PATH).
# 2. The emulators need Java 21 or newer (firebase-tools 15.34.2). Homebrew's
#    openjdk@21 is keg-only and is not on PATH, so it is put first for this command only.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)

FIREBASE_EMULATORS_PATH="$here/node_modules/.cache/firebase-emulators"
export FIREBASE_EMULATORS_PATH
mkdir -p "$FIREBASE_EMULATORS_PATH"

if command -v brew >/dev/null 2>&1; then
  jdk=$(brew --prefix openjdk@21 2>/dev/null || true)
  if [ -n "$jdk" ] && [ -x "$jdk/bin/java" ]; then
    PATH="$jdk/bin:$PATH"
    export PATH
  fi
fi

NO_UPDATE_NOTIFIER=1
export NO_UPDATE_NOTIFIER

exec "$@"
