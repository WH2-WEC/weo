local pm = _G.pm

--v function(fpd: FPD)
function process_province_turn(fpd)
    if fpd:last_process() == cm:model():turn_number() then
        return
    end
    fpd:pre_process()
    local subculture = fpd:subculture()
    local faction = fpd:owning_faction()
    fpd:apply_prod_control()
    fpd:apply_subjects()
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


end

--v function(region: CA_REGION, faction: CA_FACTION)
function process_region_captured(region, faction)


end


cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context)
    local region_list = cm:model():world():region_manager():region_list()
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        pm:get_region_detail(region:name())
    end
end


core:add_listener(
    "PMFactionTurnStart",
    "FactionTurnStart",
    function(context)
        local faction = context:faction() --:CA_FACTION
        local is_rebel = (faction:name() == "rebels")
        local has_regions = (not faction:region_list():is_empty())
        return has_regions and (not is_rebel)
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