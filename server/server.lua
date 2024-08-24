if Config.Framework == 'ESX' then
	ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'QBCore' then
	QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'Standalone' then
	-- Add your own code here
end

if Config.AdminCommand.enable then
	for k, group in pairs(Config.AdminCommand.groups) do
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, Config.AdminCommand.command))
    end

	local isAceAllowed = function(source)
        for k, group in pairs(Config.AdminCommand.groups) do
            if IsPlayerAceAllowed(source, ('command.%s'):format(group)) then
                return true
            end
        end
        return false
    end

	RegisterCommand(Config.AdminCommand.command, function(source, args, rawCommand)
		local src = source

		if not isAceAllowed(src) then 
			return Config.Notification(src, 'You don\'t have permission to do that!', 'error')
		end

		TriggerClientEvent('msk_enginetoggle:toggleEngine', src, true)
	end)
end

RegisterNetEvent('msk_enginetoggle:addTempKey', function(plate)
	if not Config.VehicleKeys.enable then return end
	local playerId = source

	if Config.VehicleKeys.script == 'VehicleKeyChain' then
		exports["VehicleKeyChain"]:AddTempKey(playerId, plate)
	elseif Config.VehicleKeys.script == 'vehicle_keys' then
		exports["vehicle_keys"]:giveVehicleKeysToPlayerId(playerId, plate, 'temporary')
	elseif Config.VehicleKeys.script == 'okokGarage' then
		TriggerEvent("okokGarage:GiveKeys", plate, playerId)
	else
		-- Add your own code here
	end

	Config.Notification(source, Translation[Config.Locale]['hotwiring_foundkey'], 'info')
end)

GithubUpdater = function()
	local GetCurrentVersion = function()
		return GetResourceMetadata( GetCurrentResourceName(), "version" )
	end

	local CurrentVersion = GetCurrentVersion()
	local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"
	local VehicleScript = ("^3[%s]^0"):format(Config.VehicleKeys.script)

	if Config.VersionChecker then
		PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/msk_enginetoggle/main/VERSION', function(Error, NewestVersion, Header)
			if CurrentVersion == NewestVersion then
				print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
			elseif CurrentVersion ~= NewestVersion then
				print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
				print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/msk_enginetoggle/releases/tag/v'.. NewestVersion .. '^0')
			end

			if Config.VehicleKeys.enable then
				if (GetResourceState(Config.VehicleKeys.script) == "started") then
					print(("Script %s was found and is running!"):format(VehicleScript))
				elseif (GetResourceState(Config.VehicleKeys.script) == "stopped") then
					print(("Script %s was found but is stopped, please start the Script!"):format(VehicleScript))
				elseif (GetResourceState(Config.VehicleKeys.script) == "missing") then
					print(("Script %s was not found, please make sure that the Script is started!"):format(VehicleScript))
				end
			end
		end)
	else
		print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
	end
end
GithubUpdater()