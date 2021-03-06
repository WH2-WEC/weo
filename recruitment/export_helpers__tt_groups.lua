--grab rm, cm and events
events = get_events(); cm = get_cm(); rm = _G.rm;


mcm = _G.mcm
local units = {
--empire
{"wh_dlc04_emp_cav_knights_blazing_sun_0", "emp_special", 2},
{"wh_dlc04_emp_inf_flagellants_0", "emp_special", 1},
{"wh_dlc04_emp_inf_free_company_militia_0", "emp_core"},
{"wh_main_emp_art_great_cannon", "emp_special", 1},
{"wh_main_emp_art_helblaster_volley_gun", "emp_rare", 2},
{"wh_main_emp_art_helstorm_rocket_battery", "emp_rare", 2},
{"wh_main_emp_art_mortar", "emp_special", 1},
{"wh_main_emp_cav_demigryph_knights_0", "emp_special", 3},
{"wh_main_emp_cav_demigryph_knights_1", "emp_special", 3},
{"wh_main_emp_cav_empire_knights", "emp_core"},
{"wh_main_emp_cav_outriders_0", "emp_special", 1},
{"wh_main_emp_cav_outriders_1", "emp_special", 2},
{"wh_main_emp_cav_pistoliers_1", "emp_special", 1},
{"wh_main_emp_cav_reiksguard", "emp_special", 2},
{"wh_main_emp_inf_crossbowmen", "emp_core"},
{"wh_main_emp_inf_greatswords", "emp_special", 2},
{"wh_main_emp_inf_halberdiers", "emp_core"},
{"wh_main_emp_inf_handgunners", "emp_core"},
{"wh_main_emp_inf_spearmen_0", "emp_core"},
{"wh_main_emp_inf_spearmen_1", "emp_core"},
{"wh_main_emp_inf_swordsmen", "emp_core"},
{"wh_main_emp_veh_luminark_of_hysh_0", "emp_rare", 3},
{"wh_main_emp_veh_steam_tank", "emp_rare", 3},
--dwf
{"wh_dlc06_dwf_art_bolt_thrower_0", "dwf_special", 1},
{"wh_dlc06_dwf_inf_bugmans_rangers_0", "dwf_rare", 1},
{"wh_dlc06_dwf_inf_rangers_0", "dwf_rare", 1},
{"wh_dlc06_dwf_inf_rangers_1", "dwf_rare", 1},
{"wh_main_dwf_art_cannon", "dwf_special", 2},
{"wh_main_dwf_art_flame_cannon", "dwf_rare", 3},
{"wh_main_dwf_art_grudge_thrower", "dwf_special", 1},
{"wh_main_dwf_art_organ_gun", "dwf_rare", 3},
{"wh_main_dwf_inf_dwarf_warrior_0", "dwf_core"},
{"wh_main_dwf_inf_dwarf_warrior_1", "dwf_core"},
{"wh_main_dwf_inf_hammerers", "dwf_special", 2},
{"wh_main_dwf_inf_ironbreakers", "dwf_special", 2},
{"wh_main_dwf_inf_irondrakes_0", "dwf_rare", 2},
{"wh_main_dwf_inf_irondrakes_2", "dwf_rare", 2},
{"wh_main_dwf_inf_longbeards", "dwf_core"},
{"wh_main_dwf_inf_longbeards_1", "dwf_core"},
{"wh_main_dwf_inf_miners_0", "dwf_special", 1},
{"wh_main_dwf_inf_miners_1", "dwf_special", 1},
{"wh_main_dwf_inf_quarrellers_0", "dwf_core"},
{"wh_main_dwf_inf_quarrellers_1", "dwf_core"},
{"wh_main_dwf_inf_slayers", "dwf_special", 1},
{"wh_main_dwf_inf_thunderers_0", "dwf_core"},
{"wh_main_dwf_veh_gyrobomber", "dwf_rare", 2},
{"wh_main_dwf_veh_gyrocopter_0", "dwf_special", 2},
{"wh_main_dwf_veh_gyrocopter_1", "dwf_special", 2},
{"wh2_dlc10_dwf_inf_giant_slayers", "dwf_special", 2},
-- vmp
{"wh_dlc02_vmp_cav_blood_knights_0", "vmp_rare", 2},
{"wh_dlc04_vmp_veh_corpse_cart_0", "vmp_special", 2},
{"wh_dlc04_vmp_veh_corpse_cart_1", "vmp_special", 3},
{"wh_dlc04_vmp_veh_corpse_cart_2", "vmp_special", 3},
{"wh_dlc04_vmp_veh_mortis_engine_0", "vmp_rare", 3},
{"wh_main_vmp_cav_hexwraiths", "vmp_special", 2},
{"wh_main_vmp_inf_cairn_wraiths", "vmp_rare", 1},
{"wh_main_vmp_inf_crypt_ghouls", "vmp_core"},
{"wh_main_vmp_inf_grave_guard_0", "vmp_special", 1},
{"wh_main_vmp_inf_grave_guard_1", "vmp_special", 1},
{"wh_main_vmp_inf_skeleton_warriors_0", "vmp_core"},
{"wh_main_vmp_inf_skeleton_warriors_1", "vmp_core"},
{"wh_main_vmp_inf_zombie", "vmp_core"},
{"wh_main_vmp_mon_crypt_horrors", "vmp_special", 2},
{"wh_main_vmp_mon_dire_wolves", "vmp_core"},
{"wh_main_vmp_mon_fell_bats", "vmp_special", 1},
{"wh_main_vmp_mon_terrorgheist", "vmp_rare", 3},
{"wh_main_vmp_mon_vargheists", "vmp_special", 2},
{"wh_main_vmp_mon_varghulf", "vmp_rare", 1},
{"wh_main_vmp_cav_black_knights_0", "vmp_special", 2},
{"wh_main_vmp_cav_black_knights_3", "vmp_special", 2},
{"wh_main_vmp_veh_black_coach", "vmp_rare", 1},
-- brt
{"wh_dlc07_brt_art_blessed_field_trebuchet_0", "brt_rare", 2},
{"wh_dlc07_brt_cav_grail_guardians_0", "brt_rare", 1},
{"wh_dlc07_brt_cav_knights_errant_0", "brt_core"},
{"wh_dlc07_brt_cav_questing_knights_0", "brt_special", 2},
{"wh_dlc07_brt_cav_royal_hippogryph_knights_0", "brt_rare", 2},
{"wh_dlc07_brt_cav_royal_pegasus_knights_0", "brt_special", 3},
{"wh_dlc07_brt_inf_battle_pilgrims_0", "brt_special", 1},
{"wh_dlc07_brt_inf_foot_squires_0", "brt_special", 1},
{"wh_dlc07_brt_inf_grail_reliquae_0", "brt_special", 2},
{"wh_dlc07_brt_inf_men_at_arms_1", "brt_core"},
{"wh_dlc07_brt_inf_men_at_arms_2", "brt_core"},
{"wh_dlc07_brt_inf_peasant_bowmen_1", "brt_core"},
{"wh_dlc07_brt_inf_peasant_bowmen_2", "brt_core"},
{"wh_dlc07_brt_inf_spearmen_at_arms_1", "brt_core"},
{"wh_dlc07_brt_peasant_mob_0", "brt_core"},
{"wh_main_brt_art_field_trebuchet", "brt_special", 2},
{"wh_main_brt_cav_grail_knights", "brt_rare", 1},
{"wh_main_brt_cav_knights_of_the_realm", "brt_core"},
{"wh_main_brt_cav_mounted_yeomen_0", "brt_core"},
{"wh_main_brt_cav_mounted_yeomen_1", "brt_core"},
{"wh_main_brt_cav_pegasus_knights", "brt_special", 2},
{"wh_main_brt_inf_men_at_arms", "brt_core"},
{"wh_main_brt_inf_peasant_bowmen", "brt_core"},
{"wh_main_brt_inf_spearmen_at_arms", "brt_core"},
-- grn
{"wh_dlc06_grn_cav_squig_hoppers_0", "grn_special", 2},
{"wh_dlc06_grn_inf_nasty_skulkers_0", "grn_core"},
{"wh_dlc06_grn_inf_squig_herd_0", "grn_special", 1},
{"wh_main_grn_art_doom_diver_catapult", "grn_rare", 2},
{"wh_main_grn_art_goblin_rock_lobber", "grn_rare", 1},
{"wh_main_grn_cav_forest_goblin_spider_riders_0", "grn_core"},
{"wh_main_grn_cav_forest_goblin_spider_riders_1", "grn_core"},
{"wh_main_grn_cav_goblin_wolf_chariot", "grn_special", 1},
{"wh_main_grn_cav_goblin_wolf_riders_0", "grn_core"},
{"wh_main_grn_cav_goblin_wolf_riders_1", "grn_core"},
{"wh_main_grn_cav_orc_boar_boy_big_uns", "grn_special", 2},
{"wh_main_grn_cav_orc_boar_boyz", "grn_special", 1},
{"wh_main_grn_cav_orc_boar_chariot", "grn_special", 2},
{"wh_main_grn_cav_savage_orc_boar_boy_big_uns", "grn_special", 2},
{"wh_main_grn_cav_savage_orc_boar_boyz", "grn_special", 1},
{"wh_main_grn_inf_black_orcs", "grn_special", 2},
{"wh_main_grn_inf_goblin_archers", "grn_core"},
{"wh_main_grn_inf_goblin_spearmen", "grn_core"},
{"wh_main_grn_inf_night_goblin_archers", "grn_core"},
{"wh_main_grn_inf_night_goblin_fanatics", "grn_core"},
{"wh_main_grn_inf_night_goblin_fanatics_1", "grn_core"},
{"wh_main_grn_inf_night_goblins", "grn_core"},
{"wh_main_grn_inf_orc_arrer_boyz", "grn_core"},
{"wh_main_grn_inf_orc_big_uns", "grn_core"},
{"wh_main_grn_inf_orc_boyz", "grn_core"},
{"wh_main_grn_inf_savage_orc_arrer_boyz", "grn_core"},
{"wh_main_grn_inf_savage_orc_big_uns", "grn_core"},
{"wh_main_grn_inf_savage_orcs", "grn_core"},
{"wh_main_grn_mon_arachnarok_spider_0", "grn_rare", 3},
{"wh_main_grn_mon_giant", "grn_rare", 2},
{"wh_main_grn_mon_trolls", "grn_special", 2},
 --chs
{"wh_main_chs_art_hellcannon", "chs_rare", 2},
{"wh_main_chs_mon_chaos_warhounds_0", "chs_core"},
{"wh_main_chs_mon_chaos_warhounds_1", "chs_core"},
{"wh_dlc01_chs_mon_dragon_ogre", "chs_special", 2},
{"wh_dlc01_chs_mon_trolls_1", "chs_special", 1},
{"wh_main_chs_mon_chaos_spawn", "chs_rare", 1},
{"wh_main_chs_mon_trolls", "chs_special", 1},
{"wh_dlc01_chs_mon_dragon_ogre_shaggoth", "chs_rare", 2},
{"wh_dlc06_chs_feral_manticore", "chs_special", 2},
{"wh_main_chs_mon_giant", "chs_rare", 1},
{"wh_dlc06_chs_cav_marauder_horsemasters_0", "chs_core"},
{"wh_main_chs_cav_marauder_horsemen_0", "chs_core"},
{"wh_main_chs_cav_marauder_horsemen_1", "chs_core"},
{"wh_dlc01_chs_inf_chaos_warriors_2", "chs_core"},
{"wh_dlc01_chs_inf_chosen_2", "chs_special", 2},
{"wh_dlc01_chs_inf_forsaken_0", "chs_core"},
{"wh_dlc06_chs_inf_aspiring_champions_0", "chs_special", 1},
{"wh_main_chs_inf_chaos_marauders_0", "chs_core"},
{"wh_main_chs_inf_chaos_marauders_1", "chs_core"},
{"wh_main_chs_inf_chaos_warriors_0", "chs_core"},
{"wh_main_chs_inf_chaos_warriors_1", "chs_core"},
{"wh_main_chs_inf_chosen_0", "chs_special", 2},
{"wh_main_chs_inf_chosen_1", "chs_special", 2},
{"wh_main_chs_cav_chaos_knights_0", "chs_special", 2},
{"wh_main_chs_cav_chaos_knights_1", "chs_special", 2},
{"wh_dlc01_chs_cav_gorebeast_chariot", "chs_special", 1},
{"wh_main_chs_cav_chaos_chariot", "chs_core"},
--bst
{"wh_dlc03_bst_inf_chaos_warhounds_0", "bst_core"},
{"wh_dlc03_bst_inf_chaos_warhounds_1", "bst_core"},
{"wh_dlc03_bst_inf_minotaurs_0", "bst_special", 2},
{"wh_dlc03_bst_inf_minotaurs_1", "bst_special", 2},
{"wh_dlc03_bst_inf_minotaurs_2", "bst_special", 2},
{"wh_dlc03_bst_mon_chaos_spawn_0", "bst_rare", 1},
{"wh_dlc05_bst_mon_harpies_0", "bst_special", 1},
{"wh_dlc03_bst_inf_razorgor_herd_0", "bst_special", 1},
{"wh_dlc03_bst_feral_manticore", "bst_special", 2},
{"wh_dlc03_bst_mon_giant_0", "bst_rare", 2},
{"wh_dlc03_bst_inf_cygor_0", "bst_rare", 2},
{"wh_dlc03_bst_inf_ungor_raiders_0", "bst_core"},
{"wh_dlc03_bst_inf_bestigor_herd_0", "bst_special", 1},
{"wh_dlc03_bst_inf_gor_herd_0", "bst_core"},
{"wh_dlc03_bst_inf_gor_herd_1", "bst_core"},
{"wh_dlc03_bst_inf_ungor_herd_1", "bst_core"},
{"wh_dlc03_bst_inf_ungor_spearmen_0", "bst_core"},
{"wh_dlc03_bst_inf_ungor_spearmen_1", "bst_core"},
{"wh_dlc03_bst_inf_centigors_0", "bst_special", 1},
{"wh_dlc03_bst_inf_centigors_1", "bst_special", 1},
{"wh_dlc03_bst_inf_centigors_2", "bst_special", 1},
{"wh_dlc03_bst_cav_razorgor_chariot_0", "bst_special", 2},
--wef
{"wh_dlc05_wef_mon_treekin_0", "wef_special", 2},
{"wh_dlc05_wef_forest_dragon_0", "wef_rare", 3},
{"wh_dlc05_wef_mon_great_eagle_0", "wef_rare", 1},
{"wh_dlc05_wef_mon_treeman_0", "wef_rare", 3},
{"wh_dlc05_wef_inf_deepwood_scouts_0", "wef_special", 1},
{"wh_dlc05_wef_inf_deepwood_scouts_1", "wef_special", 1},
{"wh_dlc05_wef_inf_glade_guard_0", "wef_core"},
{"wh_dlc05_wef_inf_glade_guard_1", "wef_core"},
{"wh_dlc05_wef_inf_glade_guard_2", "wef_core"},
{"wh_dlc05_wef_inf_waywatchers_0", "wef_rare", 1},
{"wh_dlc05_wef_cav_glade_riders_0", "wef_core"},
{"wh_dlc05_wef_cav_glade_riders_1", "wef_core"},
{"wh_dlc05_wef_cav_hawk_riders_0", "wef_special", 2},
{"wh_dlc05_wef_cav_sisters_thorn_0", "wef_special", 3},
{"wh_dlc05_wef_inf_dryads_0", "wef_core"},
{"wh_dlc05_wef_inf_eternal_guard_0", "wef_core"},
{"wh_dlc05_wef_inf_eternal_guard_1", "wef_core"},
{"wh_dlc05_wef_inf_wardancers_0", "wef_special", 1},
{"wh_dlc05_wef_inf_wardancers_1", "wef_special", 1},
{"wh_dlc05_wef_inf_wildwood_rangers_0", "wef_special", 2},
{"wh_dlc05_wef_cav_wild_riders_0", "wef_special", 2},
{"wh_dlc05_wef_cav_wild_riders_1", "wef_special", 2},
--nor
{"wh_dlc08_nor_mon_warwolves_0", "nor_special", 1},
{"wh_main_nor_mon_chaos_warhounds_0", "nor_core"},
{"wh_main_nor_mon_chaos_warhounds_1", "nor_core"},
{"wh_dlc08_nor_mon_fimir_0", "nor_rare", 1},
{"wh_dlc08_nor_mon_fimir_1", "nor_rare", 1},
{"wh_dlc08_nor_mon_norscan_ice_trolls_0", "nor_special", 2},
{"wh_main_nor_mon_chaos_trolls", "nor_special", 2},
{"wh_dlc08_nor_feral_manticore", "nor_special", 3},
{"wh_dlc08_nor_mon_frost_wyrm_0", "nor_rare", 3},
{"wh_dlc08_nor_mon_norscan_giant_0", "nor_rare", 2},
{"wh_dlc08_nor_mon_war_mammoth_0", "nor_rare", 2},
{"wh_dlc08_nor_mon_war_mammoth_1", "nor_rare", 3},
{"wh_dlc08_nor_mon_war_mammoth_2", "nor_rare", 3},
{"wh_dlc08_nor_inf_marauder_hunters_0", "nor_core"},
{"wh_dlc08_nor_inf_marauder_hunters_1", "nor_core"},
{"wh_dlc08_nor_cav_marauder_horsemasters_0", "nor_core"},
{"wh_main_nor_cav_marauder_horsemen_1", "nor_core"},
{"wh_dlc08_nor_inf_marauder_berserkers_0", "nor_special", 1},
{"wh_dlc08_nor_inf_marauder_champions_0", "nor_special", 1},
{"wh_dlc08_nor_inf_marauder_champions_1", "nor_special", 1},
{"wh_dlc08_nor_inf_marauder_spearman_0", "nor_core"},
{"wh_dlc08_nor_mon_skinwolves_0", "nor_special", 2},
{"wh_dlc08_nor_mon_skinwolves_1", "nor_special", 2},
{"wh_main_nor_inf_chaos_marauders_0", "nor_core"},
{"wh_main_nor_inf_chaos_marauders_1", "nor_core"},
{"wh_main_nor_cav_marauder_horsemen_0", "nor_core"},
{"wh_main_nor_cav_chaos_chariot", "nor_core"},
{"wh_dlc08_nor_veh_marauder_warwolves_chariot_0", "nor_special", 1},
--lzd
{"wh2_main_lzd_mon_kroxigors", "lzd_special", 1},
{"wh2_main_lzd_mon_kroxigors_blessed", "lzd_special", 1},
{"wh2_main_lzd_cav_terradon_riders_0", "lzd_special", 1},
{"wh2_main_lzd_cav_terradon_riders_1", "lzd_special", 1},
{"wh2_main_lzd_cav_terradon_riders_blessed_1", "lzd_special", 1},
{"wh2_main_lzd_mon_ancient_stegadon", "lzd_rare", 3},
{"wh2_main_lzd_mon_bastiladon_0", "lzd_special", 1},
{"wh2_main_lzd_mon_bastiladon_1", "lzd_special", 2},
{"wh2_main_lzd_mon_bastiladon_2", "lzd_special", 2},
{"wh2_main_lzd_mon_bastiladon_blessed_2", "lzd_special", 2},
{"wh2_main_lzd_mon_carnosaur_0", "lzd_rare", 2},
{"wh2_main_lzd_mon_carnosaur_blessed_0", "lzd_rare", 2},
{"wh2_main_lzd_mon_stegadon_0", "lzd_special", 2},
{"wh2_main_lzd_mon_stegadon_1", "lzd_special", 2},
{"wh2_main_lzd_mon_stegadon_blessed_1", "lzd_special", 2},
{"wh2_main_lzd_inf_chameleon_skinks_0", "lzd_special", 1},
{"wh2_main_lzd_inf_chameleon_skinks_blessed_0", "lzd_special", 1},
{"wh2_main_lzd_inf_skink_cohort_1", "lzd_core"},
{"wh2_main_lzd_inf_skink_skirmishers_0", "lzd_core"},
{"wh2_main_lzd_inf_skink_skirmishers_blessed_0", "lzd_core"},
{"wh2_main_lzd_inf_saurus_spearmen_0", "lzd_core"},
{"wh2_main_lzd_inf_saurus_spearmen_1", "lzd_core"},
{"wh2_main_lzd_inf_saurus_spearmen_blessed_1", "lzd_core"},
{"wh2_main_lzd_inf_saurus_warriors_0", "lzd_core"},
{"wh2_main_lzd_inf_saurus_warriors_1", "lzd_core"},
{"wh2_main_lzd_inf_saurus_warriors_blessed_1", "lzd_core"},
{"wh2_main_lzd_inf_skink_cohort_0", "lzd_core"},
{"wh2_main_lzd_inf_temple_guards", "lzd_special", 2},
{"wh2_main_lzd_inf_temple_guards_blessed", "lzd_special", 2},
{"wh2_main_lzd_cav_cold_one_spearmen_1", "lzd_special", 1},
{"wh2_main_lzd_cav_cold_one_spearriders_blessed_0", "lzd_special", 1},
{"wh2_main_lzd_cav_cold_ones_1", "lzd_special", 1},
{"wh2_main_lzd_cav_cold_ones_feral_0", "lzd_core"},
{"wh2_main_lzd_cav_horned_ones_0", "lzd_special", 2},
{"wh2_main_lzd_cav_horned_ones_blessed_0", "lzd_special", 2},
--skv
{"wh2_main_skv_art_plagueclaw_catapult", "skv_rare", 1},
{"wh2_main_skv_art_warp_lightning_cannon", "skv_rare", 2},
{"wh2_main_skv_veh_doomwheel", "skv_rare", 2},
{"wh2_main_skv_mon_rat_ogres", "skv_special", 2},
{"wh2_main_skv_mon_hell_pit_abomination", "skv_rare", 3},
{"wh2_main_skv_inf_death_globe_bombardiers", "skv_rare", 1},
{"wh2_main_skv_inf_death_runners_0", "skv_rare", 1},
{"wh2_main_skv_inf_gutter_runner_slingers_0", "skv_special", 1},
{"wh2_main_skv_inf_gutter_runner_slingers_1", "skv_special", 1},
{"wh2_main_skv_inf_gutter_runners_0", "skv_special", 1},
{"wh2_main_skv_inf_gutter_runners_1", "skv_special", 1},
{"wh2_main_skv_inf_night_runners_0", "skv_core"},
{"wh2_main_skv_inf_night_runners_1", "skv_core"},
{"wh2_main_skv_inf_poison_wind_globadiers", "skv_special", 2},
{"wh2_main_skv_inf_skavenslave_slingers_0", "skv_core"},
{"wh2_main_skv_inf_warpfire_thrower", "skv_core"},
{"wh2_main_skv_inf_clanrat_spearmen_0", "skv_core"},
{"wh2_main_skv_inf_clanrat_spearmen_1", "skv_core"},
{"wh2_main_skv_inf_clanrats_0", "skv_core"},
{"wh2_main_skv_inf_clanrats_1", "skv_core"},
{"wh2_main_skv_inf_plague_monk_censer_bearer", "skv_special", 2},
{"wh2_main_skv_inf_plague_monks", "skv_special", 1},
{"wh2_main_skv_inf_skavenslave_spearmen_0", "skv_core"},
{"wh2_main_skv_inf_skavenslaves_0", "skv_core"},
{"wh2_main_skv_inf_stormvermin_0", "skv_core"},
{"wh2_main_skv_inf_stormvermin_1", "skv_core"},
--hef
{"wh2_main_hef_art_eagle_claw_bolt_thrower", "hef_rare", 1},
{"wh2_dlc10_hef_mon_treekin_0", "hef_rare", 1},
{"wh2_dlc10_hef_mon_treeman_0", "hef_rare", 3},
{"wh2_main_hef_mon_great_eagle", "hef_rare", 1},
{"wh2_main_hef_mon_moon_dragon", "hef_rare", 2},
{"wh2_main_hef_mon_phoenix_flamespyre", "hef_rare", 1},
{"wh2_main_hef_mon_phoenix_frostheart", "hef_rare", 1},
{"wh2_main_hef_mon_star_dragon", "hef_rare", 3},
{"wh2_main_hef_mon_sun_dragon", "hef_rare", 2},
{"wh2_dlc10_hef_inf_shadow_walkers_0", "hef_rare", 1},
{"wh2_dlc10_hef_inf_shadow_warriors_0", "hef_special", 1},
{"wh2_dlc10_hef_inf_sisters_of_avelorn_0", "hef_rare", 1},
{"wh2_main_hef_inf_archers_0", "hef_core"},
{"wh2_main_hef_inf_archers_1", "hef_core"},
{"wh2_main_hef_inf_lothern_sea_guard_0", "hef_core"},
{"wh2_main_hef_inf_lothern_sea_guard_1", "hef_core"},
{"wh2_main_hef_cav_ellyrian_reavers_1", "hef_core"},
{"wh2_dlc10_hef_inf_dryads_0", "hef_core"},
{"wh2_main_hef_inf_phoenix_guard", "hef_special", 2},
{"wh2_main_hef_inf_spearmen_0", "hef_core"},
{"wh2_main_hef_inf_swordmasters_of_hoeth_0", "hef_special", 2},
{"wh2_main_hef_inf_white_lions_of_chrace_0", "hef_special", 1},
{"wh2_main_hef_cav_dragon_princes", "hef_special", 2},
{"wh2_main_hef_cav_ellyrian_reavers_0", "hef_core"},
{"wh2_main_hef_cav_silver_helms_0", "hef_core"},
{"wh2_main_hef_cav_silver_helms_1", "hef_core"},
{"wh2_main_hef_cav_ithilmar_chariot", "hef_special", 1},
{"wh2_main_hef_cav_tiranoc_chariot", "hef_special", 1},
--def
{"wh2_main_def_art_reaper_bolt_thrower", "def_special", 1},
{"wh2_main_def_inf_harpies", "def_special", 1},
{"wh2_dlc10_def_mon_feral_manticore_0", "def_special", 2},
{"wh2_dlc10_def_mon_kharibdyss_0", "def_rare", 2},
{"wh2_main_def_mon_black_dragon", "def_rare", 3},
{"wh2_main_def_mon_war_hydra", "def_special", 3},
{"wh2_main_def_inf_black_ark_corsairs_1", "def_core"},
{"wh2_main_def_inf_darkshards_0", "def_core"},
{"wh2_main_def_inf_darkshards_1", "def_core"},
{"wh2_main_def_inf_shades_0", "def_special", 1},
{"wh2_main_def_inf_shades_1", "def_special", 1},
{"wh2_main_def_inf_shades_2", "def_special", 1},
{"wh2_main_def_cav_dark_riders_2", "def_core"},
{"wh2_dlc10_def_inf_sisters_of_slaughter", "def_rare", 1},
{"wh2_main_def_inf_black_ark_corsairs_0", "def_core"},
{"wh2_main_def_inf_black_guard_0", "def_special", 2},
{"wh2_main_def_inf_bleakswords_0", "def_core"},
{"wh2_main_def_inf_dreadspears_0", "def_core"},
{"wh2_main_def_inf_har_ganeth_executioners_0", "def_special", 2},
{"wh2_main_def_inf_witch_elves_0", "def_core"},
{"wh2_dlc10_def_cav_doomfire_warlocks_0", "def_rare", 2},
{"wh2_main_def_cav_cold_one_knights_0", "def_special", 2},
{"wh2_main_def_cav_cold_one_knights_1", "def_special", 2},
{"wh2_main_def_cav_dark_riders_0", "def_core"},
{"wh2_main_def_cav_dark_riders_1", "def_core"},
{"wh2_main_def_cav_cold_one_chariot", "def_special", 2},
--tmb
{"wh2_dlc09_tmb_inf_nehekhara_warriors_0", "tmb_core"},
{"wh2_dlc09_tmb_inf_skeleton_archers_0", "tmb_core"},
{"wh2_dlc09_tmb_inf_skeleton_spearmen_0", "tmb_core"},
{"wh2_dlc09_tmb_inf_skeleton_warriors_0", "tmb_core"},
{"wh2_dlc09_tmb_inf_tomb_guard_0", "tmb_special", 2},
{"wh2_dlc09_tmb_inf_tomb_guard_1", "tmb_special", 2},
{"wh2_dlc09_tmb_mon_carrion_0", "tmb_special", 1},
{"wh2_dlc09_tmb_mon_dire_wolves", "tmb_core"},
{"wh2_dlc09_tmb_mon_fell_bats", "tmb_special", 1},
{"wh2_dlc09_tmb_mon_heirotitan_0", "tmb_rare", 3},
{"wh2_dlc09_tmb_mon_necrosphinx_0", "tmb_rare", 3},
{"wh2_dlc09_tmb_mon_sepulchral_stalkers_0", "tmb_special", 2},
{"wh2_dlc09_tmb_mon_tomb_scorpion_0", "tmb_special", 2},
{"wh2_dlc09_tmb_mon_ushabti_0", "tmb_special", 2},
{"wh2_dlc09_tmb_mon_ushabti_1", "tmb_special", 2},
{"wh2_dlc09_tmb_veh_khemrian_warsphinx_0", "tmb_special", 3},
{"wh2_dlc09_tmb_veh_skeleton_archer_chariot_0", "tmb_core"},
{"wh2_dlc09_tmb_veh_skeleton_chariot_0", "tmb_core"},
{"wh2_dlc09_tmb_art_casket_of_souls_0", "tmb_rare", 1},
{"wh2_dlc09_tmb_art_screaming_skull_catapult_0", "tmb_rare", 1},
{"wh2_dlc09_tmb_cav_hexwraiths", "tmb_special", 2},
{"wh2_dlc09_tmb_cav_necropolis_knights_0", "tmb_special", 2},
{"wh2_dlc09_tmb_cav_necropolis_knights_1", "tmb_special", 2},
{"wh2_dlc09_tmb_cav_nehekhara_horsemen_0", "tmb_core"},
{"wh2_dlc09_tmb_cav_skeleton_horsemen_0", "tmb_core"},
{"wh2_dlc09_tmb_cav_skeleton_horsemen_archers_0", "tmb_core"},
{"wh2_dlc09_tmb_inf_crypt_ghouls", "tmb_core"},
{"wh2_pro06_tmb_mon_bone_giant_0", "tmb_rare", 2},
--the vampire coast pirates
{"wh2_dlc11_cst_art_carronade", "cst_special", 1},
{"wh2_dlc11_cst_art_mortar", "cst_special", 2},
{"wh2_dlc11_cst_cav_deck_droppers_0", "cst_special", 1},
{"wh2_dlc11_cst_cav_deck_droppers_1", "cst_special", 1},
{"wh2_dlc11_cst_cav_deck_droppers_2", "cst_special", 1},
{"wh2_dlc11_cst_inf_deck_gunners_0", "cst_special", 1},
{"wh2_dlc11_cst_inf_depth_guard_0", "cst_special", 2},
{"wh2_dlc11_cst_inf_depth_guard_1", "cst_special", 2},
{"wh2_dlc11_cst_inf_sartosa_free_company_0", "cst_core"},
{"wh2_dlc11_cst_inf_sartosa_militia_0", "cst_core"},
{"wh2_dlc11_cst_inf_syreens", "cst_rare", 2},
{"wh2_dlc11_cst_inf_zombie_deckhands_mob_0", "cst_core"},
{"wh2_dlc11_cst_inf_zombie_deckhands_mob_1", "cst_core"},
{"wh2_dlc11_cst_inf_zombie_gunnery_mob_0", "cst_core"},
{"wh2_dlc11_cst_inf_zombie_gunnery_mob_1", "cst_core"},
{"wh2_dlc11_cst_inf_zombie_gunnery_mob_2", "cst_core"},
{"wh2_dlc11_cst_inf_zombie_gunnery_mob_3", "cst_core"},
{"wh2_dlc11_cst_mon_animated_hulks_0", "cst_special", 1},
{"wh2_dlc11_cst_mon_bloated_corpse_0", "cst_core"},
{"wh2_dlc11_cst_mon_fell_bats", "cst_special", 1},
{"wh2_dlc11_cst_mon_mournguls_0", "cst_rare", 2},
{"wh2_dlc11_cst_mon_necrofex_colossus_0", "cst_rare", 3},
{"wh2_dlc11_cst_mon_rotting_leviathan_0", "cst_rare", 2},
{"wh2_dlc11_cst_mon_rotting_prometheans_0", "cst_special", 2},
{"wh2_dlc11_cst_mon_rotting_prometheans_gunnery_mob_0", "cst_special", 2},
{"wh2_dlc11_cst_mon_scurvy_dogs", "cst_core"},
{"wh2_dlc11_cst_mon_terrorgheist", "cst_rare", 2},
{"wh2_dlc11_vmp_inf_crossbowmen", "vmp_core"},
{"wh2_dlc11_vmp_inf_handgunners", "vmp_rare", 1}
} --:vector<{string, string, number?}>

