if not Config.UseKey then
	RegisterCommand(Config.Commad, function(Source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', Source)
		end
	end, false)
end

local CurrentVersion = '2.4'
local GithubResourceName = 'EngineToggle'

print('\n')
print('##############')
print('## ' .. GithubResourceName)
print('##')
print('## Current Version: ' .. CurrentVersion)
print('##')
print('##############')
print('\n')
