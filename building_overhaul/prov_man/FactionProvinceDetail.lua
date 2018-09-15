local faction_province_detail = {} --# assume faction_province_detail: FPD

--v function(model: PM, faction: string, province: string, capital: string) --> FPD
function faction_province_detail.new(model, faction, province, capital)
    local self = {}
    setmetatable(self,{
            __index = faction_province_detail,
            __tostring = function() 
                return "WEC_FPD_"..faction.."_"..province 
            end
        }) --# assume self: FPD
    self._name = faction..province
    self._model = model
    self._faction = faction
    self._province = province
    self._regions = {} --:map<string, REGION_DETAIL>
    self._numRegions = 0 --:number
    self._regionChangeFlag = false

    self._wealth = 0 --:number
    self._taxRate = 3 --:number
    self._religions = {} --:map<string, number>
    self._religionLevels = {} --:map<string, number>

    self._unitProduction = {} --:map<string, number>
    self._producableUnits = {} --:map<string, {_bool: boolean, _reason: string}>
    self._partialUnits = {} --:map<string, number>

    self._desiredEffects = {} --:vector<string>

    self._activeEffects = {} --:vector<string>
    self._activeEffectsClear = true --:boolean
    self._activeCapital = capital
    self._correctCapital = false

    return self
end

--v function(self: FPD, text: any)
function faction_province_detail.log(self, text)
    self._model:log(tostring(text))
end


--v function(self: FPD)
function faction_province_detail.apply_all_effects(self)
    for i = 1, #self._desiredEffects do
        local effect = self._desiredEffects[i]
        table.insert(self._activeEffects, effect)
        cm:apply_effect_bundle_to_region(effect, self._activeCapital, 0)
    end
    self._activeEffectsClear = false
end

--v function(self: FPD)
function faction_province_detail.clear_active_effects(self)
    for i = 1, #self._activeEffects do
        cm:remove_effect_bundle_from_region(self._activeEffects[i], self._activeCapital)
    end
    self._activeEffects = {}
    self._activeEffectsClear = true
end

--v function(self: FPD, region_name: string)
function faction_province_detail.remove_region(self, region_name)
    if self._regions[region_name] == nil then
        self:log("ERROR: Called for the removal of region ["..region_name.."] but that region is not owned by the current FPD")
        return
    end
    self:log("Removing region ["..region_name.."] from FPD ["..self._name.."] ")
    --we have to move the capital sometimes
    if self._activeCapital == region_name then
        self:log("Remove region is removing a defacto capital!")
        --clear the effects left on the capital
        if not self._activeEffectsClear then
            self:clear_active_effects()
        end
        --we set the correct capital flag to false because it will always be false after a capital is lost
        self._correctCapital = false
        --if this isn't the only region in the province, we need a new capital!
        if self._numRegions > 1 then
            local new_capital 
            for name, _ in pairs(self._regions) do
                if not name == region_name then
                    new_capital = name
                    break
                end
            end
            if not new_capital == nil then
                self._activeCapital = new_capital
                self:apply_all_effects()
            else
                self:log("ERROR: new capital find processed in remove_region failed for FPD ["..self._name.."] ")
            end
        end
    end
    self._numRegions = self._numRegions - 1
    self._regionChangeFlag = true
    -- the RD won't disappear since all RD are stored in the model so it still has a pointer and can't be collected
    self._regions[region_name]._fpd = nil
    self._regions[region_name] = nil 

end


--v function(self: FPD, region_object: REGION_DETAIL)
function faction_province_detail.add_region(self, region_object)
    if not self._regions[region_object._key] == nil then
        self._regions[region_object._key] = region_object
        return
    end
    --link the objects to eachother
    self._regions[region_object._key] = region_object
    region_object:set_fpd(self)
    --increment num regions
    self._numRegions = self._numRegions + 1
    self._regionChangeFlag = true
    self:log("added region ["..region_object._key.."] to FPD ["..self._name.."] ")
    --we have to move the capital if the new capital is the real capital
    --don't bother checking if it's already true
    if self._correctCapital == true then
        return
    end
    if cm:get_region(region_object._key):is_province_capital() then
        --clear any effects on the old capital
        if not self._activeEffectsClear then
            self:clear_active_effects()
        end
        --set the new province capital
        self._activeCapital = region_object._key
        self._correctCapital = true
        --apply effects to it
        self:apply_all_effects()
    end
end

--v function(thresholds:vector<number>, quantity: number) --> number
local function FindThresholdFit(thresholds, quantity)

    local highest_passed_threshold --:number
    local highest_threshold_checked = 0 --:number
    for i = 1, #thresholds do
        if quantity >= thresholds[i] then
            if highest_passed_threshold == nil then
                highest_passed_threshold = thresholds[i]
            elseif thresholds[i] > highest_passed_threshold then
                highest_passed_threshold = thresholds[i]
            end
        end
        if thresholds[i] > highest_threshold_checked then
            highest_threshold_checked = thresholds[i]
        end
    end
    if highest_passed_threshold == nil then
        return highest_threshold_checked
    end
    return highest_passed_threshold
