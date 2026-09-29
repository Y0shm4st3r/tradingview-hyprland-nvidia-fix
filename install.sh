#!/bin/sh
# Install the TradingView XWayland workaround for the current user.
set -e

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
SYSTEM_DESKTOP=/usr/share/applications/tradingview.desktop

if [ ! -x /usr/lib/tradingview/tradingview ]; then
    echo "TradingView not found at /usr/lib/tradingview/tradingview" >&2
    exit 1
fi

mkdir -p "$BIN_DIR" "$APP_DIR"
install -m 755 "$(dirname "$0")/bin/tradingview" "$BIN_DIR/tradingview"

if [ -f "$SYSTEM_DESKTOP" ]; then
    sed "s|^Exec=tradingview|Exec=$BIN_DIR/tradingview|" "$SYSTEM_DESKTOP" > "$APP_DIR/tradingview.desktop"
    update-desktop-database "$APP_DIR" 2>/dev/null || true
fi

echo "Installed. Restart TradingView."
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "Note: $BIN_DIR is not in your PATH; terminal launches will still use the unpatched binary." ;;
esac
