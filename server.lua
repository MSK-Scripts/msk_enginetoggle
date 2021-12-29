if Config.UseCommand then
	RegisterCommand(Config.Commad, function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

---- Github Updater ----

local CurrentVersion = '2.6.5'
local GithubResourceName = 'EngineToggle'

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
	print("\n###############################")
	print('## ' .. GetCurrentResourceName())
	print('')
	print('## Current Version: ' .. CurrentVersion)
	print('## Newest Version: ' .. NewestVersion)
	print('')
	if Config.VehicleKeyChain then
		if (GetResourceState("VehicleKeyChain") == "started") then
			print('## [READY] Das Script "VehicleKeyChain" wurde erfolgreich gefunden!')
			print('')
		elseif (GetResourceState("VehicleKeyChain") == "stopped") then
			print('## [ERROR] Das Script "VehicleKeyChain" wurde nicht gefunden!')
			print('## Stelle bitte sicher, dass das Script beim Server Start gestartet wird.')
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