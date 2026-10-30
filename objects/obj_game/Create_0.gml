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
    }
];

// Track the active event.
current_event_index = 0;

event_active = true;
event_resolved = false;

game_message = "Choose your response below.";
result_message = "";