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
	MSK.RegisterCommand(Config.AdminCommand.command, function(source, args, raw)    
		TriggerClientEvent('msk_enginetoggle:toggleEngine', source, true)
	end, {
		allowConsole = false,
		restricted = Config.AdminCommand.groups,
		help = 'Toggle Engine as an Admin',
	})
end

-- Interne Funktion (KEIN offener NetEvent mehr!). Wird ausschließlich serverseitig aus dem
-- validierten searchKey-Callback aufgerufen, nachdem Nähe und Fund-Wahrscheinlichkeit geprüft wurden.
-- Vorher konnte jeder Client diesen Event mit beliebiger Plate spammen und sich Keys für jedes
-- Fahrzeug geben.
giveTempKey = function(playerId, plate, model)
	if not Config.VehicleKeys.enable then return end
	plate = tostring(plate)

	if Config.VehicleKeys.script == 'msk_vehiclekeys' then
		exports.msk_vehiclekeys:AddTempKey({source = playerId}, {plate = plate, model = model})
	elseif Config.VehicleKeys.script == 'VehicleKeyChain' then
		exports["VehicleKeyChain"]:AddTempKey(playerId, plate)
	elseif Config.VehicleKeys.script == 'vehicles_keys' then
		exports["vehicles_keys"]:giveVehicleKeysToPlayerId(playerId, plate, 'temporary')
	elseif Config.VehicleKeys.script == 'okokGarage' then
		TriggerEvent("okokGarage:GiveKeys", plate, playerId)
	else
		-- Add your own code here
	end
end

-- Server-Hook: andere Ressourcen können serverseitig auf Motor-Toggles reagieren via
--   AddEventHandler('msk_enginetoggle:engineToggled', function(src, netId, state) ... end)
-- Der eingehende Client-Trigger wird zuvor validiert (Nähe-Check), damit nicht jeder Client
-- beliebige Toggle-Meldungen für fremde Fahrzeuge einspeisen kann.
RegisterNetEvent('msk_enginetoggle:toggledEngine', function(netId, state)
	local src = source
	local entity = netId and NetworkGetEntityFromNetworkId(netId)

	if not isPlayerNearEntity(src, entity, 10.0) then return end

	TriggerEvent('msk_enginetoggle:engineToggled', src, netId, state)
end)

RegisterNetEvent('msk_enginetoggle:enteredVehicle', function(plate, seat, netId, isEngineOn, isDamaged)
	local src = source
	local tPlate = MSK.String.Trim(tostring(plate))

	-- Nur wenn das Fahrzeug tatsächlich als gestohlen markiert wurde (LiveCoords-Blip aktiv), gehen
	-- wir in die DB. Vorher lief bei JEDEM Einstieg jedes Spielers eine DB-Query, nur um evtl. einen
	-- Blip zu löschen der in 99% der Fälle gar nicht existiert.
	if not StolenVehicles[tPlate] then return end

	local Player = GetPlayerFromId(src)
	if not Player then return end
	local identifier = nil

	if Config.Framework == 'ESX' then
        identifier = Player.identifier
    elseif Config.Framework == 'QBCore' then
        identifier = Player.PlayerData.citizenid
    else
        -- Add your own code here
    end

	local result = MySQL.query.await(('SELECT %s FROM %s WHERE %s = @owner AND plate = @plate'):format(OWNER_COLUMN_NAME, VEHICLE_TABLE_NAME, OWNER_COLUMN_NAME), {
		['@owner'] = identifier,
		['@plate'] = tPlate
	})

	if result and result[1] and result[1][OWNER_COLUMN_NAME] == identifier then
		StolenVehicles[tPlate] = nil
		TriggerClientEvent('msk_enginetoggle:deleteVehicleBlip', src, netId)
	end
end)

MSK.Register('msk_enginetoggle:getInventory', function(source, inv)
	if inv ~= 'core_inventory' then return {} end
	local Player = GetPlayerFromId(source)
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
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end