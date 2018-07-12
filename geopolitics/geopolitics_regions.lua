local geopolitic_region = {} --# assume geopolitic_region: GEOPOLITIC_REGION

--v function(region_name: string) --> GEOPOLITIC_REGION
function geopolitic_region.new(region_name)
    local self = {}
    setmetatable(self, {
        __index = geopolitic_region,
        __tostring = function() return "GEOPOLITIC_REGION" end
    }) --# assume self: GEOPOLITIC_REGION

    self._name = region_name
    self._properties = {} --:vector<string>

    return self
end

--v function(self: GEOPOLITIC_REGION) --> string
function geopolitic_region.name(self)
    return self._name
end

--v function(self: GEOPOLITIC_REGION) --> vector<string>
function geopolitic_region.get_properties(self)
    return self._properties
end

--v function (self: GEOPOLITIC_REGION, property: string)
function geopolitic_region.add_property(self, property)
    table.insert(self:get_properties(), property)
end

--v function (self: GEOPOLITIC_REGION, property: string)
function geopolitic_region.remove_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do
        if properties[i] == property then
            table.remove(properties, i)
            break
        end
    end
end

--v function (self: GEOPOLITIC_REGION, property: string) --> boolean
function geopolitic_region.has_property(self, property)
    local properties = self:get_properties()
    for i = 1, #properties do 
        if properties[i] == property then
            return true
        end
    end
    return false
end