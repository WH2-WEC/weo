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

    self._currentFPD = nil --:FPD

    self._factionProvinceDetails = {} --: map<string, map<string, FPD>> -- faction to province key, FPD object
    self._regionDetails = {} --:map<string, REGION_DETAIL> -- region key, detail object
    --building effects on mod variables
    self._wealthEffects = {} --:map<string, number> -- building key, quantity
    self._religionEffects = {} --:map<string, map<string, number>> -- building to religion, quantity
    self._unitProdEffects = {} --:map<string, map<string, number>> -- building to unit, quantity
    self._unitProdReqs = {} --:map<string, map<string, vector<string>>> -- subculture to unit to list of required buildings
    self._unitProdUIImages = {} --:map<string, string>
    self._unitProdUILandUnits = {} --:map<string, string>
    --religion detail: struct definition in the types file
    self._religionDetails = {} --:map<string, RELIGION_DETAIL>
    --consequence bundles
    self._wealthResults = {} --:map<string, map<number, string>> -- subculture to level to bundle
    self._wealthResultsUI = {} --:map<string, map<number, vector<string>>> --subculture to level to effect text
    self._wealthThresholds = {} --:map<string, vector<number>> -- subculture to threshold set
    --tax level effects: struct definition in types files
    self._taxResults = {} --:map<string,map<number, TAX_DETAIL>> --subculture to level, detail
    --unit details: struct definition in types files

    self._saveData = {} --:map<string, map<string, WHATEVER>>

    _G.pm = self
end

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

local region_detail = {} --# assume region_detail: REGION_DETAIL

--v function(model: PM, region_key: string, province_name: string) --> REGION_DETAIL
function region_detail.new(model, region_key, province_name)
    local self = {}
    setmetatable(self, {
        __index = region_detail,
        __tostring = function()
            return "WEC_REGION_DETAIL_"..region_key
        end
    }) --# assume self: REGION_DETAIL
    
    self._key = region_key
    self._province = province_name
    self._model = model
    self._fpd = nil --: FPD
    self._buildings = {} --:map<string, boolean>
    
    return self
end


--v function(self: REGION_DETAIL, text: any)
function region_detail.log(self, text)
    self._model:log(tostring(text))
end

--v [NO_CHECK] function(self:REGION_DETAIL, fpd: FPD)
function region_detail.set_fpd(self, fpd)
    self:log("Region Detail ["..self._key.."] is now linked to ["..fpd._name.."] ")
    self._fpd = fpd
end


local faction_province_detail = {} --# assume faction_province_detail: FPD

--v function(model: PM, faction: string, province: string, capital: string) --> FPD
function faction_province_detail.new(model, faction, province, capital)
    local self = {}
    setmetatable(self,{
            __index = faction_province_detail,
            __tostring = function() 
                return "WEC_FPD_"..faction.."_"..province 
            end
        }) --# assume self: FPD
    self._name = faction..province
    self._model = model
    self._faction = faction
    self._province = province
    self._regions = {} --:map<string, REGION_DETAIL>
    self._numRegions = 0 --:number
    self._regionChangeFlag = false

    self._wealth = 30 --:number
    self._wealthLevel = 30 --:number
    self._taxRate = 3 --:number
    self._religions = {} --:map<string, number>
    self._religionLevels = {} --:map<string, number>

    self._unitProduction = {} --:map<string, number>
    self._producableUnits = {} --:map<string, {_bool: boolean, _reason: string}>
    self._partialUnits = {} --:map<string, number>

    self._desiredEffects = {} --:vector<string>

    self._activeEffects = {} --:vector<string>
    self._activeEffectsClear = true --:boolean
    self._activeCapital = capital
    self._correctCapital = false

    --ui
    self._UIWealthFactors = {} --:map<string, number>
    self._UIReligionFactors = {} --:map<string,map<string, number>>

    return self
end

--v function(self: FPD, text: any)
function faction_province_detail.log(self, text)
    self._model:log(tostring(text))
end


--v function(self: FPD)
function faction_province_detail.apply_all_effects(self)
    for i = 1, #self._desiredEffects do
        local effect = self._desiredEffects[i]
        table.insert(self._activeEffects, effect)
        cm:apply_effect_bundle_to_region(effect, self._activeCapital, 0)
    end
    self._activeEffectsClear = false
end

