/// @description PCB Design stage event definitions

// --------------------------------------------------
// CREATE PCB DESIGN EVENT POOL
// --------------------------------------------------

function create_pcb_design_event_pool()
{
    var _events = [];

    // --------------------------------------------------
    // PCB-0001: CAD SOFTWARE CRASH
    // --------------------------------------------------

    var _restore = create_event_choice(
        "PCB-0001-A",
        "Restore the last autosave",
        "The design was recovered. Mostly."
    );

    _restore.hours_cost = 3;
    _restore.sanity_change = -3;


    var _rebuild = create_event_choice(
        "PCB-0001-B",
        "Manually reconstruct the affected routing",
        "The routing was reconstructed. Your weekend was not."
    );

    _rebuild.hours_cost = 7;
    _rebuild.dfm_change = 3;
    _rebuild.sanity_change = -5;


    var _support = create_event_choice(
        "PCB-0001-C",
        "Open a support ticket and request assistance",
        "Support has requested a screenshot of the error "
        + "that disappeared when the software crashed."
    );

    _support.hours_cost = 1;
    _support.days_cost = 1;
    _support.morale_change = -2;
    _support.sanity_change = -2;


    var _ignore = create_event_choice(
        "PCB-0001-D",
        "Declare the missing changes nonessential",
        "Management has accepted your explanation. "
        + "The design database has declined to comment."
    );

    _ignore.risk_change = 8;
    _ignore.dfm_change = -5;
    _ignore.sanity_change = -4;

    // Record a condition for potential future events.
    _ignore.set_flags = ["cad_changes_unverified"];


    // --------------------------------------------------
    // BUILD STANDARDIZED EVENT
    // --------------------------------------------------

    var _event = create_decision_event(
        "PCB-0001",
        EventStage.ROUTING,
        EventCategory.SETBACK,
        "CAD SOFTWARE HAS STOPPED RESPONDING!",
        "Your PCB design software crashed during routing. "
        + "The most recent autosave is suspiciously old. "
        + "How will you proceed?",
        [
            _restore,
            _rebuild,
            _support,
            _ignore
        ]
    );

    // Only add events that pass schema validation.
    if (is_struct(_event))
    {
        array_push(_events, _event);
    }

    return _events;
}
