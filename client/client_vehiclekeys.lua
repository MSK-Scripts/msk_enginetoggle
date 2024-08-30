getInventory = function()
    if (GetResourceState("ox_inventory") == "started") then
        return 'ox_inventory'
    elseif (GetResourceState("qs-inventory") == "started") then
        return 'qs-inventory'
    elseif (GetResourceState("core_inventory") == "started") then
        return 'core_inventory'
    end
end

trim = function(str)
    return tostring(str):gsub("%s+", "")
end

getKeyFromInventory = function(plate)
    if getInventory() == 'ox_inventory' then
        local inventory = exports.ox_inventory:GetPlayerItems()

        for k, v in pairs(inventory) do
            if v.name == InventoryItem and trim(v.metadata[Config.VehicleKeys.plate]) == trim(plate) then
                return true
            end
        end
    elseif getInventory() == 'qs-inventory' then
        local inventory = exports['qs-inventory']:getUserInventory()

        for k, v in pairs(inventory) do
            if v.name == InventoryItem and trim(v.info[Config.VehicleKeys.plate]) == trim(plate) then
                return true
            end
        end
    elseif getInventory() == 'core_inventory' then
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
            if v.name == InventoryItem and trim(v.metadata[Config.VehicleKeys.plate]) == trim(plate) then
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

    if not Config.VehicleKeys.uniqueItems then
        if Config.VehicleKeys.script == 'VehicleKeyChain' and (GetResourceState("VehicleKeyChain") == "started") then
            isKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(vehicle)
        elseif Config.VehicleKeys.script == 'vehicle_keys' and (GetResourceState("vehicle_keys") == "started") then
            isKeyOwner = exports["vehicle_keys"]:doesPlayerOwnPlate(plate)
        else
            -- Add your own code here
        end
    else
        isKeyOwner = getKeyFromInventory(plate)
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