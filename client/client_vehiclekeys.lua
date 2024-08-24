trim = function(str)
    return tostring(str):gsub("%s+", "")
end

getKeyFromInventory = function(plate)
    if Config.VehicleKeys.inventory == 'ox_inventory' then
        local inventory = exports.ox_inventory:GetPlayerItems()

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and trim(v.metadata[Config.VehicleKeys.plate]) == trim(plate) then
                return true
            end
        end
    elseif Config.VehicleKeys.inventory == 'qs-inventory' then
        local inventory = exports['qs-inventory']:getUserInventory()

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and trim(v.info[Config.VehicleKeys.plate]) == trim(plate) then
                return true
            end
        end
    elseif Config.VehicleKeys.inventory == 'core_inventory' then
        local p = promise.new()

        if Config.Framework == 'ESX' then
            ESX.TriggerServerCallback('core_inventory:server:getInventory', function(inventory)
                p:resolve(inventory)
            end)
        elseif Config.Framework == 'QBCore' then
            QBCore.Functions.TriggerCallback('core_inventory:server:getInventory', function(inventory)
                p:resolve(inventory)
            end)
        elseif Config.Framework == 'Standalone' then
            -- Add your own code here
        end

        local inventory = Citizen.Await(p)

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and trim(v.metadata[Config.VehicleKeys.plate]) == trim(plate) then
                return true
            end
        end
    else
        -- Add your own code here
    end

    return false
end
exports('getKeyFromInventory', getKeyFromInventory)

getIsKeyOwner = function(vehicle)
    if not Config.VehicleKeys.enable then return true end
    local isKeyOwner, ignoreVehicle, ignorePlate = false, false, false
    local plate = GetVehicleNumberPlateText(vehicle)
    local canToggleEngine = true

    if Config.VehicleKeys.script == 'VehicleKeyChain' and (GetResourceState("VehicleKeyChain") == "started") then
        isKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(vehicle)
    elseif Config.VehicleKeys.script == 'vehicle_keys' and (GetResourceState("vehicle_keys") == "started") then
        isKeyOwner = exports["vehicle_keys"]:doesPlayerOwnPlate(plate)
    elseif Config.VehicleKeys.script == 'okokGarage' and (GetResourceState("okokGarage") == "started") then
        isKeyOwner = getKeyFromInventory(plate)
    else
        -- Add your own code here
    end

    for k, v in pairs(Config.Whitelist.vehicles) do 
        if GetHashKey(v) == GetEntityModel(vehicle) then
            ignoreVehicle = true
            break
        end
    end

    for k, v in pairs(Config.Whitelist.plates) do 
        if string.find(trim(plate), trim(v)) then 
            ignorePlate = true
            break
        end
    end

    if not isKeyOwner and not ignoreVehicle and not ignorePlate then
        canToggleEngine = false
    end

    return canToggleEngine
end
exports('getIsKeyOwner', getIsKeyOwner)