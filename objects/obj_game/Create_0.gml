// Set the game window to a landscape size
window_set_size(960, 540);

days_remaining = 25;
engineering_hours = 100;
budget = 100;
morale = 80;
drc_violations = 25;
manufacturing_readiness = 40;

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
                readiness_change: 0,
                result: "Rework selected. 12 hours spent."
            },
            {
                text: "Apply a quick patch",
                hours_cost: 4,
                days_cost: 0,
                readiness_change: -10,
                result: "Quick patch applied. Readiness -10%."
            },
            {
                text: "Request a design review",
                hours_cost: 2,
                days_cost: 1,
                readiness_change: 5,
                result: "Review requested. 2 hours and 1 day spent."
            }
        ]
		
	},
	
	{
		// NEW VIA SPACING EVENT
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
                readiness_change: 15,
                result:
                    "Via spacing corrected. Manufacturing readiness +15%."
            },

            {
                text: "Request a fabrication engineering review",
                hours_cost: 4,
                days_cost: 1,
                readiness_change: 5,
                result:
                    "Fabrication review completed. Readiness +5%."
            },

            {
                text: "Accept the risk and release artwork",
                hours_cost: 0,
                days_cost: 0,
                readiness_change: -20,
                result:
                    "Artwork released with unresolved via spacing risk. Readiness -20%."
            }
        ]
    }
];


// Track the active event.
current_event_index = 0;

event_active = true;
event_resolved = false;
campaign_complete = false;

game_message = "Choose your response below.";
result_message = "";