--v function(self: FPD)
function faction_province_detail.clear_active_effects(self)
    for i = 1, #self._activeEffects do
        cm:remove_effect_bundle_from_region(self._activeEffects[i], self._activeCapital)
    end
    self._activeEffects = {}
    self._activeEffectsClear = true
end

--v function(self: FPD, region_name: string)
function faction_province_detail.remove_region(self, region_name)
    if self._regions[region_name] == nil then
        self:log("ERROR: Called for the removal of region ["..region_name.."] but that region is not owned by the current FPD")
        return
    end
    self:log("Removing region ["..region_name.."] from FPD ["..self._name.."] ")
    --we have to move the capital sometimes
    if self._activeCapital == region_name then
        self:log("Remove region is removing a defacto capital!")
        --clear the effects left on the capital
        if not self._activeEffectsClear then
            self:clear_active_effects()
        end
        --we set the correct capital flag to false because it will always be false after a capital is lost
        self._correctCapital = false
        --if this isn't the only region in the province, we need a new capital!
        if self._numRegions > 1 then
            local new_capital 
            for name, _ in pairs(self._regions) do
                if not name == region_name then
                    new_capital = name
                    break
                end
            end
            if not new_capital == nil then
                self._activeCapital = new_capital
                self:apply_all_effects()
            else
                self:log("ERROR: new capital find processed in remove_region failed for FPD ["..self._name.."] ")
            end
        end
    end
    self._numRegions = self._numRegions - 1
    self._regionChangeFlag = true
    -- the RD won't disappear since all RD are stored in the model so it still has a pointer and can't be collected
    self._regions[region_name]._fpd = nil
    self._regions[region_name] = nil 

end


--v function(self: FPD, region_object: REGION_DETAIL)
function faction_province_detail.add_region(self, region_object)
    if not self._regions[region_object._key] == nil then
        self._regions[region_object._key] = region_object
        return
    end
    --link the objects to eachother
    self._regions[region_object._key] = region_object
    region_object:set_fpd(self)
    --increment num regions
    self._numRegions = self._numRegions + 1
    self._regionChangeFlag = true
    self:log("added region ["..region_object._key.."] to FPD ["..self._name.."] ")
    --we have to move the capital if the new capital is the real capital
    --don't bother checking if it's already true
    if self._correctCapital == true then
        return
    end
    if cm:get_region(region_object._key):is_province_capital() then
        --clear any effects on the old capital
        if not self._activeEffectsClear then
            self:clear_active_effects()
        end
        --set the new province capital
        self._activeCapital = region_object._key
        self._correctCapital = true
        --apply effects to it
        self:apply_all_effects()
    end
end

--v function(thresholds:vector<number>, quantity: number) --> number
local function FindThresholdFit(thresholds, quantity)

    local highest_passed_threshold --:number
    local highest_threshold_checked = 0 --:number
    for i = 1, #thresholds do
        if quantity >= thresholds[i] then
            if highest_passed_threshold == nil then
                highest_passed_threshold = thresholds[i]
            elseif thresholds[i] > highest_passed_threshold then
                highest_passed_threshold = thresholds[i]
            end
        end
        if thresholds[i] > highest_threshold_checked then
            highest_threshold_checked = thresholds[i]
        end
    end
    if highest_passed_threshold == nil then
        return highest_threshold_checked
    end
    return highest_passed_threshold
end

--v function(self: FPD)
function faction_province_detail.evaluate_religion(self)
    self._UIReligionFactors = {}
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            if not not self._model._religionEffects[building] then
                for religion, quantity in pairs(self._model._religionEffects[building]) do
                    if self._religions[religion] == nil then
                        self._religions[religion] = 0
                    end
                    self._religions[religion] = self._religions[religion] + quantity
                    if self._UIReligionFactors[region._key] == nil then
                        self._UIReligionFactors[region._key] = {}
                    end
                    if self._UIReligionFactors[region._key][religion] == nil then
                        self._UIReligionFactors[region._key][religion] = 0
                    end
                    self._UIReligionFactors[region._key][religion] = self._UIReligionFactors[region._key][religion] + quantity
                end
            end
        end
    end
    
    for religion, quantity in pairs(self._religions) do
        self._religions[religion] = quantity - 5 
        if self._religions[religion] < 0 then
            self._religions[religion] = 0 
        end
        --natural decay of religions every turn
        local religion_detail = self._model._religionDetails[religion]
        local religion_level = FindThresholdFit(religion_detail._thresholds, quantity)
        self._religionLevels[religion] = religion_level
        table.insert(self._desiredEffects, religion_detail._bundles[religion_level])
    end
