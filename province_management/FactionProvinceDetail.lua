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
    self._subjects = {} --:map<string, FPD_SUBJECT>


    self._taxRate = 3


    return self
end