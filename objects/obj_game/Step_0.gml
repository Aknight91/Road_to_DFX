
/// @description Decisions, progression, and campaign outcomes

// --------------------------------------------------
// CAPTURE SCREEN AT START OF FRAME
// --------------------------------------------------

// Prevent a single input from affecting two screens
// when navigation occurs during the same Step Event.

var _screen_at_step_start =
    screen_manager.get_current_screen();

// Capture the overlay active before input is processed.
// Prevents one click from affecting multiple overlay states.

var _overlay_at_step_start =
    screen_manager.get_top_overlay();


// --------------------------------------------------
// TITLE SCREEN INPUT
// --------------------------------------------------

if (screen_manager.can_receive_input(ScreenId.TITLE))
{
    // Get shared Start button geometry
    var _start_button = get_title_start_button_bounds();

    // Get mouse position in GUI coordinates
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Detect mouse click inside the Start button
    var _start_clicked =
        mouse_check_button_pressed(mb_left)
        && point_in_rectangle(
            _mouse_x,
            _mouse_y,
            _start_button.x,
            _start_button.y,
            _start_button.x + _start_button.width,
            _start_button.y + _start_button.height
        );

    // Support both mouse and keyboard navigation
   
	if (_start_clicked
	|| keyboard_check_pressed(vk_enter))
	{
	    // Each new setup begins without a selected difficulty
	    selected_campaign_difficulty = CampaignDifficulty.NONE;

	    screen_manager.navigate_to(ScreenId.CAMPAIGN_SETUP);
	}

}

// --------------------------------------------------
// CAMPAIGN SETUP INPUT
// --------------------------------------------------

// Allow returning to the title screen without
// starting or modifying a campaign.

if (screen_manager.can_receive_input(ScreenId.CAMPAIGN_SETUP))
{
    // Get shared Back button geometry
    var _back_button = get_campaign_setup_back_button_bounds();

    // Get mouse position in GUI coordinates
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Detect a mouse click inside the button
    var _back_clicked =
        mouse_check_button_pressed(mb_left)
        && point_in_rectangle(
            _mouse_x,
            _mouse_y,
            _back_button.x,
            _back_button.y,
            _back_button.x + _back_button.width,
            _back_button.y + _back_button.height
        );

    // Support mouse and keyboard navigation
    if (_back_clicked
    || keyboard_check_pressed(vk_escape))
    {
        screen_manager.navigate_to(ScreenId.TITLE);
    }
}

// --------------------------------------------------
// CAMPAIGN DIFFICULTY SELECTION
// --------------------------------------------------


if (_screen_at_step_start == ScreenId.CAMPAIGN_SETUP
&& screen_manager.can_receive_input(ScreenId.CAMPAIGN_SETUP)
&& mouse_check_button_pressed(mb_left))

{
    // Get mouse position in GUI coordinates
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Get the shared difficulty button layout
    var _options = get_campaign_setup_difficulty_options();

    // Check each difficulty button
    for (var _i = 0; _i < array_length(_options); _i++)
    {
        var _option = _options[_i];

        if (point_in_rectangle(
            _mouse_x,
            _mouse_y,
            _option.x,
            _option.y,
            _option.x + _option.width,
            _option.y + _option.height
        ))
        {
            // Store the player's explicit selection
            selected_campaign_difficulty = _option.difficulty;

            // Only one difficulty can be selected
            break;
        }
    }
}

// --------------------------------------------------
// BEGIN CAMPAIGN INPUT
// --------------------------------------------------

// Only accept input if Campaign Setup was active
// at the beginning of this Step Event.

if (_screen_at_step_start == ScreenId.CAMPAIGN_SETUP
&& screen_manager.can_receive_input(ScreenId.CAMPAIGN_SETUP))
{
    // A difficulty must be explicitly selected
    if (selected_campaign_difficulty != CampaignDifficulty.NONE)
    {
        // Get shared Begin button geometry
        var _begin_button = get_campaign_setup_begin_button_bounds();

        // Get mouse position in GUI coordinates
        var _mouse_x = device_mouse_x_to_gui(0);
        var _mouse_y = device_mouse_y_to_gui(0);

        // Detect click inside Begin Campaign button
        if (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(
            _mouse_x,
            _mouse_y,
            _begin_button.x,
            _begin_button.y,
            _begin_button.x + _begin_button.width,
            _begin_button.y + _begin_button.height
        ))
        {
            // Initialize and enter gameplay
            start_campaign();
        }
    }
}


// --------------------------------------------------
// TEMPORARY REGRESSION TEST: ENTER GAMEPLAY
// --------------------------------------------------

