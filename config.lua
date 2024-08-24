Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = false
Config.VersionChecker = true
----------------------------------------------------------------
-- If Standalone then you have to add your own code for the Hotwire Feature
-- You can use this Feature anyway
Config.Framework = 'ESX' -- 'ESX', 'QBCore' or 'Standalone'
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, typ)
    if IsDuplicityVersion() then -- serverside
        exports.msk_core:Notification(source, 'Engine', message, typ)
    else -- clientside
        exports.msk_core:Notification('Engine', message, typ)
    end
end
----------------------------------------------------------------
Config.Command = {
    enable = true, -- If you set to false then the Hotkey won't work !!!
    command = 'engine'
}

Config.Hotkey = {
    enable = true, -- Set false if you don't want to use a Hotkey
    key = 'M'
}

Config.AdminCommand = {
    enable = true, -- Start/Stop Engine if you don't have a key for that vehicle
    command = 'adengine',
    groups = {'superadmin', 'admin'}
}

Config.EngineOnAtEnter = false -- Set to true to toggle the engine automatically on when entering a vehicle

-- Set to true to start the engine from the second seat (Co-Driver)
-- Someone has to be on the Driver Seat, otherwise it won't work!
-- If VehicleKeys is activated, the Co-Driver needs a key.
Config.EngineFromSecondSeat = false
----------------------------------------------------------------
-- Vehicle Key System - set true then only the Owner of the Vehicle or someone with a Key can start the Engine
-- VehicleKeyChain: https://forum.cfx.re/t/release-vehicle-key-chain-v4-1-4-esx-qb/3319563
-- vehicle_keys: https://forum.cfx.re/t/esx-qbcore-vehicles-keys-vehicles-lock-remote-control-ui-and-much-more/4857274

Config.VehicleKeys = {
    enable = false, -- Set true to enable this feature

    -- Supported Scripts: 'VehicleKeyChain', 'vehicle_keys', 'okokGarage'
    script = 'VehicleKeyChain',

    -- This is for inventories with metadata like ox_inventory
    -- Supported Inventories: ox_inventory, qs-inventory, core_inventory
    inventory = 'ox_inventory',
    item = 'keys',
    plate = 'plate' -- Key Name for plate in your inventory for your vehicle keys script
}
----------------------------------------------------------------
Config.SaveSteeringAngle = true
Config.SaveAngleOnExit = 75 -- default: F - 75 (Exit Vehicle)
Config.PerformanceVersion = false -- true = no sync but more performance
Config.RefreshTime = 5 -- in seconds // Refreshing SteeringAngle all 5 seconds
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
        -- "MSK",
    },
}
----------------------------------------------------------------
Config.EnableLockpick = true -- Set false if you want to deactivate this feature

Config.progressBar = function(time, message)
    exports.msk_core:ProgressStart(time, message)
end

Config.LockpickHotkey = {
    enable = false, -- Set to true if you want to use a Hotkey
    command = 'lockpickvehicle',
    key = 'L'
}

Config.LockpickSettings = {
    item = 'lockpick', -- Set the item that you want to use
    removeItem = true, -- Set true if you like to remove item after failing lockpicking
    startEngine = true, -- Set true if you want to start the engine after successfull lockpicking
}

Config.Probability = {
    lockpick = 66, -- default: 66%
    alarm = 33, -- default: 33%
    enableSearchKey = true, -- Set false if you dont want this
    searchKey = 66 -- default: 66%
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
