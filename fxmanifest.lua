fx_version 'adamant'
games { 'gta5' }

author 'Musiker15'
description 'ESX Better Engine Toggle'
version '3.1.4'

shared_script {
	'@es_extended/locale.lua',
	'locales/*.lua',
    'config.lua',
}

client_scripts {
	'client.lua',
}

server_scripts {
	'server.lua',
}