local groups = {} --:map<string, boolean>
local pools = {} --:map<string, vector<string>>

local prefix_to_subculture = {
    bst = "wh_dlc03_sc_bst_beastmen",
    wef = "wh_dlc05_sc_wef_wood_elves",
    brt = "wh_main_sc_brt_bretonnia",
    chs = "wh_main_sc_chs_chaos",
    dwf = "wh_main_sc_dwf_dwarfs",
    emp = "wh_main_sc_emp_empire",
    grn = "wh_main_sc_grn_greenskins",
    ksl = "wh_main_sc_ksl_kislev",
    nor = "wh_main_sc_nor_norsca",
    teb = "wh_main_sc_teb_teb",
    vmp = "wh_main_sc_vmp_vampire_counts",
    tmb = "wh2_dlc09_sc_tmb_tomb_kings",
    def = "wh2_main_sc_def_dark_elves",
    hef = "wh2_main_sc_hef_high_elves",
    lzd = "wh2_main_sc_lzd_lizardmen",
    skv = "wh2_main_sc_skv_skaven",
    cst = "wh2_dlc11_sc_cst_vampire_coast"
}--:map<string, string>



for i = 1, #units do
    if units[i][3] then
        rm:set_weight_for_unit(units[i][1], units[i][3])
    end
    groups[units[i][2]] = true;
    rm:add_unit_to_group(units[i][1], units[i][2])
    
    if string.find(units[i][2], "_core") then
        local prefix = string.gsub(units[i][2], "_core", "")
        rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
        rm:set_ui_profile_for_unit(units[i][1], {
            _text = "This unit is a Core Unit. \n Armies may have an unlimited number of Core Units.",
            _image = "ui/custom/recruitment_controls/common_units.png"
        })
    end
    if string.find(units[i][2], "_special") then
        local prefix = string.gsub(units[i][2], "_special", "")
        rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
        local weight = units[i][3] --# assume weight: number
        rm:set_ui_profile_for_unit(units[i][1], {
            _text = "This unit is a Special Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 10 Points worth of Special Units. ",
            _image = "ui/custom/recruitment_controls/special_units_"..weight..".png"
        })
    end
    if string.find(units[i][2], "_rare") then
        local prefix = string.gsub(units[i][2], "_rare", "")
        rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
        local weight = units[i][3] --# assume weight: number
        rm:set_ui_profile_for_unit(units[i][1], {
            _text = "This unit is a Rare Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 5 Points worth of Rare Units. ",
            _image = "ui/custom/recruitment_controls/rare_units_"..weight..".png"
        })
    end

