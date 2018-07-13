
--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function GPLOG(text)
    ftext = "GEOPOLITICS" 

    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logContext = tostring(ftext)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end


--MOD SUBOBJECTS
    
--[[ OBTAINABLE PROPERTIES BLACKLISTS
Handles the white and black listing of properties for certain factions.
When certain factions own certain settlements, we don't want them getting all the properties from those settlements, only the ones which make sense. 
Example: you wouldn't want dwarfs getting a penalty with other dwarfs for owning a dwarf karak.
--]]



local geopolitic_blacklist = {} --# assume geopolitic_blacklist: GEOPOLITIC_BLACKLIST

--v function() --> GEOPOLITIC_BLACKLIST
function geopolitic_blacklist.init()
    local self = {}
    setmetatable(self, {
    __index = geopolitic_blacklist
    }) --# assume self: GEOPOLITIC_BLACKLIST

    self._factionPropertyBlackList = {} --:map<string, map<string, boolean>>
    self._subculturePropertyBlackList = {} --:map<string, map<string, boolean>>

    return self
end


--v function (self: GEOPOLITIC_BLACKLIST, property: string) --> map<string, boolean>
function geopolitic_blacklist.get_faction_blacklists_for_property(self, property)
    --eliminate nil cases
    if self._factionPropertyBlackList[property] == nil then
        self._factionPropertyBlackList[property] = {}
    end
    return self._factionPropertyBlackList[property]
end

--v function (self: GEOPOLITIC_BLACKLIST, property: string) --> map<string, boolean>
function geopolitic_blacklist.get_subculture_blacklists_for_property(self, property)
    --eliminate nil cases
    if self._subculturePropertyBlackList[property] == nil then
        self._subculturePropertyBlackList[property] = {}
    end
    return self._subculturePropertyBlackList[property]
end

--v function (self: GEOPOLITIC_BLACKLIST, property: string, faction: string) --> boolean
function geopolitic_blacklist.is_property_blacklisted_for_faction(self, property, faction)
    --nil case one, property has no black list
    if self._factionPropertyBlackList[property] == nil then
        self._factionPropertyBlackList[property] = {}
    end
    local blacklist_table = self._factionPropertyBlackList[property]
    --nil case two, faction has not been checked yet.
    if blacklist_table[faction] == nil then
        blacklist_table[faction] = false
    end
    return blacklist_table[faction]
end

--v function (self: GEOPOLITIC_BLACKLIST, property: string, subculture: string) --> boolean
function geopolitic_blacklist.is_property_blacklisted_for_subculture(self, property, subculture)
    --nil case one, property has no black list
    if self._subculturePropertyBlackList[property] == nil then
        self._subculturePropertyBlackList[property] = {}
    end
    local blacklist_table = self._subculturePropertyBlackList[property]
    --nil case two, faction has not been checked yet.
    if blacklist_table[subculture] == nil then
        blacklist_table[subculture] = false
    end
    return blacklist_table[subculture]
end


--EXTERNALS

--v function(self: GEOPOLITIC_BLACKLIST, property: string, faction: string)
function geopolitic_blacklist.set_faction_blacklisted_for_property(self, property, faction)
    local property_blacklist = self:get_faction_blacklists_for_property(property)
    property_blacklist[faction] = true
end

--v function(self: GEOPOLITIC_BLACKLIST, property: string, subculture: string)
function geopolitic_blacklist.set_subculture_blacklisted_for_property(self, property, subculture)
    local property_blacklist = self:get_subculture_blacklists_for_property(property)
    property_blacklist[subculture] = true
end

--v function(self: GEOPOLITIC_BLACKLIST, property: string, faction: string)
function geopolitic_blacklist.set_faction_permitted_for_property(self, property, faction)
    local property_blacklist = self:get_faction_blacklists_for_property(property)
    property_blacklist[faction] = false
end

--v function(self: GEOPOLITIC_BLACKLIST, property: string, subculture: string)
function geopolitic_blacklist.set_subculture_permitted_for_property(self, property, subculture)
    local property_blacklist = self:get_subculture_blacklists_for_property(property)
    property_blacklist[subculture] = false
end

--[[ GEOPOLITICAL FACTION TRACKERS
Store the properties, preferences, and obtained properties of each faction
--]]


local geopolitic_faction = {} --# assume geopolitic_faction: GEOPOLITIC_FACTION


