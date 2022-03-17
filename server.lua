local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.UseCommand then
	RegisterCommand(Config.Commad, function(source)
		TriggerClientEvent('EngineToggle:Engine', source)
	end)
end

ESX.RegisterUsableItem(Config.LockpickItem, function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerClientEvent('EngineToggle:hotwire', source)
end)

RegisterNetEvent('EngineToggle:delhotwire')
AddEventHandler('EngineToggle:delhotwire', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveLockpickItem then
		xPlayer.removeInventoryItem(Config.LockpickItem, 1)
	end
end)

RegisterNetEvent('EngineToggle:hasItem')
AddEventHandler('EngineToggle:hasItem', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local hasItem = xPlayer.getInventoryItem(Config.LockpickItem).count

	if hasItem > 0 then
		TriggerClientEvent('EngineToggle:hotwire', source)
	else
		if Config.Notifications then
			TriggerClientEvent('notifications', source, "#FF0000", _U('header'), _U('hasno_lockpick'))
		elseif Config.OkokNotify then
			TriggerClientEvent('okokNotify:Alert', source, _U('header'), _U('hasno_lockpick'), 5000, 'info')
		else
			TriggerEvent('esx:showNotification', source, _U('hasno_lockpick'))
		end
	end
end)

RegisterNetEvent('EngineToggle:addcarkeys')
AddEventHandler('EngineToggle:addcarkeys', function(plate)
    exports["VehicleKeyChain"]:AddTempKey(source, plate)

	if Config.Notifications then
		TriggerEvent('notifications', source,"#FF0000", _U('header'), _U('hotwiring_foundkey'))
	elseif Config.OkokNotify then
		TriggerClientEvent('okokNotify:Alert', source, _U('header'), _U('hotwiring_foundkey'), 5000, 'info')
	else
		TriggerEvent('esx:showNotification', source, _U('hotwiring_foundkey'))
	end
end)

---- Github Updater ----
function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"
local VehicleKeyChain = "^3[VehicleKeyChain]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
		print("###############################")
		if CurrentVersion == NewestVersion then
			print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
			if Config.VehicleKeyChain then
				if (GetResourceState("VehicleKeyChain") == "started") then
					print('^2[READY]^0 Script '.. VehicleKeyChain ..' found!')
				elseif (GetResourceState("VehicleKeyChain") == "stopped") then
					print('^1[ERROR]^0 Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
				end
			end
		elseif CurrentVersion ~= NewestVersion then
			print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
			print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/EngineToggle/releases/tag/v'.. NewestVersion .. '^0')
			if Config.VehicleKeyChain then
				if (GetResourceState("VehicleKeyChain") == "started") then
					print('^2[READY]^0 Script '.. VehicleKeyChain ..' found!')
				elseif (GetResourceState("VehicleKeyChain") == "stopped") then
					print('^1[ERROR]^0 Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
				end
			end
		end
		print("###############################")
	end)
else
	print("###############################")
	print(resourceName .. '^2 ✓ Resource loaded^0')
	print("###############################")
end