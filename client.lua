 -- 
local pressed = 1 * 1000
local steeringAngle

function PedDriving()
playerPed = PlayerPedId()
	if IsPedSittingInAnyVehicle(playerPed) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			return true
		end
	end
	return false
end

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if PedDriving() and IsControlJustPressed(1,49) then
            
            steeringAngle = GetVehicleSteeringAngle(vehicle)
            pressed = 500
            while not IsControlJustReleased(1,Config.Key) do
            Citizen.Wait(10)
                if Config.lightMode then 
                    SetVehicleSteeringAngle(vehicle, steeringAngle)
                else
                    TriggerServerEvent('msk_enginetoggle:async', NetworkGetNetworkIdFromEntity(vehicle), steeringAngle)
                end
                break
            end
        end
    end
end)

RegisterNetEvent("msk_enginetoggle:syncanglesave")
AddEventHandler("msk_enginetoggle:syncanglesave", function(vehicleNetID, steeringAngle)
vehicle = NetworkGetEntityFromNetworkId(vehicleNetID)
    if DoesEntityExist(vehicle) then
        SetVehicleSteeringAngle(vehicle, steeringAngle)
    end
end)

Citizen.CreateThread(function()
    if Config.PerformanceVersion == false then
    playerPed = PlayerPedId()
    local justDeleted  
        while true do
            Citizen.Wait(500)
            if IsPedInAnyVehicle(playerPed, false) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetPedInVehicleSeat(vehicle, -1) == playerPed and justDeleted == false and GetIsVehicleEngineRunning(vehicle) then
	                TriggerServerEvent("msk_enginetoggle:angledelete", NetworkGetNetworkIdFromEntity(vehicle))
                    justDeleted = true
                end
            else
            justDeleted = false 
            end
        end
    end
end)

-- Neon Feature
local neonoff = false

Citizen.CreateThread(function()
    while true do
        Wait(10)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
	  local driver  = GetPedInVehicleSeat(vehicle, -1)
        local neonon = IsVehicleNeonLightEnabled(vehicle, 1)
		
        if IsPedInVehicle(playerPed,vehicle, true) and driver == playerPed then
            if IsControlPressed(1, 132) and IsControlJustPressed(1, 249) then
				if neonon then
					if neonoff == false then
						neonoff = true
						DisableVehicleNeonLights(vehicle, true)
						ESX.ShowNotification('an')
						Wait(2000)
					elseif neonoff == true then
						neonoff = false
						DisableVehicleNeonLights(vehicle, false)
						ESX.ShowNotification('aus')
						Wait(2000)
					end
				else
					ESX.ShowNotification('kein licht')
					Wait(2000)
				end
            end
        else
            Wait(1000)
        end
    end
end)
