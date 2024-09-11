getInventory = function()
    if (GetResourceState("ox_inventory") == "started") then
        return 'ox_inventory'
    elseif (GetResourceState("qs-inventory") == "started") then
        return 'qs-inventory'
    elseif (GetResourceState("core_inventory") == "started") then
        return 'core_inventory'
    end
end

getKeyFromInventory = function(plate)
    plate = MSK.Trim(plate)

    if getInventory() == 'ox_inventory' then
        local inventory = exports.ox_inventory:GetPlayerItems()

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and MSK.Trim(v.metadata.plate or v.metadata.Plate or '') == plate then
                return true
            end
        end
    elseif getInventory() == 'qs-inventory' then
        local inventory = exports['qs-inventory']:getUserInventory()

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and MSK.Trim(v.info.plate or v.info.Plate or '') == plate then
                return true
            end
        end
    elseif getInventory() == 'core_inventory' then
        local inventory = MSK.Trigger('msk_enginetoggle:getInventory', 'core_inventory')

        for k, v in pairs(inventory) do
            if v.name == Config.VehicleKeys.item and MSK.Trim(v.metadata.plate or v.metadata.Plate or '') == plate then
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
        if Config.VehicleKeys.script == 'msk_vehiclekeys' and (GetResourceState("msk_vehiclekeys") == "started") then
            isKeyOwner = exports["msk_vehiclekeys"]:HasPlayerKeyOrIsVehicleOwner(vehicle)
        elseif Config.VehicleKeys.script == 'VehicleKeyChain' and (GetResourceState("VehicleKeyChain") == "started") then
            isKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(vehicle)
        elseif Config.VehicleKeys.script == 'vehicle_keys' and (GetResourceState("vehicle_keys") == "started") then
            isKeyOwner = exports["vehicle_keys"]:doesPlayerOwnPlate(plate)
        elseif Config.VehicleKeys.script == 'wasabi_carlock' and (GetResourceState("wasabi_carlock") == "started") then
            isKeyOwner = exports.wasabi_carlock:HasKey(plate)
        else
            -- Add your own code here
        end
    else
        isKeyOwner = getKeyFromInventory(plate)
    end

    for k, v in pairs(Config.Whitelist.vehicles) do 
        if GetEntityModel(vehicle) == IsModelValid(v) and v or GetHashKey(v) then
            ignoreVehicle = true
            break
        end
    end

    for k, v in pairs(Config.Whitelist.plates) do 
        if string.find(MSK.Trim(plate), MSK.Trim(v)) then 
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