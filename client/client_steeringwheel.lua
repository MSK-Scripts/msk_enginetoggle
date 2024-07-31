----------------------------------------------------------------
-- Made by cmdde
----------------------------------------------------------------

if Config.SaveSteeringAngle then
	local pressed = 1 * 1000
	
	function isPedDriving()
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				return true
			end
		end

		return false
	end
	
	CreateThread(function()
		while true do
			local sleep = 200
			local playerPed = PlayerPedId()

			if isPedDriving() then 
				sleep = 0

				if IsControlJustPressed(0, Config.SaveAngleOnExit) then
					local vehicle = GetVehiclePedIsIn(playerPed, true)
					local steeringAngle = GetVehicleSteeringAngle(vehicle)
					pressed = 500

					while not IsControlJustReleased(0, Config.SaveAngleOnExit) do
						if Config.PerformanceVersion then 
							SetVehicleSteeringAngle(vehicle, steeringAngle)
						else
							local vehNetId = VehToNet(vehicle)

							if vehNetId then
								SetNetworkIdExistsOnAllMachines(vehNetId, true)
								TriggerServerEvent('msk_enginetoggle:async', vehNetId, steeringAngle)
							end
						end

						break
					end
				end
			end

			Wait(sleep)
		end
	end)
	
	RegisterNetEvent("msk_enginetoggle:syncanglesave")
	AddEventHandler("msk_enginetoggle:syncanglesave", function(vehNetId, steeringAngle)
		if not NetworkDoesEntityExistWithNetworkId(vehNetId) then return end
		local vehicle = NetToVeh(vehNetId)

		if DoesEntityExist(vehicle) then
			SetVehicleSteeringAngle(vehicle, steeringAngle)
		end
	end)
	
	if not Config.PerformanceVersion then
		CreateThread(function()
			local playerPed = PlayerPedId()
			local justDeleted  

			while true do
				Wait(500)

				if IsPedInAnyVehicle(playerPed, false) then
					local vehicle = GetVehiclePedIsIn(playerPed, true)
					local vehNetId = VehToNet(vehicle)

					if GetPedInVehicleSeat(vehicle, -1) == playerPed and not justDeleted and GetIsVehicleEngineRunning(vehicle) and vehNetId then
						TriggerServerEvent("msk_enginetoggle:angledelete", vehNetId)
						justDeleted = true
					end
				else
					justDeleted = false
				end
			end
		end)
	end
end