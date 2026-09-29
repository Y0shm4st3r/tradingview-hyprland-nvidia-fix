# TradingView Desktop freeze fix (Hyprland + NVIDIA)

Workaround for the TradingView Desktop app (AUR package `tradingview`) freezing
when you open a new window on Hyprland with an NVIDIA GPU.

> **Credit:** Claude (Anthropic's AI assistant, running in Claude Code) found the
> cause and wrote this fix. I reported the problem, reproduced the freeze and
> tested the fix. The commits list Claude as co-author.

## Symptoms

- Opening another window (new chart window, detached tab, etc.) freezes the whole app.
- `pkill tradingview` doesn't close it; you have to run it twice or use `pkill -9`.
- The log in `~/.config/TradingView/logs/` may fill with thousands of
  `[WRN] Crash occured, sentry event id = ...` lines.

## Cause

TradingView 3.4.x ships Electron 41, which runs as native Wayland by default under
a Wayland compositor. With Hyprland and the NVIDIA driver, opening a second
window leaves the main Electron process's main thread stuck forever in
`futex_wait` (0 context switches while frozen). Closing the app cleanly needs
that same thread, so `SIGTERM` does nothing and only `SIGKILL` works.

The exact deadlock inside Electron/NVIDIA was not traced: `ptrace_scope=1` blocked
getting a stack trace. What we did confirm: the freeze happens under native
Wayland and does not happen under XWayland.

## Fix

Run TradingView under XWayland:

```sh
tradingview --ozone-platform=x11
```

This repo makes that permanent for your user, without touching package files, so
AUR updates don't overwrite it.

```sh
git clone https://github.com/Y0shm4st3r/tradingview-hyprland-nvidia-fix
cd tradingview-hyprland-nvidia-fix
./install.sh
```

It installs:

- `~/.local/bin/tradingview`: a wrapper that adds `--ozone-platform=x11`
  (used from the terminal if `~/.local/bin` comes before `/usr/bin` in `PATH`).
- `~/.local/share/applications/tradingview.desktop`: a copy of the system desktop
  entry that runs the wrapper (used by app launchers and `tradingview://` links).

Undo with `./uninstall.sh`.

## Trade-off

Under XWayland, fractional scaling can make text look a little blurry.

## Tested on

| Component   | Version                        |
|-------------|--------------------------------|
| tradingview | 3.4.1-1 (Electron 41.7.1)      |
| Hyprland    | 0.56.2                         |
| NVIDIA      | 615.71.09, RTX 3070 Ti         |
| Kernel      | 7.2.6-1-cachyos                |

If it works (or doesn't) on your setup, open an issue with your versions.
