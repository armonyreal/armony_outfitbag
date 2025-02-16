fx_version 'cerulean'
game 'gta5'

author 'Armony'
description 'Outfit Bag System using ox_inventory & ox_lib'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_inventory',
    'ox_lib',
    'oxmysql'
}
