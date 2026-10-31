/// @description Event decisions and progression

// --------------------------------------------------
// PART 1: PROCESS PLAYER DECISIONS
// --------------------------------------------------

if (event_active && !event_resolved)
{
    var _choice_index = -1;

    // Detect player selection.
    if (keyboard_check_pressed(ord("1")))
        _choice_index = 0;

    else if (keyboard_check_pressed(ord("2")))
        _choice_index = 1;

    else if (keyboard_check_pressed(ord("3")))
        _choice_index = 2;

    // Process the selected choice.
    if (_choice_index != -1)
    {
        var _event = design_events[current_event_index];
        var _choice = _event.choices[_choice_index];

        // Verify available resources.
        if (engineering_hours >= _choice.hours_cost
        && days_remaining >= _choice.days_cost)
        {
            // Apply consequences.
            engineering_hours -= _choice.hours_cost;
            days_remaining -= _choice.days_cost;

            manufacturing_readiness +=
                _choice.readiness_change;

            manufacturing_readiness =
                clamp(manufacturing_readiness, 0, 100);

            // Lock the event after successful selection.
            event_resolved = true;

            game_message = "Decision applied.";
            result_message = _choice.result;
        }
        else
        {
            game_message =
                "Insufficient resources for this decision.";
        }
    }
}


// --------------------------------------------------
// PART 2: ADVANCE TO THE NEXT EVENT
// --------------------------------------------------

if (event_resolved && keyboard_check_pressed(vk_enter))
{
    // Are there more events remaining?
    if (current_event_index < array_length(design_events) - 1)
    {
        // Move to the next event.
        current_event_index += 1;

        // Reset the event state.
        event_resolved = false;

        game_message = "Choose your response below.";
        result_message = "";
    }
    else
    {
        // No more events. Campaign is complete.
        event_active = false;
        campaign_complete = true;

        game_message = "CAMPAIGN COMPLETE!";
        result_message =
            "You have reached the end of this prototype scenario.";
    }
}