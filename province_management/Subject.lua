local subject = {} --# assume subject: SUBJECT

--v function(model: PM, cm: CM, key: string, faction: string) --> SUBJECT
function subject.new(model, cm, key, faction)
    local self = {}
    setmetatable(self, {
        __index = subject
    })--# assume self: SUBJECT
    self._model = model
    self._cm = cm
    self._key = key
    self._faction = faction
    self._demands = {} --:map<string, SUBJECT_DEMAND>
    self._activeDemand = "none" --:string
    self._nextDemandTurn = cm:model():turn_number() + 5 --:number

    return self
end

--v function(model: PM, cm: CM, key: string, faction: string, svt: SUBJECT_SAVE) --> SUBJECT
function subject.load(model, cm, key, faction, svt)
    local self = {}
    setmetatable(self, {
        __index = subject
    })--# assume self: SUBJECT
    self._model = model
    self._cm = cm
    self._key = key
    self._faction = faction
    self._demands = {} 
    self._activeDemand = svt._activeDemand
    self._nextDemandTurn = svt._nextDemandTurn

    return self
end

--v function(self: SUBJECT) --> SUBJECT_SAVE
function subject.save(self)
    local svt = {}
    svt._activeDemand = self._activeDemand
    svt._nextDemandTurn = self._nextDemandTurn
    return svt
end


--v function(self: SUBJECT) --> PM
function subject.model(self)
    return self._model
end

--v function(self: SUBJECT) --> CM
function subject.cm(self)
    return self._cm
end

--v function(self: SUBJECT) --> map<string, SUBJECT_DEMAND>
function subject.demands(self)
    return self._demands
end

--v function(self: SUBJECT) --> string
function subject.key(self)
    return self._key
end

--v function(self: SUBJECT) --> string
function subject.faction(self)
    return self._faction
end

--v function(self: SUBJECT)
function subject.demand_not_met(self)

end

--v function(self: SUBJECT)
function subject.demand_is_met(self)

end


local subject_demand = require("province_management/Demands")

--v function(self: SUBJECT, demand_template: DEMAND_TEMPLATE)
function subject.add_or_load_demand(self, demand_template)
    local new_demand = subject_demand.new(self, demand_template.key, self._faction, demand_template.validity, demand_template.event, demand_template.cnd, demand_template.alt_event, demand_template.alt_cnd, demand_template.can_pay_off)
    if new_demand:is_active() then
        self._activeDemand = new_demand:key()
        new_demand:activate()
    end
end


return {
    new = subject.new,
    load = subject.load
}
