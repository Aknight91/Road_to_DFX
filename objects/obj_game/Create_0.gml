// Initialize random behavior once at game startup
randomize();
// Set the game window to a landscape size
window_set_size(960, 540);

// Set the reference resolution for GUI elements
display_set_gui_size(960, 540);

// --------------------------------------------------
// SCREEN MANAGEMENT
// --------------------------------------------------

// Initialize screen navigation
// Start at the title screen before beginning a campaign
screen_manager = new ScreenManager(ScreenId.TITLE);	

// --------------------------------------------------
// CAMPAIGN SETUP SELECTION
// --------------------------------------------------


// No difficulty is selected automatically.
// The player must make an explicit choice.

selected_campaign_difficulty = CampaignDifficulty.NONE;

// --------------------------------------------------
// EVENT LIBRARY INITIALIZATION
// --------------------------------------------------

// Create the stage-based event library
event_library = create_event_library();


// --------------------------------------------------
// TEMPORARY EVENT LIBRARY DIAGNOSTICS
// --------------------------------------------------

// Retrieve the PCB Design event pool
var _pcb_pool = get_event_pool(
    event_library,
    EventStage.PCB_DESIGN
);

// Report the number of registered events
show_debug_message(
    "EVENT LIBRARY: PCB Design events = "
    + string(array_length(_pcb_pool))
);

// Verify the first event and its choices
if (array_length(_pcb_pool) > 0)
{
    show_debug_message(
        "EVENT LIBRARY: First event ID = "
        + _pcb_pool[0].id
    );

    show_debug_message(
        "EVENT LIBRARY: Choice count = "
        + string(array_length(_pcb_pool[0].choices))
    );
}

// --------------------------------------------------
// TEMPORARY EVENT ELIGIBILITY TEST
// --------------------------------------------------

// Test with no previously played events
var _eligible_new = get_eligible_stage_events(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    []
);

show_debug_message(
    "EVENT SELECTOR: New campaign eligible = "
    + string(array_length(_eligible_new))
);


// Simulate PCB-0001 having already been played
var _eligible_played = get_eligible_stage_events(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    ["PCB-0001"]
);

show_debug_message(
    "EVENT SELECTOR: After PCB-0001 eligible = "
    + string(array_length(_eligible_played))
);

// --------------------------------------------------
// TEMPORARY FLAG ELIGIBILITY TEST
// --------------------------------------------------

// Create a separate library for testing.
// The active campaign library remains unchanged.
var _flag_test_library = create_event_library();

var _flag_test_event =
    _flag_test_library.pcb_design[0];

// Simulate a follow-up event that requires an
// unresolved CAD issue and becomes unavailable
// once that issue has been verified.
_flag_test_event.required_flags = [
    "cad_changes_unverified"
];

_flag_test_event.blocked_flags = [
    "cad_changes_verified"
];

// Test 1: Required flag is missing
var _test_missing = get_eligible_stage_events(
    _flag_test_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    [],
    []
);

// Test 2: Required flag is present
var _test_matching = get_eligible_stage_events(
    _flag_test_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    [],
    ["cad_changes_unverified"]
);

// Test 3: Required and blocked flags are present
var _test_blocked = get_eligible_stage_events(
    _flag_test_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    [],
    [
        "cad_changes_unverified",
        "cad_changes_verified"
    ]
);

show_debug_message(
    "EVENT FLAGS: Missing required = "
    + string(array_length(_test_missing))
);

show_debug_message(
    "EVENT FLAGS: Required present = "
    + string(array_length(_test_matching))
);

show_debug_message(
    "EVENT FLAGS: Blocked condition = "
    + string(array_length(_test_blocked))
);

// --------------------------------------------------
// TEMPORARY WEIGHTED EVENT SELECTION TEST
// --------------------------------------------------

// Test selection using our registered PCB Design event
var _weighted_eligible = get_eligible_stage_events(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    [],
    []
);

var _weighted_selected = select_weighted_event(
    _weighted_eligible
);

if (is_struct(_weighted_selected))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Selected = "
        + _weighted_selected.id
    );
}

// Verify that zero-weight events cannot be selected
var _weight_test = select_weighted_event([
    { id: "ZERO", weight: 0 },
    { id: "VALID", weight: 10 }
]);

if (is_struct(_weight_test))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Positive weight = "
        + _weight_test.id
    );
}

// Verify that an empty pool is handled safely
var _empty_selection = select_weighted_event([]);

if (!is_struct(_empty_selection))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Empty pool handled"
    );
}



// Tracks the action awaiting player confirmation.
// Valid actions for now: "restart" and "title".

pause_confirmation_action = "";





/// @description Initialize campaign starting statistics

// --------------------------------------------------
// CAMPAIGN STATISTICS INITIALIZATION
// --------------------------------------------------

