# EngineToggle
FiveM Script - Vehicle Engine Toggle On/Off

**Forum:** https://forum.cfx.re/t/re-release-enginetoggle/4793840

**Discord Support:** https://discord.gg/5hHSBRHvJE

## Description
* The engine keeps running if you leave the vehicle without turning the engine off.
* You can set that the engine starts automatically when entering a vehicle.
* You can choose if you use a Hotkey or a Command.
* You can choose between 3 diffrent Notifications.
* If you set `Config.VehicleKeyChain` to true then only the Owner of the Vehicle or someone with a Key can start the Engine!
* Hotwire Function in compatibility with VKC

## Config
```lua
Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.getSharedObject = 'esx:getSharedObject'
----------------------------------------------------------------
-- Change 'false' to 'true' to toggle the engine automatically on when entering a vehicle
Config.OnAtEnter = false
----------------------------------------------------------------
Config.UseKey = true -- Set true if you want to use a Hotkey
    Config.ToggleKey = 244 -- M (https://docs.fivem.net/docs/game-references/controls/)
Config.UseCommand = false -- Set true if you want to use a Command
    Config.Commad = 'engine'
----------------------------------------------------------------
-- Vehicle Key System - set true then only the Owner of the Vehicle or someone with a Key can start the Engine
Config.VehicleKeyChain = false -- https://kiminazes-script-gems.tebex.io/package/4524211
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
-- Look for type == 'client' and type == 'server'
Config.Notification = function(src, type, xPlayer, message) -- xPlayer = ESX.GetPlayerFromId(src)
    if type == 'client' then -- clientside
        ESX.ShowNotification(message) -- replace this with your Notify // example: exports['okokNotify']:Alert('Crafting', message, 5000, 'info')
    elseif type == 'server' then -- serverside
        xPlayer.showNotification(message) -- replace this with your Notify // example: TriggerClientEvent('okokNotify:Alert', src, 'Crafting', message, 5000, 'info')
    end
end
----------------------------------------------------------------
Config.progressBar = function(time, message)
    exports['pogressBar']:drawBar(time, message)
end
----------------------------------------------------------------
Config.RemoveLockpickItem = true -- Set true if you like to remove item after failing lockpicking
Config.LockpickItem = 'lockpick' -- Set the itemname what you want to use
Config.startEngine = true -- Set true if you want to start the engine after successfull lockpicking
Config.Probability = {
    lockpick = 66, -- default: 66%
    alarm = 33, -- default: 33%
    enableSearchKey = true, -- Set false if you dont want this
    searchKey = 66 -- default: 66%
}
Config.LockpickKey = {
    enable = false, -- Set to true if you want to use a Hotkey
    key = 38 -- default: E // Set the Hotkey
}
Config.ProgessBar = {
    enable = true, -- Set true if you want to show a progressbar
    time = 8 -- In seconds // Time how long does it takes
}
Config.Animation = {
    InsideOutsideAnimation = true, -- Set to false if you want same Animation for inside and outside
    generalAnimation = 'WORLD_HUMAN_WELDING',
    
    insideVehicle = { -- Animation inside Vehicle
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer'
    },
    outsideVehicle = { -- Animation outside Vehicle
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer'
    }
}
```

## Requirements
* Standalone
* ESX Framework **only** for `Hotwire Function`
### Optional
* VehicleKeyChain (https://forum.cfx.re/t/release-vehicle-key-chain/3319563)
* ProgessBar (https://forum.cfx.re/t/release-pogress-bar-progress-bar-standalone-smooth-animation/838951)

### VehicleKeyChain
If you want to add a permanent key:
```lua
-- clientside --
local plate = GetVehicleNumberPlateText(vehicle)
-- Give a Key to the Player
exports["VehicleKeyChain"]:AddKey(PlayerId(), plate, 1)
-- Remove the Key from the Player
exports["VehicleKeyChain"]:RemoveKey(PlayerId(), plate, 1)

-- or this one

-- clientside --
-- Give a Key to the Player
local plate = 'ABC 123'
SetVehicleNumberPlateText(vehicle, plate) -- Only if you don't use AdvancedParking
exports["AdvancedParking"]:UpdatePlate(vehicle, plate) -- Only if you use AdvancedParking
exports["VehicleKeyChain"]:AddKey(PlayerId(), plate, 1)
-- Remove the Key from the Player
exports["VehicleKeyChain"]:RemoveKey(PlayerId(), plate, 1)
```
If you only want a temporary key that will be deleted after restart use this:
```lua
-- serverside --
RegisterNetEvent("VKC:giveTempKey")
AddEventHandler("VKC:giveTempKey", function(plate)
    exports["VehicleKeyChain"]:AddTempKey(source, plate)
end)

-- clientside --
TriggerServerEvent("VKC:giveTempKey", "PLATE")
```
### RealisticVehicleDamage
If you use `RealisticVehicleDamage`, then replace following Code in `client.lua` on Line 333 in RealisticVehicleDamage:
```lua
if healthEngineCurrent > cfg.engineSafeGuard+1 then
    SetVehicleUndriveable(vehicle,false)
    TriggerEvent('EngineToggle:RPDamage', true)
end

if healthEngineCurrent <= cfg.engineSafeGuard+1 and cfg.limpMode == false then
    SetVehicleUndriveable(vehicle,true)
    TriggerEvent('EngineToggle:RPDamage', false)
end
```

## My other Scripts
#### PAID
* [[ESX] Armor Script - Multiple Armor Vests](https://forum.cfx.re/t/release-esx-armor-script-usable-armor-vests-status-will-be-saved-in-database-and-restore-after-relog/4812243)
* [[ESX] Banking - NativeUI](https://forum.cfx.re/t/esx-msk-banking-nativeui/4859560)
* [[ESX] Handcuffs - Realistic Handcuffs](https://forum.cfx.re/t/esx-msk-handcuffs-realistic-handcuffs/4885324)
* [[ESX] Shopsystem - NativeUI & Database Feature](https://forum.cfx.re/t/release-esx-msk-shopsystem-nativeui-database-feature/4853593)
* [[ESX/QBCore] Simcard - Change your phonenumber](https://forum.cfx.re/t/release-esx-qbcore-usable-simcard/4847008)
* [[ESX] Weapon Ammunition with Clips, Components & Tints](https://forum.cfx.re/t/release-esx-weapon-ammunition-with-clips-components-tints/4793783)
#### FREE
* [[ESX] MSK Deathcounter - integrated in myMultichar](https://forum.cfx.re/t/release-esx-msk-deathcounter-integrated-in-mymultichar/4863428)

## License
**GNU General Public License v3.0**
