ESX = nil
if Config.ESX.version:match('1.2') then
	TriggerEvent(Config.ESX.getSharedObject, function(obj) ESX = obj end)
elseif Config.ESX.version:match('legacy') then
    ESX = exports["es_extended"]:getSharedObject()
end

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
		Config.Notification(source, 'server', xPlayer, Translation[Config.Locale]['hasno_lockpick'])
	end
end)

RegisterNetEvent('EngineToggle:addcarkeys')
AddEventHandler('EngineToggle:addcarkeys', function(plate)
    exports["VehicleKeyChain"]:AddTempKey(source, plate)
	Config.Notification(source, 'server', xPlayer, Translation[Config.Locale]['hotwiring_foundkey'])
end)

---- Github Updater ----
function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"
local VehicleKeyChain = "^3[VehicleKeyChain]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/msk_enginetoggle/main/VERSION', function(Error, NewestVersion, Header)
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
			print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/msk_enginetoggle/releases/tag/v'.. NewestVersion .. '^0')
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