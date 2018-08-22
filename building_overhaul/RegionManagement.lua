


local region_detail_manager = {} --# assume region_detail_manager: RDM

--v function()
function region_detail_manager.init()


end












local region_detail = {} --# assume region_detail: REGION_DETAIL


--v function(region_key: string, starting_wealth: number)
function region_detail.new(region_key, starting_wealth)
    local self = {}
    setmetatable(self, {
        __index = region_detail
    })
    self._key = region_key
    self._buildings = {} --: map<string, boolean>
    --religion 
    self._religions = {} --:map<string, number>
    self._religionPoints = {} --:map<string, number>
    --wealth
    self._wealth = starting_wealth
    self._wealthCap = 0

end