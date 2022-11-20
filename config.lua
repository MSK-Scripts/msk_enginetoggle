Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
----------------------------------------------------------------
-- If Standalone then you have to change the Notification
Config.Framework = 'ESX' -- 'ESX' or 'Standalone'
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
Config.SaveSteeringAngle = true
Config.NeonToggle = false

Config.SaveAngleOnExit = 49 -- default: F - 49
Config.PerformanceVersion = false -- true = no sync but more performance
Config.RefreshTime = 5 -- in seconds // Refreshing SteeringAngle all 5 seconds

Config.NeonToggleHolding = 132 -- default: STRG - 132
Config.NeonToggleJustPressed = 249 -- default: N - 249
----------------------------------------------------------------
-- With this feature you can set vehicles and plates for which you don't need a key to start the engine
-- either exact plates or just a string that should be in the vehicles plate e.g. "ESX" will ignore te plate "ESX1234" too
Config.Whitelist = {
    vehicles = {
        -- "nero2",
        -- "zentorno",
    },
    plates = {
        -- "ESX",
        -- "ZOOM",
    },
}
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
-- Only possible with ESX Framework
Config.enableLockpick = true -- Set false if you want to deactivate this feature

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
