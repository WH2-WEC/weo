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
    self._UnitGen = {} --:map<string, number>
    self._UIUnitGen = {} --:map<string, number>
    -- effects
    self._regionEffects = {} --:map<string, boolean>


    return self
end


--return access to the model
--v function(self: RD) --> PM
function rd.model(self)
    return self._model
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
    if apply_effect then
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

return {
    new = rd.new
}