local region_detail = {} --# assume region_detail: region_detail

--v function(model: PM, region_key: string) --> REGION_DETAIL
function region_detail.new(model, region_key)
    local self = {}
    setmetatable(self, {
        __index = region_detail,
        __tostring = function()
            return "WEC_REGION_DETAIL_"..region_key
        end
    }) --# assume self: REGION_DETAIL
    
    self._key = region_key
    self._model = model
    self._fpd = nil --: FPD
    self._buildings = {} --:map<string, boolean>

end