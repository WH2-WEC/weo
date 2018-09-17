pm = _G.pm; rm = _G.rm; cm = get_cm(); events = get_events(); 
pm:error_checker()



--these deal with turn start processes
--v function(region_detail: REGION_DETAIL)
local function OnTurnStartRegion(region_detail)
    local region_name = region_detail._key
    local region_obj = cm:get_region(region_name)
    region_detail._buildings = {}
    for i = 0, region_obj:settlement():slot_list():num_items() - 1 do
        local slot = region_obj:settlement():slot_list():item_at(i)
        if slot:has_building() then
            building = slot:building():name()
            region_detail._buildings[building] = true
        end
    end
end

--v function(fpd: FPD)
local function OnTurnStartProvince(fpd)
    if fpd._faction == "rebels" then
        return
    end
    pm:log("processing turn start for fpd: ["..fpd._name.."] !")
    --first of all, we want to clean up everything from last turn
    fpd:clear_active_effects()
    fpd._desiredEffects = {}
    fpd._unitProduction = {}
    --now, we want to evaluate the buildings for each region within the FPD
    for _, region_detail in pairs(fpd._regions) do
        OnTurnStartRegion(region_detail)
    end
    --now, we evaluate each element for the province
    fpd:evaluate_religion() --religion first because it can effect wealth and unit gen
    fpd:evaluate_tax_rate() --can also impact wealth and unit gen
    fpd:evaluate_unit_generation()
    fpd:evaluate_wealth()
    --all evaluations are finished so we can apply effects
    fpd:apply_all_effects()
    --apply our unit generation to RM
    for unit, quantity in pairs(fpd._unitProduction) do
        --avoid a nil case on partial units
        if fpd._partialUnits[unit] == nil then
            fpd._partialUnits[unit] = 0
        end
        if fpd._producableUnits[unit]._bool == true then
            local total = 0 --total number of units for rm to recieve
            fpd._unitProduction[unit] = fpd._unitProduction[unit] + fpd._partialUnits[unit]
            while fpd._unitProduction[unit] >= 100 do
                fpd._unitProduction[unit] = fpd._unitProduction[unit] - 100
                total = total + 1;
            end
            if total > 0 then 
                --increase unit pools
                local unit_set = pm._unitDetails[unit]._set
                for i = 1, total do
                    rm:change_unit_pool(unit_set[cm:random_number(#unit_set)], fpd._faction, 1)
                end
            end
            --store the partial unit for next turn
            fpd._partialUnits[unit] = fpd._unitProduction[unit]
            --restore the unit production so it can be viewed in the UI
            fpd._unitProduction[unit] = (total * 100) + fpd._partialUnits[unit] 
        end
    end
    pm:log("turn start process complete!")
end



core:add_listener(
    "ProvinceManagerTurnStart",
    "FactionTurnStart",
    function(context)
        return true
    end,
    function(context)
        local faction = context:faction():name() --:string
        local province_object_pair = pm._factionProvinceDetails[faction]
        if not not province_object_pair then
            for province_name, fpd in pairs(province_object_pair) do
                OnTurnStartProvince(fpd)
            end
        else
            pm:log("No FPD's found for ["..faction.."]: either they are a horde or something has gone wrong!")
        end
    end,
    true
)


--these deal with when a region is captured

--v function(region_name: string)
local function OnRegionOccupied(region_name)
    local region_obj = cm:get_region(region_name)
    local new_owner = region_obj:owning_faction():name()
    local region_detail = pm._regionDetails[region_name]
    local old_owner_fpd = region_detail._fpd
    local province_name = region_obj:province_name()
    pm:log("Region ["..region_name.."] has been occupied by ["..new_owner.."]")
    old_owner_fpd:remove_region(region_name)
    if pm._factionProvinceDetails[new_owner] == nil then
        pm._factionProvinceDetails[new_owner] = {}
    end
    if pm._factionProvinceDetails[new_owner][province_name] == nil then
        pm:create_faction_province_detail(new_owner, province_name, region_name)
    else
        pm._factionProvinceDetails[new_owner][province_name]:add_region(region_detail)
    end
    if old_owner_fpd._numRegions == 0 then
        pm:delete_fpd(old_owner_fpd)
    end
    pm:log("ownership transition complete")
end

core:add_listener(
    "RegionTransitionTracker",
    "GarrisonOccupiedEvent",
    function(context)
    return true
    end,
    function(context)
        local region = context:garrison_residence():region():name()
        OnRegionOccupied(region)
    end,
    true)





--this function creates region details 
events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1]  = function()
    local status, err = pcall(function()
        pm:log("Creating regions")
        local regions_list = cm:model():world():region_manager():region_list()
        for i = 0, regions_list:num_items() - 1 do
            local region_obj = regions_list:item_at(i)
            if not region_obj:settlement():is_null_interface() then
                --flows through to create FPD and load FPD data
                pm:create_region_detail(region_obj:name())
            end
        end
        
        if cm:get_saved_value("WEC_PM_NEWGAME") == nil then
            for faction, province_pair in pairs(pm._factionProvinceDetails) do
                for province, object in pairs(province_pair) do
                    OnTurnStartProvince(object)
                end
            end
        end
        cm:set_saved_value("WEC_PM_NEWGAME", true)
    end)
    if not status then
        --# assume err: string
        pm:log(err)
    end
    
end


--this function marks the currently selected province object for the UI

core:add_listener(
    "SettlementSelectionTracker",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() == cm:get_local_faction(true)
    end,
    function(context)
        local province = context:garrison_residence():region():province_name()
        local faction_name = context:garrison_residence():region():owning_faction():name()
        local fpd = pm._factionProvinceDetails[faction_name][province]
        if not not fpd then
            pm._currentFPD = fpd
            pm:log("Set the current fpd to ["..fpd._province.."]")
            pm:log("\t The active capital is ["..fpd._activeCapital.."] ")
            for key, object in pairs(fpd._regions) do
                pm:log("\tRegion: ".. key)
                for building, _ in pairs(object._buildings) do
                    pm:log("\t\tHas building: ".. building)
                end
            end
            pm:log("\t tax rate is ["..fpd._taxRate.."]")
            pm:log("\t wealth is ["..fpd._wealth.."] and the Wealth level is ["..fpd._wealthLevel.."] ")
            pm:log("\t the religion levels are:")
            for religion, value in pairs(fpd._religionLevels) do
                pm:log("\t\t religion: ["..religion.."], value: ["..value.."]")
            end
            pm:log("\t the unit production is:")
            for unit, number in pairs(fpd._unitProduction) do
                if not fpd._producableUnits[unit] == nil then
                    if fpd._producableUnits[unit]._bool == false then
                        pm:log("\t\t unit: ["..unit.."] production requirements not met")
                    else
                        pm:log("\t\t unit: ["..unit.."] production is at ["..number.."] ")
                    end
                else
                    pm:log("\t\t unit: ["..unit.."] production is at ["..number.."] ")
                end
            end
        end
    end,
    true
)

