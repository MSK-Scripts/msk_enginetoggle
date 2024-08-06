getIsVehicleOrKeyOwner = function(vehicle)
    if not Config.VehicleKeys.enable then return true end
    local isVehicleOrKeyOwner, isVehicle, isPlate = false, false, false
    local canToggleEngine = true

    if Config.VehicleKeys.script == 'VehicleKeyChain' and (GetResourceState("VehicleKeyChain") == "started") then
        isVehicleOrKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(vehicle)
    elseif Config.VehicleKeys.script == 'vehicle_keys' and (GetResourceState("vehicle_keys") == "started") then
        isVehicleOrKeyOwner = exports["vehicle_keys"]:doesPlayerOwnPlate(GetVehicleNumberPlateText(vehicle))
    else
        if (GetResourceState(Config.VehicleKeys.script) == "started") then
            -- Add your own code here
            isVehicleOrKeyOwner = true
        end
    end

    for k, v in pairs(Config.Whitelist.vehicles) do 
        if GetHashKey(v) == GetEntityModel(vehicle) then
            isVehicle = true
            break
        end
    end

    for k, v in pairs(Config.Whitelist.plates) do 
        if string.find(trim(tostring(GetVehicleNumberPlateText(vehicle))), v) then 
            isPlate = true
            break
        end
    end

    if not isVehicleOrKeyOwner and not isVehicle and not isPlate then
        canToggleEngine = false
    end

    return canToggleEngine
end

trim = function(str)
	return string.gsub(str, "%s+", "")
end