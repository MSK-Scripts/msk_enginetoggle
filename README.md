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
----------------------------------------------------------------
-- Change 'false' to 'true' to toggle the engine automatically on when entering a vehicle
Config.OnAtEnter = false
----------------------------------------------------------------
Config.UseKey = true -- Set true if you want to use a Hotkey
    Config.ToggleKey = 244 -- M (https://docs.fivem.net/docs/game-references/controls/)
Config.UseCommand = false -- Set true if you want to use a Command
    Config.Commad = 'engine'
----------------------------------------------------------------
-- If both false then Default ESX Notification is active!
Config.Notifications = false -- https://forum.cfx.re/t/release-standalone-notification-script/1464244
Config.OkokNotify = true -- https://forum.cfx.re/t/okoknotify-standalone-paid/3907758
----------------------------------------------------------------
-- Vehicle Key System - set true then only the Owner of the Vehicle or someone with a Key can start the Engine
Config.VehicleKeyChain = false -- https://kiminazes-script-gems.tebex.io/package/4524211
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
* ESX Framework **only** for `ESX.ShowNotification`
### Optional
* Notification (https://forum.cfx.re/t/release-standalone-notification-script/1464244)
* okokNotify (https://forum.cfx.re/t/okoknotify-standalone-paid/3907758)
* VehicleKeyChain (https://forum.cfx.re/t/release-vehicle-key-chain/3319563)
* ProgessBar (https://forum.cfx.re/t/release-pogress-bar-progress-bar-standalone-smooth-animation/838951)

### VehicleKeyChain
If you want to add a permanent key:
```lua
-- clientside --
local numberPlate = GetVehicleNumberPlateText(vehicle)
-- Give a Key to the Player
exports["kimi_callbacks"]:Trigger("VKC:createNewKey", numberPlate, 1, true)
-- Remove the Key from the Player
exports["kimi_callbacks"]:Trigger("VKC:removeKey", numberPlate, 1)

-- or this one

-- clientside --
-- Give a Key to the Player
SetVehicleNumberPlateText(vehicle, 'PLATE_TEXT')
exports["kimi_callbacks"]:Trigger("VKC:createNewKey", 'PLATE_TEXT', 1, true)
-- Remove the Key from the Player
exports["kimi_callbacks"]:Trigger("VKC:removeKey", 'PLATE_TEXT', 1)
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

## License
**GNU General Public License v3.0**
