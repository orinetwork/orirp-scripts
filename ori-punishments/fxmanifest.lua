fx_version 'cerulean'
game 'gta5'

author 'Bob Dylan'
description 'Punishment script for Ori Roleplay'
version '1.0.0'

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client/client.lua'
}
-- Server script
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}


-- Dependencies
dependencies {
    'NativeUI',
    'oxmysql'
}