GetPedVehicleSeat = function(playerPed, vehicle)
	if not playerPed then playerPed = MSK.Player.ped end
	if not vehicle then vehicle = currentVehicle and currentVehicle.vehicle or MSK.Player.vehicle or GetVehiclePedIsIn(playerPed, false) end
	if not vehicle or not DoesEntityExist(vehicle) then return end

    if vehicle == MSK.Player.vehicle then
        return MSK.Player.seat
    end

    for i = -1, 16 do
        if (GetPedInVehicleSeat(vehicle, i) == playerPed) then 
			return i 
		end
    end	
    
    return -1
end

IsVehicleWhitelisted = function(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    for k, class in pairs(Config.Whitelist.classes) do
        if vehicleClass == class then
            return true
        end
    end

    local vehicleModel = GetEntityModel(vehicle)

    for k, model in pairs(Config.Whitelist.vehicles) do
        local modelHash = type(model) == 'number' and model or GetHashKey(model)

        if vehicleModel == modelHash then
            return true
        end
    end

    local vehiclePlate = GetVehicleNumberPlateText(vehicle)

    for k, plate in pairs(Config.Whitelist.plates) do 
        if string.find(MSK.String.Trim(vehiclePlate, true), MSK.String.Trim(plate, true)) then 
            return true
        end
    end
end

IsVehicleBlacklisted = function(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    for k, class in pairs(Config.Blacklist.classes) do
        if vehicleClass == class then
            return true
        end
    end

    local vehicleModel = GetEntityModel(vehicle)

    for k, model in pairs(Config.Blacklist.vehicles) do
        local modelHash = type(model) == 'number' and model or GetHashKey(model)

        if vehicleModel == modelHash then
            return true
        end
    end

    local vehiclePlate = GetVehicleNumberPlateText(vehicle)

    for k, plate in pairs(Config.Blacklist.plates) do 
        if string.find(MSK.String.Trim(vehiclePlate, true), MSK.String.Trim(plate, true)) then 
            return true
        end
    end
end

IsAnyWheelClamped = function(vehicle)
    if not Config.VehicleClamp or GetResourceState('VehicleClamp') ~= 'started' then 
        return false 
    end

    return exports["VehicleClamp"]:IsAnyWheelClamped(vehicle)
end