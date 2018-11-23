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
    self._subculture = self._owningFaction:subculture()
    self._province = province
    self._regions = {} --:map<string, RD>
    self._numRegions = 0 --:number
    self._lastProcess = -1 --:number
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
    self._province = province
    self._regions = {}
    self._numRegions = 0
    self._lastProcess = -1 
    --subjects
    self._subjectWhitelist = svt._subjectWhitelist or {}
    self._UISubjectSources = svt._UISubjectSources or {}
    self._subjectAdjacency = {} 
    --tax rate
    self._taxRate = svt._taxRate or 3
    return self
end

--v function(self: FPD) --> FPD_SAVE
function fpd.save(self)
    local svt = {} 
    svt._subjectWhitelist = self._subjectWhitelist
    svt._UISubjectSources = self._UISubjectSources
    svt._taxRate = self._taxRate
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
    
--v function(self: FPD, region_detail: RD)
function fpd.add_region(self, region_detail)
    self._numRegions = self._numRegions + 1
    local key = region_detail:name()
    region_detail:set_fpd(self)
    self._regions[key] = region_detail
end

--v function(self: FPD, region_detail_key: string)
function fpd.remove_region(self, region_detail_key)
    local rd = self._regions[region_detail_key]
    self._regions[region_detail_key] = nil
    self._numRegions = self._numRegions - 1
    if self._model:subculture_has_prod_control(self._subculture) then
        rd:remove_effect_bundle("wec_prod_control_"..self._subculture.."_"..tostring(self._prodControl))
    end
end

--v function(self: FPD) --> boolean
function fpd.is_empty(self)
    return self._numRegions == 0 
end


--v function(self: FPD) --> map<string, boolean>
function fpd.subject_whitelist(self)
    return self._subjectWhitelist
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
    self._subjectWhitelist[subject] = true
    self._UISubjectSources[subject] = UISource
end

--v function(self: FPD, subject: string)
function fpd.offer_subject_to_adjacents(self, subject)
    self._subjectAdjacency[subject] = true
end

--v function(self: FPD)
function fpd.pre_process(self)
    self._UISubjectSources = {}
    self._subjectAdjacency = {}
end

--v function(self: FPD)
function fpd.apply_subjects(self)
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




return {
    new = fpd.new,
    load = fpd.load
}