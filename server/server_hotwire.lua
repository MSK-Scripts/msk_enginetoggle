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

        ESX.RegisterServerCallback('msk_enginetoggle:hasItem', function(source, cb, item)
            local src = source
            local xPlayer = ESX.GetPlayerFromId(src)
            local hasItem = xPlayer.hasItem(item)

            cb(hasItem and hasItem.count > 0)
        end)

        ESX.RegisterServerCallback('msk_enginetoggle:getAlarmStage', function(source, cb, plate)
            local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = trim(plate)
            })

            if result and result[1] then
                cb(result[1].owner, result[1].alarmStage)
            end
        end)
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.CreateUseableItem(Config.LockpickSettings.item, function(source)
            TriggerClientEvent('msk_enginetoggle:toggleLockpick', source)
        end)

        for stage, data in pairs(Config.SafetyStages) do
            QBCore.Functions.CreateUseableItem(data.item, function(source)
                TriggerClientEvent('msk_enginetoggle:installAlarmStage', source, stage)
            end)
        end

        QBCore.Functions.CreateCallback('msk_enginetoggle:hasItem', function(source, cb, item)
            local src = source
            local Player = QBCore.Functions.GetPlayer(src)
            local hasItem = Player.Functions.GetItemByName(item)

            cb(hasItem and hasItem.amount > 0)
        end)

        QBCore.Functions.CreateCallback('msk_enginetoggle:getAlarmStage', function(source, cb, plate)
            local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = @plate', {
                ['@plate'] = trim(plate)
            })

            if result and result[1] then
                cb(result[1].citizenid, result[1].alarmStage)
            end
        end)
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
    local Player = GetPlayerFromId(playerId)
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
		['@plate'] = trim(plate)
	})

	if result and result[1] and result[1][OWNER_COLUMN_NAME] == identifier then
		MySQL.update(('UPDATE %s SET alarmStage = @alarmStage WHERE %s = @owner AND plate = @plate'):format(VEHICLE_TABLE_NAME, OWNER_COLUMN_NAME), {
            ['@alarmStage'] = stage,
            ['@owner'] = identifier,
            ['@plate'] = trim(plate),
        })
    else
        Config.Notification(playerId, Translation[Config.Locale]['not_vehicle_owner'], 'error')
	end
end)

RegisterNetEvent('msk_enginetoggle:ownerAlert', function(coords, owner)
    local playerId = nil
    local Player = GetPlayerFromIdentifier(owner)
    if not Player then return end

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
end)

RegisterNetEvent('msk_enginetoggle:policeAlert', function(coords)
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
end)

RegisterNetEvent('msk_enginetoggle:liveCoords', function(owner, netId, coords)
    local playerId = nil
    local Player = GetPlayerFromIdentifier(owner)
    if not Player then return end

    if Config.Framework == 'ESX' then
        playerId = Player.source
    elseif Config.Framework == 'QBCore' then
        playerId = Player.PlayerData.source
    else
        -- Add your own code here
    end

    if not playerId then return end
    TriggerClientEvent('msk_enginetoggle:showVehicleBlip', playerId, netId, coords)
end)