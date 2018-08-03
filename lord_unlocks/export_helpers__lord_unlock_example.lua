




function setup_grandmaster_unlocks()


--define list of unlock conditions.
local grandmasters = {
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = false,
        ["subtype"] = "jmw_emp_kurt_helborg",
        ["forename"] = "names_name_2147343972",
        ["surname"] = "names_name_2147343980",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh2_main_special_altdorf_castle_reikguard"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = false,
        ["subtype"] = "jmw_emp_kurt_helborg",
        ["forename"] = "names_name_2147343972",
        ["surname"] = "names_name_2147343980",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh2_main_special_altdorf_castle_reikguard");
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_middenland",
        ["subtype"] = "jmw_emp_rein_volkhard",
        ["forename"] = "names_name_2296086002",
        ["surname"] = "names_name_2296086012",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh_main_special_great_temple_of_ulric"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_middenland",
        ["subtype"] = "jmw_emp_rein_volkhard",
        ["forename"] = "names_name_2296086002",
        ["surname"] = "names_name_2296086012",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh_main_special_great_temple_of_ulric");
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_averland",
        ["subtype"] = "jmw_emp_hans_leitdorf",
        ["forename"] = "names_name_2296086003",
        ["surname"] = "names_name_2296086013",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh_main_special_jmw_sblood_chapterhouse"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_averland",
        ["subtype"] = "jmw_emp_hans_leitdorf",
        ["forename"] = "names_name_2296086003",
        ["surname"] = "names_name_2296086013",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh_main_special_jmw_sblood_chapterhouse");
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_ostland",
        ["subtype"] = "jmw_emp_leopold_raukov",
        ["forename"] = "names_name_2296086004",
        ["surname"] = "names_name_2296086014",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh_main_special_jmw_bull_chapterhouse"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_ostland",
        ["subtype"] = "jmw_emp_leopold_raukov",
        ["forename"] = "names_name_2296086004",
        ["surname"] = "names_name_2296086014",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh_main_special_jmw_bull_chapterhouse");
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_middenland",
        ["subtype"] = "jmw_emp_werner_kriegstadt",
        ["forename"] = "names_name_2296086005",
        ["surname"] = "names_name_2296086015",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh_main_special_knights_panther_chapterhouse"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_middenland",
        ["subtype"] = "jmw_emp_werner_kriegstadt",
        ["forename"] = "names_name_2296086005",
        ["surname"] = "names_name_2296086015",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh_main_special_knights_panther_chapterhouse");
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_talabecland",
        ["subtype"] = "jmw_emp_siegfried_trappenfeld",
        ["forename"] = "names_name_2296086006",
        ["surname"] = "names_name_2296086016",
        ["unlock_event"] = "BuildingCompleted",
        ["unlock_condition"] = 
            function(context, faction_name)
                local building = context:building();
                return building:faction():name() == faction_name and building:name() == "wh_main_special_blazing_sun_chapterhouse"
            end
    },
    {
        ["primary_faction"] = "wh_main_emp_empire",
        ["secondary_faction"] = "wh_main_emp_talabecland",
        ["subtype"] = "jmw_emp_siegfried_trappenfeld",
        ["forename"] = "names_name_2296086006",
        ["surname"] = "names_name_2296086016",
        ["unlock_event"] = "GarrisonOccupiedEvent",
        ["unlock_condition"] = 
            function(context, faction_name)
                local region = context:garrison_residence():region();
                return context:character():faction():name() == faction_name and region:building_exists("wh_main_special_blazing_sun_chapterhouse");
            end,
        ["message"] = {
            title = "event_feed_strings_text_title_event_unit_recruited",
            subtitle = "event_feed_strings_text_title_event_unit_recruited",
            text = "event_feed_strings_text_title_event_unit_recruited",
            image = 591
        }
    }
};


