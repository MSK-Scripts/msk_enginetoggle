# EngineToggle
 FiveM Script - Vehicle Engine Toggle On/Off

## Description
With Key "M" you can toggle your vehicle Engine on or off

Activate Notifications in config.lua to true if you want. If both set to false then Default ESX Notification is active. 

If you set Config.VehicleKeyChain to true then only the Owner of the Vehicle or someone with a Key can start the Engine!


## Config
```
-- Change 'false' to 'true' to toggle the engine automatically on when entering a vehicle
OnAtEnter = false

-- Change 'false' to 'true' to use a key instead of a button
UseKey = true

if UseKey then
	-- Change this to change the key to toggle the engine (Other Keys at wiki.fivem.net/wiki/Controls)
	ToggleKey = 244 -- 244 = M
end

Config = {}

-- If both false then Default ESX Notification is active!
Config.Notifications = false -- https://forum.cfx.re/t/release-standalone-notification-script/1464244
Config.OkokNotify = false -- https://okok.tebex.io/package/4724993

-- Vehicle Key System
Config.VehicleKeyChain = false -- https://kiminazes-script-gems.tebex.io/package/4524211
```

## Requirements
* ESX 1.2 (https://github.com/esx-framework/es_extended/releases/tag/v1-final)
### Optional
* Notification (https://forum.cfx.re/t/release-standalone-notification-script/1464244)
* okokNotify (https://okok.tebex.io/package/4724993)
* VehicleKeyChain (https://kiminazes-script-gems.tebex.io/package/4524211)
