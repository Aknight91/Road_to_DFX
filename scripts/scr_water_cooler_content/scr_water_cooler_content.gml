/// @description Water Cooler - scalable milestone-specific chat content
// Add or revise conversation data here. Input/state/renderers need no edits.

function water_cooler_stage_label(_stage)
{
    switch (_stage)
    {
        case EventStage.DESIGN_SETUP: return "DESIGN SETUP";
        case EventStage.PLACEMENT: return "PLACEMENT";
        case EventStage.ROUTING: return "ROUTING";
        case EventStage.MANUFACTURER_REVIEW: return "MANUFACTURER REVIEW";
        case EventStage.RELEASE: return "RELEASE";
    }
    return "PROJECT STAGE";
}

// All future chat scenarios can be added as data here, without touching
// input, screen navigation, campaign processing, or button geometry.
// These numbers are PROVISIONAL for initial mechanics testing.
function water_cooler_get_options(_stage)
{
    return [
        {
            id: "TAKE_BREAK",
            text: "Take a short breather",
            description: "Get away from the CAD tool for a minute.",
            hours_cost: 1,
            sanity_change: 5,
            risk_change: 0,
            result: "A quiet break helps clear your head."
        },
        {
            id: "VENT",
            text: "Vent about the project deadline",
            description: "Share the frustrations, then get back to work.",
            hours_cost: 2,
            sanity_change: 10,
            risk_change: 0,
            result: "Your coworkers understand the pressure. The conversation helps."
        },
        {
            id: "FAB_STORIES",
            text: "Compare production-floor horror stories",
            description: "Pick up a practical manufacturing tip; not relaxing.",
            hours_cost: 2,
            sanity_change: -2,
            risk_change: -2,
            result: "A coworker shares a practical way to avoid a fab problem. The stories are stressful."
        }
    ];
}

