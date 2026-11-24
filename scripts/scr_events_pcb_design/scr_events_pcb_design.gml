/// @description PCB database design setup / project intake events
// Only EventStage.DESIGN_SETUP events belong here. Placement and routing
// are independent project stages even though both are PCB design work.
// The existing EventStage enum is intentionally unchanged.

function create_pcb_design()
{
    var _specs = [
        {
            id: "PCB-0003",
            category: EventCategory.ENGINEERING,
            title: "STACKUP: EIGHT LAYERS OF GUESSWORK",
            description: "The engineer sent an eight-layer requirement but no approved stackup. Apparently 'eight' was the entire material specification. The CAD database needs real layers, materials and impedance constraints before this becomes an expensive sandwich.",
            choices: [
                {
                    text: "Use the fab's reviewed standard stackup",
                    result: "The fabricator supplies a qualified stackup. You now have actual dielectric thicknesses instead of a number someone typed in an email.",
                    hours_cost: 4,
                    dfm_change: 3,
                    sanity_change: -2
                },
                {
                    text: "Rebuild the requirements and verify impedance",
                    result: "You reconstruct and verify the stackup. Eight layers, hundreds of calculations, and one suspiciously quiet kickoff engineer.",
                    hours_cost: 8,
                    dfm_change: 5,
                    sanity_change: -4
                },
                {
                    text: "Borrow the last project's stackup. Close enough.",
                    result: "You import the old stackup. It has eight layers too, which is apparently all the evidence this plan requires. Impedance remains unverified.",
                    risk_change: 8,
                    dfm_change: -6,
                    sanity_change: -3,
                    set_flags: ["stackup_unapproved"]
                },
                {
                    text: "Get EE, SI and fabrication in one meeting",
                    result: "The three teams agree on a stackup. An interdepartmental meeting has produced a usable file, alarming everyone involved.",
                    hours_cost: 2,
                    days_cost: 1,
                    dfm_change: 3,
                    sanity_change: -2
                }
            ]
        },
        {
            id: "PCB-0004",
            category: EventCategory.ENGINEERING,
            title: "MECHANICAL FILES: ATTACHMENT NOT FOUND",
            description: "The database needs a board outline, mounting holes and keepouts. Engineering supplied no STEP, DXF or approved drawing, just a few dimensions in an email. The placement start date, however, arrived perfectly intact.",
            choices: [
                {
                    text: "Rebuild the outline from approved dimensions",
                    result: "You reconstruct the geometry from approved dimensions. The board now has an outline, unlike the original handoff plan.",
                    hours_cost: 6,
                    dfa_change: 4,
                    sanity_change: -3
                },
                {
                    text: "Request the missing files and correct revisions",
                    result: "Mechanical engineering sends the approved files. Apparently they were in a folder called FINAL_FINAL_USE_THIS_ONE.",
                    hours_cost: 2,
                    days_cost: 1,
                    dfa_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Reuse an old outline and call it a head start",
                    result: "The previous outline imports beautifully. Whether it fits this enclosure is a question for future archaeologists.",
                    hours_cost: 1,
                    risk_change: 5,
                    dfa_change: -6,
                    sanity_change: -4,
                    set_flags: ["mechanical_fit_unverified"]
                },
                {
                    text: "Hold a joint ECAD/MCAD review",
                    result: "Electrical and mechanical teams approve the same geometry. Someone suggests putting the revision in the filename next time.",
                    hours_cost: 4,
                    days_cost: 1,
                    dfa_change: 5,
                    dfm_change: 2,
                    sanity_change: -2
                }
            ]
        },
        {
            id: "PCB-0006",
            category: EventCategory.ENGINEERING,
            title: "FOOTPRINT PITCH: A SMALL TYPO WITH PADS",
            description: "The connector footprint disagrees with the supplier drawing on pad pitch. It is only a fraction of a millimeter, so naturally it can ruin an entire assembly lot. Placement has not started yet.",
            choices: [
                {
                    text: "Verify dimensions and correct the footprint",
                    result: "The land pattern now matches the supplier data. A tiny correction prevents a very large tray of scrap.",
                    hours_cost: 5,
                    risk_change: -2,
                    dfm_change: 4,
                    sanity_change: -3
                },
                {
                    text: "Have CAD library and supplier verify the revision",
                    result: "The librarian and supplier agree on the footprint. The correct revision finally escapes a five-email reply-all chain.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 4,
                    sanity_change: -2
                },
                {
                    text: "Switch to a verified alternative part",
                    result: "The replacement has an approved footprint and BOM entry. Purchasing mourns the simplicity of the original order.",
                    hours_cost: 7,
                    budget_change: -8,
                    dfm_change: 2,
                    sanity_change: -4
                },
                {
                    text: "Accept the footprint; fractions are tiny",
                    result: "The unverified pads stay. Assembly has been assigned an exciting future mystery involving solder joints.",
                    drc_change: 3,
                    risk_change: 8,
                    dfm_change: -6,
                    sanity_change: -3,
                    set_flags: ["footprint_unverified"]
                }
            ]
        },
        {
            id: "PCB-0008",
            category: EventCategory.ENGINEERING,
            title: "CLEARANCE RULES: ENTER YOUR OWN ADVENTURE",
            description: "The electrical engineer forgot the power-section creepage and clearance requirements. The CAD default looks reassuring, which is exactly how unsafe assumptions like to dress.",
            choices: [
                {
                    text: "Get approved creepage and clearance values",
                    result: "Electrical engineering supplies reviewed limits. The database now distinguishes electrical safety from optimistic spacing.",
                    hours_cost: 6,
                    days_cost: 1,
                    dfm_change: 5,
                    sanity_change: -2
                },
                {
                    text: "Use conservative keepouts until approval",
                    result: "You expand the keepouts pending approval. Placement gets tighter, but at least electricity has fewer shortcuts.",
                    hours_cost: 5,
                    dfa_change: -2,
                    dfm_change: 2,
                    sanity_change: -3,
                    set_flags: ["clearance_review_pending"]
                },
                {
                    text: "Escalate the missing requirements",
                    result: "The tech lead assigns an owner. The issue now has a meeting, a tracking number, and a chance of becoming actual requirements.",
                    hours_cost: 2,
                    days_cost: 1,
                    morale_change: -2,
                    sanity_change: -2,
                    set_flags: ["clearance_review_pending"]
                },
                {
                    text: "Use CAD defaults. The software seems confident.",
                    result: "The design proceeds without verified high-voltage spacing. The default rule was not invited to the safety review for good reason.",
                    hours_cost: 1,
                    risk_change: 9,
                    dfm_change: -7,
                    sanity_change: -4,
                    set_flags: ["clearance_unverified"]
                }
            ]
        },
        {
            id: "PCB-0042",
            category: EventCategory.RESOURCE,
            title: "KICKOFF PACKAGE: NOW WITH LESS CONTENT",
            description: "The project folder contains neither a current netlist nor an approved BOM. The engineer swears both were attached. You check the email. There is a signature, a company logo, and enormous confidence.",
            choices: [
                {text: "Request the controlled netlist and BOM", result: "You get the current, revision-controlled files. The database can finally be built from deliverables rather than folklore.", hours_cost: 3, days_cost: 1, dft_change: 2, sanity_change: -2},
                {text: "Reconcile what arrived against the schematic", result: "You piece together the available inputs and flag the gaps. Your detective skills were not listed in the job description.", hours_cost: 6, dft_change: 2, sanity_change: -4},
                {text: "Use the previous revision and get moving", result: "The old files load immediately. So do all the reasons they were superseded; those will arrive later.", hours_cost: 1, risk_change: 6, dft_change: -4, sanity_change: -3, set_flags: ["design_inputs_unverified"]}
            ]
        },
        {
            id: "PCB-0043",
            category: EventCategory.RESOURCE,
            title: "SCHEMATIC NOT READY. DEADLINE IS.",
            description: "Database work starts today, according to the schedule. The electrical engineer is still changing the schematic and will not release inputs. Management has decided the due date is a separate discipline.",
            choices: [
                {text: "Agree on a real input freeze and await approval", result: "Engineering commits to a controlled handoff. It costs time, but you are no longer routing a moving target in advance.", hours_cost: 2, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Escalate the blocked handoff to the lead", result: "The project lead takes ownership of the delay. The schedule finally meets the deliverables it has been ignoring.", hours_cost: 3, days_cost: 1, sanity_change: -2},
                {text: "Build from the draft and pray revisions stop", result: "You start the database from an uncontrolled schematic. At least the next ECO will have something concrete to destroy.", hours_cost: 1, risk_change: 6, dfm_change: -2, sanity_change: -3, set_flags: ["schematic_handoff_unverified"]}
            ]
        },
        {
            id: "PCB-0044",
            category: EventCategory.RESOURCE,
            title: "ONE DESIGNER. TWO CUSTOMER DEADLINES.",
            description: "Two customers booked the same database kickoff, and project management assigned both to you. Neither delivery date may move. The resource plan apparently assumes you have a second identical twin.",
            choices: [
                {text: "Negotiate priorities and a workable schedule", result: "The teams agree on an actual sequence. You remain one person, a constraint management reluctantly accepts.", hours_cost: 2, days_cost: 1, sanity_change: -2},
                {text: "Request CAD help for intake preparation", result: "Additional CAD support is assigned. The resource chart now contains more than a wish and your name twice.", hours_cost: 4, sanity_change: -3},
                {text: "Accept both deadlines; skip the boring checks", result: "Both customers hear yes. The intake checks hear goodbye. This will make an excellent root-cause slide.", hours_cost: 1, risk_change: 5, dfm_change: -2, sanity_change: -5, set_flags: ["intake_checks_skipped"]}
            ]
        }
    ];

    return create_events_from_pack(EventStage.DESIGN_SETUP, _specs);
}

// Retain the legacy entry point for regression tests and older references.
function create_pcb_design_event_pool()
{
    return create_pcb_design();
}
