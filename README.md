# MSK EngineToggle
Vehicle Engine Toggle On/Off

![GitHub release (latest by date)](https://img.shields.io/github/v/release/Musiker15/msk_enginetoggle?color=gree&label=Update)

**Forum:** https://forum.cfx.re/t/msk-enginetoggle-toggle-engine-on-off/4793840

**Discord Support:** https://discord.gg/5hHSBRHvJE

## Description
* The engine keeps running if you leave the vehicle without turning the engine off.
* You can set that the engine starts automatically when entering a vehicle.
* You can set a Command and Hotkey *(RegisterKeyMapping)*.
* Set your own Notification and Progressbar.
* If you set `Config.VehicleKeys` to true then only the Owner of the Vehicle or someone with a Key can start the Engine!
* Admin Command to start/stop the engine without a Key *(Bypass)*
* Whitelist for models and plates that do not need a Key to start/stop the engine
* Save the Angel of the Steering Wheel *(Synced)*
* Hotwire Function in compatibility with VehicleKeyChain and Jaksams vehicle_keys

## Resmon
Resmon without any near vehicles
![Screenshot_17](https://github.com/user-attachments/assets/b20c7aac-45f4-41c8-b0ab-1fd54e98f9a4)

Resmon with near vehicles and engines on
![Screenshot_16](https://github.com/user-attachments/assets/e5fe6e23-a90d-4dfc-9f6f-34792f9d9c29)


## Requirements
* No Requirements needed
### Optional
* [ESX Legacy](https://github.com/esx-framework/esx_core)
* [QBCore](https://github.com/qbcore-framework/qb-core)
* [MSK Core](https://github.com/MSK-Scripts/msk_core)
* [VehicleKeyChain](https://forum.cfx.re/t/release-vehicle-key-chain-v4-1-4-esx-qb/3319563)
* [vehicle_keys](https://forum.cfx.re/t/esx-qbcore-vehicles-keys-vehicles-lock-remote-control-ui-and-much-more/4857274)

## Exports
All exports are CLIENTSIDE. Look at the [Documentation](https://docu.msk-scripts.de/enginetoggle) for more information.
* toggleEngine -> Toggles the engine on/off
* toggleHotwire -> Starts the Hotwire Feature
* GetEngineState -> Get the current Enginestate of the vehicle
* SetVehicleDamaged -> Set the vehicle undrivable (Can't start/stop engine)
* GetVehicleDamaged -> Get the vehicle is undrivable

### RealisticVehicleDamage
If you use `RealisticVehicleDamage`, then replace following Code in `client.lua` on Line 333 in RealisticVehicleDamage:
```lua
if healthEngineCurrent > cfg.engineSafeGuard+1 then
    SetVehicleUndriveable(vehicle, false)
    exports.msk_enginetoggle:SetVehicleDamaged(vehicle, false)
end

if healthEngineCurrent <= cfg.engineSafeGuard+1 and cfg.limpMode == false then
    SetVehicleUndriveable(vehicle, true)
    exports.msk_enginetoggle:SetVehicleDamaged(vehicle, true)
end
```

### QB-Vehiclefailure
If you use `qb-vehiclefailure`, then replace the following Code in `client.lua` on Line 530 in qb-vehiclefailure:
```lua
if healthEngineCurrent > cfg.engineSafeGuard+1 then
    SetVehicleUndriveable(vehicle, false)
    exports.msk_enginetoggle:SetVehicleDamaged(vehicle, false)
end

if healthEngineCurrent <= cfg.engineSafeGuard+1 and cfg.limpMode == false then
    local vehpos = GetEntityCoords(vehicle)
    StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", vehpos.x, vehpos.y, vehpos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    SetVehicleUndriveable(vehicle, true)
    exports.msk_enginetoggle:SetVehicleDamaged(vehicle, true)
end
```

## My other Scripts
### Paid
* [[ESX] MSK Armor - Multiple Armor Vests](https://forum.cfx.re/t/release-esx-armor-script-usable-armor-vests-status-will-be-saved-in-database-and-restore-after-relog/4812243)
* [[ESX] MSK Banking - Advanced Banking  with NativeUI](https://forum.cfx.re/t/esx-msk-bankingsystem-with-nativeui/4859560)
* [[ESX] MSK Garage - Garage & Impounds](https://forum.cfx.re/t/esx-msk-garage-and-impound/5122014)
* [[ESX] MSK Handcuffs - Realistic Handcuffs](https://forum.cfx.re/t/esx-msk-handcuffs-realistic-handcuffs/4885324)
* [[ESX/QBCore] MSK Radio - Channels with password](https://forum.cfx.re/t/esx-msk-radio/5237033)
* [[ESX/QBCore] MSK Simcard - Change your phonenumber](https://forum.cfx.re/t/release-esx-qbcore-usable-simcard/4847008)
* [[ESX] MSK Storage](https://forum.cfx.re/t/esx-msk-storage/5252155)
* [[ESX] MSK WeaponAmmo - Clips, Components & Tints](https://forum.cfx.re/t/release-esx-weapon-ammunition-with-clips-components-tints/4793783)

### Free
* [MSK Scripts Repositories](https://github.com/MSK-Scripts)
* [Musiker15's Repositories](https://github.com/Musiker15)
