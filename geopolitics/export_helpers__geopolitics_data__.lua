cm = get_cm(); events = get_events(); gpm = _G.gpm;

local blacklist = gpm:blacklist()
local loader = gpm:loader()


--[[-VALID LOADER FUNCTIONS
DESCRIPTION: 
[
    Since we don't really know when the objects for these factions are going to exist, we instead add a set of traits to the "loader" which are given
    automatically to each faction when their geopolitical object is created.
]
loader:add_default_preference_for_faction("faction_key", "property_key", #preference_value#)
loader:add_default_preference_for_subculture("sc_key", "property_key", #preference_value#)
loader:add_region_to_group("region_key", "group_key")
loader:add_default_property_for_subculture("sc_key", "property_key")
loader:add_default_property_for_faction("faction_key", "property_key")
loader:add_default_property_for_region("region_key", "property_key")
loader:add_default_property_for_region_group("group_key", "property_key")
loader:add_default_preference_for_faction("faction_key", "property_key", #preference_value#)
loader:add_default_preference_for_subculture("sc_key", "property_key", #preference_value#)
--]]


--[[-VALID BLACKLIST FUNCTIONS
DESCRIPTION: 
[
    Since factions inherit traits through the regions they own, it is often undesirable for a faction to get a trait from a region, because it doesn't fit them.
    Dynamically adding and removing traits from the region would be hard, so instead we have a blacklist which can prevent certain factions or subcultures from
    getting traits which don't fit them. 
]
blacklist:set_faction_blacklisted_for_property("property_key", "faction_key")
blacklist:set_subculture_blacklisted_for_property("property_key", "sc_key")
--]]