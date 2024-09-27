fx_version 'cerulean'
game 'gta5'

author 'Bobbie McDylan'
description 'Vehicle Lockpicking Script for Ori Roleplay'
version '1.0.0'

-- Dependencies
dependencies {
    'qb-core',      -- Requires qb-core
    'qb-target',    -- Requires qb-target for interaction
    'qb-inventory'  -- Requires qb-inventory for lockpick items
}

-- Client-side scripts
client_scripts {
    'client.lua'    -- Your main client-side script (make sure this name matches your file)
}

-- Server-side scripts
server_scripts {
    '@qb-core/shared.lua'  -- Shared QB-Core functions
}
-- Shared scripts (if any)
shared_scripts {
    '@qb-core/import.lua'  -- For importing QB-Core functions
}

lua54 'yes' -- Enable Lua 5.4 if you're using it