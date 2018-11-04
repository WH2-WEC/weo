local rm = _G.rm
local pm = _G.pm

--on selection, sets the selected settlment and prints details
core:add_listener(
    "SettlementSelectionTracker",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() == cm:get_local_faction(true)
    end,
    function(context)
        local region = context:garrison_residence():region():name()
        local faction_name = context:garrison_residence():region():owning_faction():name()
        local rd = pm:get_region(region)
        if not not rd then
            pm:set_selected_settlement(region)
            if __write_output_to_logfile then
                pm:log("Set the current region to ["..region.."]")
                pm:log("\tBuildings: ")
                for building, _ in pairs(rd:buildings()) do
                    pm:log("\t\tHas building: ".. building)
                end
                pm:log("\t tax rate is ["..rd:tax_rate().."]")
                pm:log("\t wealth is ["..rd:wealth().."] and the Wealth cap is ["..rd:wealth_cap().."] ")
                pm:log("\t the religion levels are:")
                for religion, kind in pairs(rd:get_faiths()) do
                    pm:log("\t\t religion: ["..religion.."], type: ["..kind.."], source: ["..rd:get_faith_source(religion).."] ")
                end
                pm:log("\t the unit production is:")
                for unit, number in pairs(rd:current_unit_production()) do
                    pm:log("\t\t unit: ["..unit.."] production is at ["..number.."] ")
                end
            end
        end
    end,
    true
)


--v function(region: CA_REGION, faith: WEC_FAITH_KEY, strength: number)
local function spread_faith(region, faith, strength)
    
    local own_faction = region:owning_faction()
    local processed = {} --:map<string, boolean>
    if strength > 1 then
        local adjacents = region:adjacent_region_list()
        for i = 0, adjacents:num_items() - 1 do
            local current_region = adjacents:item_at(i)
            processed[current_region:name()] = true
            if not (current_region:settlement():is_null_interface() or current_region:owning_faction():is_null_interface()) then
                local current_owner = current_region:owning_faction()
                if own_faction:at_war_with(own_faction) or own_faction:culture() ~= current_owner:culture() then
                    pm:get_region(current_region:name()):add_foreign_faith(faith, "regions_onscreen_"..current_region:name())
                else
                    pm:get_region(current_region:name()):add_own_faith(faith, "regions_onscreen_"..current_region:name())
                end
            end
            if strength > 2 then
                local double_adj_list = current_region:adjacent_region_list()
                for j = 0, double_adj_list:num_items() - 1 do
                    local double_c_region = double_adj_list:item_at(j)
                    if not processed[double_c_region:name()] then
                        local double_c_faction = double_c_region:owning_faction()
                        processed[double_c_region:name()] = true
                        if own_faction:at_war_with(own_faction) or own_faction:culture() ~= double_c_faction:culture() then
                            pm:get_region(current_region:name()):add_foreign_faith(faith, "regions_onscreen_"..double_c_region:name())
                        else
                            pm:get_region(current_region:name()):add_own_faith(faith, "regions_onscreen_"..double_c_region:name())
                        end
                    end
                end
            end
        end
    end

end






--v function(region: CA_REGION)
local function preprocess_region_turn(region)
    local rd = pm:get_region(region:name())
    rd:update_buildings()
    rd:update_wealth_cap()
    rd:reset_unit_production_ui()
    rd:reset_wealth_ui()
    rd:reset_faith_ui()
    rd:clear_effects()
    rd:set_tax_level(rd:tax_rate())
end

--v function(region: CA_REGION)
local function process_region_turn(region)
    local rd = pm:get_region(region:name())
    for building, _ in pairs(rd:buildings()) do
        --first, we want to spread religions
        if pm:building_has_faith(building) then
            local faith = pm:get_faith_from_building(building)
            local faith_key = faith[1]
            local faith_strength = faith[2]
            rd:add_own_faith(faith_key, "regions_onscreen_"..region:name())
            if faith_strength > 1 then
                spread_faith(region, faith_key, faith_strength)
            end
        end
    end
end

core:add_listener(
    "ProcessTurnStartPM",
    "FactionTurnStart",
    function(context)
        return context:faction():name() ~= "rebels"
    end,
    function(context)
        local list = context:faction():region_list()
        for i = 0, list:num_items() - 1 do
            preprocess_region_turn(context:faction():region_list():item_at(i))
        end
        for i = 0, list:num_items() - 1 do
            process_region_turn(context:faction():region_list():item_at(i))
        end
    end,
    true)

core:add_listener(
    "RegionTransitionTrackerPM",
    "GarrisonOccupiedEvent",
    function(context)
        return context:character():faction():name() ~= "rebels"
    end,
    function(context)
        --logic handled in model
        pm:transfer_region_to_faction(context:garrison_residence():region():name(), context:character():faction():name())
    end,
    true)