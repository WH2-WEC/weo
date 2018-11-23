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
    self._activeDemand = "none" --:string
    self._nextDemandTurn = 5

    return self
end

--v function(self: SUBJECT)
function subject.demand_not_met(self)

end

--v function(self: SUBJECT)
function subject.demand_is_met(self)

end

--v function(self: SUBJECT) --> string
function subject.key(self)
    return self._key
end

local demand = require("province_management/Demands")




return {
    new = subject.new
}
