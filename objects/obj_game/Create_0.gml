
// Set the game window to a landscape size
window_set_size(960, 540);

// Set the reference resolution for GUI elements
display_set_gui_size(960, 540);


// Player Resources
days_remaining = 25;
engineering_hours = 100;
budget = 100;
morale = 80;

drc_violations = 25;
manufacturing_risk = 10;


// Primary DFX Status Bars
dfa = 50;
dfm = 50;
dft = 50;
sanity = 100;


// Sanity Crisis System
sanity_zero_active = false;
sanity_zero_turns_remaining = 3;
sanity_zero_failure_pending = false;


// Software instability multiplier
software_instability = 1;

// Debug Panel
debug_panel_open = false;



// Store reusable design events.
design_events = [

    {
        title: "INCOMING DESIGN CHANGE!",

        description:
            "Engineering has received a late pin assignment change. "
            + "How will you respond?",

        choices: [
            {
                text: "Rework placement and routing",
                hours_cost: 12,
                days_cost: 0,
                drc_change: 0,
                risk_change: 0,
                dfa_change: 10,
                dfm_change: 10,
                dft_change: 0,
                sanity_change: -8,
                result:"Rework selected. Routing corrected. DFM improved."

				  
			},
            {
                text: "Apply a quick patch",
                hours_cost: 4,
                days_cost: 0,
                drc_change: 0,
                risk_change: 10,
                dfa_change: 0,
                dfm_change: -10,
                dft_change: 0,
                sanity_change: -6,
                result: "Quick patch applied. Manufacturing risk increased."
            },
            {
                text: "Request a design review",
                hours_cost: 2,
                days_cost: 1,
                drc_change: 0,
                risk_change: -5,
                dfa_change: 0,
                dfm_change: 5,
                dft_change: 0,
                sanity_change: -4,
                result: "Design review completed. Routing concerns reduced."
            }
        ]
    },

    {
        // VIA SPACING EVENT
        title: "VIA SPACING VIOLATION!",

        description:
            "Fabrication review has identified two vias "
            + "that are too close together. The manufacturer "
            + "has flagged the design. How will you respond?",

        choices: [
            {
                text: "Rework routing to increase via spacing",
                hours_cost: 10,
                days_cost: 2,
                drc_change: -1,
                risk_change: -5,
                dfa_change: 0,
                dfm_change: 10,
                dft_change: 0,
                sanity_change: -8,
                result: "Via spacing corrected. DFM improved."
            },
            {
                text: "Request fabrication engineering review",
                hours_cost: 4,
                days_cost: 1,
                drc_change: 0,
                risk_change: -5,
                dfa_change: 0,
                dfm_change: 5,
                dft_change: 0,
                sanity_change: -4,
                result: "Fabrication review completed. DFM improved."
            },
            {
                text: "Accept risk and release artwork",
                hours_cost: 0,
                days_cost: 0,
                drc_change: 0,
                risk_change: 20,
                dfa_change: 0,
                dfm_change: -15,
                dft_change: 0,
                sanity_change: -12,
                result: "Artwork released with unresolved via spacing risk."
            }
        ]
    },

    {
        // TEST COVERAGE EVENT
        title: "TEST COVERAGE GAP!",

        description:
            "Engineering has discovered that several critical "
            + "signals are missing test coverage. How will you respond?",

        choices: [
            {
                text: "Add test points and update coverage",
                hours_cost: 8,
                days_cost: 1,
                drc_change: 0,
                risk_change: -5,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: 15,
                sanity_change: -6,
                result: "Test coverage improved. DFT increased."
            },
            {
                text: "Perform a limited test review",
                hours_cost: 4,
                days_cost: 0,
                drc_change: 0,
                risk_change: 0,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: 5,
                sanity_change: -3,
                result: "Limited test coverage improvements completed."
            },
            {
                text: "Accept the existing test coverage",
                hours_cost: 0,
                days_cost: 0,
                drc_change: 0,
                risk_change: 10,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: -10,
                sanity_change: -8,
                result: "Test coverage accepted with unresolved risk."
            }
                ]
    },

    {
        // FINAL TEST SIGNOFF EVENT
        title: "FINAL TEST SIGNOFF!",

        description:
            "The design is approaching release, but final "
            + "test engineering signoff is still outstanding. "
            + "How will you respond?",

        choices: [
            {
                text: "Complete full test verification",
                hours_cost: 10,
                days_cost: 2,
                drc_change: 0,
                risk_change: -10,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: 15,
                sanity_change: -5,
                result: "Full test verification completed. DFT improved."
            },
            {
                text: "Perform a limited verification",
                hours_cost: 4,
                days_cost: 1,
                drc_change: 0,
                risk_change: -5,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: 5,
                sanity_change: -3,
                result: "Limited test verification completed."
            },
            {
                text: "Release without final verification",
                hours_cost: 0,
                days_cost: 0,
                drc_change: 0,
                risk_change: 20,
                dfa_change: 0,
                dfm_change: 0,
                dft_change: -15,
                sanity_change: -10,
                result: "Design released without complete test verification."
            }
        ]
    }
	
];


