#!/bin/bash
set -e

SCHEME="OpenClawControliOS"
PROJECT="${SCHEME}.xcodeproj"
BUNDLE_ID="ai.openclaw.control"
DEVICE="name=iPhone 17"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData/OpenClawControliOS-gkmpdujpqaruzobkiwunuvlynief"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/OpenClaw.app"

echo "=== 1. Generate Xcode Project ==="
xcodegen generate

echo "=== 2. Clean ==="
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME"

echo "=== 3. Build ==="
xcodebuild build -project "$PROJECT" -scheme "$SCHEME" \
  -sdk iphonesimulator -destination "platform=iOS Simulator,$DEVICE"

echo "=== 4. Install & Launch ==="
SIM_ID=$(xcrun simctl list devices booted 2>/dev/null | grep -i "iPhone 17" | grep -oE '[A-F0-9-]{36}')
if [ -z "$SIM_ID" ]; then
  echo "No booted simulator found. Please start the simulator first."
  exit 1
fi

# Kill if running, then install & launch
xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$SIM_ID" "$APP_PATH"
xcrun simctl launch --console-pty "$SIM_ID" "$BUNDLE_ID"

echo "=== Done ==="
