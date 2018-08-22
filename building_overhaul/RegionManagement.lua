--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function RDMLOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("RDM:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end
    


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
    self._recruiterManager = nil --:RECRUITER_MANAGER
    

    _G.rdm = self
end

--v method(text: any)
function region_detail_manager:log(text)
    RDMLOG(tostring(text))
end

--v function(self: RDM, rm: RECRUITER_MANAGER)
function region_detail_manager.add_rm(self, rm)
    self._recruiterManager = rm
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

--v function(self: RDM, building: string, region_key: string)
function region_detail_manager.process_region(self, building, region_key)
    local rd = self._regions[region_key]
    if self:building_has_religion_effect(building) then
        self._buildingReligionEffects[building](rd)
    end
    if self:building_has_wealth_effect(building) then
        self._buildingWealthEffects[building](rd)
    end
    if self:building_has_unit_gen_effect(building) then
        self._buildingUnitGenerationEffects[building](rd)
    end
end




local region_detail = {} --# assume region_detail: REGION_DETAIL


--v function(manager: RDM, region_key: string, starting_wealth: number)
function region_detail.new(manager, region_key, starting_wealth)
    local self = {}
    setmetatable(self, {
        __index = region_detail
    }) --# assume self: REGION_DETAIL
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

--v function(self: REGION_DETAIL) --> RDM
function region_detail.manager(self)
    return self._manager
end



--v function(self: REGION_DETAIL)
function region_detail.process_religion(self)

end


--v function(self: REGION_DETAIL)
function region_detail.process_wealth(self)

end


--v function(self: REGION_DETAIL)
function region_detail.process_unit_generation(self)

end


















region_detail_manager.init()