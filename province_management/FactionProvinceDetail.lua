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
    self._taxRate = 3

    return self
end


return {
    new = fpd.new
}