local provinces = {} --# assume provinces: PROVINCE_REGISTER


--v function() 
function provinces.create_index()
    local self = {}
    setmetatable(self, {
        __index = provinces
    })
    --# assume self: PROVINCE_REGISTER

    self._provinces = {} --:map<string, vector<string>>

    local regions = cm:model():world():region_manager():region_list()
    for i = 0, regions:num_items() - 1 do
        local region = regions:item_at(i)
        local province = region:province_name()
        local region_key = region:name()
        if self._provinces[province] == nil then
            self._provinces[province] = {}
        end
        table.insert(self._provinces[province], region_key)
    end
    _G.province_register = self
end

