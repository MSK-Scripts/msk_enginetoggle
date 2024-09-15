if Config.EnableLockpick and Config.LockpickHotkey.enable then
	RegisterCommand(Config.LockpickHotkey.command, function(source, args, rawCommand)
		local hasItem = MSK.HasItem(Config.LockpickSettings.item)

		if not hasItem then 
			return Config.Notification(nil, Translation[Config.Locale]['hasno_lockpick'], 'error')
		end

		toggleLockpick()
	end)
	RegisterKeyMapping(Config.LockpickHotkey.command, 'Lockpick Vehicle', 'keyboard', Config.LockpickHotkey.key)
end

toggleLockpick = function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if IsPedInAnyVehicle(playerPed, false) then return end	
	if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then return end
	
	local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
	if not DoesEntityExist(vehicle) then return end

	local plate = GetVehicleNumberPlateText(vehicle)
	local animation = {dict = Config.Animation.lockpick.dict, anim = Config.Animation.lockpick.anim}
	
	local owner, stage = MSK.Trigger('msk_enginetoggle:getAlarmStage', plate)
	local alarmStage = Config.SafetyStages[stage]

	if alarmStage.alarm then
		SetVehicleAlarm(vehicle, true)
		StartVehicleAlarm(vehicle)
	end

	if alarmStage.ownerAlert and owner then
		TriggerServerEvent('msk_enginetoggle:ownerAlert', GetEntityCoords(vehicle), owner)
	end

	if alarmStage.policeAlert then
		TriggerServerEvent('msk_enginetoggle:policeAlert', GetEntityCoords(vehicle))
	end

	if alarmStage.liveCoords and owner then
		TriggerServerEvent('msk_enginetoggle:liveCoords', owner, VehToNet(vehicle), GetEntityCoords(vehicle))
	end
	
	MSK.LoadAnimDict(animation.dict)
	TaskPlayAnim(playerPed, animation.dict, animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
	FreezeEntityPosition(playerPed, true)

	local success = false
	if Config.LockpickSettings.action == 'progressbar' then
		local time = Config.LockpickProgessbar.time * 1000
		Config.progressBar(time, Translation[Config.Locale]['lockpicking'])
		Wait(time)
	elseif Config.LockpickSettings.action == 'skillbar' then
		if Config.LockpickSkillbar.type == 'ox_lib' then
			success = lib.skillCheck({Config.LockpickSkillbar.difficulty['1'], Config.LockpickSkillbar.difficulty['2'], Config.LockpickSkillbar.difficulty['3'], Config.LockpickSkillbar.difficulty['4']}, Config.LockpickSkillbar.inputs)
		elseif Config.LockpickSkillbar.type == 'qb-skillbar' then
			local p = promise.new()
			local Skillbar = exports['qb-skillbar']:GetSkillbarObject()

			Skillbar.Start({
				duration = math.random(1000, 5000), -- how long the skillbar runs for
				pos = math.random(10, 30), -- how far to the right the static box is
				width = math.random(10, 20), -- how wide the static box is
			}, function()
				success = true
				p:resolve(success)
			end, function()
				success = false
				p:resolve(success)
			end)

			success = Citizen.Await(p)
		end
	end
	RemoveAnimDict(animation.dict)

	if not success and Config.LockpickSettings.action == 'progressbar' then
		if math.random(100) <= Config.LockpickProgessbar.lockpick then
			success = true
		end
	end

	if success then
		if GetResourceState('msk_vehiclekeys') == "started" then
			exports.msk_vehiclekeys:SetVehicleLockState(vehicle, false, true) -- vehicle, state, force
		else
			SetVehicleDoorsLocked(vehicle, 1)
			SetVehicleDoorsLockedForAllPlayers(vehicle, false)
		end
		FreezeEntityPosition(playerPed, false)
		ClearPedTasks(playerPed)
		Config.Notification(nil, Translation[Config.Locale]['vehicle_unlocked'], 'success')
	elseif not success then
		TriggerServerEvent('msk_enginetoggle:removeLockpickItem')
		FreezeEntityPosition(playerPed, false)
		ClearPedTasks(playerPed)
		Config.Notification(nil, Translation[Config.Locale]['hotwiring_failed'], 'error')
		return
	end

	Wait(500)

	local needToHotwire = false
	if not GetEngineState(vehicle) then
		needToHotwire = true
	end
	TaskEnterVehicle(playerPed, vehicle, 10.0, -1, 1.0, 1, 0)
	Wait(5000)
		
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed)
	local plate = GetVehicleNumberPlateText(vehicle)

	if Config.VehicleKeys.enable or Config.LockpickSettings.enableSearchKey then
		local dict = Config.Animation.searchKey.dict
		local anim = Config.Animation.searchKey.anim
		local time = Config.Animation.searchKey.time * 1000

		MSK.LoadAnimDict(dict)
		TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		if Config.Animation.searchKey.enableProgressbar then
			Config.progressBar(time, Translation[Config.Locale]['search_key'])
		end
		Wait(time)

		if math.random(100) <= Config.LockpickSettings.searchKey then
			if Config.VehicleKeys.enable and GetResourceState(Config.VehicleKeys.script) == "started" then
				TriggerServerEvent('msk_enginetoggle:addTempKey', plate)
			end
			needToHotwire = false
			Config.Notification(nil, Translation[Config.Locale]['hotwiring_foundkey'], 'success')
		else
			Config.Notification(nil, Translation[Config.Locale]['hotwiring_notfoundkey'], 'error')
		end

		ClearPedTasks(playerPed)
		RemoveAnimDict(dict)
	end

	if needToHotwire then
		local dict = Config.Animation.hotwire.dict
		local anim = Config.Animation.hotwire.anim
		local action = Config.Animation.hotwire.action
		local time = Config.Animation.hotwire.time * 1000
		MSK.LoadAnimDict(dict)
		TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false)

		local success = false
		if action == 'progressbar' then
			Config.progressBar(time, Translation[Config.Locale]['hotwiring'])
			Wait(time)
			success = true
		elseif action == 'skillbar' then
			if Config.LockpickSkillbar.type == 'ox_lib' then
				success = lib.skillCheck({Config.LockpickSkillbar.difficulty['1'], Config.LockpickSkillbar.difficulty['2'], Config.LockpickSkillbar.difficulty['3'], Config.LockpickSkillbar.difficulty['4']}, Config.LockpickSkillbar.inputs)
			elseif Config.LockpickSkillbar.type == 'qb-skillbar' then
				local p = promise.new()
				local Skillbar = exports['qb-skillbar']:GetSkillbarObject()

				Skillbar.Start({
					duration = math.random(1000, 5000), -- how long the skillbar runs for
					pos = math.random(10, 30), -- how far to the right the static box is
					width = math.random(10, 20), -- how wide the static box is
				}, function()
					success = true
					p:resolve(success)
				end, function()
					success = false
					p:resolve(success)
				end)

				success = Citizen.Await(p)
			end
		end

		ClearPedTasks(playerPed)
		RemoveAnimDict(dict)

		if success and Config.LockpickSettings.startEngine then
			toggleEngine(Config.LockpickSettings.startEngineBypass)
		end
	else
		if Config.LockpickSettings.startEngine then
			toggleEngine(Config.LockpickSettings.startEngineBypass)
		end
	end
