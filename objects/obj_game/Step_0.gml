
/// @description Decisions, progression, and campaign outcomes


// Toggle Debug Panel with CTRL + D
if (keyboard_check_pressed(ord("D"))
&& keyboard_check(vk_control))
{
    debug_panel_open = !debug_panel_open;
}


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


			// Advance project calendar based on engineering effort
			advance_project_work_hours(_choice.hours_cost);


            // Record manufacturing penalty before changes
            var _old_manufacturing_penalty =
                (drc_violations * 2) + manufacturing_risk;

            // Apply DRC and manufacturing risk changes
            drc_violations = max(0, drc_violations + _choice.drc_change);
            manufacturing_risk = max(0, manufacturing_risk + _choice.risk_change);

            // Calculate manufacturing penalty after changes
            var _new_manufacturing_penalty =
                (drc_violations * 2) + manufacturing_risk;

            // Apply DFX changes
            dfa = clamp(dfa + _choice.dfa_change, 0, 100);

            dfm = clamp(
                dfm + _choice.dfm_change
                + (_old_manufacturing_penalty - _new_manufacturing_penalty),
                0,
                100
            );

            dft = clamp(dft + _choice.dft_change, 0, 100);

            // Apply sanity change
            sanity = clamp(sanity + _choice.sanity_change, 0, 100);

            // Start the sanity crisis
            if (sanity <= 0 && !sanity_zero_active)
            {
                sanity_zero_active = true;
                sanity_zero_turns_remaining = 3;

                // Software instability increases dramatically
                software_instability = 5;
            }
           			

			
			 // Count subsequent decisions during the crisis
			 else if (_crisis_was_active
			 && sanity_zero_turns_remaining > 0)
			 {
			     sanity_zero_turns_remaining -= 1;

			     // Check whether the three-turn deadline expired
			     if (sanity_zero_turns_remaining <= 0)
			     {
			         sanity_zero_turns_remaining = 0;
			         sanity_zero_failure_pending = true;

			         // Fail if the final roadmap event is not reached
			         if (current_event_index < array_length(design_events) - 1)
			         {
			             campaign_failed = true;
			             event_active = false;

			             failure_reason =
			                 "SPECIAL FAILURE: Sanity crisis deadline exceeded.";
			         }
			     }
			 }



            event_resolved = true;

           
			
			game_message = "Decision applied.";
			result_message = _choice.result;



            // Immediate resource and schedule failures only
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
        current_event_index += 1;

        event_resolved = false;

        game_message = "Choose your response below.";
        result_message = "";
    }
    else
    {
        // --------------------------------------------------
        // FINAL ROADMAP EVALUATION
        // --------------------------------------------------

        event_active = false;

        failure_reason = "";

        if (dfa < required_dfa)
        {
            failure_reason +=
                "ASSEMBLY FAILURE: DFA below release requirement.\n";
        }

        if (dfm < required_dfm)
        {
            failure_reason +=
                "MANUFACTURING FAILURE: DFM below release requirement.\n";
        }

        if (dft < required_dft)
        {
            failure_reason +=
                "TEST FAILURE: DFT below release requirement.\n";
        }

        if (sanity < required_sanity)
        {
            failure_reason +=
                "ENGINEERING BURNOUT: Team sanity below survival requirement.\n";
        }

        if (failure_reason == "")
        {
            campaign_complete = true;

            game_message = "DESIGN RELEASE APPROVED!";

            result_message =
                "Congratulations! All DFX release requirements were met.";
        }
        else
        {
            campaign_failed = true;

            game_message = "PROJECT FAILURE!";

            result_message = failure_reason;
        }
    }
}




 // --------------------------------------------------
 // TEMPORARY TEST: VIEW PROJECT CALENDAR
 // Press T to inspect calendar values
 // --------------------------------------------------

 if (keyboard_check_pressed(ord("T")))
 {
     show_message(
         "Current date: "
         + format_project_date(project_current_date)
         + "\nProject deadline: "
         + format_project_date(project_deadline_date)
         + "\nTotal hours elapsed: "
         + string(project_work_hours_elapsed)
         + "\nHours accumulated today: "
         + string(project_work_hours_today)
     );
 }