// Track the active event.
current_event_index = 0;

event_active = true;
event_resolved = false;
continue_requested = false;

/// @description Request progression to the next event

request_continue = function()
{
    
	// Only allow progression during the REVIEWING phase
	if (get_campaign_phase() != CampaignPhase.REVIEWING)
	{
	    return;
	}


    // Register the request for the Step Event
    continue_requested = true;
};

campaign_complete = false;
campaign_failed = false;
campaign_half_victory = false;


 // --------------------------------------------------
 // CAMPAIGN STATE INTERFACE
 // --------------------------------------------------

 // Return the current gameplay phase
 get_campaign_phase = function()
 {
     if (!event_active)
     {
         return CampaignPhase.FINISHED;
     }

     if (event_resolved)
     {
         return CampaignPhase.REVIEWING;
     }

     return CampaignPhase.CHOOSING;
 };


 // Return the campaign outcome
 get_campaign_outcome = function()
 {
     if (campaign_failed)
     {
         return CampaignOutcome.FAILURE;
     }

     if (campaign_complete)
     {
         if (campaign_half_victory)
         {
             return CampaignOutcome.HALF_VICTORY;
         }

         return CampaignOutcome.VICTORY;
     }

     return CampaignOutcome.NONE;
 };


required_dfa = 50;
required_dfm = 50;
required_dft = 50;
required_sanity = 1;
failure_reason = "";

game_message = "";
result_message = "";



// --------------------------------------------------
// DECISION RESULT SCROLLING
// --------------------------------------------------

// Vertical scroll position for decision results
result_scroll_offset = 0;

// --------------------------------------------------
// RESULT SCROLLBAR DRAGGING
// --------------------------------------------------

// Whether the player is dragging the scrollbar
result_scroll_dragging = false;