initialize_campaign_stats = function()
{
    // Player resources
    days_remaining = 25;
    engineering_hours = 100;
    budget = 100;
    morale = 80;

    // Manufacturing conditions
    drc_violations = 25;
    manufacturing_risk = 10;

    // Primary DFX status bars
    dfa = 50;
    dfm = 50;
    dft = 50;
    sanity = 100;

    // Sanity Crisis
    sanity_zero_active = false;
    sanity_zero_turns_remaining = 3;
    sanity_zero_failure_pending = false;

    // Software instability
    software_instability = 1;
	
// --------------------------------------------------
// APPLY SELECTED CAMPAIGN DIFFICULTY
// --------------------------------------------------

// NONE returns undefined during initial game setup.
var _profile = get_campaign_difficulty_profile(
    selected_campaign_difficulty
);

// Apply starting conditions only when a valid
// difficulty has been explicitly selected.
if (is_struct(_profile))
{
    // Player resources
    engineering_hours = irandom_range(
        _profile.engineering_hours_min,
        _profile.engineering_hours_max
    );

    budget = irandom_range(
        _profile.budget_min,
        _profile.budget_max
    );

    morale = irandom_range(
        _profile.morale_min,
        _profile.morale_max
    );

    // Manufacturing conditions
    drc_violations = irandom_range(
        _profile.drc_violations_min,
        _profile.drc_violations_max
    );

    manufacturing_risk = irandom_range(
        _profile.manufacturing_risk_min,
        _profile.manufacturing_risk_max
    );

    // DFX starting values
    dfa = irandom_range(_profile.dfa_min, _profile.dfa_max);
    dfm = irandom_range(_profile.dfm_min, _profile.dfm_max);
    dft = irandom_range(_profile.dft_min, _profile.dft_max);

    // Sanity always starts at 100 for every difficulty
    sanity = _profile.sanity_start;

    // Diagnostic confirmation
    show_debug_message(
        "CAMPAIGN: Applied difficulty profile - "
        + get_campaign_difficulty_name(
            selected_campaign_difficulty
        )
    );
}

};


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
               
				// Permanent long-result regression case for UI testing
				result:
				    "The engineering team has completed the placement and "
				    + "routing rework required by the revised pin assignments."
				    + "\n\n"
				    + "Several critical connections required additional routing "
				    + "attention. The team reviewed trace clearances, routing "
				    + "constraints, and the manufacturing implications of the "
				    + "revised layout. Additional engineering hours were spent "
				    + "correcting the affected areas rather than accepting "
				    + "potential downstream fabrication problems."
				    + "\n\n"
				    + "The updated routing has been incorporated into the "
				    + "design. Manufacturing risk has been reviewed, and the "
				    + "project can proceed to its next engineering checkpoint. "
				    + "While the rework consumed valuable schedule resources, "
				    + "the team avoided releasing the original routing concerns "
				    + "into the next stage of development."


				  
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



 // --------------------------------------------------
 // CAMPAIGN PROGRESSION INITIALIZATION
 // --------------------------------------------------

 initialize_campaign_progress = function()
 {
     // Begin with the first engineering event
     current_event_index = 0;
	 
	// --------------------------------------------------
	// CAMPAIGN EVENT HISTORY AND PROJECT CONDITIONS
	// --------------------------------------------------

	// Events encountered during this campaign
	played_event_ids = [];

	// Persistent conditions created by player decisions
	project_flags = [];

	// Stage and encounter state for the future dynamic campaign
	// Do not select a new encounter until the stage pools are populated.
	current_event_stage = EventStage.PLANNING;
	active_encounter = undefined;

	// Temporary diagnostic: confirms initialization and restart reset
	show_debug_message(
	    "CAMPAIGN STATE: Dynamic encounter state initialized"
	);

	// Temporary initialization diagnostics
	show_debug_message(
	    "CAMPAIGN STATE: Played events = "
	    + string(array_length(played_event_ids))
	);

	show_debug_message(
	    "CAMPAIGN STATE: Project flags = "
	    + string(array_length(project_flags))
	);


     // Initial gameplay state
     event_active = true;
     event_resolved = false;

     // Clear pending progression requests
     continue_requested = false;

     // Reset campaign outcomes
     campaign_complete = false;
     campaign_failed = false;
     campaign_half_victory = false;
 };


/// @description Request progression to the next event

