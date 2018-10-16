local subculture_default_units = {
    ["wh_dlc03_sc_bst_beastmen"] = {"wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_ungor_raiders_0",  "wh_dlc03_bst_inf_ungor_spearmen_1", "wh_dlc03_bst_inf_gor_herd_0", "wh_dlc03_bst_inf_gor_herd_0"},
    ["wh_dlc05_sc_wef_wood_elves"] = {"wh_dlc05_wef_inf_eternal_guard_1", "wh_dlc05_wef_inf_glade_guard_0", "wh_dlc05_wef_inf_dryads_0"},
    ["wh_main_sc_brt_bretonnia"] = {"wh_main_brt_cav_knights_of_the_realm", "wh_dlc07_brt_inf_men_at_arms_2", "wh_main_brt_inf_peasant_bowmen", "wh_main_brt_cav_knights_of_the_realm"},
    ["wh_main_sc_chs_chaos"] = {"wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_cav_chaos_chariot", "wh_main_chs_inf_chaos_warriors_0", "wh_main_chs_inf_chaos_warriors_0", "wh_dlc01_chs_inf_forsaken_0"},
    ["wh_main_sc_dwf_dwarfs"] = {"wh_main_dwf_inf_longbeards", "wh_main_dwf_inf_thunderers_0", "wh_main_dwf_inf_dwarf_warrior_0"},
    ["wh_main_sc_emp_empire"] = {"wh_main_emp_inf_swordsmen", "wh_main_emp_inf_handgunners", "wh_main_emp_inf_halberdiers"},
    ["wh_main_sc_grn_greenskins"] = {"wh_main_grn_inf_orc_big_uns", "wh_dlc06_grn_inf_nasty_skulkers_0", "wh_main_grn_inf_orc_arrer_boyz"},
    ["wh_main_sc_grn_savage_orcs"] = {"wh_main_grn_inf_savage_orc_big_uns","wh_main_grn_inf_savage_orc_arrer_boyz"},
    ["lololol wh_main_sc_ksl_kislev"] = {"wh_main_emp_inf_halberdiers"},
    ["wh_main_sc_nor_norsca"] = {"wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_hunters_1", "wh_main_nor_inf_chaos_marauders_0", "wh_dlc08_nor_inf_marauder_spearman_0", "wh_main_nor_cav_marauder_horsemen_0"},
    ["lololol wh_main_sc_teb_teb"] = {"wh_main_emp_inf_halberdiers"},
    ["wh_main_sc_vmp_vampire_counts"] = {"wh_main_vmp_inf_crypt_ghouls"}, 
    ["wh2_dlc09_sc_tmb_tomb_kings"] = {"wh2_dlc09_tmb_inf_nehekhara_warriors_0", "wh2_dlc09_tmb_inf_skeleton_archers_0", "wh2_dlc09_tmb_veh_skeleton_archer_chariot_0", "wh2_dlc09_tmb_inf_nehekhara_warriors_0"},
    ["wh2_main_sc_def_dark_elves"] = {"wh2_main_def_inf_black_ark_corsairs_0","wh2_main_def_inf_darkshards_0", "wh2_main_def_inf_dreadspears_0"},
    ["wh2_main_sc_hef_high_elves"] = {"wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_spearmen_0", "wh2_main_hef_inf_archers_1", "wh2_main_hef_cav_silver_helms_0", "wh2_main_hef_inf_lothern_sea_guard_1"},
    ["wh2_main_sc_lzd_lizardmen"] = {"wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_saurus_spearmen_0", "wh2_main_lzd_inf_saurus_warriors_1", "wh2_main_lzd_inf_skink_cohort_1"},
    ["wh2_main_sc_skv_skaven"]  = {"wh2_main_skv_inf_stormvermin_0", "wh2_main_skv_inf_stormvermin_1", "wh2_main_skv_inf_gutter_runners_1"}
}--:map<string, vector<string>>













--ai systems to enforce a proxy of recruitment controls on the AI

