pm = _G.pm; rm = _G.rm; cm = get_cm(); events = get_events(); 

--this function creates region details 
cm:add_game_created_callback(function()
    local regions_list = cm:model():world():region_manager():region_list()
    for i = 0, regions_list:num_items() - 1 do
        local region_obj = regions_list:item_at(i)
        if not region_obj:settlement():is_null_interface() then
            --flows through to create FPD and load FPD data
            pm:create_region_detail(region_obj:name())
        end
    end
end)

--v function(region_detail: REGION_DETAIL)
local function OnTurnStartRegion(region_detail)
    local region_name = region_detail._key
    local region_obj = cm:get_region(region_name)
    region_detail._buildings = {}
    for i = 0, region_obj:settlement():slot_list():num_items() - 1 do
        local building = region_obj:settlement():slot_list():item_at(i):building():name()
        region_detail._buildings[building] = true
    end
end

--v function(fpd: FPD)
local function OnTurnStartProvince(fpd)

    --first of all, we want to clean up everything from last turn
    fpd:clear_active_effects()
    fpd._desiredEffects = {}
    fpd._unitProduction = {}
    --now, we want to evaluate the buildings for each region within the FPD
    for _, region_detail in pairs(fpd._regions) do
        OnTurnStartRegion(region_detail)
    end
    --now, we evaluate each element for the province
    fpd:evaluate_reglion() --religion first because it can effect wealth and unit gen
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
                rm:change_unit_pool(unit, fpd._faction, total)
            end
            --store the partial unit for next turn
            fpd._partialUnits[unit] = fpd._unitProduction[unit]
            --restore the unit production so it can be viewed in the UI
            fpd._unitProduction[unit] = (total * 100) + fpd._partialUnits[unit] 
        end
    end
end



core:add_listener(
    "ProvinceManagerTurnStart",
    "FactionTurnStart",
    true,
    function(context)
        local faction = context:faction():name() --:string
        local province_object_pair = pm._factionProvinceDetails[faction]
        for province_name, fpd in pairs(province_object_pair) do
            OnTurnStartProvince(fpd)
        end
    end,
    true
)