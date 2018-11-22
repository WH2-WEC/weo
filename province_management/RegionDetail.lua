local rd = {} --# assume rd: RD
--constructor
--v function(model: PM, cm: CM, fpd: FPD, region: string) --> RD
function rd.new(model, cm, fpd, region)
    local self = {}
    setmetatable(self, {
        __index = rd
    }) --# assume self: RD
    --model links
    self._model = model
    self._fpd = fpd
    self._cm = cm
    --key
    self._name = region
    --buildings
    self._buildings = {} --:map<string, boolean>
    --wealth
    self._wealth = 100
    self._maxWealth = 100
    self._UIWealthChanges = {} --:map<string, number>
    --UI Unit
    self._UnitGen = {} --:map<string, number>
    self._UIUnitGen = {} --:map<string, number>


    return self
end



return {
    new = rd.new
}