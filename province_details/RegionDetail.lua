local region_detail = {} --# assume region_detail: REGION_DETAIL

--v function(region: CA_REGION) --> REGION_DETAIL
function region_detail.new(region)
    local self = {}
    setmetatable(self, {
        __index = region_detail
    }) --# assume self: REGION_DETAIL

    --core
    self._name = region:name()
    self._key = region:name()
    --effects
    self._regionEffects = {} --:map<string, boolean> -- source:flag
    --wealth
    self._wealth = 35 + cm:random_number(100)
    self._UIWealthFactors = {} --:map<string, number> -- source:quantity
    --unit_production
    self._partialUnits = {} --:map<string, number> -- unit:quantity
    self._UIUnitProduction = {} --:map<string, number> -- unit:quantity
    self._UIUnitFactors = {} --:map<string, map<string, number>> -- unit:<source:quantity>
    --religion
    self._ownFaiths = {} --:map<string, boolean> -- faith:flag
    self._foreignFaiths = {} --:map<string, boolean> -- faith:flag
    self._UIFaithSources = {} --:map<string, string> -- source:faith

    return self
end




------
return {
    new = region_detail.new
}