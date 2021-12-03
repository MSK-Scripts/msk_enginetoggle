if not UseKey then
	RegisterCommand("engine", function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

local CurrentVersion = '2.3.5'
local GithubResourceName = 'EngineToggle'

PerformHttpRequest('https://github.com/Musiker15/EngineToggle/master/' .. GithubResourceName .. '/VERSION', function(Error, NewestVersion, Header)
	PerformHttpRequest('https://github.com/Musiker15/EngineToggle/master/' .. GithubResourceName .. '/CHANGES', function(Error, Changes, Header)
		print('\n')
		print('##############')
		print('## ' .. GetCurrentResourceName())
		print('##')
		print('## Current Version: ' .. CurrentVersion)
		print('##')
		--print('## Up to date!')
		print('##############')
		print('\n')
	end)
end)
