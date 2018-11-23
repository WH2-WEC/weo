local rd = {} --# assume rd: RD
--constructor
--v function(model: PM, cm: CM, fpd: FPD, region: string) --> RD
function rd.new(model, cm, fpd, region)
    local self = {}
    setmetatable(self, {
        __index = rd
    }) --# assume self: RD
    --model links
    self._model = model
    self._fpd = fpd
    self._cm = cm
    --key
    self._name = region
    --core
    self._pointer = self._cm:get_region(region)
    self._owner = self._pointer:owning_faction()
    self._subculture = self._owner:subculture()
    --buildings
    self._buildings = {} --:map<string, boolean>
    --wealth
    self._wealth = 100 --:number
    self._maxWealth = 100 --:number
    self._UIWealthChanges = {} --:map<string, number>
    --UI Unit
    self._partialUnits = {} --:map<string, number>
    self._UIUnitProduction = {} --:map<string, number>
    -- effects
    self._regionEffects = {} --:map<string, boolean>


    return self
end

--v function(self: RD) --> RD_SAVE
function rd.save(self)
    local svt = {}
    svt._wealth = self._wealth
    svt._maxWealth = self._maxWealth
    svt._UIWealthChanges = self._UIWealthChanges
    svt._partialUnits = self._partialUnits
    svt._UIUnitProduction = self._UIUnitProduction
    svt._regionEffects = self._regionEffects

    return svt
end

--v function(model: PM, cm: CM, fpd: FPD, region: string, svt: RD_SAVE) --> RD
function rd.load(model, cm, fpd, region, svt)
    local self = {}
    setmetatable(self, {
        __index = rd
    }) --# assume self: RD
    --model links
    self._model = model
    self._fpd = fpd
    self._cm = cm
    --key
    self._name = region
    --core
    self._pointer = self._cm:get_region(region)
    self._owner = self._pointer:owning_faction()
    self._subculture = self._owner:subculture()
    --buildings
    self._buildings = {} 
    --wealth
    self._wealth = svt._wealth
    self._maxWealth = svt._maxWealth
    self._UIWealthChanges = svt._UIWealthChanges
    --UI Unit
    self._partialUnits = svt._partialUnits
    self._UIUnitProduction = svt._UIUnitProduction
    -- effects
    self._regionEffects = svt._regionEffects


    return self
end

--return access to the model
--v function(self: RD) --> PM
function rd.model(self)
    return self._model
end

--return the current FPD
--v function(self: RD) --> FPD
function rd.fpd(self)
    return self._fpd
end

--not for external use. Only changes the pointer
--v function(self: RD, fpd: FPD)
function rd.set_fpd(self, fpd)
    self._fpd = fpd
end

--return access to the stored CM pointer
--v function(self: RD) --> CM
function rd.cm(self)
    return self._cm
end

--return the name
--v function(self: RD) --> string
function rd.name(self)
    return self._name
end

--return the ca object pointer
--v function(self: RD) --> CA_REGION
function rd.ca_object(self)
    return self._pointer
end

--return the owner
--v function(self: RD) --> CA_FACTION
function rd.owning_faction(self)
    return self._owner
end

--v function(self: RD) --> string
function rd.owning_subculture(self)
    return self._subculture
end


--updates the cache'd buildings
--v function(self: RD) 
function rd.update_buildings(self)
    self._buildings = {}
    local slot_list = self._cm:get_region(self._name):settlement():slot_list()
    for i = 0, slot_list:num_items() - 1 do
        local slot = slot_list:item_at(i)
        if slot:has_building() then
            self._buildings[slot:building():name()] = true
        end
    end
end

--gets the buildings
--v function(self: RD) --> map<string, boolean>
function rd.buildings(self)
    return self._buildings
end

-------------------
------EFFECTS------
-------------------

--clear all effects from the region
--v function(self: RD)
function rd.clear_effects(self)
    for bundle, _ in pairs(self._regionEffects) do
        self._cm:remove_effect_bundle_from_region(bundle, self._name)
    end
    self._regionEffects = {}
