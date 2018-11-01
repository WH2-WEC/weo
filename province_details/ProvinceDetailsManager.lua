local province_manager = {} --# assume province_manager: PM

--v function() --> PM
function province_manager.init()
    local self = {}
    setmetatable(self, {
        __index = province_manager
    }) --# assume self: PM
    
    --wealth system 


    return self
end


local region_detail = require("province_details/RegionDetail")