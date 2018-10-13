--# assume global class CT
--# assume global class CT_REGION
--# assume global class CT_FACTION
--# assume global class CT_BUILDING

--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function CTLOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("PM :  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end



local cap_tracker = {} --# assume cap_tracker: CT
local cap_region = {} --# assume cap_region: CT_REGION
local cap_faction = {} --# assume cap_faction: CT_FACTION
local cap_building = {} --# assume cap_building: CT_BUILDING

--v function() --> CT
function cap_tracker.init()
    local self = {}
    setmetatable(self, {
        __index = cap_tracker,
        __tostring = function() return "cap_tracker" end
    })--# assume self: CT

    self._regions = {} --:map<string, CT_REGION>
    self._caps = {} --:map<string, CT_FACTION>
    self._buildingEffects = {} --:map<string, CT_BUILDING>
    self._whitelistUnits = {} --:map<string, boolean>
    self._baseCaps = {} --:map<string, number>

    _G.ct = self
    return self
end

--v method(text: any)
function cap_tracker:log(text)
    CTLOG(tostring(text))
end

--v function(self: CT, unitID: string) --> boolean
function cap_tracker.unit_has_cap(self, unitID)
    return not not self._whitelistUnits[unitID]
end

--v function(self: CT, unitID: string) --> number
function cap_tracker.get_base_cap_for_unit(self, unitID)
    if self._baseCaps[unitID] == nil then
        self._baseCaps[unitID] = 0
    end
    return self._baseCaps[unitID] 
end

---SUBOBJECTS:


--v function(model: CT, faction: string) --> CT_FACTION
function cap_faction.new(model, faction)
    local self = {}
    setmetatable(self, {
        __index = cap_faction
    }) --# assume self: CT_FACTION

    self._model = model
    self._faction = faction
    self._queueCounts = {} --:map<string, number>
    self._buildingCapBonus = {} --:map<string, number>
    self._currentValues = {} --:map<string, number>
    self._factionCapBonus = {} --:map<string, number>
    self._characterCapBonus = {} --:map<string, number>

    return self
end


--v function(self: CT_FACTION, text: any)
function cap_faction.log(self, text)
    self._model:log(text)
end

--v function(self: CT_FACTION, char_list: CA_CHAR_LIST)
function cap_faction.evaluate_current_values(self, char_list)
    self._currentValues = {}
    for i = 0, char_list:num_items() - 1 do
        if cm:char_is_mobile_general_with_army(char_list:item_at(i)) then
            local unit_list = char_list:item_at(i):military_force():unit_list()
            for j = 0, unit_list:num_items() - 1 do
                local unit = unit_list:item_at(i):unit_key()
                if self._currentValues[unit] == nil then
                    self._currentValues[unit] = 0 
                end
                self._currentValues[unit] = self._currentValues[unit] + 1
            end
        end
    end
end


--v function(self: CT_FACTION, unitID: string, bonus: number)
function cap_faction.grant_faction_wide_cap_bonus(self, unitID, bonus)
    self._factionCapBonus[unitID] = bonus
end

--v function(self: CT_FACTION, unitID: string) --> number
function cap_faction.get_faction_bonus_for_unit(self, unitID)
    if self._factionCapBonus[unitID] == nil then
        self._factionCapBonus[unitID] = 0 
    end
    return self._factionCapBonus[unitID] 
end

--v function(self: CT_FACTION, unitID: string) --> number
function cap_faction.get_building_bonus_for_unit(self, unitID)
    if self._buildingCapBonus[unitID] == nil then
        self._buildingCapBonus[unitID] = 0 
    end
    return self._buildingCapBonus[unitID] 
end

--v function(self: CT_FACTION, unitID: string) --> number
function cap_faction.get_character_bonus_for_unit(self, unitID)
    if self._characterCapBonus[unitID] == nil then
        self._characterCapBonus[unitID] = 0 
    end
    return self._characterCapBonus[unitID] 
end
    

--v function(self: CT_FACTION, unitID: string) --> number
function cap_faction.get_cap_for_unit(self, unitID)
    local base = self._model:get_base_cap_for_unit(unitID)
    local faction = self:get_faction_bonus_for_unit(unitID)
    local from_buildings = self:get_building_bonus_for_unit(unitID)
    local from_characters = self:get_character_bonus_for_unit(unitID)
    
    return base + faction + from_buildings + from_characters
end

--v function(model: CT, region_key: string) --> CT_REGION
function cap_region.new(model, region_key)
    local self = {}
    setmetatable(self, {
        __index = cap_region
    }) --# assume self: CT_REGION
    self._model = model
    self._key = region_key
    self._buildings = {} --:map<string, boolean>
    return self
end


--v function(self: CT_REGION, text: any)
function cap_region.log(self, text)
    self._model:log(text)
end


--v function(self: CT_REGION, slot_list: CA_SLOT_LIST)
function cap_region.evaluate_buildings(self, slot_list)
    self._buildings = {}
    for i = 0, slot_list:num_items() - 1 do
        local slot = slot_list:item_at(i)
        if slot:has_building() then
            self._buildings[slot:building():name()] = true      
        end
    end
end

--v function(model: CT, building: string) --> CT_BUILDING
function cap_building.new(model, building)
    local self = {}
    setmetatable(self, {
        __index = cap_building
    }) --# assume self: CT_BUILDING
    self._model = model 
    self._unitEffects = {} --:map<string, number>
    return self
end

--v function(self: CT_BUILDING, text: any)
function cap_building.log(self, text)
    self._model:log(text)
end

--v function(self: CT_BUILDING, unit: string, quantity: number)
function cap_building.register_unit_effect(self, unit, quantity)
    self._unitEffects[unit] = quantity
end

--v function(self: CT_BUILDING, unitID: string) --> number
function cap_building.get_cap_contribution(self, unitID)
    if self._unitEffects[unitID] == nil then
        self._unitEffects[unitID] = 0 
    end
    return self._unitEffects[unitID]
end

-- end of subobjects


--v function(self: CT, region_key: string) --> CT_REGION
function cap_tracker.get_region(self, region_key)
    if self._regions[region_key] == nil then
        self._regions[region_key] = cap_region.new(self, region_key)
    end
    return self._regions[region_key]
end

--v function(self: CT, faction: string) --> CT_FACTION
function cap_tracker.get_faction(self, faction)
    if self._caps[faction] == nil then
        self._caps[faction] = cap_faction.new(self, faction)
    end
    return self._caps[faction]
end

--v function(self: CT, building: string) --> CT_BUILDING
function cap_tracker.get_building(self, building)
    if self._buildingEffects[building] == nil then
        self._buildingEffects[building] = cap_building.new(self, building)
    end
    return self._buildingEffects[building]
end




--PUBLIC API
--v function(self: CT, building: string, unit: string, cap_value: number)
function cap_tracker.give_building_cap_effect(self, building, unit, cap_value)
    self:get_building(building):register_unit_effect(unit, cap_value)
end

--v function(self: CT, unit: string, base_cap: number?)
function cap_tracker.track_cap_for_unit(self, unit, base_cap)
    if base_cap == nil then
        base_cap = 0
    end
    self._baseCaps[unit] = base_cap
    self._whitelistUnits[unit] = true
end

--v function(self: CT, faction: string, unit: string, bonus: number)
function cap_tracker.add_faction_cap_bonus_for_unit(self, faction, unit, bonus)
    self:get_faction(faction):grant_faction_wide_cap_bonus(unit, bonus)
end
