----------------------------------------------------------------
-- Made by cmdde
----------------------------------------------------------------

if Config.SaveSteeringAngle then
	savedAngles = {}

	RegisterServerEvent("msk_enginetoggle:async", function(vehNetId, angle)
		savedAngles[vehNetId] = angle
		TriggerClientEvent("msk_enginetoggle:syncanglesave", -1, vehNetId, savedAngles[vehicle])
	end)

	RegisterServerEvent("msk_enginetoggle:angledelete", function(vehNetId)
		savedAngles[vehNetId] = nil
	end)

	CreateThread(function()
		while true do
			local sleep = Config.RefreshTime * 1000

			for i, data in pairs(savedAngles) do
				if savedAngles[i] then
					local vehicle = NetworkGetEntityFromNetworkId(i)

					if DoesEntityExist(vehicle) then
						TriggerClientEvent("msk_enginetoggle:syncanglesave", -1, i, savedAngles[i])
					else
						savedAngles[i] = nil
					end
				end
			end

			Wait(sleep)
		end
	end)
end