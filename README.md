# Daloshka Scoop bucket

Scoop manifest for [Librium](https://github.com/Daloshka/Librium) — a free, open-source
HTTP, HTTPS and WebSocket debugging proxy for Windows and macOS.

## Install

```powershell
scoop bucket add daloshka https://github.com/Daloshka/scoop-bucket
scoop install librium
```

Then run `librium` from any shell, or use the Librium shortcut in the Start menu.

## Update and uninstall

```powershell
scoop update librium
scoop uninstall librium
```

Librium keeps its CA certificate and its SQLite history in `%LOCALAPPDATA%\Librium`, and
its filter sessions, logs and the Chrome proxy profile in `%APPDATA%\librium-desktop`,
outside the Scoop app directory, so they survive updates and are left behind on
uninstall — delete both folders by hand for a clean slate. Set `LIBRIUM_DATA_DIR` to put
that data somewhere else, for example next to Scoop on a portable drive.

## What you get

A portable build: the manifest downloads `Librium.<version>.exe` from the GitHub release,
renames it to `Librium.exe`, registers a `librium` shim and a Start menu shortcut. The UI
listens on `http://127.0.0.1:3000` and the proxy on `127.0.0.1:8080`; `LIBRIUM_UI_PORT`
and `LIBRIUM_PROXY_PORT` change both. For HTTPS, install
`%LOCALAPPDATA%\Librium\ca.crt` into *Trusted Root Certification Authorities*.

## Maintaining

`checkver` is wired to the GitHub releases of Librium, so on Windows the usual Scoop
tooling works:

```powershell
scoop update                                   # users: picks up the new manifest
.\bin\checkver.ps1 -App librium -Dir C:\path\to\scoop-bucket\bucket -Update   # maintainers, from a Scoop checkout
```

From macOS or Linux use the script in this repo instead:

```sh
./update.sh 0.5.5
```

It downloads the release exe, computes its SHA-256, rewrites `version`, `url` and `hash`
in `bucket/librium.json` and prints the git commands to run. It never commits or pushes
by itself.

## License

MIT, same as Librium.