--v function(unit_totals: map<string, number>, unitID: string)
local function increment_unit_total(unit_totals, unitID)
    if unit_totals[unitID] == nil then
        unit_totals[unitID] = 0
    end
    unit_totals[unitID] = unit_totals[unitID] + 1
end

--v function(group_totals: map<string, number>, groupID: string, weight: number)
local function increment_group_total(group_totals, groupID, weight)
    rm:log("Incrementing a group total for ["..groupID.."] with weight ["..weight.."] ")
    if group_totals[groupID] == nil then
        group_totals[groupID] = 0
    end
    group_totals[groupID] = group_totals[groupID] + (1* weight)
end

--v function(character: CA_CHAR, groupID: string, difference: number)
local function limit_character(character, groupID, difference)
    if subculture_default_units[character:faction():subculture()] == nil then
        return
    end
    local diff = difference


    rm:log("limiting character ["..tostring(character:cqi()).."] in group ["..groupID.."] who has a difference of ["..diff.."] ")
    local unit_list = character:military_force():unit_list()
    for j = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(j):unit_key()
        local groups_list = rm:get_groups_for_unit(unit)
        for k = 1, #groups_list do
            if groups_list[k] == groupID then
                cm:remove_unit_from_character(cm:char_lookup_str(character:cqi()), unit)
                local new_unit = subculture_default_units[character:faction():subculture()][cm:random_number(#subculture_default_units[character:faction():subculture()])]
                cm:grant_unit_to_character(cm:char_lookup_str(character:cqi()), new_unit)
                rm:log("removed unit ["..unit.."] and granted ["..new_unit.."] as a replacement unit!")
                if rm:get_weight_for_unit(unit, character:cqi()) >= diff then
                    rm:log("removed unit was sufficient!")
                    return
                end
                diff = diff - rm:get_weight_for_unit(unit, character:cqi());
                rm:log("removed unit was insufficient, repeating!")
            end
        end
    end
end





--v function(character: CA_CHAR)
local function rm_ai_character(character)

    if cm:char_is_mobile_general_with_army(character) then
        local unit_list = character:military_force():unit_list()
        local unit_totals = {} --:map<string, number>
        local group_totals = {} --:map<string, number>
        for j = 0, unit_list:num_items() - 1 do
            local unit = unit_list:item_at(j):unit_key()
            local groups_list = rm:get_groups_for_unit(unit)
            for k = 1, #groups_list do
                increment_group_total(group_totals, groups_list[k], rm:get_weight_for_unit(unit, character:cqi()))
            end
        end
        for groupID, quantity in pairs(group_totals) do
            local limit = rm:get_quantity_limit_for_group(groupID)
            if quantity > limit then
                limit_character(character, groupID, quantity - limit)
            end
        end
    end
end


--v function(faction:CA_FACTION)
local function rm_ai_evaluation(faction)
    if faction:name() == "rebels" then
        return
    end

    rm:log("AI CHECKS ["..faction:name().."]")
    local character_list = faction:character_list()
    for i = 0, character_list:num_items() - 1 do
        local character = character_list:item_at(i)
        rm_ai_character(character)
    end
    if not rm._unitPoolQuantities[faction:name()] == nil then
        for unit, quantity in pairs(rm._unitPoolQuantities[faction:name()]) do
            if quantity <= 0 then
                rm:log("AI Faction ["..faction:name().."] is out of unit "..unit.." ")
                cm:add_event_restricted_unit_record_for_faction(unit, faction:name())
            else
                cm:remove_event_restricted_unit_record_for_faction(unit, faction:name())
            end
        end
    end
end







core:add_listener(
    "RecruitmentControlsAI",
    "FactionTurnStart",
    function(context)
        return not context:faction():is_human()
    end,
    function(context)
        rm_ai_evaluation(context:faction())
    end,
    true
)

core:add_listener(
    "RecruitmentControlsAIUnitTrained",
    "UnitTrained",
    function(context)
        return (not context:unit():faction():is_human())
    end,
    function(context)
        local unit = context:unit() --:CA_UNIT
        if rm:unit_has_pool(unit:unit_key()) then
            rm:change_unit_pool(unit:unit_key(), unit:faction():name(), -1)
        end
    end,
    true
)