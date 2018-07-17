events = get_events(); cm = get_cm(); rm = _G.rm;

local function setup_rm_listeners()

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
                --we want to re-evaluate the units who were previously in queue, they may have changed.
                local queue_counts = rm:current_character():get_queue_counts() 
                for unitID, _ in pairs(queue_counts) do
                    --check the units again. This eventually calls a get on the queue counts, which will trigger a queue re-evaluation
                    rm:check_unit_on_character(unitID)
                    --enforce the changes.
                    rm:current_character():enforce_unit_restriction(unitID)
                end
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
end