ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.getSharedObject, function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local vehicles = {}; RPWorking = true

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if Config.UseKey and Config.ToggleKey and IsPedInAnyVehicle(PlayerPedId()) and (GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId()) then
			if IsControlJustReleased(1, Config.ToggleKey) then
				TriggerEvent('EngineToggle:Engine')
			end
		end

		if GetSeatPedIsTryingToEnter(PlayerPedId()) == -1 and not table.contains(vehicles, GetVehiclePedIsTryingToEnter(PlayerPedId())) then
			table.insert(vehicles, {GetVehiclePedIsTryingToEnter(PlayerPedId()), IsVehicleEngineOn(GetVehiclePedIsTryingToEnter(PlayerPedId()))})
		elseif IsPedInAnyVehicle(PlayerPedId(), false) and not table.contains(vehicles, GetVehiclePedIsIn(PlayerPedId(), false)) then
			table.insert(vehicles, {GetVehiclePedIsIn(PlayerPedId(), false), IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false))})
		end
		
		for i, vehicle in ipairs(vehicles) do
			if DoesEntityExist(vehicle[1]) then
				if (GetPedInVehicleSeat(vehicle[1], -1) == PlayerPedId()) or IsVehicleSeatFree(vehicle[1], -1) then
					if RPWorking then
						SetVehicleEngineOn(vehicle[1], vehicle[2], false, false)
						SetVehicleJetEngineOn(vehicle[1], vehicle[2])
						if not IsPedInAnyVehicle(PlayerPedId(), false) or (IsPedInAnyVehicle(PlayerPedId(), false) and vehicle[1]~= GetVehiclePedIsIn(PlayerPedId(), false)) then
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
		if vehicle[1] == GetVehiclePedIsIn(PlayerPedId(), false) then
			veh = vehicle[1]
			StateIndex = i
		end
	end
	Citizen.Wait(0)

	local netTime = 15
    NetworkRequestControlOfEntity(veh)
    while not NetworkHasControlOfEntity(veh) and netTime > 0 do 
        NetworkRequestControlOfEntity(veh)
        Citizen.Wait(1)
        netTime = netTime -1
    end

	if Config.VehicleKeyChain and (GetResourceState("VehicleKeyChain") == "started") then
		local isVehicleOrKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(veh)

		if IsPedInAnyVehicle(PlayerPedId(), false) and isVehicleOrKeyOwner then
			if (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
				vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
				if vehicles[StateIndex][2] then
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['engine_start'])
				else
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['engine_stop'])
				end
			end 
		elseif IsPedInAnyVehicle(PlayerPedId(), false) and (not isVehicleOrKeyOwner) then
			Config.Notification(source, 'client', nil, Translation[Config.Locale]['key_nokey'])
    	end 
	else
		if IsPedInAnyVehicle(PlayerPedId(), false) then 
			if (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
				vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
				if vehicles[StateIndex][2] then
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['engine_start'])
				else
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['engine_stop'])
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
			if GetSeatPedIsTryingToEnter(PlayerPedId()) == -1 then
				for i, vehicle in ipairs(vehicles) do
					if vehicle[1] == GetVehiclePedIsTryingToEnter(PlayerPedId()) and not vehicle[2] then
						Citizen.Wait(0)
						vehicle[2] = true
						Config.Notification(source, 'client', nil, Translation[Config.Locale]['engine_onatenter'])
					end
				end
			end
		end
	end)
end

if Config.LockpickKey.enable then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if IsControlJustReleased(1, Config.LockpickKey.key) then
				TriggerServerEvent('EngineToggle:hasItem')
			end
		end
	end)
end

RegisterNetEvent('EngineToggle:hotwire')
AddEventHandler('EngineToggle:hotwire', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local animTime = Config.ProgessBar.time * 1000
	
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle
		local animation
		local chance = math.random(100)

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
			animation = {dict = Config.Animation.insideVehicle.dict, anim = Config.Animation.insideVehicle.anim}
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 2.0, 0, 71)
			animation = {dict = Config.Animation.outsideVehicle.dict, anim = Config.Animation.outsideVehicle.anim}
		end

		if DoesEntityExist(vehicle) then
			if chance <= Config.Probability.alarm then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end

			if not Config.Animation.InsideOutsideAnimation then
				TaskStartScenarioInPlace(playerPed, Config.Animation.InsideOutsideAnimation, 0, true)
				FreezeEntityPosition(playerPed, true)
			elseif Config.Animation.InsideOutsideAnimation then
				loadAnimDict(animation.dict)
				TaskPlayAnim(playerPed, animation.dict, animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
				FreezeEntityPosition(playerPed, true)
			end

			Citizen.CreateThread(function()
				if Config.ProgessBar.enable then
					Config.progressBar(animTime, Translation[Config.Locale]['hotwiring'])
				end
				Citizen.Wait(animTime)

				if chance <= Config.Probability.lockpick then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					FreezeEntityPosition(playerPed, false)
					ClearPedTasksImmediately(playerPed)
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['vehicle_unlocked'])
				else
					TriggerServerEvent('EngineToggle:delhotwire')
					FreezeEntityPosition(playerPed, false)
					ClearPedTasksImmediately(playerPed)
					Config.Notification(source, 'client', nil, Translation[Config.Locale]['hotwiring_failed'])
					return
				end

				Citizen.Wait(500)

				if GetVehicleDoorLockStatus(vehicle) == 1 then
					SetVehicleNeedsToBeHotwired(vehicle, true)
				else
					IsVehicleNeedsToBeHotwired(vehicle)
				end

				TaskEnterVehicle(playerPed, vehicle, 10.0, -1, 1.0, 1, 0)
				Citizen.Wait(5000)

				if (not DoesEntityExist(vehicle)) then
					return
				end

				if Config.VehicleKeyChain and (GetResourceState("VehicleKeyChain") == "started") then
					local vehicle2 = GetVehiclePedIsIn(playerPed, false)
					local plate = GetVehicleNumberPlateText(vehicle2)

					if Config.Probability.enableSearchKey then
						if chance <= Config.Probability.searchKey then
							TriggerServerEvent('EngineToggle:addcarkeys', plate)
						else
							Config.Notification(source, 'client', nil, Translation[Config.Locale]['hotwiring_notfoundkey'])
						end
					else
						TriggerServerEvent('EngineToggle:addcarkeys', plate)
					end

					Citizen.Wait(200)

					if Config.startEngine then
						TriggerEvent('EngineToggle:Engine')
					end
				else
					if Config.startEngine then
						TriggerEvent('EngineToggle:Engine')
					end
				end
			end)
		end
	end
end)

function table.contains(table, element)
	for _, value in pairs(table) do
		if value[1] == element then
			return true
		end
	end
	return false
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end