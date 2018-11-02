local region_detail = {} --# assume region_detail: REGION_DETAIL

--v function(model: PM, cm: CM, region: CA_REGION) --> REGION_DETAIL
function region_detail.new(model, cm, region)
    if region:is_abandoned() then
        return nil
    end
    if region:settlement():is_null_interface() then
        return nil
    end
    local self = {}
    setmetatable(self, {
        __index = region_detail
    }) --# assume self: REGION_DETAIL

    --core
    self._model = model
    self._cm = cm
    self._name = region:name()
    self._key = region:name()
    self._owner = region:owning_faction():name()
    self._subculture = region:owning_faction():subculture()
    self._buildings = {} --:map<string, boolean> -- building:flag
    --effects
    self._regionEffects = {} --:map<string, boolean> -- source:flag
    --wealth
    self._wealth = 50 --:number
    self._wealthCap = 50 --:number
    self._UIWealthFactors = {} --:map<string, number> -- source:quantity
    --unit_production
    self._partialUnits = {} --:map<string, number> -- unit:quantity
    self._UIUnitProduction = {} --:map<string, number> -- unit:quantity
    self._UIUnitFactors = {} --:map<string, map<string, number>> -- unit:<source:quantity>
    --religion
    self._faiths = {} --:map<string, FAITH_TYPE>
    self._UIFaithSources = {} --:map<string, string> -- source:faith
    --tax level
    self._taxLevel = 3 --:number
    --adds info to the new object, indented to keep seperate
        local slot_list = self._cm:get_region(self._key):settlement():slot_list()
        for i = 0, slot_list:num_items() - 1 do
            local slot = slot_list:item_at(i)
            if slot:has_building() then
                self._buildings[slot:building():name()] = true
            end
        end
        local building = slot_list:item_at(0):building():name()
        local cap = model:get_wealth_cap_for_settlement(building)
        self._wealthCap = cap
    --return the new object and add to model
    model._regionDetails[self._key] = self
    return self
end

------------------
------core--------
------------------

--return access to the model
--v function(self: REGION_DETAIL) --> PM
function region_detail.model(self)
    return self._model
end

--return access to the stored CM pointer
--v function(self: REGION_DETAIL) --> CM
function region_detail.cm(self)
    return self._cm
end

--return the name
--v function(self: REGION_DETAIL) --> string
function region_detail.name(self)
    return self._name
end

--return the name
--v function(self: REGION_DETAIL) --> string
function region_detail.key(self)
    return self._key
end

--return the owner
--v function(self: REGION_DETAIL) --> string
function region_detail.owning_faction(self)
    return self._owner
end

--v function(self: REGION_DETAIL) --> string
function region_detail.owning_subculture(self)
    return self._subculture
end

--updates the cache'd buildings
--v function(self: REGION_DETAIL) 
function region_detail.update_buildings(self)
    self._buildings = {}
    local slot_list = self._cm:get_region(self._key):settlement():slot_list()
    for i = 0, slot_list:num_items() - 1 do
        local slot = slot_list:item_at(i)
        if slot:has_building() then
            self._buildings[slot:building():name()] = true
        end
    end
end

-------------------
------EFFECTS------
-------------------

--clear all effects from the region
--v function(self: REGION_DETAIL)
function region_detail.clear_effects(self)
    for bundle, _ in pairs(self._regionEffects) do
        self._cm:remove_effect_bundle_from_region(bundle, self._key)
    end
    self._regionEffects = {}
end

--apply a bundle to the region
--v function(self: REGION_DETAIL, bundle_key: string)
function region_detail.apply_effect_bundle(self, bundle_key)
    if self._regionEffects[bundle_key] == true then
        return -- we already have the bundle we want, return.
        --not an error, will happen with religions.
    end
    self._regionEffects[bundle_key] = true
    self._cm:apply_effect_bundle_to_region(bundle_key, self._key, 0)
end

--v function(self: REGION_DETAIL, bundle_key: string)
function region_detail.remove_effect_bundle(self, bundle_key)
    if self._regionEffects[bundle_key] == nil then
        self._model:log("Called for the removal of ["..bundle_key.."] from region ["..self._key.."] but that bundle is not applied!")
        return -- we are removing a bundle which doesn't exist! return.
    end
    self._regionEffects[bundle_key] = false
    self._cm:remove_effect_bundle_from_region(bundle_key, self._key)
end

------------------
------WEALTH------
------------------
--access the wealth
--v function(self: REGION_DETAIL) --> number
function region_detail.wealth(self)
    return self._wealth
end

--access the wealth cap
--v function(self: REGION_DETAIL) --> number
function region_detail.wealth_cap(self)
    return self._wealthCap
end

--modify the wealth
--v function(self: REGION_DETAIL, quantity: number, UIFactor: string)
function region_detail.wealth_mod(self, quantity, UIFactor)
    self._UIWealthFactors[UIFactor] = quantity
    local new_wealth = self._wealth + quantity
    if new_wealth < 0 then
        new_wealth = 0
    elseif new_wealth > self._wealthCap then
        new_wealth = self._wealthCap
    end
    self._wealth = new_wealth
