if Config.EnableLockpick then
    if Config.Framework == 'ESX' then
		ESX.RegisterUsableItem(Config.LockpickSettings.item, function(source)
			TriggerClientEvent('msk_enginetoggle:toggleHotwire', source)
		end)

        ESX.RegisterServerCallback('msk_enginetoggle:hasItem', function(source, cb, item)
            local src = source
            local xPlayer = ESX.GetPlayerFromId(src)
            local hasItem = xPlayer.hasItem(item)

            if hasItem and hasItem.count > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    elseif Config.Framework == 'QBCore' then
        QBCore.Functions.CreateUseableItem(Config.LockpickSettings.item, function(source)
            TriggerClientEvent('msk_enginetoggle:toggleHotwire', source)
        end)

        QBCore.Functions.CreateCallback('msk_enginetoggle:hasItem', function(source, cb, item)
            local src = source
            local Player = QBCore.Functions.GetPlayer(src)
            local hasItem = Player.Functions.GetItemByName(item)

            if hasItem and hasItem.amount > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    elseif Config.Framework == 'Standalone' then
        -- Add your own code here
    end

	RegisterNetEvent('msk_enginetoggle:removeLockpickItem', function()
        if not Config.LockpickSettings.removeItem then return end
        local src = source

        if Config.Framework == 'ESX' then
            local xPlayer = ESX.GetPlayerFromId(src)
            xPlayer.removeInventoryItem(Config.LockpickSettings.item, 1)
        elseif Config.Framework == 'QBCore' then
            local Player = QBCore.Functions.GetPlayer(src)
            Player.Functions.RemoveItem(Config.LockpickSettings.item, 1)
        elseif Config.Framework == 'Standalone' then
            -- Add your own code here
        end
	end)
end