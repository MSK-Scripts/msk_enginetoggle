-- Change 'false' to 'true' to toggle the engine automatically on when entering a vehicle
OnAtEnter = false

-- Change 'false' to 'true' to use a key instead of a button
UseKey = true

if UseKey then
	ToggleKey = 244 -- 244 = M (https://docs.fivem.net/docs/game-references/controls/)
end

Config = {}

-- If both false then Default ESX Notification is active!
Config.Notifications = false -- https://forum.cfx.re/t/release-standalone-notification-script/1464244
Config.OkokNotify = false -- https://okok.tebex.io/package/4724993

-- Vehicle Key System
Config.VehicleKeyChain = false -- https://kiminazes-script-gems.tebex.io/package/4524211