end
exports('toggleLockpick', toggleLockpick)
exports('toggleHotwire', toggleLockpick) -- Support for old Versions
RegisterNetEvent('msk_enginetoggle:toggleLockpick', toggleLockpick)

RegisterNetEvent('msk_enginetoggle:installAlarmStage', function(stage)
	local playerPed = PlayerPedId()

	if not IsPedInAnyVehicle(playerPed, false) then 
		Config.Notification(nil, Translation[Config.Locale]['sit_in_vehicle'], 'error')
		return 
	end

	local vehicle = GetVehiclePedIsIn(playerPed)
	local plate = GetVehicleNumberPlateText(vehicle)

	Config.progressBar(1000 * 15, Translation[Config.Locale]['install_alarm'])
	Wait(1000 * 15)

	TriggerServerEvent('msk_enginetoggle:saveAlarmStage', plate, stage)
end)

RegisterNetEvent('msk_enginetoggle:showBlipCoords', function(coords)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, 326)
	SetBlipDisplay(blip, 2)
	SetBlipColour(blip, 1)
	SetBlipScale(blip, 1.0)
	SetBlipFlashes(blip, true)

	SetTimeout(1000 * 60, function()
		RemoveBlip(blip)
	end)
end)

inOneSync = function(netId)
    local vehicle = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then 
		return {vehicle = vehicle}
	end
    return false
end

local activeBlips = {}

deleteVehicleBlip = function(netId)
	if not activeBlips[netId] then return end
	RemoveBlip(activeBlips[netId].blip)
	activeBlips[netId] = nil
end
RegisterNetEvent('msk_enginetoggle:deleteVehicleBlip', deleteVehicleBlip)

addVehicleBlip = function(netId, coords)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, 326)
	SetBlipDisplay(blip, 2)
	SetBlipColour(blip, 1)
	SetBlipScale(blip, 1.0)
	SetBlipFlashes(blip, true)
	SetBlipAsShortRange(blip, false)

	BeginTextCommandSetBlipName('STRING') 
    AddTextComponentString(Translation[Config.Locale]['blip_stolen_vehicle'])
    EndTextCommandSetBlipName(blip)

	activeBlips[netId] = {isActive = false, blip = blip}
end

showVehicleBlip = function(netId, coords)
	if not activeBlips[netId] then addVehicleBlip(netId, coords) end
	local OneSync = inOneSync(netId)

	if OneSync and activeBlips[netId] and not activeBlips[netId].isActive then
		CreateThread(function()
			activeBlips[netId].isActive = true

			while activeBlips[netId] and activeBlips[netId].isActive and DoesEntityExist(OneSync.vehicle) do
				local vehicleCoords = GetEntityCoords(OneSync.vehicle)
				local heading = math.ceil(GetEntityHeading(OneSync.vehicle))

				SetBlipCoords(activeBlips[netId].blip, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
				ShowHeadingIndicatorOnBlip(activeBlips[netId].blip, true)
				SetBlipRotation(activeBlips[netId].blip, heading)

				Wait(0)
			end
		end)
	elseif not OneSync and activeBlips[netId] then
		activeBlips[netId].isActive = false
		SetBlipCoords(activeBlips[netId].blip, coords.x, coords.y, coords.z)
		ShowHeadingIndicatorOnBlip(activeBlips[netId].blip, false)
	end

	SetTimeout(2500, function()
		if not activeBlips[netId] then return end
		showVehicleBlip(netId, coords)
	end)
end
RegisterNetEvent('msk_enginetoggle:showVehicleBlip', showVehicleBlip)