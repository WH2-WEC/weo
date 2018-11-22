local demand = {} --# assume demand: SUBJECT_DEMAND

--v function(subject: SUBJECT, key: string, validity: (function(cm: CM)--> boolean), event: string, cnd: function(context: WHATEVER) --> boolean,
--v alt_event: string, alt_cnd: function(context: WHATEVER) --> boolean, can_pay_off: boolean) --> SUBJECT_DEMAND
function demand.new(subject, key, validity, event, cnd, alt_event, alt_cnd, can_pay_off)
    local self = {}
    setmetatable(self, {
        __index = demand
    }) --# assume self: SUBJECT_DEMAND
    self._subject = subject
    self._cm = self._subject._cm
    self._key = key
    self._validityCondition = validity
    self._isActive = false --:boolean
    self._canPay = can_pay_off
    self._event = event
    self._condition = cnd
    self._eventAlt = alt_event
    self._conditionAlt = alt_cnd

    return self
end




return {
    new = demands.new
}