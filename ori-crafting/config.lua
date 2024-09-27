-- config.lua
Config = {}

-- Crafting stations
Config.CraftingStations = {
    ["darnell_bros"] = { coords = vector3(717.5, -964.9, 30.4), name = "Darnell Bros Factory" }
}

-- Craftable items
Config.CraftableItems = {
    ["diamond_ring"] = { requiredItems = { ["diamond"] = 1, ["gold"] = 1 }, label = "Diamond Ring" }
}