end

if not mcm or (not mcm:started_with_mod("tabletop_caps")) then

cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function() 
    rm:add_subtype_group_override("wh2_main_skv_lord_skrolk", "wh2_main_skv_inf_plague_monks", "skv_core", {
        _image = "ui/custom/recruitment_controls/common_units.png",
        _text = "[[col:yellow]]Special Rule: [[/col]] Lord Skrolk can bring Plague Monks as Core choices in his armies. \n Armies may have an unlimited number of Core Units." 
    })
    for name, _ in pairs(groups) do
        if string.find(name, "core") then
            rm:set_ui_name_for_group(name, "Core Units")
            rm:add_character_quantity_limit_for_group(name, 21)
        end
        if string.find(name, "special") then
            rm:set_ui_name_for_group(name, "Special Units")
            rm:add_character_quantity_limit_for_group(name, 10)
        end
        if string.find(name, "rare") then
            rm:set_ui_name_for_group(name, "Rare Units")
            rm:add_character_quantity_limit_for_group(name, 5)
        end
    end
end;

end

if not not mcm then
    local ttc = mcm:register_mod("tabletop_caps", "Tabletop Caps", "Tabletop inspired point limits on an army basis")
    local enforce = ttc:add_tweaker("enforce", "Enable Mod", "Turn the mod on or off")
    enforce:add_option("enable","On", "Enable the tabletop caps mod")
    enforce:add_option("disable", "Off", "Disable the tabletop caps mod"):add_callback(function(context)
        rm:enforce_restrictions(false)
    end)
    local ai_enforce = ttc:add_tweaker("AI", "Enforce for AI", "Enforce the same limits on the AI as the player")
    ai_enforce:add_option("enable", "On", "The AI has its unit recruitment limited")
    ai_enforce:add_option("disable", "Off", "The AI can freely recruit. Beware of Cheese!"):add_callback(function(context)
        rm:enforce_ai_restrictions(false)
    end)
    ttc:add_variable("special_limit", 1, 20, 10, 1, "Special Unit Limit", "How many points worth of special units are allowed?")
    ttc:add_variable("rare_limit", 1, 20, 5, 1, "Rare Unit Limit", "How many points worth of rare units are allowed?")
    rm:add_subtype_group_override("wh2_main_skv_lord_skrolk", "wh2_main_skv_inf_plague_monks", "skv_core", {
        _image = "ui/custom/recruitment_controls/common_units.png",
        _text = "[[col:yellow]]Special Rule: [[/col]] Lord Skrolk can bring Plague Monks as Core choices in his armies. \n Armies may have an unlimited number of Core Units." 
    })
    local weights = ttc:add_tweaker("weight", "Unit Point Cost", "Optionally treat all units as being worth one point; rather than scaling them for cost!")
    weights:add_option("default", "Use Unit Point Costs", "Use Tabletop Caps as normal")
    weights:add_option("disabled", "All units cost 1", "Use tabletop caps with all units being worth the same number of points"):add_callback(function(context)
        rm:disable_weights(true)
    end)

    mcm:add_post_process_callback(function()
        --mcm_variable_<mod_key>_<variable_key>_value
        local rare_limit = cm:get_saved_value("mcm_variable_tabletop_caps_rare_limit_value")
        local special_limit = cm:get_saved_value("mcm_variable_tabletop_caps_special_limit_value")
        for name, _ in pairs(groups) do
            if string.find(name, "core") then
                rm:set_ui_name_for_group(name, "Core Units")
                rm:add_character_quantity_limit_for_group(name, 21)
            end
            if string.find(name, "special") then
                rm:set_ui_name_for_group(name, "Special Units")
                rm:add_character_quantity_limit_for_group(name, tonumber(special_limit))
            end
            if string.find(name, "rare") then
                rm:set_ui_name_for_group(name, "Rare Units")
                rm:add_character_quantity_limit_for_group(name, tonumber(rare_limit))
            end
        end
    end)
end

local ship_subtypes = {
    "wh2_dlc11_cst_noctilus",
    "wh2_dlc11_cst_aranessa",
    "wh2_dlc11_cst_harkon",
    "wh2_dlc11_cst_cylostra",
    "wh2_dlc11_cst_admiral_tech_01",
    "wh2_dlc11_cst_admiral_tech_02",
    "wh2_dlc11_cst_admiral_tech_03",
    "wh2_dlc11_cst_admiral_tech_04"
}--:vector<string>

for i = 1, #ship_subtypes do
    rm:register_subtype_as_char_bound_horde(ship_subtypes[i])
end

