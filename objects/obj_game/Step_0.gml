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

        if (engineering_hours >= _choice.hours_cost
        && days_remaining >= _choice.days_cost)
        {
            // Was the sanity crisis already active?
            var _crisis_was_active = sanity_zero_active;

            // Apply resource costs
            engineering_hours -= _choice.hours_cost;
            days_remaining -= _choice.days_cost;

            // Apply DRC and manufacturing risk changes
            drc_violations = max(0, drc_violations + _choice.drc_change);
            manufacturing_risk = max(0, manufacturing_risk + _choice.risk_change);

            // Apply DFX changes
            dfa = clamp(dfa + _choice.dfa_change, 0, 100);
            dfm = clamp(dfm + _choice.dfm_change, 0, 100);
            dft = clamp(dft + _choice.dft_change, 0, 100);

            // Apply sanity change
            sanity = clamp(sanity + _choice.sanity_change, 0, 100);

            // Recalculate manufacturing readiness
            calculate_manufacturing_readiness();

            // Start the sanity crisis
            if (sanity <= 0 && !sanity_zero_active)
            {
                sanity_zero_active = true;
                sanity_zero_turns_remaining = 3;

                // Software instability increases dramatically
                software_instability = 5;
            }
            // Count subsequent decisions during the crisis
            else if (_crisis_was_active)
            {
                sanity_zero_turns_remaining -= 1;

                if (sanity_zero_turns_remaining <= 0)
                {
                    sanity_zero_failure_pending = true;
                }
            }

            event_resolved = true;

            game_message = "Decision applied.";
            result_message = _choice.result;

            // Check immediate project failures
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

            // Handle special sanity failure
            if (sanity_zero_failure_pending
            && current_event_index < array_length(design_events) - 1)
            {
                campaign_failed = true;
                event_active = false;

                failure_reason =
                    "Special failure: Sanity crisis exceeded recovery window.";
            }

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
    if (sanity_zero_failure_pending)
    {
        // Final opportunity: allow campaign completion first.
        if (current_event_index == array_length(design_events) - 1
        && manufacturing_readiness >= required_readiness)
        {
            campaign_complete = true;
            event_active = false;

            game_message = "MANUFACTURING RELEASE APPROVED!";

            result_message =
                "Congratulations! Your design met the "
                + "prototype manufacturing readiness requirement.";
        }
        else
        {
            campaign_failed = true;
            event_active = false;

            failure_reason =
                "Special failure: Sanity crisis exceeded recovery window.";

            game_message = "PROJECT FAILURE!";
            result_message = failure_reason;
        }
    }
    else if (current_event_index < array_length(design_events) - 1)
    {
        current_event_index += 1;

        event_resolved = false;

        game_message = "Choose your response below.";
        result_message = "";
    }
    else
    {
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