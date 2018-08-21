local provinces = {} --# assume provinces: PROVINCE_REGISTER


--v function() 
function provinces.create_index()
    local self = {}
    setmetatable(self, {
        __index = provinces
    })
    --# assume self: PROVINCE_REGISTER

    self._provinces = {} --:map<string, vector<string>>
    self._provinceCapitals = {} --:map<string, string>
    local regions = cm:model():world():region_manager():region_list()
    for i = 0, regions:num_items() - 1 do
        local region = regions:item_at(i)
        local province = region:province_name()
        local region_key = region:name()
        if self._provinces[province] == nil then
            self._provinces[province] = {}
        end
        if region:is_province_capital() then
            self._provinceCapitals[province] = region_key
        end
        table.insert(self._provinces[province], region_key)
    end
    _G.province_register = self
end

--v function (self: PROVINCE_REGISTER, region_key: string) --> vector<string>
function provinces.get_regions_in_province(self,region_key)
    local province = cm:get_region(region_key):province_name()
    return self._provinces[province]
end

--v function (self: PROVINCE_REGISTER, region_key: string) --> vector<string>
function provinces.get_remaining_regions_in_province(self,region_key)
    local remaining_regions = {}
    local province = cm:get_region(region_key):province_name()
    local regions = self._provinces[province]
    for i = 1, #regions do
        if not regions[i] == region_key then
            table.insert(remaining_regions, regions[i])
        end
    end
    return remaining_regions
end

--v function(self: PROVINCE_REGISTER, faction_key: string)
function provinces.get_per_province_owned_regions_for_faction(self, faction_key)
    local added_provinces = {} --:map<string, boolean>
    local region_list = cm:get_faction(faction_key):region_list()
    local owned_regions = {} --:vector<string>
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        if not added_provinces[region:province_name()] == true then
            if self._provinceCapitals[region:province_name()] == region:name() then
                table.insert(owned_regions, region:name())
                added_provinces[region:province_name()] = true
            elseif cm:get_region(self._provinceCapitals[region:province_name()]):owning_faction():name() == faction_key then
                table.insert(owned_regions, region:province_name())
                added_provinces[region:province_name()] = true
            end
        end
    end
end
provinces.create_index()