--v function(faction_key: string) --> GEOPOLITIC_FACTION
function geopolitic_faction.new(faction_key)
    local self = {}
    setmetatable(self, {
        __index = geopolitic_faction,
        __tostring = function() return "GEOPOLITICS_FACTION" end
    }) --# assume self: GEOPOLITIC_FACTION

    self._preferences = {} --:map<string, number>
    self._properties = {} --:vector<string>
    self._obtainedProperties = {} --:map<string, vector<string>>
    self._factionKey = faction_key
    self._numberRegion = 0 --:number
    self._regionChangeFlag = true --:boolean

    return self
end

--v function (self: GEOPOLITIC_FACTION) --> string
function geopolitic_faction.name(self)
    return self._factionKey
end


--v function (self: GEOPOLITIC_FACTION) --> vector<string>
function geopolitic_faction.get_properties(self)
    return self._properties
end

--v function (self: GEOPOLITIC_FACTION) --> map<string, number>
function geopolitic_faction.get_preferences(self)
    return self._preferences
end

--v function(self: GEOPOLITIC_FACTION) --> map<string, vector<string>>
function geopolitic_faction.get_obtained_properties(self)
    return self._obtainedProperties
end

--v function(self: GEOPOLITIC_FACTION) --> vector<string> 
function geopolitic_faction.get_obtained_property_list(self)
    local list = {} --:vector<string>
    for region_name, properties in pairs(self:get_obtained_properties()) do
        for i = 1, #properties do
            table.insert(list, properties[i])
        end
    end
    return list
end

--v function (self: GEOPOLITIC_FACTION, property: string, preference: number) 
function geopolitic_faction.set_preference_for_property(self, property, preference)
    local preferences = self:get_preferences()
    preferences[property] = preference
end

--v function (self: GEOPOLITIC_FACTION, property: string) --> number
function geopolitic_faction.get_preference_for_property(self, property)
    local preferences = self:get_preferences()
    if preferences[property] == nil then
        preferences[property] = 0
    end
    return preferences[property]
end

--v function (self: GEOPOLITIC_FACTION, property: string)
function geopolitic_faction.add_property(self, property)
    table.insert(self:get_properties(), property)
end

--v function (self: GEOPOLITIC_FACTION, property: string)
function geopolitic_faction.remove_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do
        if properties[i] == property then
            table.remove(properties, i)
            break
        end
    end
end

--v function (self: GEOPOLITIC_FACTION, property: string, region_key: string)
function geopolitic_faction.obtain_property_from_region(self, property, region_key)
    local properties = self:get_obtained_properties()
    if properties[region_key] == nil then
        properties[region_key] = {}
    end
    table.insert(properties[region_key], property)
end

--v function(self: GEOPOLITIC_FACTION, region: string) --> boolean
function geopolitic_faction.has_properties_from_region(self, region)
    if self:get_obtained_properties()[region] == nil then
        return false
    else
        return true
    end
end

--v function(self: GEOPOLITIC_FACTION, region: string)
function geopolitic_faction.reset_properties_from_region(self, region)
    self:get_obtained_properties()[region] = nil
end



--v function (self: GEOPOLITIC_FACTION, property: string) --> boolean
function geopolitic_faction.has_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do 
        if properties[i] == property then
            return true
        end
    end
    return false
end


--v function(self: GEOPOLITIC_FACTION) --> boolean
function geopolitic_faction.has_region_changed(self)
    return self._regionChangeFlag
end

--v function(self: GEOPOLITIC_FACTION)
function geopolitic_faction.set_region_changed(self)
    self._regionChangeFlag = true
end

--v function(self: GEOPOLITIC_FACTION)
function geopolitic_faction.reset_region_changed(self)
    self._regionChangeFlag = false
end


--v function(self: GEOPOLITIC_FACTION, regions: number)
function geopolitic_faction.set_region_number(self, regions)
    self._numberRegion = regions
end

--v function(self: GEOPOLITIC_FACTION) --> number
function geopolitic_faction.num_regions(self)
    return self._numberRegion
end

--[[ GEOPOLITICAL REGION INSTANCES
    These hold the properties of each region.
--]]


local geopolitic_region = {} --# assume geopolitic_region: GEOPOLITIC_REGION