// Mouse position relative to the scrollbar thumb
result_scroll_grab_offset = 0;


 // --------------------------------------------------
 // PROJECT CALENDAR SYSTEM
 // --------------------------------------------------

 // Project dates
 project_start_date = date_create_datetime(2027, 1, 4, 0, 0, 0);
 project_current_date = project_start_date;
 project_deadline_date = date_create_datetime(2027, 2, 8, 0, 0, 0);


 // Standard engineering workday
 hours_per_workday = 8;

 // Track engineering time consumed
 project_work_hours_elapsed = 0;
 project_work_hours_today = 0;
 project_schedule_delay_days = 0;


 // --------------------------------------------------
 // OVERDUE SANITY PENALTY SYSTEM
 // --------------------------------------------------


 // Sanity lost per overdue working day
 overdue_sanity_penalty_per_day = 20;



 // Number of overdue workdays already penalized
 overdue_days_penalized = 0;


 // --------------------------------------------------
 // ADVANCE PROJECT TIME USING ENGINEERING HOURS
 // --------------------------------------------------

 advance_project_work_hours = function(_hours)
 {
     // Record engineering hours consumed
     project_work_hours_elapsed += _hours;
     project_work_hours_today += _hours;

     // Advance one workday for every 8 hours accumulated
     while (project_work_hours_today >= hours_per_workday)
     {
         project_work_hours_today -= hours_per_workday;

         // Move to the next calendar day
         project_current_date = date_inc_day(
             project_current_date, 1
         );

         // Skip Saturday and Sunday
         while (date_get_weekday(project_current_date) == 0
         || date_get_weekday(project_current_date) == 6)
         {
             project_current_date = date_inc_day(
                 project_current_date, 1
             );
         }
     }
 };


 // --------------------------------------------------
 // ADVANCE PROJECT CALENDAR FOR SCHEDULE DELAYS
 // --------------------------------------------------

 advance_project_schedule_days = function(_days)
 {
	 // Record cumulative schedule delays
	 project_schedule_delay_days += max(0, floor(_days));
	 
     // Advance one working day for each day of delay
     repeat (max(0, floor(_days)))
     {
         project_current_date = date_inc_day(
             project_current_date, 1
         );

         // Skip Saturday and Sunday
         while (date_get_weekday(project_current_date) == 0
         || date_get_weekday(project_current_date) == 6)
         {
             project_current_date = date_inc_day(
                 project_current_date, 1
             );
         }
     }
 };


 // --------------------------------------------------
 // FORMAT PROJECT DATES AS MM/DD/YYYY
 // --------------------------------------------------

 format_project_date = function(_date)
 {
     var _month = string(date_get_month(_date));
     var _day = string(date_get_day(_date));
     var _year = string(date_get_year(_date));

     // Add leading zeros when necessary
     if (string_length(_month) < 2)
     {
         _month = "0" + _month;
     }

     if (string_length(_day) < 2)
     {
         _day = "0" + _day;
     }

     return _month + "/" + _day + "/" + _year;
 };



 // --------------------------------------------------
 // CALCULATE WORKDAYS UNTIL PROJECT DEADLINE
 // --------------------------------------------------

 get_workdays_until_deadline = function()
 {
     var _date = project_current_date;
     var _workdays_remaining = 0;

     // Count working days between current date and deadline
     while (_date < project_deadline_date)
     {
         _date = date_inc_day(_date, 1);

         var _weekday = date_get_weekday(_date);

         // Count Monday through Friday only
         if (_weekday != 0 && _weekday != 6)
         {
             _workdays_remaining += 1;
         }
     }

     return _workdays_remaining;
 };


 // --------------------------------------------------
 // CALCULATE WORKDAYS PAST PROJECT DEADLINE
 // --------------------------------------------------

 get_overdue_workdays = function()
 {
     var _date = project_deadline_date;
     var _overdue_days = 0;

     // Count working days after the deadline
     while (_date < project_current_date)
     {
         _date = date_inc_day(_date, 1);

         var _weekday = date_get_weekday(_date);

         // Count Monday through Friday only
         if (_weekday != 0 && _weekday != 6)
         {
             _overdue_days += 1;
         }
     }

     return _overdue_days;
 };


 // --------------------------------------------------
 // APPLY OVERDUE SANITY PENALTIES
 // --------------------------------------------------

 apply_overdue_sanity_penalty = function()
 {
     // Calculate total overdue working days
     var _overdue_days = get_overdue_workdays();

     // Determine how many days have not been penalized
     var _new_overdue_days = max(
         0,
         _overdue_days - overdue_days_penalized
     );

     // Apply penalties only for newly overdue days
     if (_new_overdue_days > 0)
     {
         var _sanity_penalty =
             _new_overdue_days * overdue_sanity_penalty_per_day;

         // Apply penalty without allowing negative sanity
         sanity = clamp(
             sanity - _sanity_penalty,
             0,
             100
         );

         // Record the days already penalized
         overdue_days_penalized = _overdue_days;
     }
 };



 // --------------------------------------------------
 // APPLY PLAYER CHOICE
 // --------------------------------------------------


