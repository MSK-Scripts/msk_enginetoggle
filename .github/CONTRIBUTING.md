# Contributing to MSK EngineToggle

Thanks for taking the time to contribute. MSK EngineToggle handles engine state,
vehicle keys and hotwiring on live servers, so a small change can have a big
effect on gameplay. This guide explains how to report issues, suggest features,
and open pull requests.

## Ways to contribute

* **Report a bug** using the bug report issue template.
* **Request a feature** using the feature request issue template.
* **Improve the docs** at [docu.msk-scripts.de](https://docu.msk-scripts.de/docs/msk_enginetoggle/).
* **Add a translation** in `translation.lua`.
* **Open a pull request** with a fix or a new feature.

If you just have a question or want to discuss an idea first, join the
[MSK Scripts Discord](https://discord.gg/5hHSBRHvJE).

## Before you start

* **Lua 5.4** is required, the resource sets `lua54 'yes'`.
* The script supports **ESX and QBCore** through the
  [msk_core](https://github.com/MSK-Scripts/msk_core) bridge. Keep new code
  framework-agnostic and go through `MSK.*` instead of calling ESX or QBCore
  directly.
* Required dependencies are `oxmysql`, `ox_lib` and `msk_core`.
* **Server-side validation is mandatory.** Anything a client can trigger has to
  be checked on the server: distance to the vehicle, ownership or key
  possession, cooldowns, and every value that ends up in the database. Never
  trust client input, and never send data to a client that it does not need.

## Project layout

```
msk_enginetoggle/
├── config.lua          settings, commands, hotkeys, vehicle key options
├── translation.lua     all languages for ingame texts
├── client/
│   ├── main.lua          engine toggle, commands, hotkey
│   ├── hotwire.lua       hotwire and lockpicking
│   ├── steeringwheel.lua steering angle saving and syncing
│   ├── sync.lua          state syncing between clients
│   ├── utils.lua         helpers
│   └── vehiclekeys.lua   adapters for the supported key scripts
└── server/
    ├── main.lua          events, validation, database
    ├── hotwire.lua       serverside hotwire checks and alerts
    └── versionchecker.lua
```

New key script support belongs in `client/vehiclekeys.lua` next to the existing
adapters. Please do not add a new dependency for it, keep the adapter optional
so servers without that script are unaffected.

## Pull request checklist

1. Fork the repo and create a branch from `main`.
2. Keep your change focused. One feature or fix per pull request.
3. Match the existing code style (naming, indentation, comment density).
4. Test ingame on at least one framework, ideally ESX or QBCore.
5. New client events must be validated on the server. New config options need a
   sensible default that keeps the current behavior.
6. If you added or changed ingame text, add it to every language in
   `translation.lua`.
7. Update `CHANGELOG.md` and the documentation if behavior, exports or config
   changed. Bump the version in `fxmanifest.lua` only if asked to, the release
   workflow reacts to that.
8. Fill out the pull request template.

## Reporting security issues

Please do not open public issues for security vulnerabilities. See
[SECURITY.md](SECURITY.md) for how to report them privately.

## License

By contributing, you agree that your contributions will be licensed under the
project's **LGPL-3.0-or-later** license. See [LICENSE](../LICENSE).
