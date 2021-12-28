# EngineToggle
FiveM Script - Vehicle Engine Toggle On/Off

**Forum:** https://forum.cfx.re/t/re-release-enginetoggle/4793840

## Description
* The engine keeps running if you leave the vehicle without turning the engine off.
* You can set that the engine starts automatically when entering a vehicle.
* You can choose if you use a Hotkey or a Command.
* You can choose between 3 diffrent Notifications.
* If you set `Config.VehicleKeyChain` to true then only the Owner of the Vehicle or someone with a Key can start the Engine!

## Config
```
Config = {}

-- Change 'false' to 'true' to toggle the engine automatically on when entering a vehicle
Config.OnAtEnter = false

Config.UseKey = true
    Config.ToggleKey = 244 -- M (https://docs.fivem.net/docs/game-references/controls/)
Config.UseCommand = true
    Config.Commad = 'engine' -- If Config.UseKey = false then you can use the command instead

-- If both false then Default ESX Notification is active!
Config.Notifications = false -- https://forum.cfx.re/t/release-standalone-notification-script/1464244
Config.OkokNotify = false -- https://okok.tebex.io/package/4724993

-- Vehicle Key System - set true then only the Owner of the Vehicle or someone with a Key can start the Engine
Config.VehicleKeyChain = false -- https://kiminazes-script-gems.tebex.io/package/4524211
```

## Requirements
* Any Framework
### Optional
* Notification (https://forum.cfx.re/t/release-standalone-notification-script/1464244)
* okokNotify (https://okok.tebex.io/package/4724993)
* VehicleKeyChain (https://kiminazes-script-gems.tebex.io/package/4524211)

## License
**GNU General Public License v3.0**

You can use and edit this Script but please do not reupload this without tagging me
