--# assume global class EOM
--# assume global class EOM_ELECTOR
--# assume global class SIMPLE_EVENT
--# assume global class PLOT_EVENT
--# type global ELECTOR_NAME = 
--# "wh_main_emp_averland" | "wh_main_emp_hochland" | "wh_main_emp_ostermark" | "wh_main_emp_stirland" |
--# "wh_main_emp_middenland" | "wh_main_emp_nordland" | "wh_main_emp_talabecland" | "wh_main_emp_wissenland" |
--# "wh_main_emp_ostland" | "wh_main_emp_marienburg" 



local eom_model = {} --# assume eom_model: EOM

--v function() 
function eom_model.init()
    local self = {}
    setmetatable(self, {
        __index = eom_model
    }) --# assume self: EOM

    self._electors = {} --:map<string, EOM_ELECTOR>
    self._events = {} --:map<string, SIMPLE_EVENT>
    self._plot = {} --:map<string, PLOT_EVENT>

    self._allowRegularEvents = false
    self._allowPlotEvents = false
    self._emperor = "wh_main_emp_empire"

    --content
    self._electorHomeRegions = {} --:map<string, vector<string>>
    
end

--v function(self: EOM, elector: ELECTOR_NAME, regions: vector<string>)
function eom_model.set_elector_home_regions(self,elector, regions)
    self._electorHomeRegions[elector] = regions
end

--v function(self: EOM, elector: ELECTOR_NAME) --> vector<string>
function eom_model.get_elector_home_regions(self, elector)
    if self._electorHomeRegions[elector] == nil then
        return {}
    else
        return self._electorHomeRegions[elector]
    end
end


local elector = require("eom_2/eom_elector")
