
/// @description Decisions, progression, and campaign outcomes


// Toggle Debug Panel with CTRL + D
if (keyboard_check_pressed(ord("D"))
&& keyboard_check(vk_control))
{
    debug_panel_open = !debug_panel_open;
}


// --------------------------------------------------
// PART 1: PROCESS PLAYER DECISIONS (KEYBOARD)
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

 // --------------------------------------------------
 // PROCESS PLAYER DECISIONS (MOUSE)
 // --------------------------------------------------

   
    if (_choice_index != -1)
    {
        apply_player_choice(_choice_index);
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

	    // Rebuild buttons using the new event's choices
	    refresh_choice_buttons();

	    game_message = "";
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

        
       
		
        if (failure_reason == "")
        {
            campaign_complete = true;

            // Check for the special half-victory condition
            if (get_overdue_workdays() > 0 && sanity <= 0)
            {
                campaign_half_victory = true;

                game_message = "DESIGN RELEASED - HALF VICTORY!";

                result_message =
                    "The design met all DFX release requirements. "
                    + "However, the project was delivered late "
                    + "and the engineer was terminated.";
            }
            else
            {
                game_message = "DESIGN RELEASE APPROVED!";

                result_message =
                    "Congratulations! All DFX release requirements were met.";
            }
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
// PART 3: CLEAN UP BUTTONS WHEN GAMEPLAY ENDS
// --------------------------------------------------

if (!event_active && array_length(choice_button_instances) > 0)
{
    clear_choice_buttons();
}
/* 
 // --------------------------------------------------
 // TEMPORARY TEST: PROJECT CALENDAR INSPECTOR
 // --------------------------------------------------

 if (keyboard_check_pressed(ord("T")))
 {
     show_message(
         "Current date: "
         + format_project_date(project_current_date)
         + "\nProject deadline: "
         + format_project_date(project_deadline_date)
         + "\nWorkdays until deadline: "
         + string(get_workdays_until_deadline())
         + "\nLegacy days remaining: "
         + string(days_remaining)
         + "\nEngineering hours elapsed: "
         + string(project_work_hours_elapsed)
         + "\nHours accumulated today: "
         + string(project_work_hours_today)
         + "\nAdditional schedule delays: "
         + string(project_schedule_delay_days)		 
		 + "\nOverdue workdays: "
		 + string(get_overdue_workdays())

     );
 }

*/