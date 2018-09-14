pm = _G.pm

--this function creates region details 
cm:add_game_created_callback(function()
    local regions_list = cm:model():world():region_manager():region_list()
    for i = 0, regions_list:num_items() - 1 do
        pm:create_region_detail(regions_list:item_at(i):name())
    end
end)