end

--update the wealth cap
--v function(self: REGION_DETAIL)
function region_detail.update_wealth_cap(self)
    local settlement = self._cm:get_region(self._key):settlement()
    local building = settlement:slot_list():item_at(0):building():name()
    local cap = self._model:get_wealth_cap_for_settlement(building)
    self._wealthCap = cap
end

--resets the wealth UI at turn start to get new factors
--v function(self: REGION_DETAIL)
function region_detail.reset_wealth_ui(self)
    self._UIWealthFactors = {}
end

--allows the UI to loop through the wealth factors
--v function(self: REGION_DETAIL) --> map<string, number>
function region_detail.wealth_factors(self)
    return self._UIWealthFactors
end

------------------
------UNITS-------
------------------

--gets the unit parts for the unit
--v function(self: REGION_DETAIL, unitID: string) --> number
function region_detail.unit_production_for_unit(self, unitID)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
    end
    return self._partialUnits[unitID]
end

--returns the number of units produced and reduces the units stored by the necessary quantity.
--v function(self: REGION_DETAIL, unitID: string) --> number
function region_detail.calc_unit_production(self, unitID)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
        return 0
    end
    local full_unit_level = self._model:get_full_unit_level_for_sc(self._subculture)
    local produced_units = 0 --:number
    if self._partialUnits[unitID] < full_unit_level then
        return produced_units
    else
        while self._partialUnits[unitID] >= full_unit_level do
            produced_units = produced_units + 1
            self._partialUnits[unitID] = self._partialUnits[unitID] - full_unit_level
        end
        return produced_units
    end
end

--adds the specified value to the unit production
--v function(self: REGION_DETAIL, unitID: string, quantity: number, UIFactor: string)
function region_detail.produce_unit(self, unitID, quantity, UIFactor)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
    end
    if self._UIUnitProduction[unitID] == nil then
        self._UIUnitProduction[unitID] = 0
    end
    if self._UIUnitFactors[unitID] == nil then
        self._UIUnitFactors[unitID] = {}
    end
    self._partialUnits[unitID] = self._partialUnits[unitID] + quantity
    self._UIUnitProduction[unitID] = self._UIUnitProduction[unitID] + quantity
    self._UIUnitFactors[unitID][UIFactor] = quantity
end

--resets the production UI for new factors at turn start
--v function(self: REGION_DETAIL)
function region_detail.reset_unit_production_ui(self)
    self._UIUnitFactors = {}
    self._UIUnitProduction = {}
end

--gets the current production levels for each unit
--v function(self: REGION_DETAIL) --> map<string, number>
function region_detail.current_unit_production(self)
    return self._UIUnitProduction
end

--gets the factors of production for a single unit
--v function(self: REGION_DETAIL, unitID: string) --> map<string, number>
function region_detail.get_unit_production_factors(self, unitID)
    if self._UIUnitFactors[unitID] == nil then
        self._model:log("UI ERROR: ASked for a unit's production factors, but they don't exist!")
        return {["[NO_PROCESS] UI ERROR"] = 1}
    end
    return self._UIUnitFactors[unitID]
end

---------------------
------RELIGION-------
---------------------

--v function(self: REGION_DETAIL, faith_key: WEC_FAITH_KEY, source: string)
function region_detail.add_own_faith(self, faith_key, source)
    self._faiths[faith_key] = "own"
    self._UIFaithSources[faith_key] = source
end

--v function(self: REGION_DETAIL, faith_key: WEC_FAITH_KEY, source: string)
function region_detail.add_foreign_faith(self, faith_key, source)
    if self._faiths[faith_key] == "own" then
        return
    end
    self._faiths[faith_key] = "foreign"
    self._UIFaithSources[faith_key] = source
end

--v function(self: REGION_DETAIL) --> map<string, FAITH_TYPE>
function region_detail.get_faiths(self)
    return self._faiths
end

--v function(self: REGION_DETAIL, faith: WEC_FAITH_KEY) --> string
function region_detail.get_faith_source(self, faith)
    if self._UIFaithSources[faith] == nil then
        self._model:log("UI ERROR: Asked for a faith key's source, but the faith isn't present!")
        return "[NO_PROCESS] UI_ERROR"
    end
    return self._UIFaithSources[faith]
end

----------------------
------TAXE RATE-------
----------------------

--v function(self: REGION_DETAIL) --> number
function region_detail.tax_rate(self)
    return self._taxLevel
end

--v function(self: REGION_DETAIL, new_level: number)
function region_detail.set_tax_level(self, new_level)
    if not self._model:is_tax_implemented(self._subculture) then
        -- no implementation, so we can just set it and return
        self._taxLevel = new_level
        return
    end
    local old_level = self._taxLevel
    local bundle_prefix = self._model:get_tax_bundle(self._subculture)
    self:remove_effect_bundle(bundle_prefix..old_level)
    self:apply_effect_bundle(bundle_prefix..new_level)
end


--access to the constructor function
return {
    new = region_detail.new
}