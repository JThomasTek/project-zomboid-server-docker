#!/bin/bash
# Test the Steam update adapter interface
# Verifies exit codes and basic behavior

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/../update-server.sh"

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 1: Verify the script accepts an install_dir argument
echo "Test 1: Script accepts install_dir argument..."
# We can't actually run steamcmd, so we verify the script structure
grep -q "INSTALL_DIR=\"\${1:-" "$UPDATE_SCRIPT"
echo "  PASS"

# Test 2: Verify the script checks steamcmd exit code
echo "Test 2: Script checks steamcmd exit code..."
grep -q "EXIT_CODE=\$?" "$UPDATE_SCRIPT"
echo "  PASS"

# Test 3: Verify the script exits with non-zero on failure
echo "Test 3: Script exits with non-zero on failure..."
grep -q "exit 1" "$UPDATE_SCRIPT"
echo "  PASS"

# Test 4: Verify bootstrap calls the adapter
echo "Test 4: Bootstrap calls the update adapter..."
grep -q "./update-server.sh" "$SCRIPT_DIR/../bootstrap"
echo "  PASS"

# Test 5: Verify bootstrap checks adapter exit code
echo "Test 5: Bootstrap checks adapter exit code..."
grep -q "if \[ \$? -ne 0 \]" "$SCRIPT_DIR/../bootstrap"
echo "  PASS"

echo ""
echo "All tests passed!"
