#!/usr/bin/env bash
#
# Install the full bd (beads) binary into bin/bd-real.
# The bin/bd wrapper will automatically delegate to it when present.
#
# This script handles the CGO build requirement and DNS workarounds
# needed in some container environments.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/bd-real"

if [[ -x "$TARGET" ]]; then
    echo "bd-real already installed: $("$TARGET" version)"
    exit 0
fi

echo "==> Installing bd (beads) binary..."

# Method 1: Try system bd
if command -v bd &>/dev/null; then
    echo "Found system bd: $(bd version)"
    exit 0
fi

# Method 2: Try go install (requires Go 1.25+ and ICU headers)
if command -v go &>/dev/null; then
    GO_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+')
    GO_MAJOR=$(echo "$GO_VERSION" | cut -d. -f1)
    GO_MINOR=$(echo "$GO_VERSION" | cut -d. -f2)

    if (( GO_MAJOR > 1 || (GO_MAJOR == 1 && GO_MINOR >= 25) )); then
        echo "==> Building from source with Go $GO_VERSION..."

        # Check for ICU headers
        if ! pkg-config --exists icu-uc 2>/dev/null; then
            echo "==> Installing ICU development headers..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -qq && sudo apt-get install -y -qq libicu-dev
            elif command -v brew &>/dev/null; then
                brew install icu4c
            else
                echo "Error: ICU headers required. Install libicu-dev (apt) or icu4c (brew)." >&2
                exit 1
            fi
        fi

        # DNS workaround for container environments
        if ! curl -fsS --connect-timeout 3 "https://storage.googleapis.com" -o /dev/null 2>/dev/null; then
            echo "==> Adding DNS entries for Go module proxy..."
            {
                echo "# Go module build dependencies (added by install-bd.sh)"
                echo "142.251.189.141 proxy.golang.org"
                echo "74.125.202.207 storage.googleapis.com"
                echo "74.125.132.102 cloud.google.com"
            } | sudo tee -a /etc/hosts >/dev/null
        fi

        GOBIN="$SCRIPT_DIR" CGO_ENABLED=1 GOPROXY=https://proxy.golang.org,direct \
            GONOSUMCHECK='*' GONOSUMDB='*' \
            go install github.com/steveyegge/beads/cmd/bd@latest

        # go install puts it at bin/bd, move to bd-real
        if [[ -x "$SCRIPT_DIR/bd" && ! -s "$TARGET" ]]; then
            # Check if the file at bin/bd is a binary (not our wrapper script)
            if file "$SCRIPT_DIR/bd" | grep -q "ELF"; then
                mv "$SCRIPT_DIR/bd" "$TARGET"
            fi
        fi

        if [[ -x "$TARGET" ]]; then
            echo "==> Installed: $("$TARGET" version)"

            # Import JSONL into database
            "$TARGET" import -i "$SCRIPT_DIR/../.beads/issues.jsonl" 2>/dev/null || true
            echo "==> Database initialized from JSONL"
            exit 0
        fi
    else
        echo "Go $GO_VERSION found, but 1.25+ required. Trying download..."
    fi
fi

# Method 3: Try downloading pre-built binary (won't have CGO, but worth trying)
echo "==> Downloading pre-built binary..."
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
[[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
[[ "$ARCH" == "aarch64" ]] && ARCH="arm64"

LATEST=$(curl -fsSL "https://api.github.com/repos/steveyegge/beads/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
URL="https://github.com/steveyegge/beads/releases/download/v${LATEST}/beads_${LATEST}_${OS}_${ARCH}.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "$URL" -o "$TMPDIR/beads.tar.gz"
tar xzf "$TMPDIR/beads.tar.gz" -C "$TMPDIR"
mv "$TMPDIR/bd" "$TARGET"
chmod +x "$TARGET"

echo "==> Installed: $("$TARGET" version)"
echo "Note: Pre-built binary may lack CGO/Dolt support. Use 'go install' for full features."
