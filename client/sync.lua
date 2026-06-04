resolveEntityFromBag = function(bagName)
	local netId = tonumber(bagName:gsub('entity:', ''), 10)
	if not netId then return end

	local timeout = GetGameTimer() + 2000

	while GetGameTimer() < timeout do
		if NetworkDoesNetworkIdExist(netId) then
			local entity = NetworkGetEntityFromNetworkId(netId)

			if entity and entity ~= 0 and DoesEntityExist(entity) then
				return entity
			end
		end

		Wait(50)
	end
end

applyEngineState = function(vehicle, state)
	if not vehicle or not DoesEntityExist(vehicle) then return end

	SetVehicleUndriveable(vehicle, not state)
	SetVehicleKeepEngineOnWhenAbandoned(vehicle, state)
	SetVehicleEngineOn(vehicle, state, false, true)

	if state then
		SetVehicleSteeringAngle(vehicle, 0.0)
	end
end

AddStateBagChangeHandler('isEngineOn', nil, function(bagName, _, value)
	if value == nil then return end

	CreateThread(function()
		local vehicle = resolveEntityFromBag(bagName)
		if not vehicle then return end

		applyEngineState(vehicle, value)
	end)
end)

AddStateBagChangeHandler('SteeringAngle', nil, function(bagName, _, value)
	if value == nil or value == 0.0 then return end

	CreateThread(function()
		local vehicle = resolveEntityFromBag(bagName)
		if not vehicle then return end

		if not IsVehicleSeatFree(vehicle, -1) then return end
		if not IsThisModelACar(GetEntityModel(vehicle)) then return end

		SetVehicleSteeringAngle(vehicle, value)
	end)
end)

AddStateBagChangeHandler('isDamaged', nil, function(bagName, _, value)
	if not value then return end

	CreateThread(function()
		local vehicle = resolveEntityFromBag(bagName)
		if not vehicle then return end

		applyEngineState(vehicle, false)
	end)
end)
