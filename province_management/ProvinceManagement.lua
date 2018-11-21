

--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function PMLOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("PM :  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--Reset the log at session start
--v function()
local function RCSESSIONLOG()
    if not __write_output_to_logfile then
        return;
    end
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("warhammer_expanded_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close() 
end
RCSESSIONLOG()


local province_manager = {} --# assume province_manager: PM

--v function() --> PM
function province_manager.init()
    local self = {} 
    setmetatable(self, {
        __index = province_manager
    }) --# assume self: PM
    --objects
    self._factionProvinceDetails = {} --:map<string, map<string, FPD>>
    self._regions = {} --:map<string, RD>
    --data storage 


    --
    _G.pm = self
    return self
end

--boilerplate

--content retrieval

--Subobjects
faction_province_detail = require("province_management/FactionProvinceDetail")
region_detail = require("province_management/RegionDetail")

--subobject queries

--content API