end

--v function(self: FPD)
function faction_province_detail.evaluate_tax_rate(self)
    local sub = cm:get_faction(self._faction):subculture()
    if self._model._taxResults[sub] == nil then
        self:log("tax rate is unimplemented for sub ["..sub.."] ")
        return
    end
    table.insert(self._desiredEffects, self._model._taxResults[sub][self._taxRate]._bundle)
end


--v function(self: FPD)
function faction_province_detail.evaluate_unit_generation(self)
    local subculture = cm:get_faction(self._faction):subculture()
    if self._model._unitProdReqs[subculture] == nil then 
        self._model._unitProdReqs[subculture] = {}
    end
    --buildings
    local unified_building_map = {} --:map<string, boolean>
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            unified_building_map[building] = true
            if not not self._model._unitProdEffects[building] then
                for unit, quantity in pairs(self._model._unitProdEffects[building]) do
                    if self._unitProduction[unit] == nil then
                        self._unitProduction[unit] = 0 
                    end
                    self._unitProduction[unit] = self._unitProduction[unit] + quantity
                end
            end
        end
    end
    --religions
    for religion, level in pairs(self._religionLevels) do
        local religion_detail = self._model._religionDetails[religion]
        if not religion_detail._unitProdEffects[level] == nil then
            for unit, quantity in pairs(religion_detail._unitProdEffects[level]) do
                if self._unitProduction[unit] == nil then
                    self._unitProduction[unit] = 0 
                end
                self._unitProduction[unit] = math.ceil(self._unitProduction[unit]*quantity)
            end
        end
    end
    --tax rate
    if self._model._taxResults[subculture] == nil then
        self:log("No tax implementation for unit prod on this subculture")
    else
        local tax_wealth_effect = self._model._taxResults[subculture][self._taxRate]._unitProdEffects
        for unit, prod in pairs(self._unitProduction) do
            self._unitProduction[unit] = math.ceil(self._unitProduction[unit]*tax_wealth_effect)
        end
    end
    --production permissions
    for unit, quantity in pairs(self._unitProduction) do
        local can_produce = true
        local reason = ""
        local req_buildings = self._model._unitProdReqs[subculture][unit]
        if req_buildings then
            for i = 1, #req_buildings do
                if not unified_building_map[req_buildings[i]] then
                    can_produce = false
                    reason = req_buildings[i]
                end
            end
        end
        if can_produce == true then
            self._producableUnits[unit] = {_bool = true, _reason = reason}
        else
            self._producableUnits[unit] = {_bool = false, _reason = reason}
        end
    end
end


--v function(self: FPD)
function faction_province_detail.evaluate_wealth(self)
    local subculture = cm:get_faction(self._faction):subculture()
    if self._model._wealthResults[subculture] == nil then
        self:log("wealth is not implemented for the subculture: ["..subculture.."]")
        return
    end
    self._UIWealthFactors = {}
    --buildings
    for key, region in pairs(self._regions) do
        for building, _ in pairs(region._buildings) do
            if not not self._model._wealthEffects[building] then
                self._wealth = self._wealth + self._model._wealthEffects[building] 
                if self._UIWealthFactors[region._key] == nil then
                    self._UIWealthFactors[region._key] = 0 
                end
                self._UIWealthFactors[region._key] = self._UIWealthFactors[region._key] + self._model._wealthEffects[building] 
            end
        end
    end
    --tax
    if self._model._taxResults[subculture] == nil then
        self:log("No tax implementation for wealth on this subculture")
    else
        local tax_wealth_effect = self._model._taxResults[subculture][self._taxRate]._wealthEffects
        self._wealth = self._wealth + tax_wealth_effect
        self._UIWealthFactors["Province Taxes"] = tax_wealth_effect
    end
    --religion
    for religion, level in pairs(self._religionLevels) do
        local religion_detail = self._model._religionDetails[religion]
        if not not religion_detail._wealthEffects[level] then
            --cache the increase for the UI 
            self._UIWealthFactors["RELIGION_"..religion] = religion_detail._wealthEffects[level]
            --apply the modifier
            self._wealth = self._wealth + religion_detail._wealthEffects[level]            
        end
    end
    local level = FindThresholdFit(self._model._wealthThresholds[subculture], self._wealth)
    self._wealthLevel = level
    table.insert(self._desiredEffects, self._model._wealthResults[subculture][level])
