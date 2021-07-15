resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Engine Toggle On/Off'
Author 'Musiker15'
version '2.3.5'

server_script { 
	'config.lua',
	'server/server.lua',
}

client_script {	
	'config.lua',
	'client/client.lua',
}