end

--apply a bundle to the region
--v function(self: RD, bundle_key: string)
function rd.apply_effect_bundle(self, bundle_key)
    if self._regionEffects[bundle_key] == true then
        return -- we already have the bundle we want, return.
        --not an error, will happen with religions.
    end
    self._regionEffects[bundle_key] = true
    self._cm:apply_effect_bundle_to_region(bundle_key, self._name, 0)
end

--v function(self: RD, bundle_key: string)
function rd.remove_effect_bundle(self, bundle_key)
    if self._regionEffects[bundle_key] == nil then
        return -- we are removing a bundle which doesn't exist! return.
        --not an error, will happen with tax
    end
    self._regionEffects[bundle_key] = false
    self._cm:remove_effect_bundle_from_region(bundle_key, self._name)
end
    
------------------
------WEALTH------
------------------
--access the wealth
--v function(self: RD) --> number
function rd.wealth(self)
    return self._wealth
end

--access the wealth cap
--v function(self: RD) --> number
function rd.wealth_cap(self)
    return self._maxWealth
end

--modify the wealth
--v function(self: RD, quantity: number, UIFactor: string)
function rd.wealth_mod(self, quantity, UIFactor)
    self._UIWealthChanges[UIFactor] = quantity
    local new_wealth = self._wealth + quantity
    if new_wealth < 0 then
        new_wealth = 0
    elseif new_wealth > self._maxWealth then
        new_wealth = self._maxWealth
    end
    self._wealth = new_wealth
end

--v function(self: RD, quantity: number, apply_effect: boolean?)
function rd.set_wealth(self, quantity, apply_effect)
    new_wealth = quantity
    if new_wealth > self._maxWealth then
        new_wealth = self._maxWealth
    end
    self._wealth = new_wealth
    if apply_effect and self._model:subculture_has_wealth(self._subculture) then
        self:apply_effect_bundle(self._model:get_wealth_bundle()..tostring(new_wealth))
    end
end

--update the wealth cap
--v function(self: RD)
function rd.update_wealth_cap(self)
    local settlement = self._cm:get_region(self._name):settlement()
    local building = settlement:slot_list():item_at(0):building():name()
    local cap = self._model:get_wealth_cap_for_settlement(building)
    self._wealthCap = cap
end

--resets the wealth UI at turn start to get new factors
--v function(self: RD)
function rd.reset_wealth_ui(self)
    self._UIWealthFactors = {}
end

--allows the UI to loop through the wealth factors
--v function(self: RD) --> map<string, number>
function rd.wealth_factors(self)
    return self._UIWealthFactors
end

------------------
------UNITS-------
------------------

--gets the unit parts for the unit
--v function(self: RD, unitID: string) --> number
function rd.unit_production_for_unit(self, unitID)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
    end
    return self._partialUnits[unitID]
end

--returns the number of units produced and reduces the units stored by the necessary quantity.
--v function(self: RD, unitID: string) --> number
function rd.calc_unit_production(self, unitID)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
        return 0
    end
    local full_unit_level = 100
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
--v function(self: RD, unitID: string, quantity: number)
function rd.produce_unit(self, unitID, quantity)
    if self._partialUnits[unitID] == nil then
        self._partialUnits[unitID] = 0 
    end
    if self._UIUnitProduction[unitID] == nil then
        self._UIUnitProduction[unitID] = 0
    end
    self._partialUnits[unitID] = self._partialUnits[unitID] + quantity
    self._UIUnitProduction[unitID] = self._UIUnitProduction[unitID] + quantity
end

--resets the production UI for new factors at turn start
--v function(self: RD)
function rd.reset_unit_production_ui(self)
    self._UIUnitProduction = {}
end

--gets the current production levels for each unit
--v function(self: RD) --> map<string, number>
function rd.current_unit_production(self)
    return self._UIUnitProduction
end



return {
    new = rd.new,
    load = rd.load
}