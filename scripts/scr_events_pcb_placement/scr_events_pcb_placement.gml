
/// @description PCB Placement stage event definitions

// --------------------------------------------------
// CREATE PCB PLACEMENT EVENT POOL
// --------------------------------------------------

function create_pcb_placement_event_pool()
{
    var _events = [];

    // --------------------------------------------------
    // PCB-0009: ASSEMBLY ACCESS CONFLICT
    // Stage: PLACEMENT
    // --------------------------------------------------

    // OPTION A: Correct the component placement

    var _reposition = create_event_choice(
        "PCB-0009-A",
        "Reposition the capacitor and nearby components",
        "The component placement has been revised. "
        + "Assembly tooling now has sufficient access."
    );

    _reposition.hours_cost = 6;
    _reposition.dfa_change = 5;
    _reposition.dfm_change = 2;
    _reposition.sanity_change = -3;


    // OPTION B: Coordinate with assembly engineering

    var _tooling_review = create_event_choice(
        "PCB-0009-B",
        "Ask assembly to qualify alternate tooling",
        "Assembly engineering approved an alternate "
        + "tooling process. Production costs increased."
    );

    _tooling_review.hours_cost = 3;
    _tooling_review.days_cost = 1;
    _tooling_review.budget_change = -5;
    _tooling_review.dfa_change = 2;
    _tooling_review.sanity_change = -2;


    // OPTION C: Replace the tall component

    var _replace_component = create_event_choice(
        "PCB-0009-C",
        "Replace the capacitor with a low-profile part",
        "A lower-profile capacitor has been approved. "
        + "The BOM and placement have been updated."
    );

    _replace_component.hours_cost = 8;
    _replace_component.budget_change = -8;
    _replace_component.dfa_change = 4;
    _replace_component.dfm_change = 3;
    _replace_component.sanity_change = -4;


    // OPTION D: Accept the assembly risk

    var _manual_assembly = create_event_choice(
        "PCB-0009-D",
        "Accept manual assembly and keep the placement",
        "The placement remains unchanged. Assembly "
        + "has warned that manual intervention may "
        + "increase production defects and costs."
    );

    _manual_assembly.hours_cost = 1;
    _manual_assembly.dfa_change = -6;
    _manual_assembly.risk_change = 7;
    _manual_assembly.sanity_change = -3;

    _manual_assembly.set_flags = [
        "assembly_access_unverified"
    ];


    // --------------------------------------------------
    // BUILD STANDARDIZED EVENT
    // --------------------------------------------------

    var _assembly_event = create_decision_event(
        "PCB-0009",
        EventStage.PLACEMENT,
        EventCategory.ENGINEERING,
        "ASSEMBLY ACCESS CONFLICT!",
        "Assembly reports that a tall capacitor blocks "
        + "pick-and-place access to nearby SMD parts. "
        + "Production needs a solution before placement "
        + "is frozen.",
        [
            _reposition,
            _tooling_review,
            _replace_component,
            _manual_assembly
        ]
    );

    if (is_struct(_assembly_event))
    {
        array_push(_events, _assembly_event);
    }


    return _events;
}
