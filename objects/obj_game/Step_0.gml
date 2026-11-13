
/// @description Decisions, progression, and campaign outcomes

// --------------------------------------------------
// TITLE SCREEN INPUT
// --------------------------------------------------

// Navigate from the title screen to campaign setup.
// Do not start a campaign until setup is complete.

if (screen_manager.can_receive_input(ScreenId.TITLE)
&& keyboard_check_pressed(vk_enter))
{
    screen_manager.navigate_to(ScreenId.CAMPAIGN_SETUP);
}


// Toggle Debug Panel with CTRL + D
if (keyboard_check_pressed(ord("D"))
&& keyboard_check(vk_control))
{
    debug_panel_open = !debug_panel_open;
}


// --------------------------------------------------
// PART 1: PROCESS PLAYER DECISIONS (KEYBOARD)
// --------------------------------------------------

if (get_campaign_phase() == CampaignPhase.CHOOSING)

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

   
   
	if (_choice_index >= 0
	&& _choice_index < array_length(design_events[current_event_index].choices))
	{
	    apply_player_choice(_choice_index);
	}


}


// --------------------------------------------------
// PART 1B: SCROLL DECISION RESULTS
// --------------------------------------------------


/// --------------------------------------------------
/// PART 1B: SCROLL DECISION RESULTS
/// --------------------------------------------------

if (screen_manager.can_receive_input(ScreenId.GAMEPLAY)
&& get_campaign_phase() == CampaignPhase.REVIEWING
&& result_message != "")
{
    // Get shared results region
    var _regions = get_ui_regions();
    var _region = _regions.results;

    // Calculate result text layout
    var _layout = calculate_result_layout(
        game_message,
        result_message,
        _region
    );

    // Get mouse coordinates in GUI space
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Check whether mouse is over the results
    var _mouse_over_results = point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _region.x,
        _layout.result_y,
        _region.x + _region.width,
        _region.y + _region.height
    );

    // --------------------------------------------------
    // MOUSE WHEEL SCROLLING
    // --------------------------------------------------

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
    // CALCULATE SHARED SCROLLBAR GEOMETRY
    // --------------------------------------------------

    var _scrollbar = calculate_result_scrollbar_layout(
        _layout,
        _regions.result_scrollbar,
        result_scroll_offset
    );

    var _max_scroll = _scrollbar.max_scroll;

    // --------------------------------------------------
    // DRAG RESULT SCROLLBAR
    // --------------------------------------------------

    if (_scrollbar.visible)
    {
        // Retrieve shared scrollbar geometry
        var _track = _scrollbar.track;
        var _thumb = _scrollbar.thumb;
        var _thumb_travel = _scrollbar.thumb_travel;

        // Start dragging when clicking the thumb
        if (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(
            _mouse_x,
            _mouse_y,
            _thumb.x,
            _thumb.y,
            _thumb.x + _thumb.width,
            _thumb.y + _thumb.height
        ))
        {
            result_scroll_dragging = true;

            // Record where the thumb was grabbed
            result_scroll_grab_offset = _mouse_y - _thumb.y;
        }

        // Update scrollbar while dragging
        if (result_scroll_dragging)
        {
            if (mouse_check_button(mb_left))
            {
                var _new_thumb_y = clamp(
                    _mouse_y - result_scroll_grab_offset,
                    _track.y,
                    _track.y + _thumb_travel
                );

                if (_thumb_travel > 0)
                {
                    result_scroll_offset =
                        ((_new_thumb_y - _track.y) / _thumb_travel)
                        * _max_scroll;
                }
            }
            else
            {
                // Stop dragging on mouse release
                result_scroll_dragging = false;
            }
        }
    }
    else
    {
        // No scrollbar needed
        result_scroll_dragging = false;
    }

    // --------------------------------------------------
    // CLAMP SCROLL POSITION
    // --------------------------------------------------

    result_scroll_offset = clamp(
        result_scroll_offset,
        0,
        _max_scroll
    );
}
else
{
    // Cancel dragging when gameplay loses input
    result_scroll_dragging = false;
}



// --------------------------------------------------
// PART 2: ADVANCE TO THE NEXT EVENT
// --------------------------------------------------

// Route keyboard progression through the controller
if (keyboard_check_pressed(vk_enter))
{
     request_continue();
}



if (screen_manager.can_receive_input(ScreenId.GAMEPLAY)
&& get_campaign_phase() == CampaignPhase.REVIEWING
&& continue_requested)
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


if (get_campaign_phase() == CampaignPhase.FINISHED
&& array_length(choice_button_instances) > 0)
{
    clear_choice_buttons();
}



// Remove the Continue button when gameplay ends

if (get_campaign_phase() == CampaignPhase.FINISHED
&& instance_exists(continue_button_instance))
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