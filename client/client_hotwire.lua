if Config.EnableLockpick and Config.LockpickHotkey.enable then
	RegisterCommand(Config.LockpickHotkey.command, function(source, args, rawCommand)
		TriggerServerEvent('msk_enginetoggle:hasItem')

        if Config.Framework == 'ESX' then
            ESX = exports["es_extended"]:getSharedObject()

            ESX.TriggerServerCallback('msk_enginetoggle:hasItem', function(hasItem)
                if not hasItem then
                    return Config.Notification(nil, Translation[Config.Locale]['hasno_lockpick'], 'error')
                end

                toggleHotwire()
            end, Config.LockpickSettings.item)
        elseif Config.Framework == 'QBCore' then
            QBCore = exports['qb-core']:GetCoreObject()

            QBCore.Functions.TriggerCallback('msk_enginetoggle:hasItem', function(hasItem)
                if not hasItem then
                    return Config.Notification(nil, Translation[Config.Locale]['hasno_lockpick'], 'error')
                end

                toggleHotwire()
            end, Config.LockpickSettings.item)
        elseif Config.Framework == 'Standalone' then
            -- Add your own code here
            toggleHotwire()
        end
	end)
	RegisterKeyMapping(Config.LockpickHotkey.command, 'Toggle Engine', 'keyboard', Config.LockpickHotkey.key)
end

loadAnimDict = function(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

toggleHotwire = function()
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
					Config.Notification(nil, Translation[Config.Locale]['vehicle_unlocked'], 'success')
				else
					TriggerServerEvent('msk_enginetoggle:removeLockpickItem')
					FreezeEntityPosition(playerPed, false)
					ClearPedTasksImmediately(playerPed)
					Config.Notification(nil, Translation[Config.Locale]['hotwiring_failed'], 'error')
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
							TriggerServerEvent('msk_enginetoggle:addcarkeys', tostring(plate))
						else
							Config.Notification(nil, Translation[Config.Locale]['hotwiring_notfoundkey'], 'info')
						end
					else
						TriggerServerEvent('msk_enginetoggle:addcarkeys', tostring(plate))
					end

					Wait(200)

					if Config.LockpickSettings.startEngine then
						toggleEngine(true)
					end
				else
					if Config.LockpickSettings.startEngine then
						toggleEngine(true)
					end
				end
			end)
		end
	end
end
exports('toggleHotwire', toggleHotwire)
RegisterNetEvent('msk_enginetoggle:toggleHotwire', toggleHotwire)