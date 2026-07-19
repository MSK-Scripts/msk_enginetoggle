if Config.SaveSteeringAngle then
	CreateThread(function()
		while true do
			local sleep = 500

			if isInVehicle and MSK.Player.seat == -1 then
				sleep = 1

				if IsControlJustPressed(0, Config.SaveAngleOnExit) then
					local vehicle = currentVehicle and currentVehicle.vehicle or MSK.Player.vehicle
					local steeringAngle = GetVehicleSteeringAngle(vehicle)

					SetSteeringAngle(vehicle, steeringAngle)
				end
			end

			Wait(sleep)
		end
	end)
end

SetSteeringAngle = function(vehicle, angle)
	if not vehicle or not DoesEntityExist(vehicle) then return end

	Entity(vehicle).state:set('SteeringAngle', angle, true)

	if angle and angle ~= 0.0 then
		SetVehicleSteeringAngle(vehicle, angle)
	end
end
exports('SetSteeringAngle', SetSteeringAngle)

GetSteeringAngle = function(vehicle)
	if not vehicle then vehicle = MSK.Player.vehicle end
	if not vehicle or not DoesEntityExist(vehicle) then return end

	if Entity(vehicle).state.SteeringAngle == nil then
		SetSteeringAngle(vehicle, GetVehicleSteeringAngle(vehicle))
	end

	return Entity(vehicle).state.SteeringAngle
end
exports('GetSteeringAngle', GetSteeringAngle)