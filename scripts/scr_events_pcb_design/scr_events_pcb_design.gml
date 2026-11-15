
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

    _ignore.set_flags = ["cad_changes_unverified"];


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

    if (is_struct(_event))
    {
        array_push(_events, _event);
    }


    // --------------------------------------------------
    // PCB-0002: MISSING CONNECTIONS DETECTED
    // --------------------------------------------------

    var _audit = create_event_choice(
        "PCB-0002-A",
        "Audit the affected nets and repair the routing",
        "The missing connections have been restored. "
        + "The PCB is back in sync with the netlist."
    );

    _audit.hours_cost = 6;
    _audit.drc_change = -3;
    _audit.sanity_change = -4;

    _audit.clear_flags = ["cad_changes_unverified"];


    var _waive = create_event_choice(
        "PCB-0002-B",
        "Mark the discrepancies as known issues",
        "The discrepancies have been documented. "
        + "Unfortunately, documenting a missing connection "
        + "does not make the connection exist."
    );

    _waive.hours_cost = 1;
    _waive.drc_change = 4;
    _waive.risk_change = 5;
    _waive.sanity_change = -3;


    var _followup = create_decision_event(
        "PCB-0002",
        EventStage.MANUFACTURER_REVIEW,
        EventCategory.SETBACK,
        "NETLIST AUDIT: MISSING CONNECTIONS!",
        "The nightly netlist comparison has identified "
        + "connections that disappeared following the "
        + "CAD software crash. The electrical engineer "
        + "would like to know where they went.",
        [
            _audit,
            _waive
        ]
    );

    if (is_struct(_followup))
    {
        _followup.required_flags = [
            "cad_changes_unverified"
        ];

        _followup.is_consequence = true;

        array_push(_events, _followup);
    }


    // --------------------------------------------------
    // PCB-0003: STACKUP NOT APPROVED
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _stackup_standard = create_event_choice(
        "PCB-0003-A",
        "Adopt the fab's standard stackup",
        "The fabricator supplied a standard stackup. "
        + "Manufacturing risk has been reduced."
    );

    _stackup_standard.hours_cost = 4;
    _stackup_standard.dfm_change = 3;
    _stackup_standard.sanity_change = -2;


    var _stackup_verify = create_event_choice(
        "PCB-0003-B",
        "Recalculate impedance and update constraints",
        "The impedance calculations and design constraints "
        + "have been updated for the new materials."
    );

    _stackup_verify.hours_cost = 8;
    _stackup_verify.dfm_change = 5;
    _stackup_verify.sanity_change = -4;


    var _stackup_ignore = create_event_choice(
        "PCB-0003-C",
        "Continue with the preliminary stackup",
        "The project moves forward. The fabricator has "
        + "declined to guarantee the requested stackup."
    );

    _stackup_ignore.risk_change = 8;
    _stackup_ignore.dfm_change = -6;
    _stackup_ignore.sanity_change = -3;

    _stackup_ignore.set_flags = ["stackup_unapproved"];


    var _stackup_review = create_event_choice(
        "PCB-0003-D",
        "Schedule a fabrication and SI review",
        "The fabrication and signal integrity teams "
        + "have agreed on a revised stackup."
    );

    _stackup_review.hours_cost = 2;
    _stackup_review.days_cost = 1;
    _stackup_review.dfm_change = 3;
    _stackup_review.sanity_change = -2;


    var _stackup_event = create_decision_event(
        "PCB-0003",
        EventStage.DESIGN_SETUP,
        EventCategory.ENGINEERING,
        "STACKUP NOT APPROVED!",
        "Your fabricator cannot source the specified "
        + "prepreg for the eight-layer PCB. A substitute "
        + "is available, but controlled impedance has "
        + "not been verified. How will you proceed?",
        [
            _stackup_standard,
            _stackup_verify,
            _stackup_ignore,
            _stackup_review
        ]
    );

    if (is_struct(_stackup_event))
    {
        array_push(_events, _stackup_event);
    }


    // --------------------------------------------------
    // PCB-0004: ENCLOSURE REVISION RECEIVED
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _mechanical_update = create_event_choice(
        "PCB-0004-A",
        "Update the outline and mounting holes",
        "The PCB outline has been revised to match "
        + "the latest mechanical requirements."
    );

    _mechanical_update.hours_cost = 6;
    _mechanical_update.dfa_change = 4;
    _mechanical_update.sanity_change = -3;


    var _mechanical_review = create_event_choice(
        "PCB-0004-B",
        "Request a formal mechanical change review",
        "The mechanical team has approved a revised "
        + "interface and documented the changes."
    );

    _mechanical_review.hours_cost = 2;
    _mechanical_review.days_cost = 1;
    _mechanical_review.dfa_change = 2;
    _mechanical_review.sanity_change = -2;


    var _mechanical_shortcut = create_event_choice(
        "PCB-0004-C",
        "Slot the holes and move on",
        "The mounting holes have been modified. "
        + "Mechanical fit has not been verified."
    );

    _mechanical_shortcut.hours_cost = 1;
    _mechanical_shortcut.dfa_change = -6;
    _mechanical_shortcut.risk_change = 5;
    _mechanical_shortcut.sanity_change = -4;

    _mechanical_shortcut.set_flags = [
        "mechanical_fit_unverified"
    ];


    var _mechanical_joint_review = create_event_choice(
        "PCB-0004-D",
        "Hold a joint ECAD/MCAD review",
        "Electrical and mechanical engineering "
        + "have agreed on the revised board geometry."
    );

    _mechanical_joint_review.hours_cost = 4;
    _mechanical_joint_review.days_cost = 1;
    _mechanical_joint_review.dfa_change = 5;
    _mechanical_joint_review.dfm_change = 2;
    _mechanical_joint_review.sanity_change = -2;


    var _mechanical_event = create_decision_event(
        "PCB-0004",
        EventStage.DESIGN_SETUP,
        EventCategory.ENGINEERING,
        "ENCLOSURE REVISION RECEIVED!",
        "Mechanical engineering revised the enclosure. "
        + "Two mounting holes no longer align, and the "
        + "board outline conflicts with a keepout. "
        + "The deadline has not moved.",
        [
            _mechanical_update,
            _mechanical_review,
            _mechanical_shortcut,
            _mechanical_joint_review
        ]
    );

    if (is_struct(_mechanical_event))
    {
        array_push(_events, _mechanical_event);
    }


    return _events;
}
