--adds new units to Drunk Flamingo's TT-based unit caps script
rm = _G.rm; cm = get_cm();
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
    skv = "wh2_main_sc_skv_skaven"
}--:map<string, string>
  

function jmw_koe_caps_sfo() 
    local jmw_koe_units = {
        --Reiksguard
        {"wh_main_emp_cav_reiksguard_sword", "emp_special", 1},
        {"wh_main_emp_cav_reiksguard_great", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard_great", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard_halberdiers", "emp_special", 1},
        --Blazing Sun
        {"wh_jmw_emp_cav_knights_blazing_sun_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knights_blazing_sun_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun_halberdiers", "emp_special", 1},
        --Feary Heart
        {"wh_jmw_emp_cav_fheart", "emp_special", 1},
        {"wh_jmw_emp_cav_fheart_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_fheart_great", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart_great", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart_halberdiers", "emp_special", 1},
        --Morr
        {"wh_jmw_emp_cav_kmorr", "emp_special", 1},
        {"wh_jmw_emp_cav_kmorr_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kmorr_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr_halberdiers", "emp_elite", 1},
        --Raven
        {"wh_jmw_emp_cav_krav", "emp_special", 1},
        {"wh_jmw_emp_inf_krav", "emp_special", 1},
        {"wh_jmw_emp_inf_krav_cross", "emp_special", 1},
        --Griffon
        {"wh_jmw_emp_cav_kgriff", "emp_special", 1},
        {"wh_jmw_emp_cav_kgriff_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kgriff_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff_halberdiers", "emp_special", 1},
        {"wh_jmw_emp_cav_demigryph_kgriff", "emp_elite", 1},
        {"wh_jmw_emp_cav_demigryph_kgriff_hell", "emp_elite", 1},
        --Hunters of Sigmar
        {"wh_jmw_emp_cav_hunt", "emp_special", 1},
        {"wh_jmw_emp_cav_hunt_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_hunt_great", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt_great", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt_halberdiers", "emp_special", 1},
        --Encarmine
        {"wh_jmw_emp_cav_encarmine", "emp_special", 1},
        {"wh_jmw_emp_inf_encarmine", "emp_special", 1},
        --Golden Lion
        {"wh_jmw_emp_cav_glion", "emp_special", 1},
        {"wh_jmw_emp_cav_glion_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_glion_great", "emp_special", 1},
        {"wh_jmw_emp_inf_glion", "emp_special", 1},
        {"wh_jmw_emp_inf_glion_great", "emp_special", 1},
        {"wh_jmw_emp_inf_glion_halberdiers", "emp_special", 1},
        --Sigmar Blood
        {"wh_jmw_emp_cav_knightsig", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsig_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsig_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig_halberdiers", "emp_special", 1},
        --Panther
        {"wh_jmw_emp_cav_knightpan_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightpan_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan_halberdiers", "emp_special", 1},
        --Black Rose
        {"wh_jmw_emp_cav_brose", "emp_special", 1},
        {"wh_jmw_emp_cav_brose_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_brose_great", "emp_special", 1},
        {"wh_jmw_emp_inf_brose", "emp_special", 1},
        {"wh_jmw_emp_inf_brose_great", "emp_special", 1},
        {"wh_jmw_emp_inf_brose_halberdiers", "emp_special", 1},
        --White Wolves
        {"wh_jmw_emp_inf_baxe", "emp_elite", 1},
        --Sons of Manann
        {"wh_jmw_emp_cav_sonsm", "emp_special", 1},
        {"wh_jmw_emp_cav_sonsm_sword", "emp_special", 1},
        {"wh_jmw_emp_inf_sonsm", "emp_special", 1},
        {"wh_jmw_emp_inf_sonsm_tri", "emp_special", 1},
        --Black Bear
        {"wh_jmw_emp_cav_bbear", "emp_special", 1},
        {"wh_jmw_emp_cav_bbear_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_bbear_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear_halberdiers", "emp_special", 1},
        --Everlasting Light
        {"wh_jmw_emp_cav_elight", "emp_special", 1},
        {"wh_jmw_emp_cav_elight_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_elight_great", "emp_special", 1},
        {"wh_jmw_emp_inf_elight", "emp_special", 1},
        {"wh_jmw_emp_inf_elight_great", "emp_special", 1},
        {"wh_jmw_emp_inf_elight_halberdiers", "emp_special", 1},
        --Sacred Scyte
        {"wh_jmw_emp_cav_sacreds", "emp_special", 1},
        {"wh_jmw_emp_cav_sacreds_great", "emp_special", 1},
        {"wh_jmw_emp_inf_sacreds", "emp_special", 1},
        {"wh_jmw_emp_inf_sacreds_great", "emp_special", 1},
        --Taals Fury
        {"wh_jmw_emp_cav_demigryph_taalsf", "emp_special", 1},
        {"wh_jmw_emp_cav_demigryph_taalsf_hell", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf_great", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf_halberdiers", "emp_special", 1},
        --Sigmar Fists
        {"wh_jmw_emp_cav_fist", "emp_special", 1},
        {"wh_jmw_emp_inf_fist", "emp_special", 1},
        {"wh_jmw_emp_inf_fist_cross", "emp_special", 1},
        --Mariner
        {"wh_jmw_emp_cav_mariner", "emp_special", 1},
        {"wh_jmw_emp_cav_mariner_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_mariner_great", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner_great", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner_halberdiers", "emp_special", 1},
        --Bull
        {"wh_jmw_emp_cav_bull", "emp_special", 1},
        {"wh_jmw_emp_cav_bull_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_bull_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bull", "emp_special", 1},
        {"wh_jmw_emp_inf_bull_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bull_halberdiers", "emp_special", 1},
        --Twin Tails Orb
        {"wh_jmw_emp_cav_ttorb", "emp_rare", 1},
        {"wh_jmw_emp_inf_ttorb", "emp_rare", 1},
        --Hammers of Sigmar
        {"wh_jmw_emp_cav_hammers", "emp_rare", 1},
        {"wh_jmw_emp_inf_hammers", "emp_rare", 1},
        --Frozen Throne
        {"wh_jmw_emp_cav_frozent", "emp_special", 1},
        {"wh_jmw_emp_cav_frozent_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_frozent_great", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent_great", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent_halberdiers", "emp_special", 1},
        --Stag
        {"wh_jmw_emp_cav_kstag", "emp_special", 1},
        {"wh_jmw_emp_cav_kstag_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kstag_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag_halberdiers", "emp_special", 1},
        --Sword and Scale
        {"wh_jmw_emp_cav_knightsas_sword_daul", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsas_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsas_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas_sword_daul", "emp_special", 1},
        --Winged Lancers
        {"wh_jmw_klv_cav_winged_lancers", "emp_rare", 1},
        --RoR
        {"wh_jmw_emp_cav_brotherhood_steel", "emp_elite", 1},
        {"wh_jmw_emp_cav_fellwolf_brotherhood", "emp_elite", 1},
        {"wh_jmw_emp_cav_reiksguard_inner_circle", "emp_elite", 1},
         {"wh_jmw_emp_cav_kgriff_red", "emp_elite", 1},
        --Myrmidia orders
        {"wh_jmw_brt_cav_righteous_spear", "emp_rare", 1},
        {"wh_jmw_brt_cav_knights_magritta", "emp_rare", 1}
    }--:vector<{string, string, number?}>

    local groups = {} --:map<string, boolean>
    for i = 1, #jmw_koe_units do
        local units = jmw_koe_units
        groups[units[i][2]] = true;
        rm:add_unit_to_group(units[i][1], units[i][2])

        if string.find(units[i][2], "_special") then
            local prefix = string.gsub(units[i][2], "_special", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is a Special Unit. \n Armies may have up to 6 Special Units.",
                _image = "ui/custom/recruitment_controls/special.png"
            })
        end
        if string.find(units[i][2], "_elite") then
            local prefix = string.gsub(units[i][2], "_elite", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is an Elite Unit. \n Armies may have up to 4 Elite Units",
                _image = "ui/custom/recruitment_controls/elite.png"
            })
        end
        if string.find(units[i][2], "_rare") then
            local prefix = string.gsub(units[i][2], "_rare", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is a Rare Unit. \n Armies may have up to 2 Rare Units.",
                _image = "ui/custom/recruitment_controls/rare.png"
            })
        end
    end
