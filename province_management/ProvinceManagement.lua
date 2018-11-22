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

--v function() --> PM
function province_manager.init()
    local self = {} 
    setmetatable(self, {
        __index = province_manager
    }) --# assume self: PM
    --objects
    self._factionProvinceDetails = {} --:map<string, map<string, FPD>>
    self._regions = {} --:map<string, RD>
    self._factionSubjects = {} --:map<string, map<string, SUBJECT>>
    --data storage 


    --access to model
    _G.pm = self
    return self
end

--boilerplate 2: default methods
--v method(text: any)
function province_manager:log(text)
    PMLOG(tostring(text))
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

--Subobjects
faction_province_detail = require("province_management/FactionProvinceDetail")
region_detail = require("province_management/RegionDetail")

--core data behaviour
--v function(self: PM, region_key: string, fpd: FPD) --> RD
function province_manager.create_or_load_region(self, region_key, fpd)
    return region_detail.new(self, cm, fpd, region_key)
end

--v function(self: PM, province_key: string, faction_key: string)
function province_manager.create_or_load_province(self, province_key, faction_key)

end

--v function(self: PM, subject_key: string, faction_key: string)
function province_manager.create_or_load_subject(self, subject_key, faction_key)

end

--subobject queries

--content API