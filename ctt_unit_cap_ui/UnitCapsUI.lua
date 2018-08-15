local unit_caps_ui = {} --# assume unit_caps_ui: UNIT_CAPS_UI


--v function()
function unit_caps_ui.init()
    local self = {}
    setmetatable(self, {
        __index = unit_caps_ui
    }) --# assume self: UNIT_CAPS_UI
    --cap counting
    self._regionsToUnits = {} --:map<string, map<string, number>>
    self._staleRegions = {} --:map<string, boolean>
    self._buildingLevelImpacts = {} --:map<string, map<string, number>>
    self._unitBaseCaps = {} --:map<string, number>
    self._cappedUnits = {} --:map<string, boolean>
    --unit counting
    self._armyUnitCounts = {} --:map<CA_CQI, map<string, number>>
    self._staleArmies = {} --:map<CA_CQI, boolean>
    --final totals
    self._globalUnitCounts = {} --:map<string, number>
    self._globalUnitCaps = {} --:map<string, number> 
    self._capsStale = true --:boolean
    self._countsStale = true --:boolean


    _G.unit_cap_display = self
end


--v function(self: UNIT_CAPS_UI, unit: string) --> boolean
function unit_caps_ui.is_unit_capped(self, unit)
    return not not self._cappedUnits[unit]
end

--v function(self: UNIT_CAPS_UI, unit: string)
function unit_caps_ui.unit_has_caps(self, unit)
    self._cappedUnits[unit] = true
end

--v function(self: UNIT_CAPS_UI) --> map<string, boolean>
function unit_caps_ui.capped_units(self)
    return self._cappedUnits
end




--region buildings--
--------------------



--v function(self: UNIT_CAPS_UI, region: string)
function unit_caps_ui.reset_region_unit_cap_contributions(self, region)
    self._regionsToUnits[region] = {}
end

--v function(self: UNIT_CAPS_UI, region: string, unit: string, cap_contribution: number)
function unit_caps_ui.increase_region_unit_cap_contribution(self, region, unit, cap_contribution)
    if self._regionsToUnits[region] == nil then
        self._regionsToUnits[region] = {}
    end
    if self._regionsToUnits[region][unit] == nil then
        self._regionsToUnits[region][unit] = 0
    end
    self._regionsToUnits[region][unit] = self._regionsToUnits[region][unit] + cap_contribution 
end



--v function(self: UNIT_CAPS_UI, region: string)
function unit_caps_ui.set_region_fresh(self, region)
    self._staleRegions[region] = true
end

--v function(self: UNIT_CAPS_UI, region: string)
function unit_caps_ui.set_region_stale(self, region)
    self._staleRegions[region] = false
    self._capsStale = true
end

--v function(self: UNIT_CAPS_UI, region: string) --> boolean
function unit_caps_ui.is_region_fresh(self, region)
    if self._staleRegions[region] == nil then
        self._staleRegions[region] = false
    end
    return self._staleRegions[region]
end


--v function(self: UNIT_CAPS_UI, building_level: string) --> map<string, number>
function unit_caps_ui.get_cap_contributions_of_building_level(self, building_level)
    if self._buildingLevelImpacts[building_level] == nil then
        self._buildingLevelImpacts[building_level] = {}
    end
    return self._buildingLevelImpacts[building_level]
end

--v function(self: UNIT_CAPS_UI, building_level: string, unit_key: string, contribution: number)
function unit_caps_ui.set_cap_contribution_of_building_level(self, building_level, unit_key, contribution)
    self:unit_has_caps(unit_key)
    if self._buildingLevelImpacts[building_level] == nil then
        self._buildingLevelImpacts[building_level] = {}
    end
    self._buildingLevelImpacts[building_level][unit_key] = contribution
end

--v function(self: UNIT_CAPS_UI, building_level: string, unit_key: string) --> number
function unit_caps_ui.get_cap_contribution_of_building_for_unit(self, building_level, unit_key)
    if self._buildingLevelImpacts[building_level] == nil then
        self._buildingLevelImpacts[building_level] = {}
    end
    if self._buildingLevelImpacts[building_level][unit_key] == nil then
        self._buildingLevelImpacts[building_level][unit_key] = 0
    end
    return self._buildingLevelImpacts[building_level][unit_key]
end

--v function(self: UNIT_CAPS_UI, region_key: string)
function unit_caps_ui.evaluate_region(self, region_key)
    local region = cm:get_region(region_key)
    self:reset_region_unit_cap_contributions(region_key)
    local building_list = region:settlement():slot_list()
    for i = 0, building_list:num_items() - 1 do
        local slot = building_list:item_at(i)
        if slot:has_building() then
            local building = slot:building():name()
            local contributions = self:get_cap_contributions_of_building_level(building)
            for unit, quantity in pairs(contributions) do
                self:increase_region_unit_cap_contribution(region_key, unit, quantity)
            end
        end
    end
    self:set_region_fresh(region_key)
end

--v function(self: UNIT_CAPS_UI, region: string, unit: string) --> number
function unit_caps_ui.get_region_unit_cap_contribution(self, region, unit)
    if not self:is_region_fresh(region) then
        self:evaluate_region(region)
    end
    if self._regionsToUnits[region][unit] == nil then
        self._regionsToUnits[region][unit] = 0 
    end
    return self._regionsToUnits[region][unit]
end

--base caps--
-------------

