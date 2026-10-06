#!/usr/bin/env bash
# Release APK without a signing key: the Gradle build refuses to run otherwise
# (see the guard in android/app/build.gradle.kts), so the flag is set here.
#
# Run it under `systemd-run --user` rather than as a background child of a
# shell: the codex sandbox kills a command's process tree when the command
# returns, and a Gradle build outlives that by minutes.
set -euo pipefail

cd /home/wuli/telltale

export JAVA_HOME=/home/wuli/tools/jdk-17.0.2
export ANDROID_HOME=/home/wuli/tools/android-sdk
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ORG_GRADLE_PROJECT_allowUnsignedRelease=true
export PATH="$JAVA_HOME/bin:$PATH"

exec /home/wuli/tools/flutter347/bin/flutter --no-version-check build apk --release
