pm = _G.pm
local WEALTH_EFFECTS_JUNCTIONS = {
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_def_dark_elves_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_0", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -15, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_1", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_2", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_3", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_4", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_5", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_6", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 15, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_7", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_8", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 25, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_9", ["effect_key"] = "wec_game_income_entertainment", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh2_main_sc_hef_high_elves_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_brt_bretonnia_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_dwf_dwarfs_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_emp_empire_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_ksl_kislev_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_0", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_1", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_2", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_3", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = -10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_4", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 0, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_5", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 10, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_6", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 20, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_7", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 30, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_8", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 40, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_8", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -3, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_9", ["effect_key"] = "wec_game_subsistence_income", ["effect_scope"] = "region_to_province_own", ["value"] = 50, ["advancement_stage"] = "start_turn_completed" },
{ ["effect_bundle_key"] = "wec_wealth_wh_main_sc_teb_teb_9", ["effect_key"] = "wec_script_var_corruption", ["effect_scope"] = "region_to_province_own", ["value"] = -5, ["advancement_stage"] = "start_turn_completed" }
}--:vector<{effect_bundle_key: string, effect_key: string, effect_scope:string, value:number, advancement_stage: string}>


--[[pm:add_wealth_threshold_for_subculture("wh_main_sc_emp_empire", 1, "wec_religion_hum_ulric_1wh_main_sc_emp_empire", {
   effects
})
--]]
pm:log("Adding wealth content!")
local wealths = {} --:map<string, map<string, WHATEVER>>
for i = 1, #WEALTH_EFFECTS_JUNCTIONS do
    local instance = WEALTH_EFFECTS_JUNCTIONS[i]
    local key = instance.effect_bundle_key
    if wealths[key] == nil then
        wealths[key] = {}
        wealths[key]._UIEffects = {} 
        wealths[key]._level = tonumber(string.sub(key, -1)) * 10
        wealths[key]._subculture = string.sub(string.gsub(key, "wec_wealth_", ""), 1, -3)
    end
    local col = "red"
    local db_effect = instance.effect_key
    local value = instance.value
    if value > 0 then
        col = "green"
    end
    local loc = effect.get_localised_string("effects_description_"..db_effect)
    local effect_text =  string.gsub(loc, '%+n', tostring(value))
    local effect_text = string.gsub(effect_text, "%%", "", 1)
    local effect_text = "[[col:"..col.."]]"..effect_text.."[[/col]]"
    table.insert(wealths[key]._UIEffects, effect_text)
end

for key, detail in pairs(wealths) do
    pm:log("level; "..detail._level)
    pm:log("subculture; "..detail._subculture)
    pm:log("key; "..key)
    pm:add_wealth_threshold_for_subculture(detail._subculture, detail._level, key, detail._UIEffects)
end