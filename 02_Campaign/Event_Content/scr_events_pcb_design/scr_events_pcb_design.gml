
/// @description PCB Design stage event definitions

// --------------------------------------------------
// CREATE PCB DESIGN EVENT POOL
// --------------------------------------------------

function create_pcb_design_event_pool()
{
    var _events = [];

    // --------------------------------------------------
    // PCB-0001: CAD SOFTWARE CRASH
    // Stage: ROUTING
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

    
	_ignore.drc_change = 3;
	_ignore.risk_change = 2;
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
    // Stage: MANUFACTURER REVIEW
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

    // --------------------------------------------------
    // PCB-0005: CONNECTOR ON BACKORDER
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _connector_alternate = create_event_choice(
        "PCB-0005-A",
        "Qualify an alternate connector",
        "An available connector has passed the initial "
        + "engineering review. The BOM is updated."
    );

    _connector_alternate.hours_cost = 6;
    _connector_alternate.dfm_change = 3;
    _connector_alternate.risk_change = -2;
    _connector_alternate.sanity_change = -3;

    var _connector_premium = create_event_choice(
        "PCB-0005-B",
        "Authorize a premium purchase",
        "Purchasing located a limited quantity of the "
        + "original connector. Finance is displeased."
    );

    _connector_premium.hours_cost = 1;
    _connector_premium.days_cost = 1;
    _connector_premium.budget_change = -15;
    _connector_premium.sanity_change = -1;

    var _connector_redesign = create_event_choice(
        "PCB-0005-C",
        "Redesign around an available connector",
        "The connector interface has been redesigned "
        + "around an available production component."
    );

    _connector_redesign.hours_cost = 10;
    _connector_redesign.dfa_change = 4;
    _connector_redesign.dfm_change = 2;
    _connector_redesign.sanity_change = -4;

    var _connector_ignore = create_event_choice(
        "PCB-0005-D",
        "Keep the original BOM and hope for the best",
        "The original connector remains on the BOM. "
        + "Purchasing has expressed serious concerns."
    );

    _connector_ignore.risk_change = 7;
    _connector_ignore.dfm_change = -5;
    _connector_ignore.sanity_change = -3;
    _connector_ignore.set_flags = [
        "connector_supply_unresolved"
    ];

    var _connector_event = create_decision_event(
        "PCB-0005",
        EventStage.DESIGN_SETUP,
        EventCategory.RESOURCE,
        "CONNECTOR ON BACKORDER!",
        "Purchasing reports that the specified board "
        + "connector has a 26-week lead time. Production "
        + "cannot wait that long. An alternate component "
        + "or redesign may be required. What will you do?",
        [
            _connector_alternate,
            _connector_premium,
            _connector_redesign,
            _connector_ignore
        ]
    );

    if (is_struct(_connector_event))
    {
        array_push(_events, _connector_event);
    }

    // --------------------------------------------------
    // PCB-0006: COMPONENT FOOTPRINT DISCREPANCY
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _footprint_verify = create_event_choice(
        "PCB-0006-A",
        "Verify the dimensions and correct the footprint",
        "The pad geometry now matches the manufacturer's "
        + "recommended land pattern."
    );

    _footprint_verify.hours_cost = 5;
    _footprint_verify.dfm_change = 4;
    _footprint_verify.risk_change = -2;
    _footprint_verify.sanity_change = -3;

    var _footprint_library = create_event_choice(
        "PCB-0006-B",
        "Request a CAD library and supplier review",
        "The CAD librarian and supplier confirmed the "
        + "correct footprint and revision."
    );

    _footprint_library.hours_cost = 3;
    _footprint_library.days_cost = 1;
    _footprint_library.dfm_change = 4;
    _footprint_library.sanity_change = -2;

    var _footprint_replace = create_event_choice(
        "PCB-0006-C",
        "Replace the part with a verified alternative",
        "The new component uses an approved footprint. "
        + "Purchasing has updated the BOM."
    );

    _footprint_replace.hours_cost = 7;
    _footprint_replace.budget_change = -8;
    _footprint_replace.dfm_change = 2;
    _footprint_replace.sanity_change = -4;

    var _footprint_ignore = create_event_choice(
        "PCB-0006-D",
        "Accept the existing footprint without review",
        "The design proceeds with an unverified land "
        + "pattern. Assembly problems may surface later."
    );

    _footprint_ignore.drc_change = 3;
    _footprint_ignore.risk_change = 8;
    _footprint_ignore.dfm_change = -6;
    _footprint_ignore.sanity_change = -3;
    _footprint_ignore.set_flags = [
        "footprint_unverified"
    ];

    var _footprint_event = create_decision_event(
        "PCB-0006",
        EventStage.DESIGN_SETUP,
        EventCategory.ENGINEERING,
        "COMPONENT FOOTPRINT DISCREPANCY!",
        "The CAD librarian discovered that the "
        + "connector footprint has a pad pitch that "
        + "does not match the manufacturer's latest "
        + "drawing. Placement has not started. "
        + "How will you resolve the discrepancy?",
        [
            _footprint_verify,
            _footprint_library,
            _footprint_replace,
            _footprint_ignore
        ]
    );

    if (is_struct(_footprint_event))
    {
        array_push(_events, _footprint_event);
    }

    // --------------------------------------------------
    // PCB-0007: DRILL SIZE NOT SUPPORTED
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _drill_redesign = create_event_choice(
        "PCB-0007-A",
        "Redesign the vias for supported drill sizes",
        "The via definitions have been updated to match "
        + "the fabricator's capabilities."
    );

    _drill_redesign.hours_cost = 6;
    _drill_redesign.dfm_change = 4;
    _drill_redesign.drc_change = -2;
    _drill_redesign.sanity_change = -3;

    var _drill_review = create_event_choice(
        "PCB-0007-B",
        "Ask the fabricator to review alternate processes",
        "The CAM team proposed a manufacturable "
        + "alternative for the affected vias."
    );

    _drill_review.hours_cost = 3;
    _drill_review.days_cost = 1;
    _drill_review.dfm_change = 3;
    _drill_review.sanity_change = -2;

    var _drill_microvia = create_event_choice(
        "PCB-0007-C",
        "Evaluate laser microvias with the fabricator",
        "A laser-drilled alternative is approved, "
        + "but production costs have increased."
    );

    _drill_microvia.hours_cost = 8;
    _drill_microvia.budget_change = -10;
    _drill_microvia.dfm_change = 2;
    _drill_microvia.sanity_change = -4;

    var _drill_ignore = create_event_choice(
        "PCB-0007-D",
        "Keep the drill specification and proceed",
        "The unsupported drill sizes remain in the "
        + "design database. CAM has been warned."
    );

    _drill_ignore.risk_change = 8;
    _drill_ignore.dfm_change = -6;
    _drill_ignore.sanity_change = -3;
    _drill_ignore.set_flags = [
        "drill_capability_unresolved"
    ];

    var _drill_event = create_decision_event(
        "PCB-0007",
        EventStage.DESIGN_SETUP,
        EventCategory.ENGINEERING,
        "DRILL SIZE NOT SUPPORTED!",
        "The fabricator reports that the specified "
        + "via drill size is below its manufacturing "
        + "limit. Routing has not started. "
        + "How will you resolve the problem?",
        [
            _drill_redesign,
            _drill_review,
            _drill_microvia,
            _drill_ignore
        ]
    );

    if (is_struct(_drill_event))
    {
        array_push(_events, _drill_event);
    }

    // --------------------------------------------------
    // PCB-0008: CLEARANCE REQUIREMENTS MISSING
    // Stage: DESIGN SETUP
    // --------------------------------------------------

    var _clearance_review = create_event_choice(
        "PCB-0008-A",
        "Obtain approved creepage and clearance values",
        "Electrical engineering supplied reviewed "
        + "clearance requirements for the power section."
    );

    _clearance_review.hours_cost = 6;
    _clearance_review.days_cost = 1;
    _clearance_review.dfm_change = 5;
    _clearance_review.sanity_change = -2;

    var _clearance_conservative = create_event_choice(
        "PCB-0008-B",
        "Expand the keepouts pending engineering approval",
        "Conservative placement keepouts have been "
        + "applied pending final electrical approval."
    );

    _clearance_conservative.hours_cost = 5;
    _clearance_conservative.dfa_change = -2;
    _clearance_conservative.dfm_change = 2;
    _clearance_conservative.sanity_change = -3;
    _clearance_conservative.set_flags = [
        "clearance_review_pending"
    ];

    var _clearance_escalate = create_event_choice(
        "PCB-0008-C",
        "Escalate the missing requirements to the tech lead",
        "The tech lead assigned an owner to resolve "
        + "the missing requirements before release."
    );

    _clearance_escalate.hours_cost = 2;
    _clearance_escalate.days_cost = 1;
    _clearance_escalate.morale_change = -2;
    _clearance_escalate.sanity_change = -2;
    _clearance_escalate.set_flags = [
        "clearance_review_pending"
    ];

    var _clearance_ignore = create_event_choice(
        "PCB-0008-D",
        "Use the default CAD clearance rules",
        "The design proceeds without verified "
        + "high-voltage clearance requirements."
    );

    _clearance_ignore.hours_cost = 1;
    _clearance_ignore.risk_change = 9;
    _clearance_ignore.dfm_change = -7;
    _clearance_ignore.sanity_change = -4;
    _clearance_ignore.set_flags = [
        "clearance_unverified"
    ];

    var _clearance_event = create_decision_event(
        "PCB-0008",
        EventStage.DESIGN_SETUP,
        EventCategory.ENGINEERING,
        "CLEARANCE REQUIREMENTS MISSING!",
        "The electrical engineer has not supplied "
        + "the clearance requirements for the power "
        + "section. Placement cannot be finalized "
        + "confidently. What will you do?",
        [
            _clearance_review,
            _clearance_conservative,
            _clearance_escalate,
            _clearance_ignore
        ]
    );

    if (is_struct(_clearance_event))
    {
        array_push(_events, _clearance_event);
    }

    return _events;
}
