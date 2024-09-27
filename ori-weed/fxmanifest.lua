fx_version 'cerulean'
games { 'gta5' }

author 'Bob Dylan'
description 'Advanced Weed Script for Ori Roleplay'
version '1.0.0'

shared_scripts {
    'config.lua'
}

-- What to run
client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

