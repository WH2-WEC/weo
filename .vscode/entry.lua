---[[province extensions
require("provinces/ProvinceObjects")
--]]



---[[master recruitment system
require("recruitment/RecruitmentControls")
require("recruitment/export_helpers__recruitment_controls")
require("recruitment/export_helpers__recruitment_controls_ai")
require("recruitment/export_helpers__tt_groups")
--]]



---[[region details manager
 require("province_management/ProvinceManagement")
 require("province_management/export_helpers__pm_core")
 require("province_management/export_helpers__pm_ui")
--]]



---[[geopolitical system

    require("geopolitics/geopolitics")
 --   require("geopolitics/export_helpers__geopolitical_system")
  --  require("geopolitics/export_helpers__geopolitics_data__")
  --  require("geopolitics/export_helpers__geopolitics_ui")
--]]


---[[cap tracker
require("show_me_the_caps/CapTracker")
require("show_me_the_caps/export_helpers__cap_tracking")
--]]



---[[imperium effects
  require("imperium_effects/ImperiumEffects")
  require("imperium_effects/export_helpers__imperium_effects_core")
--]]

---[[tech unlocks
  require("tech_unlocks/TechUnlocks")
--]]

require("eom_2/eom_main")