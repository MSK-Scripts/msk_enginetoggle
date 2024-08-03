if Config.Framework == 'ESX' then
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'QBCore' then
	QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'Standalone' then
	-- Add your own code here
end

currentVehicle = {}
isInVehicle, isEnteringVehicle, disabledDrive = false, false, false

if Config.Command.enable then
	RegisterCommand(Config.Command.command, function(source, args, rawCommand)
		toggleEngine()
	end)

	if Config.Hotkey.enable then
		RegisterKeyMapping(Config.Command.command, 'Toggle Engine', 'keyboard', Config.Hotkey.key)
	end
end

toggleEngine = function(bypass)
	local playerPed = PlayerPedId()
	local canToggleEngine = true

	if not IsPedInAnyVehicle(playerPed) then return end
	local currVehicle = GetVehiclePedIsIn(playerPed)

	if not Config.EngineFromSecondSeat and GetPedInVehicleSeat(currVehicle, -1) ~= playerPed then return end

	if Config.EngineFromSecondSeat then
		if playerPed ~= GetPedInVehicleSeat(currVehicle, -1) and playerPed ~= GetPedInVehicleSeat(currVehicle, 0) then
			return
		end

		if IsVehicleSeatFree(currVehicle, -1) then return end
	end
	
	if not bypass then
		canToggleEngine = getIsVehicleOrKeyOwner(currVehicle)
	end
	
	if not canToggleEngine then 
		return Config.Notification(nil, Translation[Config.Locale]['key_nokey'], 'error')
	end

	if getVehicleDamaged(currVehicle) then return end
	local isEngineOn = GetIsVehicleEngineRunning(currVehicle)

	SetVehicleEngineOn(currVehicle, not isEngineOn, false, true)
	SetVehicleKeepEngineOnWhenAbandoned(currVehicle, not isEngineOn)
	SetVehicleUndriveable(currVehicle, isEngineOn)
	setEngineState(currVehicle, not isEngineOn)
	
	if isEngineOn then
		CreateThread(disableDrive)
		Config.Notification(nil, Translation[Config.Locale]['engine_stop'], 'success')
	else
		disabledDrive = false
		Config.Notification(nil, Translation[Config.Locale]['engine_start'], 'success')
	end
end
exports('toggleEngine', toggleEngine)
RegisterNetEvent('msk_enginetoggle:toggleEngine', toggleEngine)

