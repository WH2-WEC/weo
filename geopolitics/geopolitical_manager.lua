--[[
contains the subobjects of the factions, regions, and blacklist blacklist that are used to evaluate the system.
--]]


local geopolitic_blacklist = require("geopolitics/geopolitics_blacklists")
local geopolitic_faction = require("geopolitics/geopolitics_factions")
local geopolitic_region = require("geopolitics/geopolitics_regions")







local geopolitical_manager = {} --# assume geopolitical_manager: GEOPOLITICAL_MANAGER

function geopolitical_manager.init()
    local self = {}
    setmetatable(self, {
        __index = geopolitical_manager,
        __tostring = function() return "GEOPOLITICAL_MANAGER" end
    }) --# assume self: GEOPOLITICAL_MANAGER

    self._factions = {} --:map<string, GEOPOLITIC_FACTION>
    self._regions = {} --:map<string, GEOPOLITIC_REGION>
    self._blacklist = geopolitic_blacklist.init()
    
    self._factionRelations = {} --:map<string, map<string, number>>
    --This is a map<WHO BUNDLES ARE APPLIED TO, map<THE FACTION THE BUNDLE CONCERNS, QUANTITY OF THE BUNDLE>>
    _G.gpm = self
end

--v function(self: GEOPOLITICAL_MANAGER) --> GEOPOLITIC_BLACKLIST
function geopolitical_manager.blacklist(self)
    return self._blacklist
end

--v function(self: GEOPOLITICAL_MANAGER) --> map<string, GEOPOLITIC_FACTION>
function geopolitical_manager.get_factions(self)
    return self._factions
end

--v function(self: GEOPOLITICAL_MANAGER) --> map<string, GEOPOLITIC_REGION>
function geopolitical_manager.get_regions(self)
    return self._regions
end

--v function(self: GEOPOLITICAL_MANAGER, faction_key: string)
function geopolitical_manager.new_faction(self, faction_key)
    if not self._factions[faction_key] == nil then
        --LOG("ERROR: there is already a faction object for this faction!")
        return
    end
    local faction = geopolitic_faction.new(faction_key)
    --we give all factions a property equal to their name to simplify some relations.
    faction:add_property(faction_key)
    self._factions[faction_key] = faction
end

--v function(self: GEOPOLITICAL_MANAGER, region_key: string)
function geopolitical_manager.new_region(self, region_key)
    if not self._regions[region_key] == nil then
        --LOG("ERROR: there is already a faction object for this faction!")
        return
    end
    local region = geopolitic_faction.new(region_key)
    --we give all regions a property equal to their name to simplify some relations.
    region:add_property(region_key)
    self._factions[region_key] = region
end



--v function(self: GEOPOLITICAL_MANAGER, faction: string) --> GEOPOLITIC_FACTION
function geopolitical_manager.get_faction(self, faction)
    if self._factions[faction] == nil then
        self:new_faction(faction)
    end
    return self._factions[faction]
end

--v function(self: GEOPOLITICAL_MANAGER, region: string) --> GEOPOLITIC_REGION
function geopolitical_manager.get_region(self, region)
    if self._regions[region] == nil then
        self:new_region(region)
    end
    return self._regions[region]
end

--v function(self: GEOPOLITICAL_MANAGER, faction_key: string) --> map<string, number>
function geopolitical_manager.get_relations_table_for_faction(self, faction_key)
    if self._factionRelations[faction_key] == nil then
        self._factionRelations[faction_key] = {}
    end
    return self._factionRelations[faction_key]
end

--v function(self: GEOPOLITICAL_MANAGER, of_faction: string, to_faction: string) --> number
function geopolitical_manager.get_relation_value_of_faction_to_faction(self, of_faction, to_faction)
    local relations_table = self:get_relations_table_for_faction(of_faction)
    --nil case: faction has no set relation to other faction
    if relations_table[to_faction] == nil then
        relations_table[to_faction] = 0 
    end
    return relations_table[to_faction]
end

--v function(self: GEOPOLITICAL_MANAGER, of_faction: string, to_faction: string, relation_value: number)
function geopolitical_manager.set_relation_value_of_faction_to_faction(self, of_faction, to_faction, relation_value)
    local relations_table = self:get_relations_table_for_faction(of_faction)
    relations_table[to_faction] = relation_value
end






--active methods

--v function(self: GEOPOLITICAL_MANAGER, property: string, faction_object: CA_FACTION) --> boolean
function geopolitical_manager.can_faction_obtain_property(self, property, faction_object)
    local subculture = faction_object:subculture()
    local faction = faction_object:name()
    --check blacklists and return
    if self:blacklist():is_property_blacklisted_for_subculture(property, subculture) or self:blacklist():is_property_blacklisted_for_faction(property, faction) then
        return false
    else
        return true
    end
end

--takes the faction object for a faction and then assembles its obtained properties based on owned regions respecting the blacklist.
--v function(self: GEOPOLITICAL_MANAGER, faction: CA_FACTION)
function geopolitical_manager.assemble_obtained_properties_for_faction(self, faction)
    local faction_key = faction:name()
    local region_list = faction:region_list()
    local geo_faction = self:get_faction(faction_key)

    for i = 0, region_list:num_items() - 1 do
        local region_name = region_list:item_at(i):name()
        geo_faction:reset_properties_from_region(region_name)
        local geo_region = self:get_region(region_name)
        local region_properties = geo_region:get_properties()
        for j = 1, #region_properties do
            local current_property = region_properties[j]
            if self:can_faction_obtain_property(current_property, faction) then
                geo_faction:obtain_property_from_region(current_property, region_name)
            end
        end
    end
    geo_faction:reset_region_changed()
end




--v function(self: GEOPOLITICAL_MANAGER, target_faction: string, judging_faction: string)
function geopolitical_manager.evaluate_relations_between(self, target_faction, judging_faction)
    --TARGET FACTION is RECIEVING A BUNDLE that changes JUDGING FACTION's view of them
    local judge = self:get_faction(judging_faction)
    local target_properties = self:get_faction(target_faction):get_properties()
    local target_obtained_properties = self:get_faction(target_faction):get_obtained_property_list()
    
    local current_total = 0
    for i = 1, #target_properties do
        local current_property = target_properties[i]
        if judge:get_preference_for_property(current_property) then

        end
    end

end

