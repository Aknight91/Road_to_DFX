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

// Calculate manufacturing readiness
calculate_manufacturing_readiness = function()
{
    manufacturing_readiness = clamp(
        100 - (drc_violations * 2) - manufacturing_risk,
        0,
        100
    );
};

// Set initial manufacturing readiness
calculate_manufacturing_readiness();

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
		sanity_change: -100,
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
		sanity_change: -100,
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
		sanity_change: -100,
        result: "Design review completed. Routing concerns reduced."
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
    }
];


// Track the active event.
current_event_index = 0;

event_active = true;
event_resolved = false;

campaign_complete = false;
campaign_failed = false;

required_readiness = 50;
failure_reason = "";

game_message = "Choose your response below.";
result_message = "";