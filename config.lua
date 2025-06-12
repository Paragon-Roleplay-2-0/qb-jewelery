Config = Config or {}

-- Set to true or false or GetConvar('UseTarget', 'false') == 'true' to use global option or script specific
-- These have to be a string thanks to how Convars are returned.
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.Target = 'ox' -- supported: 'ox' or 'qb'

Config.Timeout = 15 * (60 * 1000)

Config.RequiredCops = 0 -- 2

Config.Inventory = 'ox' -- supported: 'ox' or 'qb'

Config.JewelleryLocation = {
    ['coords'] = vector3(-630.5, -237.13, 38.08),
}

Config.WhitelistedWeapons = {
    [`weapon_assaultrifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_carbinerifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_carbinerifle_mk2`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pumpshotgun`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pumpshotgun_mk2`] = {
        ['timeOut'] = 10000
    },
    [`weapon_sawnoffshotgun`] = {
        ['timeOut'] = 10000
    },
    [`weapon_compactrifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_microsmg`] = {
        ['timeOut'] = 10000
    },
    [`weapon_autoshotgun`] = {
        ['timeOut'] = 10000
    },

    -- ADD ADDITIONAL WEAPONS HERE
}