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
    self._numRegions = 0
    self._regionChangeFlag = false

    self._wealth = 0
    self._taxRate = 3
    self._unitProduction = {} --:map<string, number>
    self._producableUnits = {} --:map<string, {_bool: boolean, _reason: string}>
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





return {
    new = faction_province_detail.new
}