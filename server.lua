if Config.UseCommand then
	RegisterCommand(Config.Commad, function(source, Arguments, RawCommand)
		if #Arguments == 0 then
			TriggerClientEvent('EngineToggle:Engine', source)
		end
	end, false)
end

---- Github Updater ----

function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"
local VehicleKeyChain = "^3[VehicleKeyChain]^0"

PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/EngineToggle/main/VERSION', function(Error, NewestVersion, Header)
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
        print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/EngineToggle/releases/tag/v'.. NewestVersion .. '^0')
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