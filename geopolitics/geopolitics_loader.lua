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
    self._subculturePreferences = {} --:map<string, vector<string>>
    self._factionPreferences = {} --:map<string, vector<string>>


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
function geopolitic_loader.get_defaults_for_region(self, region)
    if self._regionDefaults[region] == nil then
        self._regionDefaults[region] = {}
    end
    return self._regionDefaults[region]
end

--v function(self: GEOPOLITIC_LOADER, region: string) --> vector<string>
function geopolitic_loader.get_group_defaults_for_region(self, region)
    local group = self._regionToRegionGroup[region]
    if group == nil then
        return {}
    end
    if self._regionGroupDefaults[group] == nil then
        self._regionGroupDefaults[group] = {}
    end
    return self._regionGroupDefaults[group]
end

--v function(self: GEOPOLITIC_LOADER, subculture: string) --> vector<string>
function geopolitic_loader.get_preferences_defaults_for_subculture(self, subculture)
    if self._subculturePreferences[subculture] == nil then
        self._subculturePreferences[subculture] = {}
    end
    return self._subculturePreferences[subculture]
end 

--v function(self: GEOPOLITIC_LOADER, faction: string) --> vector<string>
function geopolitic_loader.get_preferences_defaults_for_faction(self, faction)
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
    
--v function(self: GEOPOLITIC_LOADER, subculture: string, property: string)
function geopolitic_loader.add_default_preference_for_subculture(self, subculture, property)
    if self._subculturePreferences[subculture] == nil then
        self._subculturePreferences[subculture] = {}
    end
    table.insert(self._subculturePreferences[subculture], property)
end

--v function(self: GEOPOLITIC_LOADER, faction: string, property: string)
function geopolitic_loader.add_default_preference_for_faction(self, faction, property)
    if self._factionPreferences[faction] == nil then
        self._factionPreferences[faction] = {}
    end
    table.insert(self._factionPreferences[faction], property)
end


--region grouping
--v function(self: GEOPOLITIC_LOADER, region: string, group: string)
function geopolitic_loader.add_region_to_group(self, region, group)
    self._regionToRegionGroup[region] = group
end





return {
    init = geopolitic_loader.init
}