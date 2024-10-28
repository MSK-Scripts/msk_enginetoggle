if Config.SaveSteeringAngle then
	CreateThread(function()
		while true do
			local sleep = 500

			if isInVehicle and MSK.Player.seat == -1 then
				sleep = 1

				if IsControlJustPressed(0, Config.SaveAngleOnExit) then
					local vehicle = currentVehicle and currentVehicle.vehicle or MSK.Player.vehicle
					local steeringAngle = GetVehicleSteeringAngle(vehicle)

					while not IsControlJustReleased(0, Config.SaveAngleOnExit) do
						SetSteeringAngle(vehicle, steeringAngle)
						break
					end
				end
			end

			Wait(sleep)
		end
	end)
end

SetSteeringAngle = function(vehicle, angle)
	assert(vehicle and DoesEntityExist(vehicle), 'Parameter "vehicle" is nil or the Vehicle does not exist on function SetSteeringAngle')

	Entity(vehicle).state:set('SteeringAngle', angle, true)

	if angle and angle ~= 0.0 then
		SetVehicleSteeringAngle(vehicle, angle)
	end
end
exports('SetSteeringAngle', SetSteeringAngle)

GetSteeringAngle = function(vehicle)
	if not vehicle then vehicle = MSK.Player.vehicle end
	assert(vehicle and DoesEntityExist(vehicle), 'Parameter "vehicle" is nil or the Vehicle does not exist on function GetSteeringAngle')

	if Entity(vehicle).state.SteeringAngle == nil then
		SetSteeringAngle(vehicle, GetVehicleSteeringAngle(vehicle))
	end

	return Entity(vehicle).state.SteeringAngle
end
exports('GetSteeringAngle', GetSteeringAngle)