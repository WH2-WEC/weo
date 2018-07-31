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
    popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--Reset the log at session start
--v function()
local function PMSESSIONLOG()
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
PMSESSIONLOG()
local province_manager = {} --# assume province_manager: PROVINCE_MANAGER

--v function() 
function province_manager.init() 
    local self = {}
    setmetatable(self, {
        __index = province_manager,
        __tostring = function() return "PROVINCE_MANAGER" end
    }) --# assume self: PROVINCE_MANAGER


    _G.spm = self
end

--v function(self: PROVINCE_MANAGER, text: any)
function province_manager.log(self, text)
    PMLOG(tostring(text))
end
------------------------------
------------------------------
------------------------------
------------------------------
------------------------------
--REGION DETAIL SUBOBJECT-----

local region_detail = {} --# assume region_detail: REGION_DETAILS

--v function(region_name: string) --> REGION_DETAILS
function region_detail.new(region_name)
    local self = {}
    setmetatable(self, {
        __index = province_manager,
        __tostring = function() return "REGION_DETAILS" end
    }) --# assume self: REGION_DETAILS
    self._name = region_name
    return self
end
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
--PROVINCE DETAIL SUBOBJECT--


local province_details = {} --# assume province_details: PROVINCE_DETAILS
--v function(province_name: string) --> PROVINCE_DETAILS
function province_details.new(province_name)
    local self = {}
    setmetatable(self, {
        __index = province_manager,
        __tostring = function() return "PROVINCE_DETAILS" end
    }) --# assume self: PROVINCE_DETAILS
    self._name = province_name

    return self
end



-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------