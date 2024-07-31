if Config.Framework == 'ESX' then
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'QBCore' then
	QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'Standalone' then
	-- Add your own code here
end

currentVehicle = {}
isInVehicle, isEnteringVehicle, disabledDrive = false, false, false
RPWorking = true

RegisterNetEvent('msk_enginetoggle:RPDamage', function(state)
	RPWorking = state
end)

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

	if GetPedInVehicleSeat(currVehicle, -1) ~= playerPed then return end
	local isEngineOn = GetIsVehicleEngineRunning(currVehicle)

	if Config.VehicleKeyChain and (GetResourceState("VehicleKeyChain") == "started") then
		local isVehicle, isPlate = false, false
		local isVehicleOrKeyOwner = exports["VehicleKeyChain"]:IsVehicleOrKeyOwner(currVehicle)

		for k, v in pairs(Config.Whitelist.vehicles) do 
			if GetHashKey(v) == GetEntityModel(currVehicle) then
				isVehicle = true
				break
			end
		end

		for k, v in pairs(Config.Whitelist.plates) do 
			if string.find(trim(tostring(GetVehicleNumberPlateText(currVehicle))), v) then 
				isPlate = true
				break
			end
		end

		if not isVehicleOrKeyOwner and not isVehicle and not isPlate and not bypass then
			canToggleEngine = false
		end
	end

	if not canToggleEngine then 
		return Config.Notification(nil, Translation[Config.Locale]['key_nokey'], 'error')
	end
	if not RPWorking then return end

	SetVehicleEngineOn(currVehicle, not isEngineOn, false, true)
	SetVehicleKeepEngineOnWhenAbandoned(currVehicle, not isEngineOn)

	if not isEngineOn and (IsThisModelAHeli(GetEntityModel(currVehicle)) or IsThisModelAPlane(GetEntityModel(currVehicle))) then
		SetHeliBladesFullSpeed(currVehicle)
	end
	
	if isEngineOn then
		CreateThread(disableDrive)
		SetVehicleUndriveable(currVehicle, true)
		Config.Notification(nil, Translation[Config.Locale]['engine_stop'], 'success')
	else
		disabledDrive = false
		SetVehicleUndriveable(currVehicle, false)
		Config.Notification(nil, Translation[Config.Locale]['engine_start'], 'success')
	end
end
exports('toggleEngine', toggleEngine)
RegisterNetEvent('msk_enginetoggle:toggleEngine', toggleEngine)

AddEventHandler('msk_enginetoggle:enteringVehicle', function(vehicle, plate, seat, netId)
	logging('enteringVehicle', vehicle, plate, netId)
	local playerPed = PlayerPedId()

	local isEngineOn = GetIsVehicleEngineRunning(vehicle)
	logging('isEngineOn', isEngineOn)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')

		if not Config.EngineOnAtEnter then
			SetVehicleUndriveable(vehicle, true)
			SetVehicleEngineOn(vehicle, false, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
		end
	end
end)

AddEventHandler('msk_enginetoggle:enteredVehicle', function(vehicle, plate, seat, netId)
	logging('enteredVehicle', vehicle, plate, netId)
	local playerPed = PlayerPedId()

	local isEngineOn = GetIsVehicleEngineRunning(vehicle)
	logging('isEngineOn', isEngineOn)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')

		if not Config.EngineOnAtEnter then
			SetVehicleUndriveable(vehicle, true)
			SetVehicleEngineOn(vehicle, false, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
			CreateThread(disableDrive)
		else
			SetVehicleUndriveable(vehicle, false)
			SetVehicleEngineOn(vehicle, true, false, true)
			SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
		end
	end
end)

AddEventHandler('msk_enginetoggle:exitedVehicle', function(vehicle, plate, seat, netId)
	logging('exitedVehicle', vehicle, plate, netId)
	local playerPed = PlayerPedId()

	local isEngineOn = GetIsVehicleEngineRunning(vehicle)
	logging('isEngineOn', isEngineOn)

	if seat == -1 and not isEngineOn then
		logging('SetVehicleUndriveable')
		SetVehicleUndriveable(vehicle, true)
		SetVehicleEngineOn(vehicle, false, false, true)
		SetVehicleKeepEngineOnWhenAbandoned(vehicle, false)
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
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerEvent('msk_enginetoggle:enteringVehicle', vehicle, plate, seat, netId)
                TriggerServerEvent('msk_enginetoggle:enteringVehicle', plate, seat, netId)
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
				currentVehicle.netId = VehToNet(currentVehicle.vehicle)
				TriggerEvent('msk_enginetoggle:enteredVehicle', currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat, currentVehicle.netId)
                TriggerServerEvent('msk_enginetoggle:enteredVehicle', currentVehicle.plate, currentVehicle.seat, currentVehicle.netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(playerPed, false) or IsPlayerDead(PlayerId()) then
				isInVehicle = false
				TriggerEvent('msk_enginetoggle:exitedVehicle', currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat, currentVehicle.netId)
                TriggerServerEvent('msk_enginetoggle:exitedVehicle', currentVehicle.plate, currentVehicle.seat, currentVehicle.netId)
				currentVehicle = {}
			end
		end

		Wait(sleep)
	end
end)

disableDrive = function()
	if disabledDrive then return end
	disabledDrive = true

	while isInVehicle and disabledDrive and currentVehicle.seat == -1 and not GetIsVehicleEngineRunning(currentVehicle.vehicle) do
		local sleep = 1

		DisableControlAction(0, 71, true)

		Wait(sleep)
	end

	disabledDrive = false
end

trim = function(str)
	return string.gsub(str, "%s+", "")
end

function GetPedVehicleSeat(ped, vehicle)
    for i = -1, 16 do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -1
end

logging = function(...)
	if not Config.Debug then return end
	print('[DEBUG]', ...)
end