apply_player_choice = function(_choice_index)
{
    
	// Only process decisions during the CHOOSING phase
	if (get_campaign_phase() != CampaignPhase.CHOOSING)
	{
	    exit;
	}


    
	var _event = design_events[current_event_index];

	// Reject choice indices outside the current event's choices
	if (_choice_index < 0
	|| _choice_index >= array_length(_event.choices))
	{
	    show_debug_message(
	        "WARNING: Invalid choice index: "
	        + string(_choice_index)
	    );

	    exit;
	}

	var _choice = _event.choices[_choice_index];


    if (engineering_hours >= _choice.hours_cost)

     {
         // Was the sanity crisis already active?
         var _crisis_was_active = sanity_zero_active;

         // Apply engineering resource costs
         engineering_hours -= _choice.hours_cost;

         // Advance calendar based on engineering effort
         advance_project_work_hours(_choice.hours_cost);

         // Advance calendar for additional schedule delays
         advance_project_schedule_days(_choice.days_cost);

         // Update remaining workdays
         days_remaining = get_workdays_until_deadline();

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

         // Apply overdue Sanity penalties
         apply_overdue_sanity_penalty();

         // Start the Sanity Crisis
         if (sanity <= 0 && !sanity_zero_active)
         {
             sanity_zero_active = true;
             sanity_zero_turns_remaining = 3;
             software_instability = 5;
         }
         // Count subsequent decisions during the crisis
         else if (_crisis_was_active
         && sanity_zero_turns_remaining > 0)
         {
             sanity_zero_turns_remaining -= 1;

             if (sanity_zero_turns_remaining <= 0)
             {
                 sanity_zero_turns_remaining = 0;
                 sanity_zero_failure_pending = true;

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

         // Immediate engineering resource exhaustion check
         if (engineering_hours <= 0)
         {
             campaign_failed = true;
             event_active = false;

             failure_reason =
                 "Project failed: Engineering hours exhausted.";
         }

         if (campaign_failed)
         {
             game_message = "PROJECT FAILURE!";
             result_message = failure_reason;
         }
		 
		// Start each new decision result at the top
		result_scroll_offset = 0;

     }
     else
     {
         game_message =
             "Insufficient resources for this decision.";
     }
	 
	 
 };


/// --------------------------------------------------
/// REUSABLE CHOICE BUTTON MANAGEMENT
/// --------------------------------------------------

// Track button instances belonging to this controller
choice_button_instances = [];


 // Destroy all choice buttons owned by this controller
 clear_choice_buttons = function()
 {
     for (var _i = 0; _i < array_length(choice_button_instances); _i++)
     {
         if (instance_exists(choice_button_instances[_i]))
         {
             instance_destroy(choice_button_instances[_i]);
         }
     }

     choice_button_instances = [];
 };


// Create or rebuild buttons for the current event
refresh_choice_buttons = function()
{
   
    // Remove previously created buttons
    clear_choice_buttons();


    
    // Calculate button layout using Flex Panels
    var _choices = design_events[current_event_index].choices;
    var _region = get_ui_regions().choices;

    var _flex_layout = calculate_choice_layout_flex(
        _choices,
        _region
    );

    // Use calculated rectangles for our button instances
    var _layout = _flex_layout.buttons;

    // Report layouts that exceed the choice region
    if (_flex_layout.overflow)
    {
        show_debug_message(
            "WARNING: Choice layout exceeds its defined region."
        );
    }


    // Create one reusable button per choice
    for (var _i = 0; _i < array_length(_layout); _i++)
    {
        var _bounds = _layout[_i];

        var _button = instance_create_depth(
            0,
            0,
            depth - 1,
            obj_choice_button
        );

        // Connect button to the game controller
        _button.controller = id;
        _button.choice_index = _i;
		
		
		// Supply the button's display text
		_button.choice_label =
		    string(_i + 1) + ". " + _choices[_i].text;


        // Apply calculated position and dimensions
        _button.button_x = _bounds.x;
        _button.button_y = _bounds.y;
        _button.button_width = _bounds.width;
        _button.button_height = _bounds.height;

        // Track this instance for later cleanup
        array_push(choice_button_instances, _button);
    }
};

		// Create the initial event's buttons
		refresh_choice_buttons();
	

// --------------------------------------------------
// CREATE THE CONTINUE BUTTON
// --------------------------------------------------

// Create one Continue button for the campaign
continue_button_instance = instance_create_depth(
    0,
    0,
    depth - 1,
    obj_continue_button
);

// Connect the button to the game controller
continue_button_instance.controller = id;