--v function(region_name: string) --> GEOPOLITIC_REGION
function geopolitic_region.new(region_name)
    local self = {}
    setmetatable(self, {
        __index = geopolitic_region,
        __tostring = function() return "GEOPOLITIC_REGION" end
    }) --# assume self: GEOPOLITIC_REGION

    self._name = region_name
    self._properties = {} --:vector<string>

    return self
end

--v function(self: GEOPOLITIC_REGION) --> string
function geopolitic_region.name(self)
    return self._name
end

--v function(self: GEOPOLITIC_REGION) --> vector<string>
function geopolitic_region.get_properties(self)
    return self._properties
end

--v function (self: GEOPOLITIC_REGION, property: string)
function geopolitic_region.add_property(self, property)
    table.insert(self:get_properties(), property)
end

--v function (self: GEOPOLITIC_REGION, property: string)
function geopolitic_region.remove_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do
        if properties[i] == property then
            table.remove(properties, i)
            break
        end
    end
end

--v function (self: GEOPOLITIC_REGION, property: string) --> boolean
function geopolitic_region.has_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do 
        if properties[i] == property then
            return true
        end
    end
    return false
end

--[[ GEOPOLITICAL DEFAULTS LOADER
 --this holds information about the properties to assign to each faction or region as they are created.
]]
local geopolitic_loader = {} --# assume geopolitic_loader: GEOPOLITIC_LOADER

--v function() --> GEOPOLITIC_LOADER
function geopolitic_loader.init() 
    local self = {}
    setmetatable(self, {
        __index = geopolitic_loader,
        __tostring = function() return "GEOPOLITIC_LOADER" end
    }) --# assume self: GEOPOLITIC_LOADER

    --properties
    self._subcultureProperties = {} --:map<string, vector<string>>
    self._factionProperties = {} --:map<string, vector<string>>
    self._regionDefaults = {} --:map<string, vector<string>>
    self._regionGroupDefaults = {} --:map<string, vector<string>>
    self._regionToRegionGroup = {} --:map<string, string>
    --preferences
    self._subculturePreferences = {} --:map<string, map<string, number>>
    self._factionPreferences = {} --:map<string, map<string, number>>


    return self
end


--v function(self: GEOPOLITIC_LOADER, subculture: string) --> vector<string>
function geopolitic_loader.get_default_properties_for_subculture(self, subculture)
    if self._subcultureProperties[subculture] == nil then
        self._subcultureProperties[subculture] = {}
    end
    return self._subcultureProperties[subculture]
end

--v function(self: GEOPOLITIC_LOADER, faction: string) --> vector<string>
function geopolitic_loader.get_default_properties_for_faction(self, faction)
    if self._factionProperties[faction] == nil then
        self._factionProperties[faction] = {}
    end
    return self._factionProperties[faction]
end

--v function(self: GEOPOLITIC_LOADER, region: string) --> vector<string>
function geopolitic_loader.get_default_properties_for_region(self, region)
    if self._regionDefaults[region] == nil then
        self._regionDefaults[region] = {}
    end
    return self._regionDefaults[region]
end

--v function(self: GEOPOLITIC_LOADER, region: string) --> vector<string>
function geopolitic_loader.get_default_group_properties_for_region(self, region)
    local group = self._regionToRegionGroup[region]
    if group == nil then
        return {}
    end
    if self._regionGroupDefaults[group] == nil then
        self._regionGroupDefaults[group] = {}
    end
    return self._regionGroupDefaults[group]
end

--v function(self: GEOPOLITIC_LOADER, subculture: string) --> map<string, number>
function geopolitic_loader.get_default_preferences_for_subculture(self, subculture)
    if self._subculturePreferences[subculture] == nil then
        self._subculturePreferences[subculture] = {}
    end
    return self._subculturePreferences[subculture]
end 

--v function(self: GEOPOLITIC_LOADER, faction: string) --> map<string, number>
function geopolitic_loader.get_default_preferences_for_faction(self, faction)
    if self._factionPreferences[faction] == nil then
        self._factionPreferences[faction] = {}
    end
    return self._factionPreferences[faction]
end 



---assignment

--v function(self: GEOPOLITIC_LOADER, subculture: string, property: string)
function geopolitic_loader.add_default_property_for_subculture(self, subculture, property)
    if self._subcultureProperties[subculture] == nil then
        self._subcultureProperties[subculture] = {}
    end
    table.insert(self._subcultureProperties[subculture], property)
end