end



--v function(self: PM, fpd: FPD) 
function province_manager.save_fpd(self, fpd)
    local name = fpd._name
    local data_string = ""
    --wealth
    data_string = data_string.."|_wealth:"..fpd._wealth
    --wealthLevel
    data_string = data_string.."|_wealthLevel:"..fpd._wealthLevel
    --tax rate 
    data_string = data_string.."|_taxRate:"..fpd._taxRate
    --religions
    data_string = data_string.."|_religions:M:"
    for religion, value in pairs(fpd._religions) do
        data_string = data_string..religion.."<"..value..">"
    end
    data_string = data_string.."|_religionLevels:M:"
    --religionLevels
    for religion, value in pairs(fpd._religionLevels) do
        data_string = data_string..religion.."<"..value..">"
    end
    --unitGen
    data_string = data_string.."|_unitProduction:M:"
    for unit, value in pairs(fpd._unitProduction) do
        data_string = data_string..unit.."<"..value..">"
    end
    --partial_units
    data_string = data_string.."|_partialUnits:M:"
    for unit, value in pairs(fpd._partialUnits) do
        data_string = data_string..unit.."<"..value..">"
    end
    --capital
    data_string = data_string.."|_activeCapital:"..fpd._activeCapital
    --correct_capital
    --no need to save if it is false
    if fpd._correctCapital == true then
        data_string = data_string.."|_correctCapital:true"
    end
    --effects clear
    data_string = data_string.."|_activeEffectsClear:"..tostring(fpd._activeEffectsClear)
    if fpd._activeEffectsClear == false then
        --active effects
        --no need to save when its clear
        data_string = data_string.."|_activeEffects:V:"
        for i = 1, #fpd._activeEffects do
            data_string = data_string.."<"..fpd._activeEffects[i]..">"
        end
    end
    --desired effects
    data_string = data_string.."|_desiredEffects:V:"
    for i = 1, #fpd._desiredEffects do
        data_string = data_string.."<"..fpd._desiredEffects[i]..">"
    end
    --UI factors
    --no need to save unless the FPD is human
    if cm:get_faction(fpd._faction):is_human() then
        data_string = data_string.."|_UIWealthFactors:M:"
        for factor, value in pairs(fpd._UIWealthFactors) do
            data_string = data_string .. factor .. "<"..value..">"
        end
        data_string = data_string.."|_UIReligionFactors:MM:"
        for religion, factortable in pairs(fpd._UIReligionFactors) do
            data_string = data_string..religion.."{"
            for factor, value in pairs(factortable) do
                data_string = data_string..factor.."<"..value..">"
            end
            data_string = data_string.."}"
        end
    end
    --end
    data_string = data_string.."|"
    cm:set_saved_value("WEC_FPD_"..fpd._name, data_string)
    self:log("Saved FPD: "..fpd._name.." with savestring ["..data_string.."]")
end


