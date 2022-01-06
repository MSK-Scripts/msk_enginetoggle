if Config.UseCommand then
	RegisterCommand(Config.Commad, function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

---- Github Updater ----

function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^2["..GetCurrentResourceName().."]^0"
local VehicleKeyChain = "^3[VehicleKeyChain]^0"

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
	print("###############################")
    if CurrentVersion == NewestVersion then
	    print(resourceName .. ' Resource is Up to Date.')
	    print('Current Version: ^2' .. CurrentVersion .. '^0')
		if Config.VehicleKeyChain then
			if (GetResourceState("VehicleKeyChain") == "started") then
				print('')
				print('## [READY] Script '.. VehicleKeyChain ..' found!')
			elseif (GetResourceState("VehicleKeyChain") == "stopped") then
				print('')
				print('## [ERROR] Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
			end
		end
    elseif CurrentVersion ~= NewestVersion then
        print(resourceName .. ' Resource Outdated. Please Update!')
		print('Current Version: ^1' .. CurrentVersion .. '^0')
	    print('Newest Version: ^2' .. NewestVersion .. '^0')
        print('Download Newest Version here: https://github.com/Musiker15/EngineToggle/releases')
		if Config.VehicleKeyChain then
			if (GetResourceState("VehicleKeyChain") == "started") then
				print('')
				print('^2[READY]^0 Script '.. VehicleKeyChain ..' found!')
			elseif (GetResourceState("VehicleKeyChain") == "stopped") then
				print('')
				print('^1[ERROR]^0 Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
			end
		end
    end
	print("###############################")
end)