end

--v function(self: FPD)
function faction_province_detail.evaluate_reglion(self)
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            if not not self._model._religionEffects[building] then
                for religion, quantity in pairs(self._model._religionEffects[building]) do
                    self._religions[religion] = self._religions[religion] + quantity
                end
            end
        end
    end
    
    for religion, quantity in pairs(self._religions) do
        self._religions[religion] = quantity - 5 
        --natural decay of religions every turn
        local religion_detail = self._model._religionDetails[religion]
        local religion_level = FindThresholdFit(religion_detail._thresholds, quantity)
        self._religionLevels[religion] = religion_level
        table.insert(self._desiredEffects, religion_detail._bundles[religion_level])
    end
end

--v function(self: FPD)
function faction_province_detail.evaluate_tax_rate(self)
    local sub = cm:get_faction(self._faction):subculture()
    if self._model._taxResults[sub] == nil then
        self:log("tax rate is unimplemented for sub ["..sub.."] ")
        return
    end
    table.insert(self._desiredEffects, self._model._taxResults[sub][self._taxRate]._bundle)
end


--v function(self: FPD)
function faction_province_detail.evaluate_unit_generation(self)
    local subculture = cm:get_faction(self._faction):subculture()
    if self._model._unitProdReqs[subculture] == nil then 
        self._model._unitProdReqs[subculture] = {}
    end
    --buildings
    local unified_building_map = {} --:map<string, boolean>
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            unified_building_map[building] = true
            if not not self._model._unitProdEffects[building] then
                for unit, quantity in pairs(self._model._unitProdEffects[building]) do
                    if self._unitProduction[unit] == nil then
                        self._unitProduction[unit] = 0 
                    end
                    self._unitProduction[unit] = self._unitProduction[unit] + quantity
                end
            end
        end
    end
    --religions
    for religion, level in pairs(self._religionLevels) do
        local religion_detail = self._model._religionDetails[religion]
        if not religion_detail._unitProdEffects[level] == nil then
            for unit, quantity in pairs(religion_detail._unitProdEffects[level]) do
                if self._unitProduction[unit] == nil then
                    self._unitProduction[unit] = 0 
                end
                self._unitProduction[unit] = self._unitProduction[unit] + quantity
            end
        end
    end
    --tax rate
    if self._model._taxResults[subculture] == nil then
        self:log("No tax implementation for wealth on this subculture")
    else
        local tax_wealth_effect = self._model._taxResults[subculture][self._taxRate]._unitProdEffects
        for unit, quantity in pairs(tax_wealth_effect) do
            if self._unitProduction[unit] == nil then
                self._unitProduction[unit] = 0 
            end
            self._unitProduction[unit] = self._unitProduction[unit] + quantity
        end
    end
    --production permissions
    for unit, quantity in pairs(self._unitProduction) do
        local can_produce = true
        local reason = ""
        local req_buildings = self._model._unitProdReqs[subculture][unit]
        if req_buildings then
            for i = 1, #req_buildings do
                if not unified_building_map[req_buildings[i]] then
                    can_produce = false
                    reason = req_buildings[i]
                end
            end
        end
        if can_produce == true then
            self._producableUnits[unit] = {_bool = true, _reason = reason}
        else
            self._producableUnits[unit] = {_bool = false, _reason = reason}
        end
    end
end


--v function(self: FPD)
function faction_province_detail.evaluate_wealth(self)
    local subculture = cm:get_faction(self._faction):subculture()
    if self._model._wealthResults[subculture] == nil then
        self:log("wealth is not implemented for the subculture: ["..subculture.."]")
        return
    end
    --buildings
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            if not not self._model._wealthEffects[building] then
                self._wealth = self._wealth + self._model._wealthEffects[building] 
            end
        end
    end
    --religion
    for religion, level in pairs(self._religionLevels) do
        local religion_detail = self._model._religionDetails[religion]
        if not religion_detail._wealthEffects[level] == nil then
            self._wealth = self._wealth + religion_detail._wealthEffects[level]
        end
    end
    --wealth
    if self._model._taxResults[subculture] == nil then
        self:log("No tax implementation for wealth on this subculture")
    else
        local tax_wealth_effect = self._model._taxResults[subculture][self._taxRate]._wealthEffects
        self._wealth = self._wealth + tax_wealth_effect
    end

    local level = FindThresholdFit(self._model._wealthThresholds[subculture], self._wealth)
    table.insert(self._desiredEffects, self._model._wealthResults[subculture][level])
end




return {
    new = faction_province_detail.new
}