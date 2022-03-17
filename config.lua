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