--v function(self: GEOPOLITIC_LOADER, faction: string, property: string)
function geopolitic_loader.add_default_property_for_faction(self, faction, property)
    if self._factionProperties[faction] == nil then
        self._factionProperties[faction] = {}
    end
    table.insert(self._factionProperties[faction], property)
end

--v function(self: GEOPOLITIC_LOADER, region: string, property: string)
function geopolitic_loader.add_default_property_for_region(self, region, property)
    if self._regionDefaults[region] == nil then
        self._regionDefaults[region] = {}
    end
    table.insert(self._regionDefaults[region], property)
end

--v function(self: GEOPOLITIC_LOADER, region_group: string, property: string)
function geopolitic_loader.add_default_property_for_region_group(self, region_group, property)
    if self._regionGroupDefaults[region_group] == nil then
        self._regionGroupDefaults[region_group] = {}
    end
    table.insert(self._regionGroupDefaults[region_group], property)
end
    
--v function(self: GEOPOLITIC_LOADER, subculture: string, property: string, value: number)
function geopolitic_loader.add_default_preference_for_subculture(self, subculture, property, value)
    if self._subculturePreferences[subculture] == nil then
        self._subculturePreferences[subculture] = {}
    end
    self._subculturePreferences[subculture][property] = value
end

--v function(self: GEOPOLITIC_LOADER, faction: string, property: string, value: number)
function geopolitic_loader.add_default_preference_for_faction(self, faction, property, value)
    if self._factionPreferences[faction] == nil then
        self._factionPreferences[faction] = {}
    end
    self._factionPreferences[faction][property] = value
end


--region grouping
--v function(self: GEOPOLITIC_LOADER, region: string, group: string)
function geopolitic_loader.add_region_to_group(self, region, group)
    self._regionToRegionGroup[region] = group
end



-------------------------
----CORE MOD OBJECT------
-------------------------



--[[GEOPOLITICAL MANAGER
Holds the Relationship matrix and a library of subobjects to track the assignment of properties and calculations of relations based upon them.
--]]


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
    self._propertyLoader = geopolitic_loader.init()
    
    self._factionRelations = {} --:map<string, map<string, number>>
    --This is a map<WHO BUNDLES ARE APPLIED TO, map<THE FACTION THE BUNDLE CONCERNS, QUANTITY OF THE BUNDLE>>
    _G.gpm = self
end

--v function(self: GEOPOLITICAL_MANAGER, text: any)
function geopolitical_manager.log(self, text)
    GPLOG(tostring(text))
end


--v function(self: GEOPOLITICAL_MANAGER) --> map<string, map<string, number>>
function geopolitical_manager.save(self)
    return self._factionRelations
end

--v function(self: GEOPOLITICAL_MANAGER, savetable: map<string, map<string, number>>)
function geopolitical_manager.load(self, savetable)
    self._factionRelations = savetable
end



--v function(self: GEOPOLITICAL_MANAGER) --> GEOPOLITIC_BLACKLIST
function geopolitical_manager.blacklist(self)
    return self._blacklist
end

--v function(self: GEOPOLITICAL_MANAGER) --> GEOPOLITIC_LOADER
function geopolitical_manager.loader(self)
    return self._propertyLoader
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
        self:log("ERROR: new_faction called but there is already a faction object for this faction_key!")
        return
    end
    self:log("Creating faction ["..faction_key.."]")
    local geo_faction = geopolitic_faction.new(faction_key)
    --we give all factions a property equal to their name to simplify some relations.
    geo_faction:add_property(faction_key)
    --now we want to find the defaults for this faction from the loader.
    local subculture = cm:get_faction(faction_key):subculture()
    --add default properties
    local subculture_properties = self:loader():get_default_properties_for_subculture(subculture)
    local faction_properties = self:loader():get_default_properties_for_faction(faction_key)
    for i = 1, #subculture_properties do
        geo_faction:add_property(subculture_properties[i])
    end
    for i = 1, #faction_properties do
        geo_faction:add_property(faction_properties[i])
    end
    --add default preferences
    local subculture_preferences = self:loader():get_default_preferences_for_subculture(subculture)
    local faction_preferences = self:loader():get_default_preferences_for_faction(faction_key)
    for property, preference in pairs(subculture_preferences) do
        geo_faction:set_preference_for_property(property, preference)
    end
    for property, preference in pairs(faction_preferences) do
        geo_faction:set_preference_for_property(property, preference)
    end
    self._factions[faction_key] = geo_faction
