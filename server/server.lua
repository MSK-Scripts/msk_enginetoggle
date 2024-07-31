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

RegisterNetEvent('msk_enginetoggle:addcarkeys', function(plate)
    exports["VehicleKeyChain"]:AddTempKey(source, plate)
	Config.Notification(source, Translation[Config.Locale]['hotwiring_foundkey'], 'info')
end)

GithubUpdater = function()
	local GetCurrentVersion = function()
		return GetResourceMetadata( GetCurrentResourceName(), "version" )
	end

	local CurrentVersion = GetCurrentVersion()
	local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"
	local VehicleKeyChain = "^3[VehicleKeyChain]^0"

	if Config.VersionChecker then
		PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/msk_enginetoggle/main/VERSION', function(Error, NewestVersion, Header)
			if CurrentVersion == NewestVersion then
				print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
			elseif CurrentVersion ~= NewestVersion then
				print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
				print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/msk_enginetoggle/releases/tag/v'.. NewestVersion .. '^0')
			end

			if Config.VehicleKeyChain then
				if (GetResourceState("VehicleKeyChain") == "started") then
					print('^2[READY]^0 Script '.. VehicleKeyChain ..' found!')
				elseif (GetResourceState("VehicleKeyChain") == "stopped") then
					print('^1[ERROR]^0 Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
				end
			end
		end)
	else
		print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
	end
end
GithubUpdater()