--[[
Handles the white and black listing of properties for certain factions.
--]]



---PRIVATE FUNCTIONS


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


--PUBLIC FUNCTIONS

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

--v function(self: GEOPOLITIC_BLACKLIST, property: string, faction_object: CA_FACTION) --> boolean
function geopolitic_blacklist.can_faction_obtain_property(self, property, faction_object)
    local subculture = faction_object:subculture()
    local faction = faction_object:name()
    --check blacklists and return
    if self:is_property_blacklisted_for_subculture(property, subculture) or self:is_property_blacklisted_for_faction(property, faction) then
        return false
    else
        return true
    end
end


return {
    init = geopolitic_blacklist.init
}



