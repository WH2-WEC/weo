local fpd = {} --# assume fpd: FPD

--v function(model: PM, cm: CM, faction: string, province: string) --> FPD
function fpd.new(model, cm, faction, province)
    local self = {}
    setmetatable(self, {
        __index = fpd
    })--# assume self: FPD

    self._model = model
    self._cm = cm
    self._faction = faction
    self._owningFaction = self._cm:get_faction(faction)
    if self._owningFaction == false then
        model:log("Warning! Get Faction returned false for ["..faction.."] while creating a FPD. Attempting to use the real query.")
        self._owningFaction = self._cm:model():world():faction_by_key(faction)
    end
    if self._owningFaction then
        self._subculture = self._owningFaction:subculture()
    else
        self._subculture = "rebels"
    end
    self._province = province
    self._regions = {} --:map<string, RD>
    self._capitalRegion = nil --: RD
    self._numRegions = 0 --:number
    self._lastProcess = -1 --:number
    self._capitalOwned = false
    --subjects
    self._subjectWhitelist = {} --:map<string, boolean> --subject key to present
    self._UISubjectSources = {} --:map<string, string>  -- subject key to UI Source
    self._subjectAdjacency = {} --:map<string, boolean> --subjects being offered to adjacent provinces
    --tax rate
    self._prodControl = 3 --:number
    return self
end

-----------------
--save and load--
-----------------

--v function(model: PM, cm: CM, faction: string, province: string, svt: FPD_SAVE) --> FPD
function fpd.load(model, cm, faction, province, svt) 
    local self = {}
    setmetatable(self, {
        __index = fpd
    })--# assume self: FPD

    self._model = model
    self._cm = cm
    self._faction = faction
    self._owningFaction = self._cm:get_faction(faction)
    if self._owningFaction == false then
        model:log("Warning! Get Faction returned false for ["..faction.."] while creating a FPD. Attempting to use the real query.")
        self._owningFaction = self._cm:model():world():faction_by_key(faction)
    end
    if self._owningFaction then
        self._subculture = self._owningFaction:subculture()
    else
        self._subculture = "rebels"
    end
    self._province = province
    self._regions = {}
    self._numRegions = 0
    self._lastProcess = -1 
    --subjects
    self._subjectWhitelist = svt._subjectWhitelist or {}
    self._UISubjectSources = svt._UISubjectSources or {}
    self._subjectAdjacency = {} 
    self._prodControl = svt._prodControl or 3 
    return self
end

--v function(self: FPD) --> FPD_SAVE
function fpd.save(self)
    local svt = {} 
    svt._subjectWhitelist = self._subjectWhitelist
    svt._UISubjectSources = self._UISubjectSources
    svt._prodControl = self._prodControl
    return svt
end

-----------------------------------
--region and ownership management--
-----------------------------------

--v function(self: FPD) --> string
function fpd.subculture(self)
    return self._subculture
end

--v function(self: FPD) --> CA_FACTION
function fpd.owning_faction(self)
    return self._owningFaction
end

--v function(self: FPD) --> string
function fpd.faction(self)
    return self._faction
end

--v function(self: FPD) --> string
function fpd.province(self)
    return self._province
end
    
--v function(self: FPD, region_detail: RD)
function fpd.add_region(self, region_detail)
    self._numRegions = self._numRegions + 1
    local key = region_detail:name()
    region_detail:set_fpd(self)
    self._regions[key] = region_detail
    if region_detail:ca_object():is_province_capital() then
        self._capitalOwned = true
        self._capitalRegion = region_detail
    end
end

--v function(self: FPD, region_detail_key: string)
function fpd.remove_region(self, region_detail_key)
    local rd = self._regions[region_detail_key]
    self._regions[region_detail_key] = nil
    self._numRegions = self._numRegions - 1
    if rd:ca_object():is_province_capital() then
        self._capitalOwned = false
        self._capitalRegion = nil
    end
end

--v function(self: FPD) --> boolean
function fpd.is_empty(self)
    return self._numRegions == 0 
end
-------------------
--capital regions--
-------------------

--v function(self: FPD) --> boolean
function fpd.is_capital_owned(self)
    return self._capitalOwned
end

--v function(self: FPD) --> RD
function fpd.capital_region(self)
    return self._capitalRegion
end

-------------------
--subjects system--
-------------------

--v function(self: FPD) --> map<string, boolean>
function fpd.subject_whitelist(self)
    return self._subjectWhitelist
end

--v function(self: FPD) --> map<string, boolean>
function fpd.subject_offers(self)
    return self._subjectAdjacency
end

--v function(self: FPD) --> boolean
function fpd.has_subject(self)
    return not not self._subjectWhitelist
end
-----------------
--process flags--
-----------------
--v function(self: FPD) --> number
function fpd.last_process(self)
    return self._lastProcess
end

--v function(self: FPD)
function fpd.processes_finished(self)
    self._lastProcess = self._cm:model():turn_number()
end

--v function(self: FPD)
function fpd.apply_prod_control(self)
    if not self._model:subculture_has_prod_control(self._subculture) then
        return
    end
    for name, region_detail in pairs(self._regions) do
        region_detail:apply_effect_bundle("wec_prod_control_"..self._subculture.."_"..tostring(self._prodControl))
    end
end

--v function(self: FPD, level: number)
function fpd.set_prod_control_level(self, level)
    if not self._model:subculture_has_prod_control(self._subculture) then
        return
    end
    local new_value = level
    if new_value > 5 then
        new_value = 5 
    elseif new_value < 1 then
        new_value = 1 
    end
    for name, region_detail in pairs(self._regions) do
        region_detail:remove_effect_bundle("wec_prod_control_"..self._subculture.."_"..tostring(self._prodControl))
        region_detail:apply_effect_bundle("wec_prod_control_"..self._subculture.."_"..tostring(new_value))
    end
    self._prodControl = new_value
end

--v function(self: FPD, subject: string, UISource: string)
function fpd.add_subject(self, subject, UISource)
    if self._subjectWhitelist[subject] == true then
        return
    end
    if self._model:is_subject_valid_for_subculture(subject, self._subculture) then
        self._subjectWhitelist[subject] = true
        self._UISubjectSources[subject] = UISource
    end
end

--v function(self: FPD, subject: string)
function fpd.offer_subject_to_adjacents(self, subject)
    self._subjectAdjacency[subject] = true
end

--v function(self: FPD)
function fpd.pre_process(self)
    self._UISubjectSources = {}
    self._subjectAdjacency = {}
    for name, region_detail in pairs(self._regions) do
        for building_name, _ in pairs(region_detail:buildings()) do
            if self._model:building_has_subject(building_name) then
                self:add_subject(self._model:building_subject(building_name), building_name)
            end
            if self._model:building_has_subject_adjacency(building_name) then
                self:offer_subject_to_adjacents(self._model:building_subject_adjacency(building_name))
            end
        end
    end
end

--v function(self: FPD) --> map<string, RD>
function fpd.regions(self)
    return self._regions
end


return {
    new = fpd.new,
    load = fpd.load
}