--v function(self: UNIT_CAPS_UI, unit_key: string) --> number
function unit_caps_ui.get_base_cap_of_unit(self, unit_key)
    if self._unitBaseCaps[unit_key] == nil then
        self._unitBaseCaps[unit_key] = 0 
    end
    return self._unitBaseCaps[unit_key]
end

--v function(self: UNIT_CAPS_UI, unit_key: string, base_cap: number)
function unit_caps_ui.set_unit_base_cap(self, unit_key, base_cap)
    self:unit_has_caps(unit_key)
    self._unitBaseCaps[unit_key] = 0 
end



--unit counts--
---------------


--v function(self: UNIT_CAPS_UI, cqi: CA_CQI) --> boolean
function unit_caps_ui.is_army_fresh(self, cqi)
    if self._staleArmies[cqi] == nil then
        self._staleArmies[cqi] = false
    end
    return self._staleArmies[cqi]
end


--v function(self: UNIT_CAPS_UI, cqi: CA_CQI)
function unit_caps_ui.set_army_fresh(self, cqi)
    self._staleArmies[cqi] = true
end

--v function(self: UNIT_CAPS_UI, cqi: CA_CQI)
function unit_caps_ui.set_army_stale(self, cqi)
    self._staleArmies[cqi] = false
    self._countsStale = true
end

--v function(self: UNIT_CAPS_UI, cqi: CA_CQI)
function unit_caps_ui.evaluate_army(self, cqi)
    local character = cm:get_character_by_cqi(cqi)
    self._armyUnitCounts[cqi] = {}
    if not character:has_military_force() then
        return
    end
    local unit_list = character:military_force():unit_list()
    for i = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(i):unit_key()
        if self._armyUnitCounts[cqi][unit] == nil then
            self._armyUnitCounts[cqi][unit] = 0
        end
        self._armyUnitCounts[cqi][unit] = self._armyUnitCounts[cqi][unit] + 1;
    end
end


--v function(self: UNIT_CAPS_UI, cqi: CA_CQI, unit: string) --> number
function unit_caps_ui.get_quantity_of_unit_in_army(self, cqi, unit)
    if not self:is_army_fresh(cqi) then
        self:evaluate_army(cqi)
    end
    if self._armyUnitCounts[cqi][unit] == nil then
        self._armyUnitCounts[cqi][unit] = 0
    end
    return  self._armyUnitCounts[cqi][unit]
end




--totals--
----------


--v function(self: UNIT_CAPS_UI)
function unit_caps_ui.reset_global_caps(self)
    self._globalUnitCaps = {}
end

--v function(self: UNIT_CAPS_UI)
function unit_caps_ui.reset_global_counts(self)
    self._globalUnitCounts = {}
end



--v function(self: UNIT_CAPS_UI, unit_key: string, cap: number)
function unit_caps_ui.increment_global_cap_for_unit(self, unit_key, cap)
    if self._globalUnitCaps[unit_key] == nil then 
        self._globalUnitCaps[unit_key] = 0
    end
    self._globalUnitCaps[unit_key] = self._globalUnitCaps[unit_key] + cap
end

--v function(self: UNIT_CAPS_UI, unit_key: string, count: number)
function unit_caps_ui.increment_global_count_for_unit(self, unit_key, count)
    if self._globalUnitCounts[unit_key] == nil then
        self._globalUnitCounts[unit_key] = 0
    end
    self._globalUnitCounts[unit_key] = self._globalUnitCounts[unit_key] + count
end

--v function(self: UNIT_CAPS_UI) --> boolean
function unit_caps_ui.are_counts_stale(self)
    return self._countsStale
end

--v function(self: UNIT_CAPS_UI) --> boolean
function unit_caps_ui.are_caps_stale(self)
    return self._capsStale
end

--v function(self: UNIT_CAPS_UI)
function unit_caps_ui.evaluate_counts(self)
    self:reset_global_counts()
    local human_faction = cm:get_faction(cm:get_local_faction(true))
    local char_list = human_faction:character_list()
    for i = 0, char_list:num_items() - 1 do
        local character = char_list:item_at(i)
        if character:has_military_force() then
            for unit, is_capped in pairs(self:capped_units()) do
                if is_capped then
                    local count = self:get_quantity_of_unit_in_army(character:cqi(), unit)
                    self:increment_global_count_for_unit(unit, count)
                end
            end
        end
    end
    self._countsStale = false
end

--v function(self: UNIT_CAPS_UI)
function unit_caps_ui.evaluate_caps(self)
    self:reset_global_caps()
    local human_faction = cm:get_faction(cm:get_local_faction(true))
    local region_list = human_faction:region_list()
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        for unit, is_capped in pairs(self:capped_units()) do
            if is_capped then
                local cap = self:get_region_unit_cap_contribution(region:name(), unit)
                self:increment_global_cap_for_unit(unit, cap)
            end
        end
    end
    self._capsStale = false
end

--v function(self: UNIT_CAPS_UI, unit_key: string) --> number
function unit_caps_ui.get_global_count_for_unit(self, unit_key)
    if self:are_counts_stale() then
        self:evaluate_counts()
    end
    if self._globalUnitCounts[unit_key] == nil then
        self._globalUnitCounts[unit_key] = 0
    end
    return self._globalUnitCounts[unit_key]
end


--v function(self: UNIT_CAPS_UI, unit_key: string) --> number
function unit_caps_ui.get_global_cap_for_unit(self, unit_key)
    if self:are_caps_stale() then
        self:evaluate_caps()
    end
    return self._globalUnitCaps[unit_key]
end
    