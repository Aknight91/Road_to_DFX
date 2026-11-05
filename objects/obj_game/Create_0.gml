
// Set the game window to a landscape size
window_set_size(960, 540);


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
                dfa_change: 0,
                dfm_change: 10,
                dft_change: 0,
                sanity_change: -8,
                result: "Rework selected. Routing corrected. DFM improved."
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
	}

    ,
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

campaign_complete = false;
campaign_failed = false;

required_dfa = 50;
required_dfm = 50;
required_dft = 50;
required_sanity = 1;
failure_reason = "";

game_message = "Choose your response below.";
result_message = "";


 // --------------------------------------------------
 // PROJECT CALENDAR SYSTEM
 // --------------------------------------------------

 // Temporary dates for mechanics testing
 project_start_date = date_create_datetime(2027, 1, 4, 0, 0, 0);
 project_current_date = project_start_date;
 project_deadline_date = date_create_datetime(2027, 2, 8, 0, 0, 0);

 // Standard engineering workday
 hours_per_workday = 8;

 // Track engineering time consumed
 project_work_hours_elapsed = 0;
 project_work_hours_today = 0;



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
