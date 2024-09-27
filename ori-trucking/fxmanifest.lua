-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'Bobbie McDylan'
description 'Truck Delivery Job for Ori Roleplay'
version '1.0.0'

-- QBCore is a dependency
shared_script '@qb-core/shared/locale.lua'

-- Client script to handle job logic, vehicle spawning, target interactions, and payments
client_script 'client/client.lua'

-- Dependencies
dependencies {
    'qb-core',       -- Required for using QBCore functions
    'qb-target'      -- Required for targeting system (third-eye)
}
