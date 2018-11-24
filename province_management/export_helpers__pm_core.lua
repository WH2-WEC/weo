local pm = _G.pm
local rm = _G.rm

--v function(fpd: FPD)
function process_province_turn(fpd)
    if fpd:last_process() == cm:model():turn_number() then
        return
    end
    fpd:pre_process()
    local subculture = fpd:subculture()
    local faction = fpd:owning_faction()
    fpd:apply_prod_control()
    fpd:processes_finished()
end

--v function(region: CA_REGION)
local function pre_process_region_turn(region)
    local rd = pm:get_region_detail(region:name())
    rd:reset_unit_production_ui()
    rd:reset_wealth_ui()
    rd:clear_effects()
    rd:update_buildings()
end

--v function(region: CA_REGION)
local function process_region_turn(region)
    local rd = pm:get_region_detail(region:name())
    process_province_turn(rd:fpd())
    rd:update_wealth_cap()
    for building_key, _ in pairs(rd:buildings()) do
        rd:wealth_mod(pm:get_building_wealth_effect(building_key), "_"..building_key)
        if pm:building_has_unit_production(building_key) then
            for unit, quantity in pairs(pm:building_unit_production(building_key)) do
                rd:produce_unit(unit, quantity)
            end
        end
    end
    rd:apply_wealth()
    for unit, _ in pairs(rd:unit_production()) do
        local quantity = rd:calc_unit_production(unit)
        if rm:unit_has_pool(unit) then
            rm:change_unit_pool(unit, rd:owning_faction():name(), quantity)
        end
    end

    
end

--v function(region: CA_REGION, faction: CA_FACTION)
function process_region_captured(region, faction)
    local prov_key = region:province_name()
    local rd = pm:get_region_detail(region:name())
    local subculture = faction:subculture()
    local fpd = rd:fpd()
    --if we have a fpd, then proceed.
    --if the region was previous abandoned, there won't be an FPD!
    if not not fpd then
        pm:log("Processing region capture for region ["..region:name().."] in province ["..region:province_name().."] by faction ["..faction:name().."] from faction ["..fpd:faction().."] ")
        fpd:remove_region(rd:name())
        if fpd:is_empty() then
            pm:delete_fpd(fpd:faction(), fpd:province())
        end
        fpd = nil
    else
        pm:log("Processing region capture for region ["..region:name().."] in province ["..region:province_name().."] by faction ["..faction:name().."] from previous abandonment! ")
    end
    local new_fpd = pm:get_faction_province_detail(faction:name(), region:province_name())
    new_fpd:add_region(rd)
    pre_process_region_turn(region)
    rd:set_wealth(rd:wealth() - 60, true)
    new_fpd:apply_prod_control()
end

--v function(region: CA_REGION)
function process_region_abandonment(region)


end

core:add_listener(
    "PMFactionTurnStart",
    "FactionTurnStart",
    function(context)
        local faction = context:faction() --:CA_FACTION
        local is_rebel = (faction:name() == "rebels")
        local has_regions = (not faction:region_list():is_empty())
        local has_pm = pm:subculture_has_province_management(faction:subculture())
        return has_regions and (not is_rebel) and has_pm
    end,
    function(context)
        local region_list = context:faction():region_list() --:CA_REGION_LIST
        for i = 0, region_list:num_items() - 1 do
            pre_process_region_turn(region_list:item_at(i))
        end
        for i = 0, region_list:num_items() - 1 do
            process_region_turn(region_list:item_at(i))
        end
    end,
    true
)

cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context)
    local region_list = cm:model():world():region_manager():region_list()
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        pm:get_region_detail(region:name())
    end
    local region_list = cm:model():world():whose_turn_is_it():region_list()

end


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
            local sub = fpd:subculture()
            if not pm:subculture_has_province_management(sub) then
                return
            end
            pm._currentFPD = fpd
            pm:log("Set the current fpd to ["..fpd._province.."]")
            if pm:subculture_has_prod_control(sub) then
                pm:log("\t prod control level is ["..fpd._prodControl.."]")
            end
            pm:log("\t The Current subjects are:")
            for subject, _ in pairs(fpd:subject_whitelist()) do
                pm:log("\t\tSubject: ["..subject.."], state: ["..pm:get_faction_subject(cm:get_local_faction(true), subject):state().."]")
            end
            for key, rd in pairs(fpd._regions) do
                pm:log("\tRegion: ".. key)
                for building, _ in pairs(rd._buildings) do
                    pm:log("\t\tHas building: ".. building)
                end
                if pm:subculture_has_wealth(sub) then
                    pm:log("\t wealth is ["..rd._wealth.."] and the wealth cap is ["..rd._maxWealth.."] ")
                end
                pm:log("\t the unit production is:")
                for unit, number in pairs(rd._partialUnits) do
                    pm:log("\t\t unit: ["..unit.."] production is at ["..number.."] ")
                end
            end

        end
    end,
    true
)