events = get_events(); cm = get_cm(); rm = _G.rm;

rm:error_checker()
rm:add_character_quantity_limit_for_unit("wh_main_emp_inf_swordsmen", 2)
core:add_listener(
    "RecruiterManagerOnRecruitOptionClicked",
    "ComponentLClickUp",
    true,
    function(context)
        --# assume context: CA_UIContext
        local unit_component_ID = tostring(UIComponent(context.component):Id())
        --is our clicked component a unit?
        if string.find(unit_component_ID, "_recruitable") and UIComponent(context.component):CurrentState() == "active" then
            --its a unit! lock it.
            UIComponent(context.component):SetInteractive(false)
            rm:log("Locking recruitment button for ["..unit_component_ID.."] temporarily");
            --reduce the string to get the name of the unit.
            local unitID = string.gsub(unit_component_ID, "_recruitable", "")
            --add the unit to queue so that our model knows it exists.
            rm:current_character():add_unit_to_queue(unitID)
            --run the checks on that character with the updated queue quantities.
            rm:check_unit_on_character(unitID)
            --now, enforce the checks on that unit again.
            rm:current_character():enforce_unit_restriction(unitID)
        end
    end,
    true);
    core:add_listener(
        "RecruiterManagerOnQueuedUnitClicked",
        "ComponentLClickUp",
        true,
        function(context)
            --# assume context: CA_UIContext
            local queue_component_ID = tostring(UIComponent(context.component):Id())
            if string.find(queue_component_ID, "QueuedLandUnit") then
                rm:log("Component Clicked was a Queued Unit!")
                --set the queue stale so that when we get it, we refresh the queue!
                rm:current_character():set_queue_stale()
                cm:callback( function() -- we callback this because if we don't do it on a small delay, it will pick up the unit we just cancelled as existing!
                    --we want to re-evaluate the units who were previously in queue, they may have changed.
                    local queue_counts = rm:current_character():get_queue_counts() 
                    for unitID, _ in pairs(queue_counts) do
                        --check the units again. This eventually calls a get on the queue counts, which will trigger a queue re-evaluation
                        rm:check_unit_on_character(unitID)
                        --enforce the changes.
                        rm:current_character():enforce_unit_restriction(unitID)
                    end
                end, 0.1)
            end
        end,
        true);
    core:add_listener(
        "RecruiterManagerPlayerCharacterMoved",
        "CharacterFinishedMoving",
        function(context)
            return context:character():faction():is_human() and rm:has_character(context:character():cqi())
        end,
        function(context)
            rm:log("Player Character moved!")
            local character = context:character()
            --# assume character: CA_CHAR
            --the character moved, so we're going to set both their army and their queue stale and force the script to re-evaluate them next time they are available.
            rm:get_character_by_cqi(character:cqi()):set_army_stale()
            rm:get_character_by_cqi(character:cqi()):set_queue_stale()
        end,
        true)
    core:add_listener(
        "RecruiterManagerPlayerFactionRecruitedUnit",
        "UnitTrained",
        function(context)
            return context:unit():faction():is_human() and rm:has_character(context:character():cqi())
        end,
        function(context)
            local unit = context:unit()
            --# assume unit: CA_UNIT
            local char_cqi = unit:force_commander():command_queue_index();
            rm:log("Player faction recruited a unit!")
            rm:get_character_by_cqi(char_cqi):set_army_stale()
            rm:get_character_by_cqi(char_cqi):set_queue_stale()
        end,
        true)

        core:add_listener(
            "RecruiterManagerOnCharacterSelected",
            "CharacterSelected",
            function(context)
            return context:character():faction():is_human() and context:character():has_military_force()
            end,
            function(context)
                rm:log("Human Character Selected by player!")
                local character = context:character()
                --# assume character: CA_CHAR
                --tell RM which character is selected. This is core to the entire system.
                rm:set_current_character(character:cqi()) 
            end,
            true)
        core:add_listener(
            "RecruiterManagerOnRecruitPanelOpened",
            "PanelOpenedCampaign",
            function(context) 
                return context.string == "units_recruitment"; 
            end,
            function(context)
                cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
                    --check every unit which has a restriction against the character's lists. This will call refresh on queue and army further upstream when necessary!
                    rm:check_all_units_on_character() 
                    --enforce restrictions for all units with an entry, this should ensure restrictions get picked up correctly.
                    rm:current_character():enforce_all_restrictions()
                end, 0.1)
            end,
            true
        )