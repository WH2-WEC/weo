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
    self._humans = {} --:map<string, boolean>
    for i = 1, #cm:get_human_factions() do
        self._humans[cm:get_human_factions()[i]] = true
    end
    --objects
    self._factionProvinceDetails = {} --:map<string, map<string, FPD>>
    self._regions = {} --:map<string, RD>
    self._factionSubjects = {} --:map<string, map<string, SUBJECT>>
    --modifiers
    --globally modify all changes in wealth and unit production with a function by subculture
    self._wealthModifiers = {} --:map<string, (function(wealth: number, rd: RD) --> number)>
    self._unitProdModifiers = {} --:map<string, (function(prod: number, rd: RD) --> number)>
    --data storage 
    self._provinceManagementSubcultures = {} --:map<string, boolean>
    self._wealthSubcultures = {} --:map<string, boolean>
    self._productionControlSubcultures = {} --:map<string, boolean>
    self._wealthCapBuildings = {} --:map<string, number>
    self._buildingWealthEffects = {} --:map<string, number>
    self._buildingUnitProduction = {} --:map<string, map<string, number>>
    self._buildingSubjectWhitelist = {} --:map<string, string>
    self._buildingSubjectAdjacency = {} --:map<string, string>
    self._subcultureSubjectKeys = {} --:map<string, map<string, boolean>>
    self._subjectDemands = {} --:map<string, map<string, DEMAND_TEMPLATE>>

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

--v function(self: PM, faction: string) --> boolean
function province_manager.is_faction_human(self, faction)
    return not not self._humans[faction]
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
---------------------
--content retrieval--
---------------------
----------
--global--
----------
--v function(self: PM, subculture: string) --> boolean
function province_manager.subculture_has_province_management(self, subculture)
    return not not self._provinceManagementSubcultures[subculture]
end

----------
--wealth--
----------

--v function(self: PM, building: string) --> number
function province_manager.get_building_wealth_effect(self, building)
    if self._buildingWealthEffects[building] == nil then
        return 0
    end
    return self._buildingWealthEffects[building]
end

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

----------------
--prod control--
----------------
--v function(self: PM, subculture: string) --> boolean
function province_manager.subculture_has_prod_control(self, subculture)
    return not not self._productionControlSubcultures[subculture]
end
------------
--subjects--
------------
--v function(self: PM, building: string) --> boolean
function province_manager.building_has_subject(self, building)
    return not not self._buildingSubjectWhitelist[building]
end

--v function(self: PM, building: string) --> string
function province_manager.building_subject(self, building)
    return self._buildingSubjectWhitelist[building]
end

--v function(self: PM, building: string) --> boolean
function province_manager.building_has_subject_adjacency(self, building)
    return not not self._buildingSubjectAdjacency[building]
end

--v function(self: PM, building: string) --> string
function province_manager.building_subject_adjacency(self, building)
    return self._buildingSubjectAdjacency[building]
end

--v function(self: PM, subject: string, subculture: string) --> boolean
function province_manager.is_subject_valid_for_subculture(self, subject, subculture)
    if self._subcultureSubjectKeys[subculture] == nil then
        return false
    end
    return not not self._subcultureSubjectKeys[subculture][subject]
end

-------------------
--unit production--
-------------------

--v function(self: PM, building: string) --> boolean
function province_manager.building_has_unit_production(self, building)
    return not not self._buildingUnitProduction[building]
end

--v function(self: PM, building: string) --> map<string, number>
function province_manager.building_unit_production(self, building)
    if self._buildingUnitProduction[building] == nil then
        return {}
    end
    return self._buildingUnitProduction[building]
end

-------------
--modifiers--
-------------

--v function(self: PM, subculture: string) --> (function(wealth: number, rd: RD) --> number)
function province_manager.get_wealth_modifier_for_subculture(self, subculture)
    if self._wealthModifiers[subculture] then
        return self._wealthModifiers[subculture]
    else
        return function(wealth, rd)
                return wealth
            end
    end
end

--v function(self: PM, subculture: string) --> (function(prod: number, rd: RD) --> number)
function province_manager.get_unit_prod_modifier_for_subculture(self, subculture)
    if self._wealthModifiers[subculture] then
        return self._wealthModifiers[subculture]
    else
        return function(prod, rd)
                return prod
            end
    end
end
    





--------------
--Subobjects--
--------------
subject = require("province_management/Subject")

--v function(self: PM, faction_key: string, subject_key: string) --> SUBJECT
function province_manager.create_or_load_subject(self, faction_key, subject_key)
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

--v function(self: PM, faction_key: string, subject_key: string) --> SUBJECT
function province_manager.get_faction_subject(self, faction_key, subject_key)
    if self._factionSubjects[faction_key] == nil then
        self._factionSubjects[faction_key] = {}
    end
    if not not self._factionSubjects[faction_key][subject_key] then
        return self._factionSubjects[faction_key][subject_key] 
    else
        local new_subject = self:create_or_load_subject(faction_key, subject_key)
        for subject, demandpair in pairs(self._subjectDemands) do
            for key, demand in pairs(demandpair) do
                new_subject:add_or_load_demand(demand)
            end
        end
        return new_subject
    end
end


region_detail = require("province_management/RegionDetail")
faction_province_detail = require("province_management/FactionProvinceDetail")

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

