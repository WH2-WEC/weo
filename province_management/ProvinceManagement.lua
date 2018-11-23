--boilerplate 1: functions
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

--v function(cm: CM, core: CORE) --> PM
function province_manager.init(cm, core)
    local self = {} 
    setmetatable(self, {
        __index = province_manager
    }) --# assume self: PM
    --ca pointers
    self._core = core
    self._cm = cm
    --objects
    self._factionProvinceDetails = {} --:map<string, map<string, FPD>>
    self._regions = {} --:map<string, RD>
    self._factionSubjects = {} --:map<string, map<string, SUBJECT>>
    --data storage 
    self._wealthSubcultures = {} --:map<string, boolean>
    self._wealthCapBuildings = {} --:map<string, number>
    self._buildingWealthEffects = {} --:map<string, number>


    --access to model
    _G.pm = self
    return self
end

--boilerplate 2: default methods
--v method(text: any)
function province_manager:log(text)
    PMLOG(tostring(text))
end

--v function(self: PM) --> CORE
function province_manager.core_object(self)
    return self._core
end

--v function(self: PM) --> CM
function province_manager.cm(self)
    return self._cm
end

--v [NO_CHECK] function(self: PM)
function province_manager.error_checker(self)
    --Vanish's PCaller
    --All credits to vanish
    --v function(func: function) --> any
    function safeCall(func)
        local status, result = pcall(func)
        if not status then
            PMLOG("ERROR")
            PMLOG(tostring(result))
            PMLOG(debug.traceback());
        end
        return result;
    end
    
    
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            return unpack2(result);
            end
    end
    
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
        end
    );
    
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
        end
    )
    
    local currentAddListener = core.add_listener;
    --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
    function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
        local wrappedCondition = nil;
        if is_function(conditionFunc) then
            --wrappedCondition =  wrapFunction(conditionFunc, function(arg) output("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
            wrappedCondition =  wrapFunction(conditionFunc);
        else
            wrappedCondition = conditionFunc;
        end
        currentAddListener(
            core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
            --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) output("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
        )
    end
    core.add_listener = myAddListener;

end

--content retrieval
--v function(self: PM, building: string) --> number
function province_manager.get_wealth_cap_for_settlement(self, building)
    if self._wealthCapBuildings[building] == nil then
        return 250
    end
    return self._wealthCapBuildings[building]
end
    
--v function(self: PM) --> string
function province_manager.get_wealth_bundle(self)
    return "wec_wealth_"
end

--v function(self: PM, subculture: string) --> boolean
function province_manager.subculture_has_wealth(self, subculture)
    return not not self._wealthSubcultures[subculture]
end

--Subobjects
region_detail = require("province_management/RegionDetail")
faction_province_detail = require("province_management/FactionProvinceDetail")
subject = require("province_management/Subject")


--core data behaviour
--v function(self: PM, region_key: string, fpd: FPD) --> RD
function province_manager.create_or_load_region(self, region_key, fpd)
    local savestring = cm:get_saved_value("wec_pm_regions_save_"..region_key)
    if savestring == nil then
        self._regions[region_key] = region_detail.new(self, self._cm, fpd, region_key)
        return self._regions[region_key]
    else
        local savedata = cm:load_values_from_string(savestring)
        --# assume savedata: RD_SAVE
        self._regions[region_key] = region_detail.load(self, self._cm, fpd, region_key, savedata)
        return self._regions[region_key]
    end
end

--v function(self: PM, province_key: string, faction_key: string)
function province_manager.create_or_load_province(self, province_key, faction_key)
    local savestring = cm:get_saved_value("wec_pm_faction_province_detail_save_"..province_key.."_"..faction_key)
    if savestring == nil then
        if self._factionProvinceDetails[faction_key] == nil then
            self._factionProvinceDetails[faction_key] = {}
        end
        self._factionProvinceDetails[province_key][faction_key] = faction_province_detail.new(self, self._cm, province_key, faction_key)
    else
        if self._factionProvinceDetails[faction_key] == nil then
            self._factionProvinceDetails[faction_key] = {}
        end
        local savedata = cm:load_values_from_string(savestring)
        --# assume savedata: FPD_SAVE
        self._factionProvinceDetails[province_key][faction_key] = faction_province_detail.load(self, self._cm, province_key, faction_key, savedata)
    end
end

--v function(self: PM, subject_key: string, faction_key: string) --> SUBJECT
function province_manager.create_or_load_subject(self, subject_key, faction_key)
    local savestring = cm:get_saved_value("wec_pm_subjects_save_"..subject_key.."_"..faction_key)
    if savestring == nil then
        if self._factionSubjects[faction_key] == nil then
            self._factionSubjects[faction_key] = {}
        end
        self._factionSubjects[faction_key][subject_key] = subject.new(self, self._cm, subject_key, faction_key)
        return self._factionSubjects[faction_key][subject_key]
    else
        local savedata = cm:load_values_from_string(savestring)
        --# assume savedata: SUBJECT_SAVE
        if self._factionSubjects[faction_key] == nil then
            self._factionSubjects[faction_key] = {}
        end
        self._factionSubjects[faction_key][subject_key] = subject.load(self, self._cm, subject_key, faction_key, savedata)
        return self._factionSubjects[faction_key][subject_key]
    end
end

--subobject queries

--content API

--v function(self: PM, building: string, wealth_cap: number)
function province_manager.add_wealth_cap_for_building(self, building, wealth_cap)
    self._wealthCapBuildings[building] = wealth_cap
end


--v function(self: PM, building: string, wealth: number)
function province_manager.add_wealth_effect_for_building(self, building, wealth)
    self._wealthCapBuildings[building] = wealth
end

--v function(self: PM, subculture: string)
function province_manager.enable_wealth_for_subculture(self, subculture)
    self._wealthSubcultures[subculture] = true
end

province_manager.init(cm, core)