AddEventHandler('msk_enginetoggle:enteringVehicle', function(vehicle, plate, seat, netId, isEngineOn)
	logging('enteringVehicle', vehicle, plate, seat, netId, isEngineOn)
	local playerPed = PlayerPedId()
	local vehicleModel = GetEntityModel(vehicle)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')

		if not Config.EngineOnAtEnter then
			SetVehicleUndriveable(vehicle, true)
			SetVehicleEngineOn(vehicle, false, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
		end
	elseif seat == -1 and isEngineOn and (IsThisModelAHeli(vehicleModel) or IsThisModelAPlane(vehicleModel)) then
		SetVehicleEngineOn(vehicle, true, false, true)
		SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
		SetHeliBladesFullSpeed(vehicle)
	end
end)

AddEventHandler('msk_enginetoggle:enteredVehicle', function(vehicle, plate, seat, netId, isEngineOn)
	logging('enteredVehicle', vehicle, plate, seat, netId, isEngineOn)
	local playerPed = PlayerPedId()
	local vehicleModel = GetEntityModel(vehicle)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')

		if not Config.EngineOnAtEnter then
			CreateThread(disableDrive)
			SetVehicleUndriveable(vehicle, true)
			SetVehicleEngineOn(vehicle, false, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
		else
			SetVehicleUndriveable(vehicle, false)
			SetVehicleEngineOn(vehicle, true, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
		end
	elseif seat == -1 and isEngineOn and (IsThisModelAHeli(vehicleModel) or IsThisModelAPlane(vehicleModel)) then
		SetVehicleEngineOn(vehicle, true, false, true)
		SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
		SetHeliBladesFullSpeed(vehicle)
	end
end)

AddEventHandler('msk_enginetoggle:exitedVehicle', function(vehicle, plate, seat, netId, isEngineOn)
	logging('exitedVehicle', vehicle, plate, seat, netId, isEngineOn)
	local playerPed = PlayerPedId()
	local vehicleModel = GetEntityModel(vehicle)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')
		SetVehicleUndriveable(vehicle, true)
		SetVehicleEngineOn(vehicle, false, false, true)
		SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
	end
end)

CreateThread(function()
	while true do
		local sleep = 500
		local playerPed = PlayerPedId()
		local vehiclePool = GetGamePool('CVehicle')

		for i = 1, #vehiclePool do
			local vehicle = vehiclePool[i]

			if DoesEntityExist(vehicle) and not getVehicleDamaged(vehicle) and IsVehicleSeatFree(vehicle, -1) and (not IsPedInAnyVehicle(playerPed, false) or (IsPedInAnyVehicle(playerPed, false) and vehicle ~= GetVehiclePedIsIn(playerPed, false))) then
				local vehicleModel = GetEntityModel(vehicle)

				if (IsThisModelAHeli(vehicleModel) or IsThisModelAPlane(vehicleModel)) then
					if getEngineState(vehicle) then
						SetVehicleEngineOn(vehicle, true, false, true)
						SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
						SetHeliBladesFullSpeed(vehicle)
					end
				end
			end
		end

		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		local sleep = 200
		local playerPed = PlayerPedId()

		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and not isEnteringVehicle then
				local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
                local plate = GetVehicleNumberPlateText(vehicle)
                local seat = GetSeatPedIsTryingToEnter(playerPed)
				local isEngineOn = getEngineState(vehicle)
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerEvent('msk_enginetoggle:enteringVehicle', vehicle, plate, seat, netId, isEngineOn)
                TriggerServerEvent('msk_enginetoggle:enteringVehicle', plate, seat, netId, isEngineOn)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) and not IsPedInAnyVehicle(playerPed, true) and isEnteringVehicle then
				TriggerEvent('msk_enginetoggle:enteringVehicleAborted')
                TriggerServerEvent('msk_enginetoggle:enteringVehicleAborted')
                isEnteringVehicle = false
			elseif IsPedInAnyVehicle(playerPed, false) then
				isEnteringVehicle = false
                isInVehicle = true
				currentVehicle.vehicle = GetVehiclePedIsIn(playerPed)
				currentVehicle.plate = GetVehicleNumberPlateText(currentVehicle.vehicle)
				currentVehicle.seat = GetPedVehicleSeat(playerPed, currentVehicle.vehicle)
				currentVehicle.isEngineOn = getEngineState(currentVehicle.vehicle)
				currentVehicle.netId = VehToNet(currentVehicle.vehicle)
				TriggerEvent('msk_enginetoggle:enteredVehicle', currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat, currentVehicle.netId, currentVehicle.isEngineOn)
                TriggerServerEvent('msk_enginetoggle:enteredVehicle', currentVehicle.plate, currentVehicle.seat, currentVehicle.netId,currentVehicle.isEngineOn)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(playerPed, false) or IsPlayerDead(PlayerId()) then
				isInVehicle = false
				TriggerEvent('msk_enginetoggle:exitedVehicle', currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat, currentVehicle.netId, currentVehicle.isEngineOn)
                TriggerServerEvent('msk_enginetoggle:exitedVehicle', currentVehicle.plate, currentVehicle.seat, currentVehicle.netId, currentVehicle.isEngineOn)
				currentVehicle = {}
			end
		end

		Wait(sleep)
	end
end)

setEngineState = function(vehicle, state)
	logging('setEngineState', vehicle, state)
	currentVehicle.isEngineOn = state
	Entity(vehicle).state.isEngineOn = state
end

getEngineState = function(vehicle)
	if Entity(vehicle).state.isEngineOn == nil then
		Entity(vehicle).state.isEngineOn = GetIsVehicleEngineRunning(vehicle)
	end
	return Entity(vehicle).state.isEngineOn
end
exports('getEngineState', getEngineState)

setVehicleDamaged = function(vehicle, state)
	currentVehicle.isDamaged = state
	Entity(vehicle).state.isDamaged = state
end
exports('setVehicleDamaged', setVehicleDamaged)
RegisterNetEvent('msk_enginetoggle:setVehicleDamaged', setVehicleDamaged)

getVehicleDamaged = function(vehicle)
	if Entity(vehicle).state.isDamaged == nil then
		Entity(vehicle).state.isDamaged = false
	end
	return Entity(vehicle).state.isDamaged
end
exports('getVehicleDamaged', getVehicleDamaged)

disableDrive = function()
	if disabledDrive then return end
	disabledDrive = true

	while isInVehicle and disabledDrive and currentVehicle.seat == -1 and not currentVehicle.isEngineOn do
		local sleep = 1

		DisableControlAction(0, 71, true)

		Wait(sleep)
	end

	disabledDrive = false
end

GetPedVehicleSeat = function(ped, vehicle)
    for i = -1, 16 do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -1
end

logging = function(...)
	if not Config.Debug then return end
	print('[DEBUG]', ...)
end