--v function(self: PM, fpd: FPD, data:string)
function province_manager.load_fpd(self, fpd, data)
    --# assume fpd: WHATEVER -- a lighter nocheck for the function
    --v function(text: string | number | boolean | CA_CQI)
    local function LOG(text)
        if not __write_output_to_logfile then
            return;
        end
    
        local logText = tostring(text)
        local logTimeStamp = os.date("%d, %m %Y %X")
        local popLog = io.open("loading_test.txt","a")
        --# assume logTimeStamp: string
        popLog :write("PM :  [".. logTimeStamp .. "]:  "..logText .. "  \n")
        popLog :flush()
        popLog :close()
    end

    self:log("Loading FPD: ["..fpd._name.."]")
    LOG("Loading FPD: ["..fpd._name.."]")
    LOG("Operating on Data ["..data.."]")
    local last_div = 1 --:int
    local next_div = nil --:int
    local sets = {} --:map<int, int>
    while true do
        local next_div = string.find(data, "|", last_div + 1)
        if not next_div then
            break;
        end
        sets[last_div] = next_div
        LOG("Found div set ["..last_div.."] to ["..next_div.."]")
        last_div = next_div
    end
    for set_start, set_end in pairs(sets) do
        local set = string.sub(data, set_start + 1, set_end - 1)
        LOG("Operating on substring ["..set.."] ")
        if string.find(set, ":M:") then
            LOG("Set is a map!")
            --its a map!
            local new_set = string.gsub(set, "M:", "")
            local index_end = string.find(new_set, ":")
            local index = string.sub(new_set, 1, index_end - 1)
            local map_set = string.sub(new_set, index_end + 1)
            fpd[index] = {}
            local current_key_start = 1
            LOG("STARTING WHILE #1")
            while true do
                local next_open = string.find(map_set, "<", current_key_start)
                if not next_open then
                    LOG("BREAKING WHILE #1")
                    break
                end
                local key = string.sub(map_set, current_key_start, next_open - 1)
                local next_close = string.find(map_set, ">", next_open)
                local value = string.sub(map_set, next_open+1, next_close -1) 
                if not string.find(value, "%a") then
                    --# assume value: number
                    value = tonumber(value) 
                end
                fpd[index][key] = value
                current_key_start = next_close + 1
            end
        elseif string.find(set, ":MM:") then
            LOG("Set is a double map!")
            --double map!
            local new_set = string.gsub(set, "MM:", "")
            local index_end = string.find(new_set, ":")
            local index = string.sub(new_set, 1, index_end - 1)
            local map_set = string.sub(new_set, index_end + 1)
            fpd[index] = {}
            local current_key_start = 1
            LOG("STARTING WHILE #2")
            while true do
                local next_open = string.find(map_set, "{", current_key_start)
                if not next_open then
                    LOG("BREAKING WHILE #2")
                    break
                end
                local key = string.sub(map_set, current_key_start, next_open -1)
                fpd[index][key] = {}
                local next_close = string.find(map_set, "}", next_open)
                local sub_set = string.sub(map_set, next_open+1, next_close-1)
                LOG("Operating on Subset ["..sub_set.."]")
                LOG("STARTING WHILE #2 STAGE 2")
                local current_subkey_start = 1
                while true do
                    local next_sub_open = string.find(sub_set, "<", current_subkey_start)
                    if not next_sub_open then
                        LOG("BREAKING WHILE #2 STAGE 2")
                        break
                    end
                    local subkey = string.sub(sub_set, current_subkey_start, next_sub_open-1)
                    local next_sub_close = string.find(sub_set, ">", next_sub_open+1)
                    local subvalue = string.sub(sub_set, next_sub_open+1, next_sub_close-1)
                    fpd[index][key][subkey] = subvalue
                    current_subkey_start = next_sub_close + 1
                end
                current_key_start = next_close + 1
            end
        elseif string.find(set, ":V:") then
            LOG("Set is a vector!")
            --its a vector!
            local new_set = string.gsub(set, "V:", "")
            local index_end = string.find(new_set, ":")
            local index = string.sub(new_set,1, index_end - 1 )
            fpd[index] = {}
            local vec_set = string.sub(new_set, index_end+1)
            local search_start = 1
            LOG("STARTING WHILE #3")
            while true do
                local next_open = string.find(vec_set, "<", search_start)
                if not next_open then
                    LOG("BREAKING WHILE #3")
                    break;
                end
                local next_close = string.find(vec_set, ">", next_open)
                local value = string.sub(vec_set, next_open+1, next_close-1)
                if not string.find(value, "%a") then
                    value = tonumber(value)
                end
                table.insert(fpd[index], value)
                search_start = next_close + 1
            end
            
        else
            --its a simple value
            local index_end = string.find(set, ":")
            local index = string.sub(set,1, index_end - 1)
            local value = string.sub(set, index_end + 1)
            if not string.find(value, "%a") then
                value = tonumber(value)
            end
            fpd[index] = value
        end
    end
end

--v function(self: PM, faction_name: string, province_name: string, region_name: string) --> FPD
function province_manager.create_faction_province_detail(self, faction_name, province_name, region_name)
    self:log("Creating an FPD for ["..faction_name.."], ["..province_name.."], with starting capital ["..region_name.."]  ")
    local fpd = faction_province_detail.new(self, faction_name, province_name, region_name)
    if self._factionProvinceDetails[faction_name] == nil then
        self._factionProvinceDetails[faction_name] = {}
    end
    self._factionProvinceDetails[faction_name][province_name] = fpd
    local savedata = cm:get_saved_value("WEC_FPD_"..fpd._name) --:string
    if not not savedata then
        self:load_fpd(fpd, savedata)
    else
        self:log("No saved data found for new FPD")
        --we don't need to preform this if we're loading
        local region_obj = cm:get_region(region_name)
        if region_obj:is_province_capital() then
            fpd._correctCapital = true
        end
    end
    fpd:add_region(self._regionDetails[region_name])
    return fpd
