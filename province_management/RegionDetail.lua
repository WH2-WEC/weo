local rd = {} --# assume rd: RD
--constructor
--v function(model: PM, cm: CM, region: string) --> RD
function rd.new(model, cm, region)
    local self = {}
    setmetatable(self, {
        __index = rd
    }) --# assume self: RD
    self._model = model
    self._name = region
    self._cm = cm
    self._buildings = {} --:map<string, boolean>
    self._wealth = 100
    self._maxWealth = 100
    self._UIWealthChanges = {} --:map<string, number>
    self._UnitGen = {} --:map<string, number>
    self._UIUnitGen = {} --:map<string, number>


    return self
end