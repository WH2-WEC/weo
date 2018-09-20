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
                self._unitProduction[unit] = self._unitProduction[unit] + quantity
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
            savetable._producableUnits = fpd._producableUnits
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
    self:log("Creating an FPD for ["..faction_name.."], ["..province_name.."], with starting capital ["..region_name.."]  ")
    local fpd = faction_province_detail.new(self, faction_name, province_name, region_name)
    if self._factionProvinceDetails[faction_name] == nil then
        self._factionProvinceDetails[faction_name] = {}
    end
    self._factionProvinceDetails[faction_name][province_name] = fpd
    if not self._saveData[fpd._name] == nil then
        self:load_fpd(fpd)
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


province_manager.init()
_G.pm:log("province manager initialised")


cm:add_saving_game_callback(
    function(context)
        local status, err = pcall( function(context--:WHATEVER
        )
            local savedata = _G.pm:save() 
            cm:save_named_value("WEC_PM_SAVEDATA", savedata, context)
        end, context)
        if not status then 
            --# assume err: string
            PMLOG(err)
        end
    end
)
cm:add_loading_game_callback(
    function(context)
        local status, err = pcall(function(context--:WHATEVER
        )
            local savedata = cm:load_named_value("WEC_PM_SAVEDATA", {}, context)
            _G.pm:load(savedata)
        end, context)
        if not status then 
            --# assume err: string
            PMLOG(err)
        end
    end
)