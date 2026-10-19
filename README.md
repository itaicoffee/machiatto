# Machiatto ☕︎

A one-click macOS menubar toggle that keeps your Mac awake.

- Click the cup icon in the menubar to **caffeinate** (prevents idle system sleep). The cup fills in.
- Click again to let the Mac sleep normally. The cup goes hollow and dims.
- Right-click for status and **Quit**.

Under the hood it holds an `IOPMAssertion` of type `PreventUserIdleSystemSleep`, the same thing `caffeinate -i` does. The display can still dim and lock; the machine just won't sleep. Quitting the app releases the assertion.

## Build & install

```sh
./build.sh --install
```

Builds `build/Machiatto.app` with `swiftc`, ad-hoc signs it, copies it to `/Applications`, and launches it. Requires Xcode command line tools.

To start it at login: System Settings → General → Login Items → add Machiatto.

## Layout

- `Sources/main.swift` — the whole app (AppKit status item + power assertion)
- `Info.plist` — bundle metadata (`LSUIElement` hides it from the Dock)
- `build.sh` — build / install script
