if Config.UseCommand then
	RegisterCommand(Config.Commad, function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

local CurrentVersion = '2.6.2'
local GithubResourceName = 'EngineToggle'

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
	print("\n###############################")
	print('## ' .. GetCurrentResourceName())
	print('')
	print('## Current Version: ' .. CurrentVersion)
	print('## Newest Version: ' .. NewestVersion)
	print('')
	if CurrentVersion ~= NewestVersion then
		print('## Outdated')
		print('## Download Newest Version here: https://github.com/Musiker15/EngineToggle/releases')
		print("###############################\n")
	elseif CurrentVersion == NewestVersion then
		print('## Up to Date')
		print("###############################\n")
	end
end)