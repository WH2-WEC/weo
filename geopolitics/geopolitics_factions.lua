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
    self._factionKey = faction_key

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