end


core:add_listener(
    "SFOcapsDilemmaKOE",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == "cap_army_choice"
    end,
    function(context)
        if context:choice() == 1 or context:choice() == 2 then
            jmw_koe_caps_sfo()
        end
    end,
    false)

if cm:get_saved_value("SFO_APPLY_CAPS") then
    jmw_koe_caps_sfo()
end
    
    



--NON SFO VERSION-----
----------------------

if not _G.sfo then
    local jmw_koe_units = {
        --Reiksguard
        {"wh_main_emp_cav_reiksguard_sword", "emp_special", 1},
        {"wh_main_emp_cav_reiksguard_great", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard_great", "emp_special", 1},
        {"wh_main_emp_inf_reiksguard_halberdiers", "emp_special", 1},
        --Blazing Sun
        {"wh_jmw_emp_cav_knights_blazing_sun_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knights_blazing_sun_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knights_blazing_sun_halberdiers", "emp_special", 1},
        --Feary Heart
        {"wh_jmw_emp_cav_fheart", "emp_special", 1},
        {"wh_jmw_emp_cav_fheart_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_fheart_great", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart_great", "emp_special", 1},
        {"wh_jmw_emp_inf_fheart_halberdiers", "emp_special", 1},
        --Morr
        {"wh_jmw_emp_cav_kmorr", "emp_special", 1},
        {"wh_jmw_emp_cav_kmorr_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kmorr_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kmorr_halberdiers", "emp_special", 1},
        --Raven
        {"wh_jmw_emp_cav_krav", "emp_special", 1},
        {"wh_jmw_emp_inf_krav", "emp_special", 1},
        {"wh_jmw_emp_inf_krav_cross", "emp_special", 1},
        --Griffon
        {"wh_jmw_emp_cav_kgriff", "emp_special", 1},
        {"wh_jmw_emp_cav_kgriff_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kgriff_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kgriff_halberdiers", "emp_special", 1},
        {"wh_jmw_emp_cav_demigryph_kgriff", "emp_elite", 1},
        {"wh_jmw_emp_cav_demigryph_kgriff_hell", "emp_elite", 1},
        --Hunters of Sigmar
        {"wh_jmw_emp_cav_hunt", "emp_special", 1},
        {"wh_jmw_emp_cav_hunt_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_hunt_great", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt_great", "emp_special", 1},
        {"wh_jmw_emp_inf_hunt_halberdiers", "emp_special", 1},
        --Encarmine
        {"wh_jmw_emp_cav_encarmine", "emp_special", 1},
        {"wh_jmw_emp_inf_encarmine", "emp_special", 1},
        --Golden Lion
        {"wh_jmw_emp_cav_glion", "emp_special", 1},
        {"wh_jmw_emp_cav_glion_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_glion_great", "emp_special", 1},
        {"wh_jmw_emp_inf_glion", "emp_special", 1},
        {"wh_jmw_emp_inf_glion_great", "emp_special", 1},
        {"wh_jmw_emp_inf_glion_halberdiers", "emp_special", 1},
        --Longshanks
        {"wh_jmw_emp_inf_longshanks", "emp_special", 1},
        {"wh_jmw_emp_inf_longshanks_bow", "emp_special", 1},
        --Verdant Field
        {"wh_jmw_emp_cav_vfield", "emp_special", 1},
        {"wh_jmw_emp_inf_vfield", "emp_special", 1},
        --Sigmar Blood
        {"wh_jmw_emp_cav_knightsig", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsig_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsig_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsig_halberdiers", "emp_special", 1},
        --Panther
        {"wh_jmw_emp_cav_knightpan_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightpan_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightpan_halberdiers", "emp_special", 1},
        --Black Rose
        {"wh_jmw_emp_cav_brose", "emp_special", 1},
        {"wh_jmw_emp_cav_brose_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_brose_great", "emp_special", 1},
        {"wh_jmw_emp_inf_brose", "emp_special", 1},
        {"wh_jmw_emp_inf_brose_great", "emp_special", 1},
        {"wh_jmw_emp_inf_brose_halberdiers", "emp_special", 1},
        --White Wolves
        {"wh_jmw_emp_inf_baxe", "emp_elite", 1},
        --Sons of Manann
        {"wh_jmw_emp_cav_sonsm", "emp_special", 1},
        {"wh_jmw_emp_cav_sonsm_sword", "emp_special", 1},
        {"wh_jmw_emp_inf_sonsm", "emp_special", 1},
        {"wh_jmw_emp_inf_sonsm_tri", "emp_special", 1},
        --Black Bear
        {"wh_jmw_emp_cav_bbear", "emp_special", 1},
        {"wh_jmw_emp_cav_bbear_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_bbear_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bbear_halberdiers", "emp_special", 1},
        --Everlasting Light
        {"wh_jmw_emp_cav_elight", "emp_special", 1},
        {"wh_jmw_emp_cav_elight_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_elight_great", "emp_special", 1},
        {"wh_jmw_emp_inf_elight", "emp_special", 1},
        {"wh_jmw_emp_inf_elight_great", "emp_special", 1},
        {"wh_jmw_emp_inf_elight_halberdiers", "emp_special", 1},
        --Sacred Scyte
        {"wh_jmw_emp_cav_sacreds", "emp_special", 1},
        {"wh_jmw_emp_cav_sacreds_great", "emp_special", 1},
        {"wh_jmw_emp_inf_sacreds", "emp_special", 1},
        {"wh_jmw_emp_inf_sacreds_great", "emp_special", 1},
        --Taals Fury
        {"wh_jmw_emp_cav_demigryph_taalsf", "emp_special", 1},
        {"wh_jmw_emp_cav_demigryph_taalsf_hell", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf_great", "emp_special", 1},
        {"wh_jmw_emp_inf_taalsf_halberdiers", "emp_special", 1},
        --Sigmar Fists
        {"wh_jmw_emp_cav_fist", "emp_special", 1},
        {"wh_jmw_emp_inf_fist", "emp_special", 1},
        {"wh_jmw_emp_inf_fist_cross", "emp_special", 1},
        --Mariner
        {"wh_jmw_emp_cav_mariner", "emp_special", 1},
        {"wh_jmw_emp_cav_mariner_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_mariner_great", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner_great", "emp_special", 1},
        {"wh_jmw_emp_inf_mariner_halberdiers", "emp_special", 1},
        --Bull
        {"wh_jmw_emp_cav_bull", "emp_special", 1},
        {"wh_jmw_emp_cav_bull_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_bull_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bull", "emp_special", 1},
        {"wh_jmw_emp_inf_bull_great", "emp_special", 1},
        {"wh_jmw_emp_inf_bull_halberdiers", "emp_special", 1},
        --Twin Tails Orb
        {"wh_jmw_emp_cav_ttorb", "emp_special", 1},
        {"wh_jmw_emp_inf_ttorb", "emp_special", 1},
        --Hammers of Sigmar
        {"wh_jmw_emp_cav_hammers", "emp_special", 1},
        {"wh_jmw_emp_inf_hammers", "emp_special", 1},
        --Frozen Throne
        {"wh_jmw_emp_cav_frozent", "emp_special", 1},
        {"wh_jmw_emp_cav_frozent_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_frozent_great", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent_great", "emp_special", 1},
        {"wh_jmw_emp_inf_frozent_halberdiers", "emp_special", 1},
        --Stag
        {"wh_jmw_emp_cav_kstag", "emp_special", 1},
        {"wh_jmw_emp_cav_kstag_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_kstag_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag_great", "emp_special", 1},
        {"wh_jmw_emp_inf_kstag_halberdiers", "emp_special", 1},
        --Sword and Scale
        {"wh_jmw_emp_cav_knightsas_sword_daul", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsas_sword", "emp_special", 1},
        {"wh_jmw_emp_cav_knightsas_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas_great", "emp_special", 1},
        {"wh_jmw_emp_inf_knightsas_sword_daul", "emp_special", 1},
        --Winged Lancers
        {"wh_jmw_klv_cav_winged_lancers", "emp_rare", 1},
        --RoR
        {"wh_jmw_emp_cav_brotherhood_steel", "emp_elite", 1},
        {"wh_jmw_emp_cav_fellwolf_brotherhood", "emp_elite", 1},
        {"wh_jmw_emp_cav_reiksguard_inner_circle", "emp_elite", 1},
         {"wh_jmw_emp_cav_kgriff_red", "emp_elite", 1},
        --Myrmidia orders
        {"wh_jmw_brt_cav_righteous_spear", "emp_rare", 1},
        {"wh_jmw_brt_cav_knights_magritta", "emp_rare", 1}
    }--:vector<{string, string, number?}>
    if not not rm then
        local units = jmw_koe_units
        for i = 1, #units do
            if units[i][3] then
                rm:set_weight_for_unit(units[i][1], units[i][3])
            end
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
                    _text = "This unit is a Special Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 10 Points worth of Special Units.",
                    _image = "ui/custom/recruitment_controls/special_units_"..weight..".png"
                })
            end
            if string.find(units[i][2], "_rare") then
                local prefix = string.gsub(units[i][2], "_rare", "")
                rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
                local weight = units[i][3] --# assume weight: number
                rm:set_ui_profile_for_unit(units[i][1], {
                    _text = "This unit is a Rare Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 5 Points worth of Rare Units.",
                    _image = "ui/custom/recruitment_controls/rare_units_"..weight..".png"
                })
            end
        end
    end
end