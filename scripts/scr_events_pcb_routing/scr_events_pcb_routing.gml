/// @description PCB Routing events and final Routing Review
// Includes CAD recovery, drill/via routing constraints, and the routing pack.
// Every event has EventStage.ROUTING; all checkpoint IDs remain unchanged.

function create_pcb_routing()
{
    var _specs = [
        {
            id: "PCB-0001",
            category: EventCategory.SETBACK,
            title: "CAD HAS CRASHED. AGAIN. OF COURSE.",
            description: "Your beloved PCB CAD suite crashes halfway through routing. The autosave is old enough to qualify as project history. Customer support insists this is an isolated incident, for the ninth time today.",
            choices: [
                {
                    text: "Restore the last autosave",
                    result: "The database opens. Most of the work survived, which counts as a feature in the current software release.",
                    hours_cost: 3,
                    sanity_change: -3
                },
                {
                    text: "Reconstruct the missing routes by hand",
                    result: "The routing is rebuilt and checked. Your weekend has been reallocated to the CAD vendor's quality assurance program.",
                    hours_cost: 7,
                    dfm_change: 3,
                    sanity_change: -5
                },
                {
                    text: "Open a support ticket and surrender hope",
                    result: "Support requests a screenshot of the crash dialog. The dialog vanished when the application crashed. This is apparently useful information.",
                    hours_cost: 1,
                    days_cost: 1,
                    morale_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Declare the missing routes nonessential",
                    result: "You sign off the vanished changes as optional. The netlist, untroubled by management approval, may have other plans.",
                    drc_change: 3,
                    risk_change: 2,
                    dfm_change: -5,
                    sanity_change: -4,
                    set_flags: ["cad_changes_unverified"]
                }
            ]
        },
        {
            id: "PCB-0007",
            category: EventCategory.ENGINEERING,
            title: "VIA DRILL SIZE: FAB SAYS ABSOLUTELY NOT",
            description: "The imported via table specifies holes smaller than the fabricator can reliably drill. Routing is underway, so the constraint arrives at the convenient moment when changing it hurts most.",
            choices: [
                {
                    text: "Redesign vias for supported drill sizes",
                    result: "The via geometry now fits the fab process. The design survives a small encounter with reality.",
                    hours_cost: 6,
                    drc_change: -2,
                    dfm_change: 4,
                    sanity_change: -3
                },
                {
                    text: "Review alternate processes with the fab",
                    result: "CAM proposes a manufacturable option. They even explain it without using the phrase 'as previously stated.'",
                    hours_cost: 3,
                    days_cost: 1,
                    dfm_change: 3,
                    sanity_change: -2
                },
                {
                    text: "Evaluate laser microvias and cost",
                    result: "A laser-drilled process is approved. The technical problem is solved; the budget has been invited to suffer.",
                    hours_cost: 8,
                    budget_change: -10,
                    dfm_change: 2,
                    sanity_change: -4
                },
                {
                    text: "Keep the drill sizes and request magic",
                    result: "The unsupported hole sizes remain. CAM has been warned, though warnings cannot make drill bits smaller.",
                    risk_change: 8,
                    dfm_change: -6,
                    sanity_change: -3,
                    set_flags: ["drill_capability_unresolved"]
                }
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0030
            id: "PCB-0030",
            title: "DIFF PAIR SKEW: THE CLOCK IS DISPLEASED",
            description: "A connector move pushes the differential clock pair beyond its skew budget. The receiver may still work, assuming it has a more relaxed relationship with timing than the datasheet.",
            choices: [
                {text: "Reroute and verify pair timing", result: "The skew is corrected and timing passes. The two traces have finally agreed on when to arrive.", hours_cost: 5, risk_change: -2, dfm_change: 1, sanity_change: -3},
                {text: "Request an SI-approved skew budget change", result: "Signal integrity reviews the timing margin and documents the new limit. The numbers receive adult supervision.", hours_cost: 2, days_cost: 1, risk_change: -1, sanity_change: -2},
                {text: "Let the lab discover the mismatch", result: "The skew stays. Bring-up will now determine whether the receiver shares your optimism.", hours_cost: 1, risk_change: 5, dft_change: -2, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0031
            id: "PCB-0031",
            title: "RETURN PATH TAKES THE SCENIC ROUTE",
            description: "A high-speed signal crosses a split in its reference plane. The return current must detour, bringing emissions and jitter to a party nobody planned.",
            choices: [
                {text: "Reroute over continuous reference copper", result: "The signal gets a proper return path. Electrons no longer need directions from the front desk.", hours_cost: 5, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Review stitching options with SI", result: "Signal integrity approves a stitching strategy. The return current is offered a route that actually exists.", hours_cost: 3, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Waive the split and document the concern", result: "The discontinuity remains, neatly documented. EMI testing is unlikely to be moved by your formatting.", hours_cost: 1, risk_change: 6, dfm_change: -3, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0032
            id: "PCB-0032",
            title: "ANALOG TRACE HEARS EVERYTHING",
            description: "A sensitive sense trace runs beside a switching node. Simulation predicts enough noise to make the measurements look like abstract art. The schematic, of course, was beautifully quiet.",
            choices: [
                {text: "Separate the traces and protect the return", result: "The analog route moves out of the switching field. The readings may once again resemble measurements.", hours_cost: 4, risk_change: -3, dft_change: 1, sanity_change: -3},
                {text: "Ask analog engineering to review coupling", result: "Engineering finds a verified routing solution. For once, the simulation and layout have met in person.", hours_cost: 2, days_cost: 1, risk_change: -1, sanity_change: -2},
                {text: "Trust the filter to clean up the mess", result: "The coupling remains. The filter has been promoted to chief miracle officer for first-article test.", hours_cost: 1, risk_change: 5, dft_change: -3, sanity_change: -2}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0033
            id: "PCB-0033",
            title: "VIA STUBS: THE SIGNAL HAS ECHOES",
            description: "The multi-gigabit channel model reveals reflections from unused via barrels. The eye diagram is closing. Unfortunately, the design review calendar is still wide open.",
            choices: [
                {text: "Revise the via transitions", result: "The transitions are corrected and the channel model improves. The signal stops arguing with its own reflection.", hours_cost: 5, risk_change: -2, dfm_change: 1, sanity_change: -3},
                {text: "Qualify backdrilling with the fabricator", result: "The fab approves controlled backdrilling. The stubs will be removed with considerably more precision than this schedule.", hours_cost: 3, days_cost: 1, budget_change: -4, risk_change: -2, sanity_change: -2},
                {text: "Save the surprise for compliance testing", result: "The stubs remain. You have booked a future appointment with a very expensive oscilloscope.", hours_cost: 1, risk_change: 6, dft_change: -2, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0034
            id: "PCB-0034",
            title: "POWER COPPER: TOO THIN FOR ITS AMBITION",
            description: "The high-current supply necks down beside a mounting feature. Current density and heating exceed the comfortable part of the calculation. Marketing has already called it a high-power design.",
            choices: [
                {text: "Widen the route and check current density", result: "The bottleneck is corrected and thermal calculations pass. Copper is once again doing its assigned job.", hours_cost: 5, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Add a parallel path and consult fabrication", result: "The reinforced route passes fab review. The extra copper is cheaper than discovering smoke is a feature.", hours_cost: 3, days_cost: 1, risk_change: -2, dfm_change: 1, sanity_change: -2},
                {text: "Assume the duty cycle will save it", result: "The narrow copper stays. The electrical limit now depends on the product never doing what the specification allows.", hours_cost: 1, risk_change: 5, dfm_change: -4, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0035
            id: "PCB-0035",
            title: "BGA ESCAPE: THERE IS NO THERE THERE",
            description: "Two power nets block the last BGA escape channels. Every remaining route violates clearance. The autorouter offers 47 suggestions, all involving imaginary board space.",
            choices: [
                {text: "Replan the BGA fanout and escape", result: "The escape routes are rebuilt without clearance violations. The BGA is no longer a tiny geometric hostage situation.", hours_cost: 6, drc_change: -1, dfm_change: 1, sanity_change: -4},
                {text: "Qualify via-in-pad with the fab", result: "Fabrication approves a controlled via-in-pad approach. The assembly cost climbs, but the traces can actually leave.", hours_cost: 3, days_cost: 1, budget_change: -4, risk_change: -2, sanity_change: -2},
                {text: "Squeeze traces through forbidden clearances", result: "The nets escape. The clearance rules do not. You have traded unrouted nets for DRC violations with excellent attendance.", hours_cost: 1, drc_change: 2, risk_change: 4, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0036
            id: "PCB-0036",
            title: "COPPER TOO CLOSE TO THE EDGE. LITERALLY.",
            description: "Several routes violate copper-to-board-edge clearance near an enclosure cutout. The outline cannot move. The router has apparently mistaken the board edge for a suggestion.",
            choices: [
                {text: "Reroute copper away from the edge", result: "The clearance errors are repaired. The copper will be inside the PCB after profiling, an underrated advantage.", hours_cost: 4, drc_change: -3, dfm_change: 1, sanity_change: -2},
                {text: "Get a controlled fab clearance disposition", result: "Fabrication signs off a revised clearance plan. The edge now has tolerances instead of wishful thinking.", hours_cost: 2, days_cost: 1, risk_change: -1, sanity_change: -2},
                {text: "Leave the copper where the cutter can find it", result: "The copper remains near the profiling path. The router may finish your traces during depanelization.", hours_cost: 1, drc_change: 3, risk_change: 5, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0037
            id: "PCB-0037",
            title: "IMPEDANCE CONTROL: TERMS AND CONDITIONS APPLY",
            description: "A layer change alters trace geometry and controlled impedance. The fabrication notes still describe the old stackup. Both documents are certain they are correct.",
            choices: [
                {text: "Fix geometry and recalculate impedance", result: "The route and constraints now agree. The signal can stop choosing between two incompatible truths.", hours_cost: 5, risk_change: -3, dfm_change: 1, sanity_change: -3},
                {text: "Review coupons and constraints with the fab", result: "The fab approves aligned impedance requirements. For once, the notes describe the board being built.", hours_cost: 3, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Waive the variance and admire the paperwork", result: "The impedance mismatch remains in production data. The waiver is beautifully formatted and electrically useless.", hours_cost: 1, risk_change: 6, dfm_change: -4, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0038
            id: "PCB-0038",
            title: "THERMAL SPOKES VS. ACTUAL ELECTRICITY",
            description: "A power pad has thermal spokes thin enough to please soldering but not the load current. Assembly and electrical engineering have discovered that the same copper must satisfy both departments.",
            choices: [
                {text: "Rebuild the pad connection for the load", result: "The pad now carries the required current. Assembly is informed that electricity was also a stakeholder.", hours_cost: 4, risk_change: -2, dfa_change: 1, sanity_change: -3},
                {text: "Get a joint assembly and power review", result: "The teams approve a workable compromise. The copper has survived a multidisciplinary custody battle.", hours_cost: 3, days_cost: 1, dfa_change: 2, risk_change: -1, sanity_change: -2},
                {text: "Keep the spokes and let current negotiate", result: "The undersized connection remains. Electrical current has declined to respect the assembly preference.", hours_cost: 1, risk_change: 5, dfa_change: -3, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0039
            id: "PCB-0039",
            title: "TEST PROBE ACCESS: NOW YOU SEE IT, NOW...",
            description: "New routes and stitching vias surround the reset test point. The fixture probe no longer fits. Test engineering asks whether the board is intended to be tested or merely admired.",
            choices: [
                {text: "Restore an accessible reset test point", result: "Probe access returns. The fixture can test the reset net without developing new limbs.", hours_cost: 4, dft_change: 4, sanity_change: -2},
                {text: "Have test engineering approve another target", result: "Test engineering qualifies another contact. The fixture change is documented before manufacturing gets creative.", hours_cost: 2, days_cost: 1, dft_change: 2, sanity_change: -2},
                {text: "Delete the test requirement instead", result: "The net becomes harder to diagnose. Removing the requirement did not remove the need to test the board.", hours_cost: 1, dft_change: -6, risk_change: 3, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0040
            id: "PCB-0040",
            title: "CLOCK ROUTE VISITS THE NOISE FACTORY",
            description: "The reference clock runs beside a switching converter loop. Jitter risk is rising. The power stage calls this 'efficient use of board area'; the clock disagrees.",
            choices: [
                {text: "Move the clock to a quieter corridor", result: "The clock is rerouted with a clean return. It no longer shares a wall with the electrical equivalent of a jackhammer.", hours_cost: 4, risk_change: -2, dft_change: 1, sanity_change: -3},
                {text: "Run a focused clock-integrity review", result: "Signal integrity checks the coupling and approves corrections. The jitter concern gets numbers instead of adjectives.", hours_cost: 3, days_cost: 1, risk_change: -1, sanity_change: -2},
                {text: "Leave the route and add bring-up tests", result: "The coupling risk stays. Test has been asked to measure whether optimism can substitute for layout.", hours_cost: 1, risk_change: 4, dft_change: -1, sanity_change: -3}
            ]
        },
        {
            // Ordinary Routing encounter: PCB-0041
            id: "PCB-0041",
            title: "VIA ASPECT RATIO: CAM SENDS A VERY FIRM NO",
            description: "A buried via transition exceeds the fab's qualified drill aspect ratio. CAM requests a disposition before fabrication. This is engineer-speak for 'we are not drilling that.'",
            choices: [
                {text: "Switch to a qualified via structure", result: "The new transition fits the process window. The drill shop can resume treating holes as holes.", hours_cost: 5, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Review alternate fabrication processes", result: "Fabrication approves an alternative. It comes with a process note rather than a prayer.", hours_cost: 2, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Keep the via geometry and seek an exception", result: "The high-risk geometry stays. The exception request cannot change how plating chemistry works.", hours_cost: 1, risk_change: 6, dfm_change: -5, sanity_change: -3}
            ]
        },
        {
            // Mandatory final Routing checkpoint: RTE-REVIEW-001
            id: "RTE-REVIEW-001",
            category: EventCategory.MILESTONE,
            title: "ROUTING REVIEW: SIGNATURES BEFORE SURVIVAL",
            description: "Routing is complete, according to the status report. SI, PI, fabrication and test need to agree before manufacturer review. Every department has brought a different definition of 'complete.'",
            choices: [
                {text: "Review and sign off the routing package", result: "The routing review is approved for manufacturer evaluation. All required signatures exist in the same revision.", hours_cost: 3, risk_change: -1, sanity_change: -2},
                {text: "Hold a final cross-functional routing review", result: "The teams close open questions before handoff. The meeting is long, but the manufacturing surprise list is shorter.", hours_cost: 5, days_cost: 1, risk_change: -2, dft_change: 1, sanity_change: -3},
                {text: "Sign off and staple the risks to the package", result: "Routing advances with documented open concerns. The signature is real; the confidence is an optional accessory.", hours_cost: 1, risk_change: 5, dfm_change: -2, sanity_change: -3}
            ]
        }
    ];

    return create_events_from_pack(EventStage.ROUTING, _specs);
}
