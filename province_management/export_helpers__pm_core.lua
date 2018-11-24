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
    --fpd
    process_province_turn(rd:fpd())
    --wealth
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
    --unit prod
    for unit, _ in pairs(rd:unit_production()) do
        local quantity = rd:calc_unit_production(unit)
        if rm:unit_has_pool(unit) then
            rm:change_unit_pool(unit, rd:owning_faction():name(), quantity)
        end
    end
end

--v function(faction: CA_FACTION)
local function process_faction_subjects(faction)
    --for each fpd owned by this faction
    for province_key, fpd in pairs(pm:get_provinces_for_faction(faction:name())) do
        if fpd:is_capital_owned() then
            --find adjacent stuff
            local adj_provinces = {} --:map<string, CA_REGION>
            for region_key, region_detail in pairs(fpd:regions()) do
                local adj_list = region_detail:ca_object():adjacent_region_list()
                for j = 0, adj_list:num_items() - 1 do
                    local region = adj_list:item_at(j)
                    if region:province_name() ~= fpd:province() then
                        adj_provinces[region:name()] = region
                    end
                end
            end
            --add adjacent stuff
            for region_key, region in pairs(adj_provinces) do
                local other_fpd = pm:get_faction_province_detail(region:owning_faction():name(), region:province_name())
                for subject_key, _ in pairs(other_fpd:subject_offers()) do
                    fpd:add_subject(subject_key, "_"..region_key)
                end
            end
            --for each subject they have active, turn on the bundle
            for subject_key, _ in pairs(fpd:subject_whitelist()) do
                fpd:capital_region():apply_effect_bundle("wec_subject_bundle_"..subject_key.."_"..pm:get_faction_subject(faction:name(), subject_key):state())
            end
        end
    end

end


--v function(region: CA_REGION, faction: CA_FACTION)
local function process_region_captured(region, faction)
    local prov_key = region:province_name()
    local rd = pm:get_region_detail(region:name())
    local subculture = faction:subculture()
    local fpd = rd:fpd()
    local save_old = true
    --if we have a fpd, then proceed.
    --if the region was previous abandoned, there won't be an FPD!
    if not not fpd then
        pm:log("Processing region capture for region ["..region:name().."] in province ["..region:province_name().."] by faction ["..faction:name().."] from faction ["..fpd:faction().."] ")
        fpd:remove_region(rd:name())
        if fpd:is_empty() then
            pm:delete_fpd(fpd:faction(), fpd:province())
            save_old = false
        end
    else
        pm:log("Processing region capture for region ["..region:name().."] in province ["..region:province_name().."] by faction ["..faction:name().."] from previous abandonment! ")
    end
    local new_fpd = pm:get_faction_province_detail(faction:name(), region:province_name())
    new_fpd:add_region(rd)
    pre_process_region_turn(region)
    rd:set_wealth(rd:wealth() - 60, true)
    new_fpd:apply_prod_control()
    if save_old then
        pm:save_fpd(fpd)
    end
    pm:save_fpd(new_fpd)
    pm:save_rd(rd)
end

--v function(region: CA_REGION)
local function process_region_abandonment(region)


end


cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function() 
    local ok, err = pcall( function()
    for i = 1, #cm:get_human_factions() do
        pm._humans[cm:get_human_factions()[i]] = true
    end
    local region_list = cm:model():world():region_manager():region_list()
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        if not (region:settlement():is_null_interface() or region:owning_faction() == "rebels") then
            pm:get_region_detail(region:name())
        end
    end
    if cm:is_new_game() then
        local region_list = cm:model():world():whose_turn_is_it():region_list()
        for i = 0, region_list:num_items() - 1 do
            pre_process_region_turn(region_list:item_at(i))
        end
        for i = 0, region_list:num_items() - 1 do
            process_region_turn(region_list:item_at(i))
        end
        process_faction_subjects(cm:model():world():whose_turn_is_it())
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
            process_faction_subjects(context:faction())
        end,
        true
        )
    end)
    if not ok then
        pm:log(tostring(err))
    end
end


core:add_listener(
    "SettlementSelectionTracker",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() == cm:get_local_faction(true)
    end,
    function(context)
        local province = context:garrison_residence():region():province_name()
        local faction_name = context:garrison_residence():faction():name()
        local fpd = pm:get_faction_province_detail(faction_name, province)
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