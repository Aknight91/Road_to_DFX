
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
// PART 1B: SCROLL DECISION RESULTS
// --------------------------------------------------

if (event_active && event_resolved && result_message != "")
{
    // Get the shared results region
    var _region = get_ui_regions().results;

    // Calculate the height of the result message
    var _layout = calculate_result_layout(
        game_message,
        result_message,
        _region
    );

    // Calculate the maximum allowed scroll distance
    var _max_scroll = max(
        0,
        _layout.result_height - _layout.available_result_height
    );

    // Get mouse coordinates relative to the GUI
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Check whether the mouse is over the result text area
    var _mouse_over_results = point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _region.x,
        _layout.result_y,
        _region.x + _region.width,
        _region.y + _region.height
    );

    // Scroll only when the mouse is over the results
    if (_mouse_over_results)
    {
        if (mouse_wheel_down())
        {
            result_scroll_offset += 24;
        }
        else if (mouse_wheel_up())
        {
            result_scroll_offset -= 24;
        }
    }
	
// --------------------------------------------------
// DRAG RESULT SCROLLBAR WITH LEFT MOUSE BUTTON
// --------------------------------------------------

if (_max_scroll > 0 && _layout.available_result_height > 0)
{
    // Get the scrollbar's shared layout position
    var _bar = get_ui_regions().result_scrollbar;

    var _track_y = _layout.result_y;
    var _track_height = _layout.available_result_height;

    // Match the thumb dimensions used in Draw GUI
    var _thumb_height = clamp(
        (_track_height * _track_height) / _layout.result_height,
        18,
        _track_height
    );

    var _thumb_travel = _track_height - _thumb_height;

    // Calculate the thumb's current position
    var _thumb_y = _track_y
        + (result_scroll_offset / _max_scroll) * _thumb_travel;

    // Start dragging when the player clicks the thumb
    if (mouse_check_button_pressed(mb_left)
    && point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _bar.x,
        _thumb_y,
        _bar.x + _bar.width,
        _thumb_y + _thumb_height
    ))
    {
        result_scroll_dragging = true;

        // Remember where the thumb was grabbed
        result_scroll_grab_offset = _mouse_y - _thumb_y;
    }

    // Update scroll position while dragging
    if (result_scroll_dragging)
    {
        if (mouse_check_button(mb_left))
        {
            var _new_thumb_y = clamp(
                _mouse_y - result_scroll_grab_offset,
                _track_y,
                _track_y + _thumb_travel
            );

            if (_thumb_travel > 0)
            {
                result_scroll_offset =
                    ((_new_thumb_y - _track_y) / _thumb_travel)
                    * _max_scroll;
            }
        }
        else
        {
            // Stop dragging when the mouse is released
            result_scroll_dragging = false;
        }
    }
}
else
{
    // Disable dragging when no scrolling is necessary
    result_scroll_dragging = false;
}

    // Prevent scrolling beyond the message boundaries
    result_scroll_offset = clamp(
        result_scroll_offset,
        0,
        _max_scroll
    );
}


// --------------------------------------------------
// PART 2: ADVANCE TO THE NEXT EVENT
// --------------------------------------------------

if (event_active
&& event_resolved
&& (keyboard_check_pressed(vk_enter) || continue_requested))
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

// Reset the Continue request after checking progression
continue_requested = false;

// --------------------------------------------------
// PART 3: CLEAN UP BUTTONS WHEN GAMEPLAY ENDS
// --------------------------------------------------

if (!event_active && array_length(choice_button_instances) > 0)
{
    clear_choice_buttons();
}


// Remove the Continue button when gameplay ends
if (!event_active && instance_exists(continue_button_instance))
{
    instance_destroy(continue_button_instance);
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