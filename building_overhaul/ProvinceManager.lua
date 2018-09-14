local province_manager = {} --# assume province_manager: PM

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


--v function()
function province_manager.init()
    local self = {}
    setmetatable(self, {
        __index = province_manager,
        __tostring = function() return "WEC_PROVINCE_MANAGER" end
    }) --# assume self: PM

    self._factionProvinceDetails = {} --: map<string, map<string, FPD>> -- faction to province key, FPD object
    self._regionDetails = {} --:map<string, REGION_DETAIL> -- region key, detail object
    --building effects on mod variables
    self._wealthEffects = {} --:map<string, number> -- building key, quantity
    self._religionEffects = {} --:map<string, map<string, number>> -- building to religion, quantity
    self._unitProdEffects = {} --:map<string, map<string, number>> -- building to unit, quantity
    self._unitProdReqs = {} --:map<string, map<string, vector<string>>> -- subculture to unit to list of required buildings
    --religion detail: struct definition in the types file
    self._religionDetails = {} --:map<string, RELIGION_DETAIL>
    --consequence bundles
    self._wealthResults = {} --:map<string, map<number, string>> -- subculture to level to bundle
    self._wealthParameters = {} --:map<number, number> -- min value for bundle to level
    --tax level effects: struct definition in types files
    self._taxResults = {} --:map<string,map<number, TAX_DETAIL>>

    _G.pm = self
end