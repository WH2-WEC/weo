events = get_events(); cm = get_cm();
rm = _G.rm; rdm = _G.rdm;

rdm:add_rm(rm)



--v function(region: CA_REGION, faction: CA_FACTION)
local function process_region(region, faction)
    local region_name = region:name()
    local region_detail = rdm:get_region(region_name)

end








--v function(faction: CA_FACTION)
local function process_faction_regions(faction)
    local faction_name = faction:name()
    local subculture_key = faction:subculture()
    local regions = faction:region_list()
    for i = 0, regions:num_items() do
        local region = regions:item_at(i)
        
    end
end







core:add_listener(
    "FactionTurnStartRegionManagement",
    "FactionTurnStart",
    function(context)
        return not wh_faction_is_horde(context:faction())
    end,
    function(context)
        process_faction_regions(context:faction())
    end,
    true
)