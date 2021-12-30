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

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
	print("\n###############################")
	print('## ' .. resourceName)
	print('')
	print('## Current Version: ' .. CurrentVersion)
	print('## Newest Version: ' .. NewestVersion)
	print('')
	if Config.VehicleKeyChain then
		if (GetResourceState("VehicleKeyChain") == "started") then
			print('## [READY] Script "VehicleKeyChain" found!')
			print('')
		elseif (GetResourceState("VehicleKeyChain") == "stopped") then
			print('## [ERROR] Script "VehicleKeyChain" not found!')
			print('## Please be sure, that VehicleKeyChain is started.')
			print('')
		end
	end
	if CurrentVersion ~= NewestVersion then
		print('## Outdated')
		print('## Download Newest Version here: https://github.com/Musiker15/EngineToggle/releases')
		print("###############################\n")
	elseif CurrentVersion == NewestVersion then
		print('## Up to Date')
		print("###############################\n")
	end
end)