end

--v function(self: GEOPOLITICAL_MANAGER, region_key: string)
function geopolitical_manager.new_region(self, region_key)
    if not self._regions[region_key] == nil then
        self:log("ERROR: new_region called but there is already a region object for this region_key!")
        return
    end
    self:log("Creating region ["..region_key.."] ")
    local geo_region = geopolitic_faction.new(region_key)
    --we give all regions a property equal to their name to simplify some relations.
    geo_region:add_property(region_key)
    --add the default properties of that region
    local region_properties = self:loader():get_default_properties_for_region(region_key)
    local region_grouped_properties = self:loader():get_default_group_properties_for_region(region_key)
    for i = 1, #region_properties do 
        geo_region:add_property(region_properties[i])
    end
    for i = 1, #region_grouped_properties do
        geo_region:add_property(region_grouped_properties[i])
    end

    self._factions[region_key] = geo_region
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
    self:log("assembled obtained properties for faction ["..faction:name().."]")
    geo_faction:set_region_number(region_list:num_items())
    geo_faction:reset_region_changed()
end




--v function(self: GEOPOLITICAL_MANAGER, target_faction: string, judging_faction: string)
function geopolitical_manager.evaluate_relations_between(self, target_faction, judging_faction)
    --TARGET FACTION is RECIEVING A BUNDLE that changes JUDGING FACTION's view of them
    local judge = self:get_faction(judging_faction)
    local target_properties = self:get_faction(target_faction):get_properties()
    local target_obtained_properties = self:get_faction(target_faction):get_obtained_property_list()
    
    local current_total = 0 --:number
    --cycle through inherent properties
    for i = 1, #target_properties do
        local current_property = target_properties[i]
        local preference = judge:get_preference_for_property(current_property)
        current_total = current_total + preference
    end
    --cycle through obtained properties
    for i = 1, #target_obtained_properties do
        local current_property = target_obtained_properties[i]
        local preference = judge:get_preference_for_property(current_property)
        current_total = current_total + preference
    end
    --set the relation
    self:log("Evaluated the relation between target faction ["..target_faction.."] and judging faction ["..judging_faction.."] to be ["..current_total.."]; changed from ["..self:get_relation_value_of_faction_to_faction(target_faction, judging_faction).."] ")
    self:set_relation_value_of_faction_to_faction(target_faction, judging_faction, current_total)
end


--v function(self: GEOPOLITICAL_MANAGER, faction_object: CA_FACTION)
function geopolitical_manager.evaluate_all_relations_for_faction(self, faction_object)
    local faction_name = faction_object:name()
    local met_list = faction_object:factions_met()

    for i = 0, met_list:num_items() - 1 do
        self:evaluate_relations_between(faction_name, met_list:item_at(i):name())
    end
end




--v function(self: GEOPOLITICAL_MANAGER, target_faction: string)
function geopolitical_manager.apply_bundles_for(self, target_faction)
    local relations_table = self:get_relations_table_for_faction(target_faction)
    for faction_key, bundle_value in pairs(relations_table) do
        local bundle_name_raw = "wec_geopolitics_"..faction_key.."_"..tostring(bundle_value)
        local bundle_name = string.gsub(bundle_name_raw, "-", "n")
        if not cm:get_saved_value("geopolitics_last_bundle_"..target_faction.."_"..faction_key) == nil then
            cm:remove_effect_bundle(cm:get_saved_value("geopolitics_last_bundle_"..target_faction.."_"..faction_key), target_faction)
        end
        cm:apply_effect_bundle(bundle_name, target_faction, 0)
        cm:set_saved_value("geopolitics_last_bundle_"..target_faction.."_"..faction_key, bundle_name)
        self:log("applied bundle ["..bundle_name.."] to faction ["..target_faction.."] ")
    end
end


geopolitical_manager.init()

cm:add_saving_game_callback( function(context)
    if not not _G.gpm then
        local gpm = _G.gpm
        local geopolitics_save_table = gpm:save()
        cm:save_named_value("geopolitics_save_table", geopolitics_save_table, context)
    end
end)

cm:add_loading_game_callback( function(context)
    if not not _G.gpm then
        local gpm = _G.gpm
        local geopolitics_save_table = cm:load_named_value("geopolitics_table_table", {}, context)
        gpm:load(geopolitics_save_table)
    end
end)
