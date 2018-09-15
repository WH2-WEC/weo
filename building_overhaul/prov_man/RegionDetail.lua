local region_detail = {} --# assume region_detail: REGION_DETAIL

--v function(model: PM, region_key: string, province_name: string) --> REGION_DETAIL
function region_detail.new(model, region_key, province_name)
    local self = {}
    setmetatable(self, {
        __index = region_detail,
        __tostring = function()
            return "WEC_REGION_DETAIL_"..region_key
        end
    }) --# assume self: REGION_DETAIL
    
    self._key = region_key
    self._province = province_name
    self._model = model
    self._fpd = nil --: FPD
    self._buildings = {} --:map<string, boolean>
    
    return self
end


--v function(self: REGION_DETAIL, text: any)
function region_detail.log(self, text)
    self._model:log(tostring(text))
end

--v [NO_CHECK] function(self:REGION_DETAIL, fpd: FPD)
function region_detail.set_fpd(self, fpd)
    self:log("Region Detail ["..self._key.."] is now linked to ["..fpd._name.."] ")
    self._fpd = fpd
end


return {
    new = region_detail.new
}