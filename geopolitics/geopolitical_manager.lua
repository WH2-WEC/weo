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


    _G.gpm = self
end








