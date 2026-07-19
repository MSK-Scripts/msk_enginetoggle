if Config.Framework == 'ESX' or Config.Framework == 'AUTO' and GetResourceState('es_extended') ~= 'missing' then
    if not ESX then 
        ESX = exports["es_extended"]:getSharedObject() 
        Config.Framework = 'ESX'
    end

	VEHICLE_TABLE_NAME = "owned_vehicles"
	OWNER_COLUMN_NAME = "owner"
elseif Config.Framework == 'QBCore' or Config.Framework == 'AUTO' and GetResourceState('qb-core') ~= 'missing' then
    if not QBCore then 
        QBCore = exports['qb-core']:GetCoreObject() 
        Config.Framework = 'QBCore'
    end

	VEHICLE_TABLE_NAME = "player_vehicles"
	OWNER_COLUMN_NAME = "citizenid"
else
    VEHICLE_TABLE_NAME = ""
	OWNER_COLUMN_NAME = ""
end

if Config.EnableLockpick then
    alterDatabase = function()        
        MySQL.query.await(("ALTER TABLE %s ADD COLUMN IF NOT EXISTS `alarmStage` varchar(50) NOT NULL DEFAULT 'stage_1';"):format(VEHICLE_TABLE_NAME))
    end
    alterDatabase()

    if Config.Framework == 'ESX' then
		ESX.RegisterUsableItem(Config.LockpickSettings.item, function(source)
			TriggerClientEvent('msk_enginetoggle:toggleLockpick', source)
		end)

        for stage, data in pairs(Config.SafetyStages) do
            ESX.RegisterUsableItem(data.item, function(source)
                TriggerClientEvent('msk_enginetoggle:installAlarmStage', source, stage)
            end)
        end
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.CreateUseableItem(Config.LockpickSettings.item, function(source)
            TriggerClientEvent('msk_enginetoggle:toggleLockpick', source)
        end)

        for stage, data in pairs(Config.SafetyStages) do
            QBCore.Functions.CreateUseableItem(data.item, function(source)
                TriggerClientEvent('msk_enginetoggle:installAlarmStage', source, stage)
            end)
        end
    else
        -- Add your own code here
    end
end

HasPlayerJob = function(Player)
    for i=1, #Config.PoliceAlert do
        if Config.PoliceAlert[i] == GetPlayerJob(Player) then
            return true
        end
    end
    return false
end

-- Als gestohlen markierte Fahrzeuge (plate -> true). Wird nur bei aktivem LiveCoords-Blip gesetzt
-- und dient dazu, die DB-Query in enteredVehicle auf die wenigen relevanten Fälle zu beschränken.
StolenVehicles = {}

-- Anti-Spam Cooldowns pro Spieler und Aktion
local cooldowns = {}

isOnCooldown = function(src, key, ms)
    local now = GetGameTimer()
    cooldowns[src] = cooldowns[src] or {}

    if cooldowns[src][key] and now < cooldowns[src][key] then
        return true
    end

    cooldowns[src][key] = now + ms
    return false
end

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

-- Prüft serverseitig, ob der Spieler wirklich in der Nähe der Entity ist. Verhindert Remote-Aufrufe
-- (z.B. Keys/Alarme für Fahrzeuge am anderen Ende der Map).
isPlayerNearEntity = function(src, entity, maxDist)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local pedCoords = GetEntityCoords(ped)
    local entityCoords = GetEntityCoords(entity)
    return #(pedCoords - entityCoords) <= (maxDist or 10.0)
end

-- Serverinterne Ermittlung von Owner + Stage. Der Owner-Identifier verlässt damit nie den Client.
getAlarmData = function(plate)
    if VEHICLE_TABLE_NAME == '' or OWNER_COLUMN_NAME == '' then return nil, 'stage_1' end

    local result = MySQL.query.await(('SELECT %s, alarmStage FROM %s WHERE plate = @plate'):format(OWNER_COLUMN_NAME, VEHICLE_TABLE_NAME), {
        ['@plate'] = MSK.String.Trim(plate)
    })

    if result and result[1] then
        return result[1][OWNER_COLUMN_NAME], result[1].alarmStage
    end
    return nil, 'stage_1'
end

-- Der Client-Callback gibt ausschließlich die Stage zurück (für den akustischen Alarm), niemals den Owner.
MSK.Register('msk_enginetoggle:getAlarmStage', function(source, plate)
    local _, stage = getAlarmData(plate)
    return stage
end)

RegisterNetEvent('msk_enginetoggle:removeLockpickItem', function()
    if not Config.LockpickSettings.removeItem then return end
    local src = source
    local Player = GetPlayerFromId(src)

    if Config.Framework == 'ESX' then
        Player.removeInventoryItem(Config.LockpickSettings.item, 1)
    elseif Config.Framework == 'QBCore' then
        Player.Functions.RemoveItem(Config.LockpickSettings.item, 1)
    else
        -- Add your own code here
    end
end)