// Development-only shortcut.
// Remove after Campaign Setup can start gameplay normally.

if (screen_manager.can_receive_input(ScreenId.CAMPAIGN_SETUP)
&& keyboard_check_pressed(vk_f9))
{
    start_campaign();
}

// --------------------------------------------------
// PAUSE MENU - ESCAPE KEY INPUT
// --------------------------------------------------

// Escape controls the pause menu only during gameplay.
// Before gameplay, existing screen navigation handles Escape.

if (_screen_at_step_start == ScreenId.GAMEPLAY
&& keyboard_check_pressed(vk_escape))
{
    var _top_overlay = screen_manager.get_top_overlay();

   
// Close the confirmation first, if one is open
if (_top_overlay == OverlayId.CONFIRMATION)
{
    screen_manager.close_top_overlay();

    show_debug_message("PAUSE MENU: Confirmation cancelled");
}

// Otherwise close the pause menu normally
else if (_top_overlay == OverlayId.PAUSE_MENU)
{
    screen_manager.close_top_overlay();

    show_debug_message("PAUSE MENU: Closed");
}


    // Escape opens the pause menu if no overlay is active
    else if (_top_overlay == noone
    && screen_manager.can_receive_input(ScreenId.GAMEPLAY))
    {
        screen_manager.open_overlay(OverlayId.PAUSE_MENU);

        show_debug_message("PAUSE MENU: Opened");
    }
}

// --------------------------------------------------
// PAUSE MENU - RESUME BUTTON INPUT
// --------------------------------------------------

if (_screen_at_step_start == ScreenId.GAMEPLAY
&& screen_manager.get_top_overlay() == OverlayId.PAUSE_MENU
&& mouse_check_button_pressed(mb_left))
{
    // Get mouse position in GUI coordinates
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Resume is the first menu button (index 0)
    var _resume_button = get_pause_menu_button_bounds(0);

    // Check whether Resume was clicked
    if (point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _resume_button.x,
        _resume_button.y,
        _resume_button.x + _resume_button.width,
        _resume_button.y + _resume_button.height
    ))
    {
        // Dismiss the pause overlay
        screen_manager.close_top_overlay();
    }
}

// --------------------------------------------------
// PAUSE MENU - RESTART CONFIRMATION INPUT
// --------------------------------------------------

if (_screen_at_step_start == ScreenId.GAMEPLAY
&& screen_manager.get_top_overlay() == OverlayId.PAUSE_MENU
&& mouse_check_button_pressed(mb_left))
{
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Restart Campaign is menu index 3
    var _restart_button = get_pause_menu_button_bounds(3);

    if (point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _restart_button.x,
        _restart_button.y,
        _restart_button.x + _restart_button.width,
        _restart_button.y + _restart_button.height
    ))
    {
        // Open confirmation without changing campaign state
        screen_manager.open_overlay(OverlayId.CONFIRMATION);
    }
}

// --------------------------------------------------
// PAUSE MENU - CONFIRMATION BUTTON INPUT
// --------------------------------------------------

if (_screen_at_step_start == ScreenId.GAMEPLAY
&& _overlay_at_step_start == OverlayId.CONFIRMATION
&& screen_manager.get_top_overlay() == OverlayId.CONFIRMATION
&& mouse_check_button_pressed(mb_left))
{
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    var _restart_button =
        get_pause_confirmation_button_bounds(0);

    var _cancel_button =
        get_pause_confirmation_button_bounds(1);


    // --------------------------------------------------
    // CONFIRM RESTART
    // --------------------------------------------------

    if (point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _restart_button.x,
        _restart_button.y,
        _restart_button.x + _restart_button.width,
        _restart_button.y + _restart_button.height
    ))
    {
        // Close confirmation
        screen_manager.close_top_overlay();

        // Close pause menu
        screen_manager.close_top_overlay();

        // Prevent the restart click from also activating
        // a gameplay button created during this frame.
        mouse_clear(mb_left);

        // Restart using the existing campaign initializer
        start_campaign();
    }


    // --------------------------------------------------
    // CANCEL RESTART
    // --------------------------------------------------

    else if (point_in_rectangle(
        _mouse_x,
        _mouse_y,
        _cancel_button.x,
        _cancel_button.y,
        _cancel_button.x + _cancel_button.width,
        _cancel_button.y + _cancel_button.height
    ))
    {
        // Close only the confirmation dialog
        screen_manager.close_top_overlay();

        // Consume this mouse click
        mouse_clear(mb_left);
    }
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