end

--v function(self: PM, fpd: FPD)
function province_manager.delete_fpd(self, fpd)
    self:log("removing no longer in use fpd ["..fpd._name.."]")
    self._saveData[fpd._name] = nil;
    self._factionProvinceDetails[fpd._faction][fpd._province] = nil
end

--v function(self: PM, region: string)
function province_manager.create_region_detail(self, region)
    self:log("Creating a region detail for ["..region.."]")
    local region_obj = cm:get_region(region)
    local province = region_obj:province_name()
    local faction = region_obj:owning_faction():name()
    local new_region = region_detail.new(self, region, province)
    self._regionDetails[region] = new_region
    if self._factionProvinceDetails[faction] == nil then
        self._factionProvinceDetails[faction] = {}
    end
    if self._factionProvinceDetails[faction][province] == nil then
        self:log("Region detail has no FPD to join, creating one!")
        self:create_faction_province_detail(faction, province, region)
    else
        self:log("New Region Detail is joining an existing FPD")
        self._factionProvinceDetails[faction][province]:add_region(new_region)
    end
end


--content API functions
--v function(self: PM, building: string, wealth_effect: number)
function province_manager.add_building_wealth_effect(self, building, wealth_effect)
    if is_number(wealth_effect) and is_string(building) then
        self._wealthEffects[building] = wealth_effect
    end
end

--v function(self: PM, building: string, religion: RELIGION_NAME, effect: number)
function province_manager.add_building_religion_effect(self, building, religion, effect)
    if is_number(effect) and is_string(religion) and is_string(building) then
        if self._religionEffects[building] == nil then
            self._religionEffects[building] = {}
        end
        self._religionEffects[building][religion] = effect
    end
end

--v function(self: PM, building: string, unitID: string, effect: number)
function province_manager.add_building_unit_production_effect(self, building, unitID, effect)
    if is_number(effect) and is_string(unitID) and is_string(building) then
        if self._unitProdEffects[building] == nil then
            self._unitProdEffects[building] = {}
        end
        self._unitProdEffects[building][unitID] = effect
    end
end

--v function(self: PM, subculture: string, unitID: string, building: string)
function province_manager.add_building_unit_requirement(self, subculture, unitID, building)
    if is_string(building) and is_string(unitID) and is_string(subculture) then
        if self._unitProdReqs[subculture] == nil then
            self._unitProdReqs[subculture] = {}
        end
        if self._unitProdReqs[subculture][unitID] == nil then
            self._unitProdReqs[subculture][unitID] = {}
        end
        table.insert(self._unitProdReqs[subculture][unitID], building)
    end
end

--v function(self: PM, religion_key: RELIGION_NAME, religion_detail: RELIGION_DETAIL)
function province_manager.create_religion(self, religion_key, religion_detail)
    if is_string(religion_key) and is_table(religion_detail) then
        self._religionDetails[religion_detail._name] = religion_detail
    end
end

--v function(self: PM, subculture: string, quantity: number, effect_bundle: string, UIEffect: vector<string>)
function province_manager.add_wealth_threshold_for_subculture(self, subculture, quantity, effect_bundle, UIEffect)
    if is_string(subculture) and is_number(quantity) and is_string(effect_bundle) then
        if self._wealthResults[subculture] == nil then
            self._wealthResults[subculture] = {}
            self._wealthThresholds[subculture] = {}
            self._wealthResultsUI[subculture] = {}
        end
        self._wealthResultsUI[subculture][quantity] = UIEffect
        self._wealthResults[subculture][quantity] = effect_bundle
        table.insert(self._wealthThresholds[subculture], quantity)
    end
end

--v function(self: PM, subculture: string, level: number, tax_detail: TAX_DETAIL)
function province_manager.add_tax_level_for_subculture(self, subculture, level, tax_detail)
    if is_string(subculture) and is_number(level) and is_table(tax_detail) then
        if self._taxResults[subculture] == nil then
            self._taxResults[subculture] = {}
        end
        self._taxResults[subculture][level] = tax_detail
    end
end

--v function(self: PM, main_unit: string, land_unit: string, ui_image: string)
function province_manager.add_unit_ui_detail(self, main_unit, land_unit, ui_image)
    self._unitProdUIImages[main_unit] = ui_image
    self._unitProdUILandUnits[main_unit] = land_unit
end



province_manager.init()
_G.pm:log("province manager initialised")


