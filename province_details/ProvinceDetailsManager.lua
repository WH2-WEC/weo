--PROVINCE MANAGER MODEL
--API at end of file.

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


local province_manager = {} --# assume province_manager: PM

--model instantiation
--v function() --> PM
function province_manager.init()
    local self = {}
    setmetatable(self, {
        __index = province_manager
    }) --# assume self: PM
    --core
    self._regionDetails = {} --:map<string, REGION_DETAIL>
    --wealth system 
    self._buildingToWealthEffect = {} --:map<string, number> -- building:quantity
    self._settlementToWealthCap = {} --:map<string, number> -- settlement_building:quantity
    --unit production
    self._buildingUnitProduction = {} --:map<string, map<string, number>> -- building:<unit:quantity>
    self._fullUnitLevel = {} --:map<string, number> -- subculture:full_unit_level
    --religion
    self._buildingFaiths = {} --:map<string, {WEC_FAITH_KEY, number}> -- faith:<building:strength>
    self._faithForeignFlags = {} --:map<WEC_FAITH_KEY, boolean> -- faith:can_be_foreign
    self._faithUnitProductionEffects = {} --:map<WEC_FAITH_KEY, map<string, number>> -- faith:<unit:quantity>
    self._faithWealthEffects = {} --:map<WEC_FAITH_KEY, {_own: number, _foreign: number}> -- faith:wealth_effect
    --tax
    self._taxBundles = {} --:map<string, string> -- subculture:tax_bundle_prefix
    self._taxWealthEffects = {} --:map<string, {number, number, number, number, number}>
    self._taxUnitProductionMod = {} --:map<string, {number, number, number, number, number}>
    --UI Content
    self._UITaxEffects = {} --:map<string, {vector<string>, vector<string>, vector<string>, vector<string>, vector<string>}> --subculture:{effects_levels_vectors}
    self._UIFaithEffects = {} --:map<WEC_FAITH_KEY, {_own: vector<string>, _foreign: vector<string>}> -- faith:{own_effects,foreign_effects}
    self._UIUnitIcons = {} --:map<string, string> -- unit:icon_path
    --UI model
    self._currentSettlement = nil --:string

    _G.pm = self
    return self
end

--log script to text
--v method(text: any)
function province_manager:log(text)
    PMLOG(tostring(text))
end

--logs lua errors to a file after this is called.
--v [NO_CHECK] 
--v function (self: PM)
function province_manager.error_checker(self)
    --Vanish's PCaller
    --All credits to vanish

    --safely call a function
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
    
    --pack args. 
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --unpack args
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --wrap a function in pcall
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
    
    --add wrap to trigger event
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
        end
    );
    
    --add wrap to check callbacks
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
        end
    )
    
    --add wrap to listeners
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
-------DATA----------
---------------------


--wealth
--v function(self: PM, building: string) --> number
function province_manager.get_building_wealth_effect(self, building)
    if self._buildingToWealthEffect[building] == nil then
        self._buildingToWealthEffect[building] = 0
    end
    return self._buildingToWealthEffect[building]
end

--shortcut, is the building a settlement?
--v function(self: PM, building: string) --> boolean
function province_manager.building_is_settlement(self, building)
    return not not building:find("_settlement_")
end

--get the wealth cap for a settlement building.
--v function(self: PM, settlement: string) --> number
function province_manager.get_wealth_cap_for_settlement(self, settlement)
    if self._settlementToWealthCap[settlement] == nil then
        self:log("API ERROR: No wealth cap registered for ["..settlement.."], returning default 150")
        return 150
    end
    return self._settlementToWealthCap[settlement]
end

--get the number that == a full unit
--v function(self: PM, subculture: string) --> number
function province_manager.get_full_unit_level_for_sc(self, subculture)
    if self._fullUnitLevel[subculture] == nil then
        self._fullUnitLevel[subculture] = 100 --default value
    end
    return self._fullUnitLevel[subculture]
end

--get the units produced by a building
--v function(self: PM, building: string) --> map<string, number>
function province_manager.get_unit_production_for_building(self, building)
    if self._buildingUnitProduction[building] == nil then
        self._buildingUnitProduction = {}
    end
    return self._buildingUnitProduction[building]
end

--is tax implemented for a subculture 
--v function(self: PM, subculture: string) --> boolean
function province_manager.is_tax_implemented(self, subculture)
    return not not self._taxBundles[subculture]
end

--get the tax bundle prefix for a subculture
--v function(self: PM, subculture: string) --> string
function province_manager.get_tax_bundle(self, subculture)
    return self._taxBundles[subculture]
end


---------------------
-------REGIONS-------
---------------------


local region_detail = require("province_details/RegionDetail")

--v function(self: PM, region: string) --> REGION_DETAIL
function province_manager.get_region(self, region) 
    if not not self._regionDetails[region] then
        return self._regionDetails[region]
    end
    return region_detail.new(self, cm, cm:get_region(region))
end


--v function(self: PM, region: string)
function province_manager.save_region(self, region)


end



---------------------
-------API-----------
---------------------

--wealth
--v function(self: PM, building: string, quantity: number)
function province_manager.add_wealth_effect_to_building(self, building, quantity)
    self._buildingToWealthEffect[building] = quantity
end

--v function(self: PM, building: string, quantity: number)
function province_manager.add_wealth_cap_to_settlement(self, building, quantity)
    self._settlementToWealthCap[building] = quantity
end

--units
--v function(self: PM, building: string, unitID: string, quantity: number)
function province_manager.add_unit_production_to_building(self, building, unitID, quantity)
    if self._buildingUnitProduction[unitID] == nil then
        self._buildingUnitProduction[unitID] = {}
    end
    self._buildingUnitProduction[unitID][building] = quantity
end

--v function(self: PM, subculture: string, level: number)
function province_manager.set_full_unit_level_for_subculture(self, subculture, level)
    self._fullUnitLevel[subculture] = level
end

--faith
--v function(self: PM, building: string, faith: WEC_FAITH_KEY, strength: number)
function province_manager.add_faith_to_building(self, building, faith, strength)
    self._buildingFaiths[building] = {faith, strength}
end

--v function(self: PM, detail: FAITH_DETAIL_ENUM)
function province_manager.implement_faith(self, detail)
    local key = detail._key
    self._faithForeignFlags[key] = detail._canBeForeign
    self._faithWealthEffects[key] = detail._wealthEffect
    self._faithUnitProductionEffects[key] = detail._ownUnitProd
    self._UIFaithEffects[key] = {_own = detail._ownUI, _foreign = detail._foreignUI}
end

--tax
--v function(self: PM, subculture: string, detail: TAX_DETAIL_ENUM)
function province_manager.implement_tax_for_subculture(self, subculture, detail)
    self._taxBundles[subculture] = detail._bundle
    self._UITaxEffects[subculture] = detail._UIEffects
    self._taxWealthEffects[subculture] = detail._wealthEffects
    self._taxUnitProductionMod[subculture] = detail._unitProdModifier
end




province_manager.init():error_checker() -- launch model with error checking enabled


