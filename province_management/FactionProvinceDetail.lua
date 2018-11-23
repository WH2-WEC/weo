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
    self._province = province
    self._regions = {} --:map<string, RD>
    --subjects
    self._subjectWhitelist = {} --:map<string, boolean> --subject key to present
    self._UISubjectSources = {} --:map<string, string>  -- subject key to UI Source
    self._subjectAdjacency = {} --:map<string, boolean> --subjects being offered to adjacent provinces
    --tax rate
    self._taxRate = 3 --:number

    return self
end

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

--v function(self: FPD, region_detail: RD)
function fpd.add_region(self, region_detail)
    local key = region_detail:name()
    region_detail:set_fpd(self)
    self._regions[key] = region_detail
end



--v function(self: FPD) --> map<string, boolean>
function fpd.subject_whitelist(self)
    return self._subjectWhitelist
end

return {
    new = fpd.new,
    load = fpd.load
}