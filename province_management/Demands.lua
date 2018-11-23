local demand = {} --# assume demand: SUBJECT_DEMAND

--v function(subject: SUBJECT, key: string, faction: string, validity: (function(cm: CM)--> boolean), event: string, cnd: function(context: WHATEVER) --> boolean,
--v alt_event: string, alt_cnd: function(context: WHATEVER) --> boolean, can_pay_off: boolean) --> SUBJECT_DEMAND
function demand.new(subject, key, faction, validity, event, cnd, alt_event, alt_cnd, can_pay_off)
    local self = {}
    setmetatable(self, {
        __index = demand
    }) --# assume self: SUBJECT_DEMAND
    self._faction = faction
    self._subject = subject
    self._cm = self._subject._cm
    self._key = key
    self._validityCondition = validity
    self._activityKey = "wec_demand_"..key.."_"..faction
    self._canPay = can_pay_off
    self._event = event
    self._condition = cnd
    self._eventAlt = alt_event
    self._conditionAlt = alt_cnd

    return self
end

--v function(self: SUBJECT_DEMAND) --> SUBJECT
function demand.subject(self)
    return self._subject
end

--v function(self: SUBJECT_DEMAND) --> boolean
function demand.is_demand_valid(self)
    return self._validityCondition(self._cm)
end

--v function(self: SUBJECT_DEMAND) --> boolean
function demand.is_active(self)
    return not not self._cm:get_saved_value(self._activityKey)
end

--v function(self: SUBJECT_DEMAND)
function demand.activate(self)
    local co = self._subject._model:core_object()
    self._cm:set_saved_value(self._activityKey, true)
    co:add_listener(
        self._activityKey,
        self._event,
        function(context)
            local retval = self._condition(context)
            if not retval then
                self._subject:demand_not_met()
                return false
            else
                return true
            end
        end,
        function(context)
            co:remove_listener(self._activityKey)
            self._cm:set_saved_value(self._activityKey, false)
            self._subject:demand_is_met()
        end,
        false
    )
end


return {
    new = demand.new
}