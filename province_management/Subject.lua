local subject = {} --# assume subject: SUBJECT

--v function(model: PM, key: string) --> SUBJECT
function subject.new(model, key)
    local self = {}
    setmetatable(self, {
        __index = subject
    })--# assume self: SUBJECT
    self._model = model
    self._cm = self._model._cm
    self._key = key
    self._demands = {} --:map<string, SUBJECT_DEMAND>
    self._nextDemandTurn = 5

    return self
end

local demand = require("province_management/Demands")




return {
    new = subject.new
}
