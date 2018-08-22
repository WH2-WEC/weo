


local region_detail_manager = {} --# assume region_detail_manager: RDM

--v function()
function region_detail_manager.init()
    local self = {}
    setmetatable(self, {
        __index = region_detail_manager
    }) --# assume self: RDM

    --religion and wealth impact
    self._buildingReligionEffects = {} --:map<string, function(region: REGION_DETAIL)>
    self._buildingWealthEffects = {} --:map<string, function(region:REGION_DETAIL)>
    self._buildingUnitGenerationEffects = {} --:map<string, function(region: REGION_DETAIL)>

    self._regions = {} --: map<string, REGION_DETAIL>


end

--v function(self: RDM, building: string) --> boolean
function region_detail_manager.building_has_religion_effect(self, building)
    return not not self._buildingReligionEffects[building]
end
--v function(self: RDM, building: string) --> boolean
function region_detail_manager.building_has_wealth_effect(self, building)
    return not not self._buildingWealthEffects[building]
end
--v function(self: RDM, building: string) --> boolean
function region_detail_manager.building_has_unit_gen_effect(self, building)
    return not not self._buildingUnitGenerationEffects[building]
end

--v function(self: RDM, building: string, effect: function(region: REGION_DETAIL))
function region_detail_manager.add_building_religion_effect(self, building, effect)
    self._buildingReligionEffects[building] = effect
end

--v function(self: RDM, building: string, effect: function(region: REGION_DETAIL))
function region_detail_manager.add_building_wealth_effect(self, building, effect)
    self._buildingWealthEffects[building] = effect
end

--v function(self: RDM, building: string, effect: function(region: REGION_DETAIL))
function region_detail_manager.add_building_unit_gen_effect(self, building, effect)
    self._buildingUnitGenerationEffects[building] = effect
end







local region_detail = {} --# assume region_detail: REGION_DETAIL


--v function(manager: RDM, region_key: string, starting_wealth: number)
function region_detail.new(manager, region_key, starting_wealth)
    local self = {}
    setmetatable(self, {
        __index = region_detail
    })
    self._key = region_key
    self._manager = manager
    self._buildings = {} --: map<string, boolean>
    --religion 
    self._activeReligions = {} --:map<string, number>
    self._religionStrengths = {} --:map<string, number>
    --wealth
    self._wealth = starting_wealth
    self._wealthCap = 100 --:number
    --unit generation
    self._unitGeneration = {} --:map<string, number>

end