--v function(self: PM, faction_key: string, province_key: string) --> FPD
function province_manager.create_or_load_province(self, faction_key, province_key)
    local savestring = cm:get_saved_value("wec_pm_faction_province_detail_save_"..province_key.."_"..faction_key)
    if savestring == nil then
        if self._factionProvinceDetails[faction_key] == nil then
            self._factionProvinceDetails[faction_key] = {}
        end
        self._factionProvinceDetails[province_key][faction_key] = faction_province_detail.new(self, self._cm, faction_key, province_key)
        return self._factionProvinceDetails[province_key][faction_key]
    else
        if self._factionProvinceDetails[faction_key] == nil then
            self._factionProvinceDetails[faction_key] = {}
        end
        local savedata = cm:load_values_from_string(savestring)
        --# assume savedata: FPD_SAVE
        self._factionProvinceDetails[province_key][faction_key] = faction_province_detail.load(self, self._cm, faction_key, province_key, savedata)
        return self._factionProvinceDetails[province_key][faction_key]
    end
end



--v function(self: PM,  faction_key: string, province_key: string) --> FPD
function province_manager.get_faction_province_detail(self, faction_key, province_key)
    if self._factionProvinceDetails[faction_key] == nil then 
        self._factionProvinceDetails[faction_key] = {}
    end
    if not not self._factionProvinceDetails[faction_key][province_key] then
        return self._factionProvinceDetails[faction_key][province_key]
    else
        local new_province = self:create_or_load_province(faction_key, province_key)
        for key, _ in pairs(new_province:subject_whitelist()) do
            self:get_faction_subject(faction_key, key)
        end
        return new_province
    end
end

--v function(self: PM, faction_key: string) --> map<string, FPD>
function province_manager.get_provinces_for_faction(self, faction_key)
    if self._factionProvinceDetails[faction_key] == nil then 
        self._factionProvinceDetails[faction_key] = {}
    end
    return self._factionProvinceDetails[faction_key]

end

--v function(self: PM, region_key: string) --> RD
function province_manager.get_region_detail(self, region_key)
    if not not self._regions[region_key] then
        return self._regions[region_key]
    else
        --create a new region and any associated objects.
        local obj = cm:get_region(region_key)
        local faction = obj:owning_faction():name()
        local province = obj:province_name()
        local fpd = self:get_faction_province_detail(faction, province)
        local new_region = self:create_or_load_region(region_key, fpd)
        fpd:add_region(new_region)
        return new_region
    end
end

--v function(self: PM, faction_key: string, province_key: string)
function province_manager.delete_fpd(self, faction_key, province_key)
    if self._factionProvinceDetails[faction_key] == nil then
        return
    end
    cm:set_saved_value("wec_pm_faction_province_detail_save_"..province_key.."_"..faction_key, false)
    self._factionProvinceDetails[faction_key][province_key] = nil
end

--------------------------------
--saving and loading functions--
--------------------------------

--v function(self:PM, fpd: FPD)
function province_manager.save_fpd(self, fpd)
    local savedata = fpd:save()
    local savestring = cm:process_table_save(savedata)
    local province_key = fpd:province()
    local faction_key = fpd:faction()
    cm:set_saved_value("wec_pm_faction_province_detail_save_"..province_key.."_"..faction_key, savestring)
end

--v function(self: PM, rd: RD)
function province_manager.save_rd(self, rd)
    local savedata = rd:save()
    local savestring = cm:process_table_save(savedata)
    local region_key = rd:name()
    cm:set_saved_value("wec_pm_regions_save_"..region_key, savestring)
end

--v function(self: PM, subject: SUBJECT)
function province_manager.save_subject(self, subject)
    local savedata = subject:save()
    local savestring = cm:process_table_save(savedata)
    local subject_key = subject:key()
    local faction_key = subject:faction()
    cm:set_saved_value("wec_pm_subjects_save_"..subject_key.."_"..faction_key, savestring)
end


------------------
--functional API--
------------------

--v function(self: PM, modifier: (function(wealth: number, rd: RD) --> number), subculture: string)
function province_manager.add_wealth_modifier_for_subculture(self, modifier, subculture)
    self._wealthModifiers[subculture] = modifier
end

--v function(self: PM, modifier: (function(prod: number, rd: RD) --> number), subculture: string)
function province_manager.add_unit_prod_modifier_for_subculture(self, modifier, subculture)
    self._wealthModifiers[subculture] = modifier
end

---------------
--content API--
---------------
----------
--global--
----------

--v function(self: PM, subculture: string)
function province_manager.enable_province_management_for_subculture(self, subculture)
    self._provinceManagementSubcultures[subculture] = true
end

----------
--wealth--
----------

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
----------------
--prod control--
----------------
--v function(self: PM, subculture: string)
function province_manager.enable_prod_control_for_subculture(self, subculture)
    self._productionControlSubcultures[subculture] = true
end

------------
--subjects--
------------
--v function(self: PM, building: string, subject: string)
function province_manager.add_subject_to_building(self, building, subject)
    self._buildingSubjectWhitelist[building] = subject
end

--v function(self: PM, building: string, subject: string)
function province_manager.add_subject_adjacency_for_building(self, building, subject)
    self._buildingSubjectAdjacency[building] = subject
end

--v function(self: PM, subject: string, subculture: string)
function province_manager.enable_subject_for_subculture(self, subject, subculture)
    if self._subcultureSubjectKeys[subculture] == nil then
        self._subcultureSubjectKeys[subculture] = {}
    end
    self._subcultureSubjectKeys[subculture][subject] = true 
end

-------------------
--unit production--
-------------------
--v function(self: PM, building: string, unit: string, quantity: number)
function province_manager.add_building_unit_production(self, building, unit, quantity)
    if self._buildingUnitProduction[building] == nil then
        self._buildingUnitProduction[building] = {}
    end
    self._buildingUnitProduction[building][unit] = quantity
end

--init
province_manager.init(cm, core):error_checker()