request_continue = function()
{
    // Reject progression when gameplay does not own input
    if (!screen_manager.can_receive_input(ScreenId.GAMEPLAY))
    {
        return;
    }

    // Only allow progression during the REVIEWING phase
    if (get_campaign_phase() != CampaignPhase.REVIEWING)
    {
        return;
    }

    // Register the request for the Step Event
    continue_requested = true;
};





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


 // --------------------------------------------------
 // CURRENT CAMPAIGN EVENT ACCESS
 // --------------------------------------------------

 // Prefer an active dynamic encounter when available.
 // Otherwise, preserve the existing four-event prototype.
 // Returns undefined if neither source has a valid event.
 get_current_campaign_event = function()
 {
     if (is_struct(active_encounter))
     {
         return active_encounter;
     }

     if (current_event_index >= 0
     && current_event_index < array_length(design_events))
     {
         return design_events[current_event_index];
     }

     return undefined;
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

// --------------------------------------------------
// CAMPAIGN MESSAGE INITIALIZATION
// --------------------------------------------------

initialize_campaign_messages = function()
{
    // Clear previous campaign failure information
    failure_reason = "";

    // Clear event and campaign messages
    game_message = "";
    result_message = "";
};


/// @description Reset decision result scrolling state

// --------------------------------------------------
// RESULT SCROLLING INITIALIZATION
// --------------------------------------------------

reset_result_scroll_state = function()
{
    // Reset the visible position of result text
    result_scroll_offset = 0;

    // Cancel any active scrollbar dragging
    result_scroll_dragging = false;

    // Clear the previous mouse grab position
    result_scroll_grab_offset = 0;
};



 // --------------------------------------------------
 // CAMPAIGN CALENDAR INITIALIZATION
 // --------------------------------------------------

 initialize_campaign_calendar = function()
 {
     // Project dates
     project_start_date = date_create_datetime(
         2027, 1, 4, 0, 0, 0
     );

     project_current_date = project_start_date;

     project_deadline_date = date_create_datetime(
         2027, 2, 8, 0, 0, 0
     );

     // Standard engineering workday
     hours_per_workday = 8;

     // Engineering time tracking
     project_work_hours_elapsed = 0;
     project_work_hours_today = 0;
     project_schedule_delay_days = 0;

     // Overdue Sanity penalty configuration
     overdue_sanity_penalty_per_day = 20;

     // Number of overdue workdays already penalized
     overdue_days_penalized = 0;
 };


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
	
	// Reject player decisions when gameplay does not own input
	if (!screen_manager.can_receive_input(ScreenId.GAMEPLAY))
	{
	    exit;
	}

	// Only process decisions during the CHOOSING phase
	if (get_campaign_phase() != CampaignPhase.CHOOSING)
	{
	    exit;
	}


    
	var _event = get_current_campaign_event();

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

// Track the Continue button belonging to this controller
continue_button_instance = noone;

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


   // Calculate button layout using the current campaign event
var _event = get_current_campaign_event();
var _choices = _event.choices;
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
		
		// --------------------------------------------------
		// CENTRALIZED CAMPAIGN STATE INITIALIZATION
		// --------------------------------------------------

		initialize_campaign_state = function()
		{
		    // Reset engineering resources and DFX values
		    initialize_campaign_stats();

		    // Reset dates, work hours, and overdue tracking
		    initialize_campaign_calendar();

		    // Reset event progression and campaign outcome
		    initialize_campaign_progress();

		    // Clear previous campaign messages
		    initialize_campaign_messages();

		    // Reset temporary results UI state
		    reset_result_scroll_state();
		};		

/// @description Start or restart a campaign

// --------------------------------------------------
// START CAMPAIGN
// --------------------------------------------------

start_campaign = function()
{
    // Reset all campaign-specific data
    initialize_campaign_state();




    // Rebuild choice buttons for the first event
    // This also removes the previous choice buttons
    refresh_choice_buttons();

    // Create a Continue button only if one does not exist
    if (!instance_exists(continue_button_instance))
    {
        continue_button_instance = instance_create_depth(
            0,
            0,
            depth - 1,
            obj_continue_button
        );
    }

    // Ensure the Continue button belongs to this controller
    continue_button_instance.controller = id;

    // Display gameplay after initialization
    screen_manager.navigate_to(ScreenId.GAMEPLAY);
};


// --------------------------------------------------
// INITIAL CONTROLLER STATE
// --------------------------------------------------

// Initialize campaign variables without starting gameplay.
// The campaign will start through the title/setup menu.

initialize_campaign_state();

// --------------------------------------------------
// TEMPORARY STAGE EVENT SELECTION TEST
// --------------------------------------------------

// Use separate test history and conditions.
// Do not modify the active campaign state.

var _test_played_ids = [];
var _test_flags = [];


// Test 1: Select our registered PCB Design event
var _test_first_event = select_next_stage_event(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (is_struct(_test_first_event))
{
    show_debug_message(
        "STAGE SELECTOR: First event = "
        + _test_first_event.id
    );

    // Simulate recording that event as played
    array_push(
        _test_played_ids,
        _test_first_event.id
    );
}


// Test 2: Confirm the event cannot repeat
var _test_second_event = select_next_stage_event(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (!is_struct(_test_second_event))
{
    show_debug_message(
        "STAGE SELECTOR: Played event excluded"
    );
}


// Test 3: Confirm empty stage pools are safe
var _test_empty_stage = select_next_stage_event(
    event_library,
    EventStage.FABRICATION,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (!is_struct(_test_empty_stage))
{
    show_debug_message(
        "STAGE SELECTOR: Empty stage handled"
    );
}


// --------------------------------------------------
// TEMPORARY CHOICE RANDOMIZATION TEST
// --------------------------------------------------

// Retrieve the permanent event definition
var _source_event = event_library.pcb_design[0];

// Create an independent, shuffled encounter
var _test_encounter = prepare_event_encounter(
    _source_event
);

// Display original first choice
show_debug_message(
    "CHOICE TEST: Original first = "
    + _source_event.choices[0].id
);

// Display shuffled choices and associated costs
for (
    var _i = 0;
    _i < array_length(_test_encounter.choices);
    _i++
)
{
    var _choice = _test_encounter.choices[_i];

    show_debug_message(
        "CHOICE TEST: Position "
        + string(_i + 1)
        + " = "
        + _choice.id
        + " | Hours = "
        + string(_choice.hours_cost)
    );
}

// Confirm the permanent library is unchanged
show_debug_message(
    "CHOICE TEST: Original still first = "
    + _source_event.choices[0].id
);


// --------------------------------------------------
// TEMPORARY COMPLETE ENCOUNTER PIPELINE TEST
// --------------------------------------------------

// Independent test history and conditions
var _pipeline_played = [];
var _pipeline_flags = [];

// Select and prepare the first encounter
var _pipeline_event = select_and_prepare_stage_encounter(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    _pipeline_played,
    _pipeline_flags
);

if (is_struct(_pipeline_event))
{
    show_debug_message(
        "ENCOUNTER PIPELINE: Selected = "
        + _pipeline_event.id
    );

    show_debug_message(
        "ENCOUNTER PIPELINE: Choices = "
        + string(array_length(_pipeline_event.choices))
    );

    // Simulate recording the event as played
    array_push(
        _pipeline_played,
        _pipeline_event.id
    );
}

// Check that the same event cannot be selected again
var _pipeline_next = select_and_prepare_stage_encounter(
    event_library,
    EventStage.PCB_DESIGN,
    CampaignDifficulty.MEDIUM,
    _pipeline_played,
    _pipeline_flags
);

if (!is_struct(_pipeline_next))
{
    show_debug_message(
        "ENCOUNTER PIPELINE: No repeat available"
    );
}

// --------------------------------------------------
// TEMPORARY CAMPAIGN ENCOUNTER SESSION TEST
// STEP 58, PART 2I
// --------------------------------------------------

// Test using an independent session object, not obj_game state.
var _session_test = {
    event_library: event_library,
    current_event_stage: EventStage.PCB_DESIGN,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: [],
    active_encounter: undefined
};

var _session_started = begin_campaign_encounter(_session_test);

if (_session_started && is_struct(_session_test.active_encounter))
{
    show_debug_message(
        "SESSION TEST: Active encounter = "
        + _session_test.active_encounter.id
    );

    show_debug_message(
        "SESSION TEST: Played count = "
        + string(array_length(_session_test.played_event_ids))
    );
}
else
{
    show_debug_message("SESSION TEST: Failed to begin encounter");
}

var _session_repeated = begin_campaign_encounter(_session_test);

if (!_session_repeated)
{
    show_debug_message("SESSION TEST: Repeat prevented");
}

show_debug_message(
    "SESSION TEST: Real campaign played count = "
    + string(array_length(played_event_ids))
);

// --------------------------------------------------
// TEMPORARY EVENT BRIDGE DIAGNOSTICS
// STEP 58, PART 2J
// --------------------------------------------------

// Confirm that normal gameplay still uses the legacy event.
var _bridge_legacy_event = get_current_campaign_event();

if (is_struct(_bridge_legacy_event))
{
    show_debug_message(
        "EVENT BRIDGE: Legacy = " + _bridge_legacy_event.title
    );
}

// Temporarily supply a prepared encounter for this test.
var _bridge_original_encounter = active_encounter;
active_encounter = prepare_event_encounter(event_library.pcb_design[0]);

var _bridge_dynamic_event = get_current_campaign_event();

if (is_struct(_bridge_dynamic_event))
{
    show_debug_message(
        "EVENT BRIDGE: Dynamic = " + _bridge_dynamic_event.id
    );
}

// Restore the original state before the first Step Event.
active_encounter = _bridge_original_encounter;

if (!is_struct(active_encounter)
&& is_struct(get_current_campaign_event()))
{
    show_debug_message("EVENT BRIDGE: Legacy restored");
}
