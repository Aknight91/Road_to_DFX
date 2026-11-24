/// @description PCB Manufacturer Review: CAM and fabrication event pool
// Stage-specific content only; uses existing event schema and campaign selector.
// Do not add event-selection logic, balancing systems, or release shortcuts here.

function create_pcb_manufacturer_review()
{
    var _specs = [
        {
            id: "PCB-0002",
            title: "NETLIST AUDIT: CONNECTIONS HAVE VANISHED",
            description: "CAM compares the routed database to the netlist after the CAD crash and finds missing electrical connections. The nets did not move. They simply ceased to exist, which management is calling a documentation discrepancy.",
            choices: [
                {
                    text: "Audit and repair every missing connection",
                    result: "You repair and verify the missing nets. The board can now conduct electricity through paths that actually exist.",
                    hours_cost: 6,
                    drc_change: -3,
                    sanity_change: -4,
                    clear_flags: ["cad_changes_unverified"]
                },
                {
                    text: "Record the missing connections as known issues",
                    result: "The nets are still missing. They now have issue numbers, which is reassuring only if you have never powered a PCB.",
                    hours_cost: 1,
                    drc_change: 4,
                    risk_change: 5,
                    sanity_change: -3
                }
            ],
            category: EventCategory.SETBACK,
            required_flags: ["cad_changes_unverified"],
            is_consequence: true
        },
        {
            id: "PCB-0045",
            title: "DRILL FILES AND GERBERS ARE NO LONGER SPEAKING",
            description: "CAM finds seventeen drill hits with no matching copper features. The files were exported from the same project, allegedly. Manufacturing would like to know which revision is the real one before the drill press finds out.",
            choices: [
                {
                    text: "Regenerate the outputs and verify the drill map",
                    result: "The drill map and copper data now agree. Seventeen holes have been returned to the universe they were designed for.",
                    hours_cost: 5,
                    drc_change: -3,
                    risk_change: -2,
                    dfm_change: 2,
                    sanity_change: -3
                },
                {
                    text: "Request a CAM comparison and controlled re-export",
                    result: "CAM identifies the mismatch and signs off the corrected output set. The formal review was worth its weight in avoided scrap.",
                    hours_cost: 3,
                    days_cost: 1,
                    drc_change: -1,
                    risk_change: -1,
                    sanity_change: -2
                },
                {
                    text: "Tell the fabricator to use whichever file looks newer",
                    result: "The machine operators have received your philosophy of revision control. The scrap bin has requested additional capacity.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfm_change: -5,
                    sanity_change: -3,
                    set_flags: ["drill_output_mismatch_unresolved"]
                }
            ]
        },
        {
            id: "PCB-0046",
            title: "SOLDER MASK DAMS: AN IMAGINARY FEATURE",
            description: "The fabricator cannot hold the microscopic solder-mask webs between fine-pitch pads. In CAD they look excellent. Under an actual solder stencil, they look like a career development exercise.",
            choices: [
                {
                    text: "Revise the mask openings to supported dimensions",
                    result: "The mask geometry now matches what the fabricator can actually print. Assembly no longer needs to believe in invisible barriers.",
                    hours_cost: 4,
                    dfm_change: 3,
                    dfa_change: 2,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Have the fab and assembly teams qualify an alternate",
                    result: "The teams approve a controlled mask process and document the assembly risk. The word controlled is doing useful work for once.",
                    hours_cost: 2,
                    days_cost: 1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Keep the mask drawing and hope solder respects it",
                    result: "The solder will be free to bridge the pads without interference from the mask webs that do not exist.",
                    hours_cost: 1,
                    risk_change: 6,
                    dfm_change: -5,
                    sanity_change: -3,
                    set_flags: ["solder_mask_web_unresolved"]
                }
            ]
        },
        {
            id: "PCB-0047",
            title: "ANNULAR RINGS FAIL THE FABRICATOR'S REALITY CHECK",
            description: "CAM flags drilled holes with less annular ring than the shop can reliably hold. The drawing says the holes are centered. The drill spindle has never signed that agreement.",
            choices: [
                {
                    text: "Increase ring clearance and regenerate fabrication data",
                    result: "The drill-to-pad geometry is corrected and the fab review passes. Mechanical tolerance has returned to the design process.",
                    hours_cost: 5,
                    drc_change: -2,
                    dfm_change: 3,
                    risk_change: -2,
                    sanity_change: -3
                },
                {
                    text: "Review registration capability with CAM",
                    result: "CAM approves a qualified modification and records the tolerance assumptions. At least one person has consulted a machine specification.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Waive the breakout risk because nominal looks fine",
                    result: "The minimum annular ring is now a positive-thinking initiative. Yield engineering is drafting its response.",
                    hours_cost: 1,
                    drc_change: 3,
                    risk_change: 6,
                    dfm_change: -5,
                    sanity_change: -3,
                    set_flags: ["annular_ring_unverified"]
                }
            ]
        },
        {
            id: "PCB-0048",
            title: "FABRICATION NOTES DISAGREE WITH THE DATA PACKAGE",
            description: "The drawing specifies one-ounce finished copper while the fabrication data and purchase notes call for two. Purchasing says both are approved. Copper plating is not equipped to resolve organizational conflict.",
            choices: [
                {
                    text: "Reconcile notes, copper weights and released outputs",
                    result: "All controlled documents now specify the same finished copper. Manufacturing can proceed without holding a company-wide vote.",
                    hours_cost: 4,
                    dfm_change: 3,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Request formal fab and engineering disposition",
                    result: "The engineering team issues one authoritative specification. The review takes a day but saves an expensive guessing contest.",
                    hours_cost: 2,
                    days_cost: 1,
                    risk_change: -1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Let the fabricator pick whichever copper is easier",
                    result: "The resulting board may meet one of the requirements. Unfortunately the purchase order does not accept multiple-choice answers.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfm_change: -4,
                    sanity_change: -3,
                    set_flags: ["copper_spec_conflict_unresolved"]
                }
            ]
        },
        {
            id: "PCB-0049",
            title: "CONTROLLED IMPEDANCE COUPONS DID NOT MAKE THE TRIP",
            description: "The CAM review finds a controlled-impedance requirement but no usable coupon plan. The customer expects test evidence. The fabrication drawing offers a highly confident arrow pointing at the word impedance.",
            choices: [
                {
                    text: "Add qualified coupons and verify the stackup relationship",
                    result: "The coupon plan now measures the routed structure. The customer will receive data rather than a decorative claim.",
                    hours_cost: 4,
                    dfm_change: 3,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Coordinate a fab-approved coupon strategy",
                    result: "The fabricator documents suitable coupon geometry and test reporting. One more meeting, one fewer mystery impedance.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Claim the impedance simulation counts as a coupon",
                    result: "The simulation remains a simulation. The receiving inspector is still holding the calipers and an unanswered question.",
                    hours_cost: 1,
                    risk_change: 5,
                    dfm_change: -4,
                    sanity_change: -3,
                    set_flags: ["impedance_coupon_missing"]
                }
            ]
        },
        {
            id: "PCB-0050",
            title: "PANELIZATION IS TRYING TO SNAP A COMPONENT OFF",
            description: "Assembly proposes breakaway tabs next to a fragile ceramic capacitor. The board will separate beautifully. The capacitor may separate with equal enthusiasm.",
            choices: [
                {
                    text: "Redesign the panel tabs and verify board support",
                    result: "The depanelization loads are redirected away from sensitive parts. The capacitor may remain in its assigned location.",
                    hours_cost: 5,
                    dfa_change: 3,
                    dfm_change: 2,
                    risk_change: -2,
                    sanity_change: -3
                },
                {
                    text: "Qualify a supported depanelization process",
                    result: "Assembly signs off on tooling and handling controls. The process can work if everybody remembers the controls.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfa_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Leave panel tabs where the drawing says they fit",
                    result: "The component is now the nearest structural member. Customer reliability will have questions about your new mechanical strategy.",
                    hours_cost: 1,
                    risk_change: 6,
                    dfa_change: -4,
                    dfm_change: -3,
                    sanity_change: -3,
                    set_flags: ["panelization_stress_unverified"]
                }
            ]
        },
        {
            id: "PCB-0051",
            title: "VIA-IN-PAD FILL SPECIFICATION: THREE PEOPLE, FOUR ANSWERS",
            description: "The BGA pads require filled and capped vias. CAM found a note for tenting instead. Assembly is understandably curious how solder will stay in a hole decorated with optimism.",
            choices: [
                {
                    text: "Specify the approved fill, cap and planarization process",
                    result: "Fabrication confirms the via-in-pad process and acceptance criteria. The solder joint can now be built on a real surface.",
                    hours_cost: 5,
                    dfm_change: 4,
                    risk_change: -3,
                    sanity_change: -3
                },
                {
                    text: "Hold a process review and qualify the via structure",
                    result: "CAM and assembly align on a controlled process revision. Even the process traveler knows what it is doing now.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    risk_change: -1,
                    sanity_change: -2
                },
                {
                    text: "Call tenting equivalent to filling and release it",
                    result: "The solder has been invited to drain into the via. Failure analysis already has a folder with your project name.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfm_change: -6,
                    sanity_change: -4,
                    set_flags: ["via_fill_unverified"]
                }
            ]
        },
        {
            id: "PCB-0052",
            title: "DRILL REGISTRATION DOES NOT FIT THE COPPER GEOMETRY",
            description: "CAM tolerance analysis predicts potential drill breakout at a dense connector. The nominal CAD screenshot is flawless. The fabrication process, inconsiderately, includes tolerances.",
            choices: [
                {
                    text: "Correct drill clearances and regenerate the manufacturing data",
                    result: "The new pad and drill geometry meets the registered process window. The drill no longer needs perfect aim.",
                    hours_cost: 6,
                    drc_change: -3,
                    dfm_change: 4,
                    risk_change: -3,
                    sanity_change: -4
                },
                {
                    text: "Review an alternate drill process with the fabricator",
                    result: "The shop qualifies an adjusted drill specification. Production receives actual limits instead of a nice rendering.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    risk_change: -1,
                    sanity_change: -2
                },
                {
                    text: "Approve the nominal geometry and hope for perfect alignment",
                    result: "The fabricator has been asked to manufacture without variation. It has declined to suspend the laws of machinery.",
                    hours_cost: 1,
                    drc_change: 4,
                    risk_change: 7,
                    dfm_change: -6,
                    sanity_change: -4,
                    set_flags: ["drill_registration_unverified"]
                }
            ]
        },
        {
            id: "PCB-0053",
            title: "COPPER BALANCE RESEMBLES A WEATHER MAP",
            description: "CAM reports severe copper imbalance between the layers. The plating and lamination teams foresee warpage. The layout screenshot still looks wonderfully symmetrical when viewed from the correct distance.",
            choices: [
                {
                    text: "Rebalance copper and revalidate the manufacturing stack",
                    result: "The fill pattern is adjusted and CAM accepts the balance. The board is less likely to ship as a shallow serving bowl.",
                    hours_cost: 5,
                    dfm_change: 4,
                    risk_change: -2,
                    sanity_change: -3
                },
                {
                    text: "Qualify a controlled lamination plan with the fab",
                    result: "The shop approves process adjustments and documents the remaining bow-and-twist risks. The plan includes measurements.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Tell the board shop to flatten it after fabrication",
                    result: "Warpage is now somebody else's deliverable. That will be comforting when the assembly stencil refuses to seat.",
                    hours_cost: 1,
                    risk_change: 6,
                    dfm_change: -5,
                    sanity_change: -3,
                    set_flags: ["copper_balance_unverified"]
                }
            ]
        },
        {
            id: "PCB-0054",
            title: "DEPTH ROUTING IS ONE CUT AWAY FROM COPPER",
            description: "The fabrication toolpath for a recessed mounting feature crosses too close to buried copper. CAM asks whether the board is supposed to have a surprise cross-section.",
            choices: [
                {
                    text: "Redesign the recess keepout and verify the toolpath",
                    result: "CAM confirms the milling clearance. The buried layers can remain buried, as originally advertised.",
                    hours_cost: 5,
                    drc_change: -3,
                    dfm_change: 3,
                    risk_change: -2,
                    sanity_change: -3
                },
                {
                    text: "Qualify a revised routing process with the board shop",
                    result: "The shop approves a controlled alternate toolpath. The milling machine gets coordinates that do not double as a teardown plan.",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Approve the cut because the 3D preview looks fine",
                    result: "The preview does not show the buried trace you are about to machine through. The field-return group is updating its calendar.",
                    hours_cost: 1,
                    drc_change: 4,
                    risk_change: 7,
                    dfm_change: -5,
                    sanity_change: -4,
                    set_flags: ["milling_clearance_unverified"]
                }
            ]
        }
    ];

    return create_events_from_pack(EventStage.MANUFACTURER_REVIEW, _specs);
}
