if Config.Framework == 'AUTO' then
	if GetResourceState('es_extended') ~= 'missing' then
        ESX = exports["es_extended"]:getSharedObject()
		Config.Framework = 'ESX'
    elseif GetResourceState('qb-core') ~= 'missing' then
        QBCore = exports['qb-core']:GetCoreObject()
		Config.Framework = 'QBCore'
    end
elseif Config.Framework == 'ESX' then
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'QBCore' then
	QBCore = exports['qb-core']:GetCoreObject()
else
	-- Add your own code here
end

GetPlayerFromId = function(playerId)
	local Player = nil

	if Config.Framework == 'ESX' then
        Player = ESX.GetPlayerFromId(playerId)
    elseif Config.Framework == 'QBCore' then
        Player = QBCore.Functions.GetPlayer(playerId)
    else
        -- Add your own code here
    end

	return Player
end

GetPlayerFromIdentifier = function(identifier)
	local Player = nil

	if Config.Framework == 'ESX' then
        Player = ESX.GetPlayerFromIdentifier(identifier)
    elseif Config.Framework == 'QBCore' then
        Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    else
        -- Add your own code here
    end

	return Player
end

GetPlayerJob = function(Player)
    local job = 'unemployed'

    if Config.Framework == 'ESX' then
        job = Player.job.name
    elseif Config.Framework == 'QBCore' then
        job = Player.PlayerData.job.name
    else
        -- Add your own code here
    end

    return job
end

if Config.AdminCommand.enable then
	local allowedGroups = Config.AdminCommand.groups

	for i = 1, #allowedGroups do
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(allowedGroups[i], Config.AdminCommand.command))
	end

	local isAceAllowed = function(playerId, command)
        return IsPlayerAceAllowed(playerId, ('command.%s'):format(command))
    end

	RegisterCommand(Config.AdminCommand.command, function(source, args, rawCommand)
		local src = source

		if not isAceAllowed(src, Config.AdminCommand.command) then 
			return Config.Notification(src, 'You don\'t have permission to do that!', 'error')
		end

		TriggerClientEvent('msk_enginetoggle:toggleEngine', src, true)
	end)
end

RegisterNetEvent('msk_enginetoggle:addTempKey', function(plate)
	if not Config.VehicleKeys.enable then return end
	local playerId = source
	plate = tostring(plate)

	if Config.VehicleKeys.script == 'msk_vehiclekeys' then
		exports["msk_vehiclekeys"]:AddKey({source = playerId}, plate, 'temporary')
	elseif Config.VehicleKeys.script == 'VehicleKeyChain' then
		exports["VehicleKeyChain"]:AddTempKey(playerId, plate)
	elseif Config.VehicleKeys.script == 'vehicles_keys' then
		exports["vehicles_keys"]:giveVehicleKeysToPlayerId(playerId, plate, 'temporary')
	elseif Config.VehicleKeys.script == 'okokGarage' then
		TriggerEvent("okokGarage:GiveKeys", plate, playerId)
	else
		-- Add your own code here
	end
end)

RegisterNetEvent('msk_enginetoggle:enteredVehicle', function(plate, seat, netId, isEngineOn, isDamaged)
	local src = source
	local Player = GetPlayerFromId(src)
	local identifier = nil

	if Config.Framework == 'ESX' then
        identifier = Player.identifier
    elseif Config.Framework == 'QBCore' then
        identifier = Player.PlayerData.citizenid 
    else
        -- Add your own code here
    end

	local result = MySQL.query.await(('SELECT * FROM %s WHERE %s = @owner AND plate = @plate'):format(VEHICLE_TABLE_NAME, OWNER_COLUMN_NAME), {
		['@owner'] = identifier,
		['@plate'] = MSK.String.Trim(plate)
	})

	if result and result[1] then
		if result[1][OWNER_COLUMN_NAME] == identifier then
			TriggerClientEvent('msk_enginetoggle:deleteVehicleBlip', src, netId)
		end
	end
end)

MSK.Register('msk_enginetoggle:getInventory', function(source, inv)
	if inv ~= 'core_inventory' then return {} end
	local Player = GetPlayerFromId(src)
	local identifier = nil

	if Config.Framework == 'ESX' then
        identifier = Player.identifier
    elseif Config.Framework == 'QBCore' then
        identifier = Player.PlayerData.citizenid 
    else
        -- Add your own code here
    end

	local invName = ('content-%s'):format(identifier):gsub(':', '')
	return exports['core_inventory']:getInventory(invName)
end)

logging = function(code, ...)
    if code == 'debug' and not Config.Debug then return end
    MSK.Logging(code, ...)
end