RegisterNetEvent('msk_enginetoggle:saveAlarmStage', function(plate, stage)
    local playerId = source

    -- Stage gegen die Config validieren, sonst könnte ein Client eine beliebige Zeichenkette in die DB schreiben
    if not Config.SafetyStages[stage] then return end

    local Player = GetPlayerFromId(playerId)
    if not Player then return end
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

	if result and result[1] and result[1][OWNER_COLUMN_NAME] == identifier then
		MySQL.update(('UPDATE %s SET alarmStage = @alarmStage WHERE %s = @owner AND plate = @plate'):format(VEHICLE_TABLE_NAME, OWNER_COLUMN_NAME), {
            ['@alarmStage'] = stage,
            ['@owner'] = identifier,
            ['@plate'] = MSK.String.Trim(plate),
        })
    else
        Config.Notification(playerId, Translation[Config.Locale]['not_vehicle_owner'], 'error')
	end
end)

-- Interne Alert-Funktionen (keine offenen NetEvents mehr!). Owner und Koordinaten werden
-- ausschließlich serverseitig aus triggerAlarm ermittelt und sind damit nicht mehr spoofbar.
notifyOwner = function(owner, coords)
    local Player = GetPlayerFromIdentifier(owner)
    if not Player then return end
    local playerId = nil

    if Config.Framework == 'ESX' then
        playerId = Player.source
    elseif Config.Framework == 'QBCore' then
        playerId = Player.PlayerData.source
    else
        -- Add your own code here
    end

    if not playerId then return end
    Config.Notification(playerId, Translation[Config.Locale]['stole_vehicle'])
    TriggerClientEvent('msk_enginetoggle:showBlipCoords', playerId, coords)
end

notifyPolice = function(coords)
    if Config.Framework == 'ESX' then
        local xPlayers = ESX.GetExtendedPlayers()

        for k, xPlayer in pairs(xPlayers) do
            if HasPlayerJob(xPlayer) then
                Config.Notification(xPlayer.source, Translation[Config.Locale]['stole_vehicle_police'])
                TriggerClientEvent('msk_enginetoggle:showBlipCoords', xPlayer.source, coords)
            end
        end
    elseif Config.Framework == 'QBCore' then
        local Players = QBCore.Functions.GetQBPlayers()

        for k, Player in pairs(Players) do
            if HasPlayerJob(Player) then
                Config.Notification(Player.PlayerData.source, Translation[Config.Locale]['stole_vehicle_police'])
                TriggerClientEvent('msk_enginetoggle:showBlipCoords', Player.PlayerData.source, coords)
            end
        end
    else
        -- Add your own code here
    end
end

sendLiveCoords = function(owner, netId, coords)
    local Player = GetPlayerFromIdentifier(owner)
    if not Player then return end
    local playerId = nil

    if Config.Framework == 'ESX' then
        playerId = Player.source
    elseif Config.Framework == 'QBCore' then
        playerId = Player.PlayerData.source
    else
        -- Add your own code here
    end

    if not playerId then return end
    TriggerClientEvent('msk_enginetoggle:showVehicleBlip', playerId, netId, coords)
end

-- Zentrale, serverseitig validierte Alarm-Auslösung. Der Client sendet nur die netId; Plate, Owner,
-- Stage und Koordinaten ermittelt der Server selbst aus der Entity. Nähe- und Cooldown-Check gegen Spam.
RegisterNetEvent('msk_enginetoggle:triggerAlarm', function(netId)
    local src = source
    local entity = netId and NetworkGetEntityFromNetworkId(netId)

    if not isPlayerNearEntity(src, entity, 10.0) then return end
    if isOnCooldown(src, 'triggerAlarm', 5000) then return end

    local plate = GetVehicleNumberPlateText(entity)
    local owner, stage = getAlarmData(plate)
    local alarmStage = Config.SafetyStages[stage] or Config.SafetyStages['stage_1']
    local coords = GetEntityCoords(entity)

    if alarmStage.ownerAlert and owner then
        notifyOwner(owner, coords)
    end

    if alarmStage.policeAlert then
        notifyPolice(coords)
    end

    if alarmStage.liveCoords and owner then
        StolenVehicles[MSK.String.Trim(plate)] = true
        sendLiveCoords(owner, netId, coords)
    end
end)

-- Serverseitig validierte Schlüsselsuche: prüft Nähe + Cooldown, würfelt den Fund selbst und vergibt
-- den TempKey. Ersetzt das alte clientseitige math.random und den offenen addTempKey-Event.
MSK.Register('msk_enginetoggle:searchKey', function(source, netId)
    local src = source
    local entity = netId and NetworkGetEntityFromNetworkId(netId)

    if not isPlayerNearEntity(src, entity, 10.0) then return false end
    if isOnCooldown(src, 'searchKey', 3000) then return false end

    if math.random(100) > Config.LockpickSettings.searchKey then
        return false
    end

    if Config.VehicleKeys.enable and GetResourceState(Config.VehicleKeys.script) == 'started' then
        local plate = GetVehicleNumberPlateText(entity)
        local model = GetEntityModel(entity)
        giveTempKey(src, plate, model)
    end

    return true
end)