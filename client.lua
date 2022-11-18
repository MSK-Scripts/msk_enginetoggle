if Config.Framework:match('ESX') then
	ESX = exports["es_extended"]:getSharedObject()
end

local vehicles = {}; RPWorking = true

CreateThread(function()
	while true do
		Wait(0)
		if Config.UseKey and Config.ToggleKey and IsPedInAnyVehicle(PlayerPedId()) and (GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId()) then
			if IsControlJustReleased(1, Config.ToggleKey) then
				TriggerEvent('msk_enginetoggle:Engine')
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

RegisterNetEvent('msk_enginetoggle:Engine')
AddEventHandler('msk_enginetoggle:Engine', function()
	local veh
	local StateIndex

	for i, vehicle in ipairs(vehicles) do
		if vehicle[1] == GetVehiclePedIsIn(PlayerPedId(), false) then
			-- sets the veh variable as the vehicle you're currently in
			veh = vehicle[1]
			StateIndex = i
			-- sets the state index = 1
		end
	end
	Wait(0)

	-- The below is simply to generate a timer for requesting control of entity
	local netTime = 15
    NetworkRequestControlOfEntity(veh)
    while not NetworkHasControlOfEntity(veh) and netTime > 0 do 
        NetworkRequestControlOfEntity(veh)
        Wait(1)
        netTime = netTime -1
    end

	if Config.VehicleKeyChain and (GetResourceState("VehicleKeyChain") == "started") then
		local isVehicle, isPlate = false, false
		local isVehicleOrKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(veh)

		for k, v in pairs(Config.Whitelist.vehicles) do 
			if GetHashKey(v) == GetEntityModel(veh) then
				isVehicle = true
			end
		end
		for k, v in pairs(Config.Whitelist.plates) do 
			if string.find(trim(tostring(GetVehicleNumberPlateText(veh))), v) then 
				isPlate = true
			end
		end

		if IsPedInAnyVehicle(PlayerPedId(), false) and (isVehicleOrKeyOwner or isVehicle or isPlate) then
			if (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
				vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
				if vehicles[StateIndex][2] then
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['engine_start'])
				else
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['engine_stop'])
				end
			end 
		elseif IsPedInAnyVehicle(PlayerPedId(), false) and (not isVehicleOrKeyOwner or not isVehicle or not isPlate) then
			Config.Notification(nil, 'client', nil, Translation[Config.Locale]['key_nokey'])
    	end 
	else
		if IsPedInAnyVehicle(PlayerPedId(), false) then 
			if (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
				vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
				if vehicles[StateIndex][2] then
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['engine_start'])
				else
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['engine_stop'])
				end
			end
		end
    end 
end)

RegisterNetEvent('msk_enginetoggle:RPDamage')
AddEventHandler('msk_enginetoggle:RPDamage', function(State)
	RPWorking = State
end)

if Config.OnAtEnter then
	CreateThread(function()
		while true do
			Wait(0)
			if GetSeatPedIsTryingToEnter(PlayerPedId()) == -1 then
				for i, vehicle in ipairs(vehicles) do
					if vehicle[1] == GetVehiclePedIsTryingToEnter(PlayerPedId()) and not vehicle[2] then
						Wait(0)
						vehicle[2] = true
						Config.Notification(nil, 'client', nil, Translation[Config.Locale]['engine_onatenter'])
					end
				end
			end
		end
	end)
end

if Config.enableLockpick and Config.LockpickKey.enable then
	CreateThread(function()
		while true do
			Wait(0)
			if IsControlJustReleased(1, Config.LockpickKey.key) then
				TriggerServerEvent('msk_enginetoggle:hasItem')
			end
		end
	end)
end

RegisterNetEvent('msk_enginetoggle:hotwire')
AddEventHandler('msk_enginetoggle:hotwire', function()
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

			CreateThread(function()
				if Config.ProgessBar.enable then
					Config.progressBar(animTime, Translation[Config.Locale]['hotwiring'])
				end
				Wait(animTime)

				if chance <= Config.Probability.lockpick then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					FreezeEntityPosition(playerPed, false)
					ClearPedTasksImmediately(playerPed)
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['vehicle_unlocked'])
				else
					TriggerServerEvent('msk_enginetoggle:delhotwire')
					FreezeEntityPosition(playerPed, false)
					ClearPedTasksImmediately(playerPed)
					Config.Notification(nil, 'client', nil, Translation[Config.Locale]['hotwiring_failed'])
					return
				end

				Wait(500)

				if GetVehicleDoorLockStatus(vehicle) == 1 then
					SetVehicleNeedsToBeHotwired(vehicle, true)
				else
					IsVehicleNeedsToBeHotwired(vehicle)
				end

				TaskEnterVehicle(playerPed, vehicle, 10.0, -1, 1.0, 1, 0)
				Wait(5000)

				if (not DoesEntityExist(vehicle)) then
					return
				end

				if Config.VehicleKeyChain and (GetResourceState("VehicleKeyChain") == "started") then
					local vehicle2 = GetVehiclePedIsIn(playerPed, false)
					local plate = GetVehicleNumberPlateText(vehicle2)

					if Config.Probability.enableSearchKey then
						if chance <= Config.Probability.searchKey then
							TriggerServerEvent('msk_enginetoggle:addcarkeys', plate)
						else
							Config.Notification(nil, 'client', nil, Translation[Config.Locale]['hotwiring_notfoundkey'])
						end
					else
						TriggerServerEvent('msk_enginetoggle:addcarkeys', plate)
					end

					Wait(200)

					if Config.startEngine then
						TriggerEvent('msk_enginetoggle:Engine')
					end
				else
					if Config.startEngine then
						TriggerEvent('msk_enginetoggle:Engine')
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
        Wait(5)
    end
end

function trim(str)
	return string.gsub(str, "%s+", "")
 end

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
