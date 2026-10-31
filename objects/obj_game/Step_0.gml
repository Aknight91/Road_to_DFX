/// @description Decisions, progression, and campaign outcomes

// --------------------------------------------------
// PART 1: PROCESS PLAYER DECISIONS
// --------------------------------------------------

if (event_active && !event_resolved)
{
    var _choice_index = -1;

    if (keyboard_check_pressed(ord("1")))
        _choice_index = 0;

    else if (keyboard_check_pressed(ord("2")))
        _choice_index = 1;

    else if (keyboard_check_pressed(ord("3")))
        _choice_index = 2;

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

            event_resolved = true;

            game_message = "Decision applied.";
            result_message = _choice.result;

            // Check for immediate project failure.
            if (engineering_hours <= 0)
            {
                campaign_failed = true;
                event_active = false;
                failure_reason =
                    "Project failed: Engineering hours exhausted.";
            }
            else if (days_remaining <= 0)
            {
                campaign_failed = true;
                event_active = false;
                failure_reason =
                    "Project failed: Schedule expired.";
            }
            else if (manufacturing_readiness <= 0)
            {
                campaign_failed = true;
                event_active = false;
                failure_reason =
                    "Project failed: Manufacturing readiness reached 0%.";
            }

            // Display failure if a limit was reached.
            if (campaign_failed)
            {
                game_message = "PROJECT FAILURE!";
                result_message = failure_reason;
            }
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

if (event_active
&& event_resolved
&& keyboard_check_pressed(vk_enter))
{
    if (current_event_index < array_length(design_events) - 1)
    {
        // Move to the next event.
        current_event_index += 1;

        event_resolved = false;

        game_message = "Choose your response below.";
        result_message = "";
    }
    else
    {
        // All events have been completed.
        event_active = false;

        if (manufacturing_readiness >= required_readiness)
        {
            campaign_complete = true;

            game_message = "MANUFACTURING RELEASE APPROVED!";

            result_message =
                "Congratulations! Your design met the "
                + "prototype manufacturing readiness requirement.";
        }
        else
        {
            campaign_failed = true;

            failure_reason =
                "Project failed: Manufacturing readiness "
                + "was below the required release threshold.";

            game_message = "PROJECT FAILURE!";
            result_message = failure_reason;
        }
    }
}