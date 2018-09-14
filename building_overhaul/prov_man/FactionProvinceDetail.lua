local faction_province_detail = {} --# assume faction_province_detail: FPD

--v function(model: PM, faction: string, province: string, capital: string) --> FPD
function faction_province_detail.new(model, faction, province, capital)
    local self = {}
    setmetatable(self,{
            __index = faction_province_detail,
            __tostring = function() 
                return "WEC_FPD_"..faction.."_"..province 
            end
        }) --# assume self: FPD
    self._name = faction..province
    self._model = model
    self._faction = faction
    self._province = province
    self._regions = {} --:map<string, REGION_DETAIL>

    self._wealth = 0
    self._taxRate = 3
    self._unitProduction = {} --:map<string, number>
    self._producableUnits = {} --:map<string, {_bool: boolean, _reason: string}>
    self._activeEffects = {} --:vector<string>
    self._activeCapital = capital

    return self
end



