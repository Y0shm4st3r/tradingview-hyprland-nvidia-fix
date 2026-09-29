#!/bin/sh
# Remove the TradingView XWayland workaround.
rm -f "$HOME/.local/bin/tradingview" "$HOME/.local/share/applications/tradingview.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
echo "Removed."
