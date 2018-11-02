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


core:add_listener(
    "ProcessTurnStartPM",
    "FactionTurnStart",
    function(context)
        return context:faction():name() ~= "rebels"
    end,
    function(context)


    end,
    true)

core:add_listener(
    "RegionTransitionTrackerPM",
    "GarrisonOccupiedEvent",
    function(context)
        return context:character():faction():name() ~= "rebels"
    end,
    function(context)
        
    end,
    true)