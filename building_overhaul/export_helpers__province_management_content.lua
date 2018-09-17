pm = _G.pm

pm:add_wealth_threshold_for_subculture("wh_main_sc_emp_empire", 1, "wh2_dlc10_power_of_nature", {
    "[[col:green]] A temporary dummy [[/col]]",
    "[[col:red]] To show how this shit works [[//col]] "
})

emp_detail_3 = {
    _level = 3,
    _UIName = "[[col:yellow]]Moderate Taxes[[/col]]",
    _UIEffects = {
        "[[col:green]] +5% Unit Generation (All Units) [[/col]]",
        "[[col:green]] +5% Income (Province Wide) [[/col]]",
        "[[col:red]] -4 Public Order[[//col]]",
        "[[col:red]] -10 Wealth[[//col]]"
    },
    _bundle = "wh2_dlc10_dark_elf_fortress_gate",
    _wealthEffects = -1,
    _unitProdEffects = 1.05
}


pm:add_tax_level_for_subculture("wh_main_sc_emp_empire", 3, emp_detail_3)