for i = 1, #grandmasters do 
    local current_lord_template = grandmasters[i];
    local lord = customized_ll_unlock:new(
        current_lord_template.forename,
        current_lord_template.surname,
        current_lord_template.subtype,
        current_lord_template.unlock_event,
        current_lord_template.unlock_condition);
    if current_lord_template.message then
        lord:add_message_event(
            current_lord_template.message.title,
            current_lord_template.message.subtitle,
            current_lord_template.message.text,
            current_lord_template.message.image
        )
    end
    if not current_lord_template.secondary_faction == false then
        if cm:get_faction(current_lord_template.primary_faction):is_human() then
            lord:start(current_lord_template.primary_faction);
        elseif cm:get_faction(current_lord_template.secondary_faction):is_human() then
            lord:start(current_lord_template.secondary_faction);
        else
            lord:start(current_lord_template.primary_faction);
        end
    else 
        lord:start(current_lord_template.primary_faction);
    end
end		



end;










customized_ll_unlock = {
cm = false,
unlock_event = "",
unlock_condition = false,
forename = "",
surname = "",
subtype = ""
};


function customized_ll_unlock:new(new_forename, new_surname, new_subtype, new_unlock_event, new_unlock_condition)
    --type checks
    if not is_string(new_forename) then
        script_error("ERROR: customized_ll_unlock:new() called but the supplied forename isn't a string!");
        return false;
    end
    if not is_string(new_surname) then
        script_error("ERROR: customized_ll_unlock:new() called but the supplied surname isn't a string!");
        return false;
    end
    if not is_string(new_subtype) then
        script_error("ERROR: customized_ll_unlock:new() called but the supplied pool_event isn't a string!");
        return false;
    end
    if not is_string(new_unlock_event) then
        script_error("ERROR: customized_ll_unlock:new() called but the supplied unlock_event isn't a string!");
        return false;
    end
    if not is_function(new_unlock_condition) then
        script_error("ERROR: customized_ll_unlock:new() called but the supplied unlock_condition is not a function!");
        return false;
    end

    out("jmw: customized_ll_unlock:new() called for subtype ["..new_subtype.."], forename ["..new_forename.."] and surname ["..new_surname.."]");

    local cm = get_cm();
    local ll = {};

    setmetatable(ll, self);
    self.__index = self;

    ll.cm = cm;
    ll.forename = new_forename;
    ll.surname = new_surname;
    ll.subtype = new_subtype;
    ll.unlock_event = new_unlock_event;
    ll.unlock_condition = new_unlock_condition;
    ll.has_message_event = false;


    return ll;
end;


function customized_ll_unlock:add_message_event(title_string, subtitle_string, text_string, image_number)
    self.has_message_event = true
    self.title_string = title_string
    self.subtitle_string = subtitle_string
    self.text_string = text_string
    self.image_number = image_number
end









function customized_ll_unlock:start(human_faction_name)
    local cm = self.cm;
    
    if cm:get_saved_value("cllu_"..self.subtype.."_"..human_faction_name.."_inpool") then
        out("legendary lord with subtype ["..self.subtype.."] for faction [" .. human_faction_name .. "] is already unlocked");
        return false;
    end

    out("adding a listener for legendary lord with subtype ["..self.subtype.."] for faction [" .. human_faction_name .. "]");
    core:add_listener(
        "cllu_"..self.subtype.."_"..human_faction_name.."_listener",
        self.unlock_event,
        function(context)
            return self.unlock_condition(context, human_faction_name);
        end,
        function()
            out("adding legendary lord with subtype ["..self.subtype.."] to the pool for faction [" .. human_faction_name .. "]");
            cm:spawn_character_to_pool(human_faction_name, self.forename, self.surname, "", "", 18, true, "general", self.subtype, true, "");
            cm:set_saved_value("cllu_"..self.subtype.."_"..human_faction_name.."_inpool", true);
            core:remove_listener("cllu_"..self.subtype.."_"..human_faction_name.."_listener");
            if self.has_message_event == true then
                cm:show_message_event(
                    human_faction_name,
                    self.title_string,
                    self.subtitle_string,
                    self.text_string,
                    true,
                    self.image_number
                    );
            end
        end,
        false);
end;



















events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() setup_grandmaster_unlocks() end;


















