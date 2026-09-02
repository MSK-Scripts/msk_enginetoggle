# Pull Request

## Description

<!-- What does this PR change and why? -->

## Type of change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that changes existing behavior)
- [ ] Documentation update
- [ ] Translation

## Related issues

<!-- Link any related issues, e.g. Closes #123 -->

## Testing

<!-- How did you test this ingame? -->

- Framework(s) tested:
  - [ ] ESX
  - [ ] QBCore

- Vehicle key script tested (if relevant):
  - [ ] MSK VehicleKeys
  - [ ] VehicleKeyChain
  - [ ] vehicle_keys (Jaksam)
  - [ ] wasabi_carlock
  - [ ] qs-vehiclekeys
  - [ ] None

## Checklist

- [ ] My code follows the style of the existing codebase
- [ ] The change is framework-agnostic and goes through `MSK.*` instead of calling ESX or QBCore directly
- [ ] Every new client trigger is validated on the server (distance, ownership or key, cooldown)
- [ ] New config options default to the current behavior
- [ ] New ingame text was added to every language in `translation.lua`
- [ ] I updated `CHANGELOG.md` and the documentation if behavior, exports or config changed
