GetPedVehicleSeat = function(playerPed, vehicle)
	if not playerPed then playerPed = PlayerPedId() end
	if not vehicle then vehicle = currentVehicle and currentVehicle.vehicle or GetVehiclePedIsIn(playerPed) end
	if not vehicle or not DoesEntityExist(vehicle) then return end

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