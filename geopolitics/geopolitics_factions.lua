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



return {
    new = geopolitic_faction.new
}