fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_enginetoggle'
description 'EngineToggle for Vehicles'
version '4.1.2'

lua54 'yes'

shared_script {
    'config.lua',
	'translation.lua'
}

client_scripts {
	'client/**/*.*'
}

server_scripts {
	'server/**/*.*'
}