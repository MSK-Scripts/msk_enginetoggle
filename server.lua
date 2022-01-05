if Config.UseCommand then
	RegisterCommand(Config.Commad, function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

---- Github Updater ----

local CurrentVersion = '2.6.5'
local resourceName = "\x1b[32m["..GetCurrentResourceName().."]\x1b[0m"
local VehicleKeyChain = "\x1b[32m[VehicleKeyChain]\x1b[0m"

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
	print("\n###############################")
    if CurrentVersion == NewestVersion then
	    print(resourceName .. 'Resource is Up to Date')
	    print('## Current Version: ' .. CurrentVersion)
		print('')
		if Config.VehicleKeyChain then
			if (GetResourceState("VehicleKeyChain") == "started") then
				print('## [READY] Script '.. VehicleKeyChain ..' found!')
			elseif (GetResourceState("VehicleKeyChain") == "stopped") then
				print('## [ERROR] Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
			end
		end
    elseif CurrentVersion ~= NewestVersion then
        print(resourceName .. 'Resource Outdated. Please Update!')
		print('## Current Version: ' .. CurrentVersion)
	    print('## Newest Version: ' .. NewestVersion)
        print('## Download Newest Version here: https://github.com/Musiker15/EngineToggle/releases')
		print('')
		if Config.VehicleKeyChain then
			if (GetResourceState("VehicleKeyChain") == "started") then
				print('## [READY] Script '.. VehicleKeyChain ..' found!')
			elseif (GetResourceState("VehicleKeyChain") == "stopped") then
				print('## [ERROR] Script '.. VehicleKeyChain ..' not found! Please be sure, that '.. VehicleKeyChain ..' is started.')
			end
		end
    end
	print("###############################\n")
end)