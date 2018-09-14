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
    self._taxResults = {} --:map<string,map<number, TAX_DETAIL>> --subculture to level, detail

    self._saveData = {} --:map<string, map<string, WHATEVER>>

    _G.pm = self
end

--v method(text: any)
function province_manager:log(text)
    PMLOG(tostring(text))
end


local region_detail = require("building_overhaul/prov_man/RegionDetail")
local faction_province_detail = require("building_overhaul/prov_man/FactionProvinceDetail")

--v function(self: PM) --> map<string, map<string, WHATEVER>>
function province_manager.save(self)
    self._saveData = {}
    for faction, province_object_pair in pairs(self._factionProvinceDetails) do
        for province, fpd in pairs(province_object_pair) do
            self._saveData[faction..province] = {}
            local savetable = self._saveData[faction..province]
            savetable._wealth = fpd._wealth
            savetable._taxRate = fpd._taxRate
            savetable._religions = fpd._religions
            savetable._partialUnits = fpd._partialUnits
            savetable._activeCapital = fpd._activeCapital
            savetable._activeEffects = fpd._activeEffects
            savetable._desiredEffects = fpd._desiredEffects
            savetable._activeEffectsClear = fpd._activeEffectsClear
        end
    end
    return self._saveData
end

--v function(self: PM, savedata: map<string, map<string, WHATEVER>>)
function province_manager.load(self, savedata)
    self._saveData = savedata
end

--v [NO_CHECK] function(self: PM,fpd: FPD)
function province_manager.load_fpd(self, fpd)
    --no check because kailua doesn't aprove this way of doing it
    self:log("LOADING: data for FPD ["..fpd._name.."] ")
    local savetable = self._saveData[fpd._name]
    for key, value in pairs(savetable) do
        fpd[key] = value
    end
end
--v function(self: PM, faction_name: string, province_name: string, region_name: string) --> FPD
function province_manager.create_faction_province_detail(self, faction_name, province_name, region_name)
    local fpd = faction_province_detail.new(self, faction_name, province_name, region_name)
    if not self._saveData[fpd._name] == nil then
        self:load_fpd(fpd)
    else
        --we don't need to preform this if we're loading
        local region_obj = cm:get_region(region_name)
        if region_obj:is_province_capital() then
            fpd._correctCapital = true
        end
    end
    fpd:add_region(self._regionDetails[region_name])
    return fpd
end



--v function(self: PM, region: string)
function province_manager.create_region_detail(self, region)
    local region_obj = cm:get_region(region)
    local province = region_obj:province_name()
    local faction = region_obj:owning_faction():name()
    local new_region = region_detail.new(self, region, province)
    self._regionDetails[region] = new_region
    if self._factionProvinceDetails[faction] == nil then
        self._factionProvinceDetails[faction] = {}
    end
    if self._factionProvinceDetails[faction][province] == nil then
        self:create_faction_province_detail(faction, province, region)
    else
        self._factionProvinceDetails[faction][province]:add_region(new_region)
    end
end



province_manager.init()
_G.pm:log("province manager initialised")


cm:add_saving_game_callback(
    function(context)
        local savedata = _G.pm:save() 
        cm:save_named_value("WEC_PM_SAVEDATA", savedata, context)
    end
)

cm:add_loading_game_callback(
    function(context)
        local savedata = cm:load_named_value("WEC_PM_SAVEDATA", {}, context)
        _G.pm:load(savedata)
    end
)