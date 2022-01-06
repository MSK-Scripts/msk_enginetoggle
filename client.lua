local vehicles = {}; RPWorking = true

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if Config.UseKey and Config.ToggleKey then
			if IsControlJustReleased(1, Config.ToggleKey) then
				TriggerEvent('EngineToggle:Engine')
			end
		end
		if GetSeatPedIsTryingToEnter(GetPlayerPed(-1)) == -1 and not table.contains(vehicles, GetVehiclePedIsTryingToEnter(GetPlayerPed(-1))) then
			table.insert(vehicles, {GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)), IsVehicleEngineOn(GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)))})
		elseif IsPedInAnyVehicle(GetPlayerPed(-1), false) and not table.contains(vehicles, GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
			table.insert(vehicles, {GetVehiclePedIsIn(GetPlayerPed(-1), false), IsVehicleEngineOn(GetVehiclePedIsIn(GetPlayerPed(-1), false))})
		end
		for i, vehicle in ipairs(vehicles) do
			if DoesEntityExist(vehicle[1]) then
				if (GetPedInVehicleSeat(vehicle[1], -1) == GetPlayerPed(-1)) or IsVehicleSeatFree(vehicle[1], -1) then
					if RPWorking then
						SetVehicleEngineOn(vehicle[1], vehicle[2], true, false)
						SetVehicleJetEngineOn(vehicle[1], vehicle[2])
						if not IsPedInAnyVehicle(GetPlayerPed(-1), false) or (IsPedInAnyVehicle(GetPlayerPed(-1), false) and vehicle[1]~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
							if IsThisModelAHeli(GetEntityModel(vehicle[1])) or IsThisModelAPlane(GetEntityModel(vehicle[1])) then
								if vehicle[2] then
									SetHeliBladesFullSpeed(vehicle[1])
								end
							end
						end
					end
				end
			else
				table.remove(vehicles, i)
			end
		end
	end
end)

RegisterNetEvent('EngineToggle:Engine')
AddEventHandler('EngineToggle:Engine', function()
	local veh
	local StateIndex
	for i, vehicle in ipairs(vehicles) do
		if vehicle[1] == GetVehiclePedIsIn(GetPlayerPed(-1), false) then
			veh = vehicle[1]
			StateIndex = i
		end
	end
	Citizen.Wait(0)
	if Config.VehicleKeyChain then
		local isVehicleOrKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(veh)
		if IsPedInAnyVehicle(GetPlayerPed(-1), false) and isVehicleOrKeyOwner then 
			if (GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1)) then
				vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
				if vehicles[StateIndex][2] then
					if Config.Notifications then
						TriggerEvent('notifications', "#00EE00", _U('notification_header'), _U('n_engine_start'))
					elseif Config.OkokNotify then
						exports['okokNotify']:Alert(_U('notification_header'), _U('okok_engine_start'), 5000, 'info')
					else
						TriggerEvent('esx:showNotification', _U('engine_start'))
					end
				else
					if Config.Notifications then
						TriggerEvent('notifications', "#FF0000", _U('notification_header'), _U('n_engine_stop'))
					elseif Config.OkokNotify then
						exports['okokNotify']:Alert(_U('notification_header'), _U('okok_engine_stop'), 5000, 'info')
					else
						TriggerEvent('esx:showNotification', _U('engine_stop'))
					end
				end
			end 
		elseif (not isVehicleOrKeyOwner) then
			if Config.Notifications then
				TriggerEvent('notifications', "#FF0000", _U('notification_header'), _U('n_key_noey'))
			elseif Config.OkokNotify then
				exports['okokNotify']:Alert(_U('notification_header'), _U('okok_key_noey'), 5000, 'error')
			else
				TriggerEvent('esx:showNotification', _U('key_noey'))
			end
    	end 
	elseif IsPedInAnyVehicle(GetPlayerPed(-1), false) then 
		if (GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1)) then
			vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
			if vehicles[StateIndex][2] then
				if Config.Notifications then
					TriggerEvent('notifications', "#00EE00", _U('notification_header'), _U('n_engine_start'))
				elseif Config.OkokNotify then
					exports['okokNotify']:Alert(_U('notification_header'), _U('okok_engine_start'), 5000, 'info')
				else
					TriggerEvent('esx:showNotification', _U('engine_start'))
				end
			else
				if Config.Notifications then
					TriggerEvent('notifications', "#FF0000", _U('notification_header'), _U('n_engine_stop'))
				elseif Config.OkokNotify then
					exports['okokNotify']:Alert(_U('notification_header'), _U('okok_engine_stop'), 5000, 'info')
				else
					TriggerEvent('esx:showNotification', _U('engine_stop'))
				end
			end
		end 
    end 
end)

RegisterNetEvent('EngineToggle:RPDamage')
AddEventHandler('EngineToggle:RPDamage', function(State)
	RPWorking = State
end)

if Config.OnAtEnter then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if GetSeatPedIsTryingToEnter(GetPlayerPed(-1)) == -1 then
				for i, vehicle in ipairs(vehicles) do
					if vehicle[1] == GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) and not vehicle[2] then
						Citizen.Wait(0)
						vehicle[2] = true
						if Config.Notifications then
							TriggerEvent('notifications', "#00EE00", _U('notification_header'), _U('n_engine_onatenter'))
						elseif Config.OkokNotify then
							exports['okokNotify']:Alert(_U('notification_header'), _U('okok_engine_onatenter'), 5000, 'warning')
						else
							TriggerEvent('esx:showNotification', _U('engine_onatenter'))
						end
					end
				end
			end
		end
	end)
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value[1] == element then
      return true
    end
  end
  return false
end
