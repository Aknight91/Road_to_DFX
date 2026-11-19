/// @description Placement content pack 01: PCB-0010 to PCB-0029
// 20 ordinary encounters plus one required Placement Review.
// Data only: decisions use the existing standard event schema.

function create_pcb_placement_pack_01()
{
    var _specs = [
        {
            id: "PCB-0010",
            title: "THERMAL HOTSPOT DETECTED!",
            description: "A power regulator may overheat the nearby temperature-sensitive components. Placement is nearly frozen.",
            choices: [
                {text: "Relocate the regulator", result: "The hot component now has breathing room.", hours_cost: 8, dfm_change: 4, risk_change: -2, sanity_change: -4},
                {text: "Improve copper and thermal via coverage", result: "The heat-spreading plan is updated at added fabrication cost.", hours_cost: 6, budget_change: -5, dfm_change: 3, sanity_change: -3},
                {text: "Waive the thermal concern", result: "Reliability engineering has kept a copy of your waiver.", hours_cost: 1, risk_change: 8, dfm_change: -6, sanity_change: -4, set_flags: ["thermal_risk_unresolved"]}
            ]
        },
        {
            id: "PCB-0011",
            title: "TEST POINTS BLOCKED!",
            description: "Large components prevent automated test probes from reaching several critical nets.",
            choices: [
                {text: "Rearrange placement and add test points", result: "Test engineering now has probe access to the affected nets.", hours_cost: 7, dft_change: 6, dfa_change: 1, sanity_change: -3},
                {text: "Commission an alternate fixture strategy", result: "A custom fixture has been approved, with added cost.", hours_cost: 4, days_cost: 1, budget_change: -6, dft_change: 4, sanity_change: -2},
                {text: "Release the placement with reduced coverage", result: "Several nets will remain untested by the fixture.", hours_cost: 1, dft_change: -7, risk_change: 6, sanity_change: -4, set_flags: ["test_access_unverified"]}
            ]
        },
        {
            id: "PCB-0012",
            title: "FIDUCIAL IN THE SHADOW!",
            description: "A tall connector blocks the assembly camera's line of sight to a global fiducial.",
            choices: [
                {text: "Move the fiducial into a clear zone", result: "The vision system can locate the board reliably.", hours_cost: 4, dfa_change: 4, sanity_change: -2},
                {text: "Ask assembly to qualify another target", result: "A revised camera setup is approved after review.", hours_cost: 2, days_cost: 1, dfa_change: 2, budget_change: -3, sanity_change: -2},
                {text: "Keep the blocked fiducial", result: "The board may require manual alignment at assembly.", hours_cost: 1, dfa_change: -5, risk_change: 5, sanity_change: -3, set_flags: ["fiducial_visibility_unverified"]}
            ]
        },
        {
            id: "PCB-0013",
            title: "DECOUPLING CAPACITOR TOO FAR AWAY!",
            description: "The electrical engineer spots decoupling capacitors far from a high-speed IC's power pins.",
            choices: [
                {text: "Move decouplers beside the power pins", result: "The return path and local bypassing are improved.", hours_cost: 6, dfm_change: 2, risk_change: -3, sanity_change: -3},
                {text: "Review the power distribution network", result: "The PDN review identifies a practical placement compromise.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Trust the existing capacitor locations", result: "The power-integrity concern remains open.", hours_cost: 1, risk_change: 7, sanity_change: -3, set_flags: ["pdn_placement_unverified"]}
            ]
        },
        {
            id: "PCB-0014",
            title: "MECHANICAL KEEP-OUT VIOLATION!",
            description: "A placement check reveals components inside a reserved enclosure keep-out region.",
            choices: [
                {text: "Move the conflicting components", result: "The enclosure keep-out is respected.", hours_cost: 5, dfa_change: 4, sanity_change: -3},
                {text: "Negotiate a mechanical exception", result: "Mechanical engineering documents an approved change.", hours_cost: 3, days_cost: 1, dfa_change: 2, sanity_change: -2},
                {text: "Assume the enclosure will be adjusted", result: "The mechanical interference remains unresolved.", hours_cost: 1, dfa_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["placement_keepout_unresolved"]}
            ]
        },
        {
            id: "PCB-0015",
            title: "POLARITY MARKS DON'T MATCH!",
            description: "Several polarized components have rotations inconsistent with the assembly drawing.",
            choices: [
                {text: "Audit orientations and correct assembly data", result: "Polarities, rotations and assembly output now agree.", hours_cost: 6, dfa_change: 5, risk_change: -2, sanity_change: -3},
                {text: "Request a librarian and assembly review", result: "The library and centroid convention are reconciled.", hours_cost: 3, days_cost: 1, dfa_change: 3, sanity_change: -2},
                {text: "Leave the rotations for the assembler", result: "Assembly must interpret conflicting orientation information.", hours_cost: 1, dfa_change: -7, risk_change: 6, sanity_change: -4, set_flags: ["polarity_orientation_unverified"]}
            ]
        },
        {
            id: "PCB-0016",
            title: "AOI CAMERA CAN'T SEE THE JOINTS!",
            description: "A shield can obstruct automated optical inspection of nearby solder joints.",
            choices: [
                {text: "Rearrange parts to expose the joints", result: "Inspection access has been restored.", hours_cost: 6, dfa_change: 3, dft_change: 4, sanity_change: -3},
                {text: "Approve an alternate inspection plan", result: "Quality agrees to a supplementary inspection process.", hours_cost: 3, days_cost: 1, budget_change: -4, dft_change: 3, sanity_change: -2},
                {text: "Skip the obstructed inspection locations", result: "Some solder joints will escape the planned AOI coverage.", hours_cost: 1, dft_change: -6, risk_change: 7, sanity_change: -3, set_flags: ["aoi_coverage_incomplete"]}
            ]
        },
        {
            id: "PCB-0017",
            title: "REWORK ACCESS BLOCKED!",
            description: "The service engineer cannot reach a likely replacement component with a hot-air tool.",
            choices: [
                {text: "Create a rework access corridor", result: "The component can be replaced without disturbing its neighbors.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Review a specialized rework process", result: "The rework team approves a slower but workable procedure.", hours_cost: 3, days_cost: 1, budget_change: -3, dfa_change: 2, sanity_change: -2},
                {text: "Accept limited field repairability", result: "Service access will be poor if the component fails.", hours_cost: 1, dfa_change: -5, risk_change: 4, sanity_change: -3, set_flags: ["rework_access_limited"]}
            ]
        },
        {
            id: "PCB-0018",
            title: "MOUNTING SCREW ACCESS LOST!",
            description: "The enclosure team cannot fit a screwdriver past a tall component near a mounting hole.",
            choices: [
                {text: "Move the component beyond the tool envelope", result: "Mechanical assembly clearance is restored.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Qualify a different fastener or tool", result: "The hardware team approves a revised fastening process.", hours_cost: 3, days_cost: 1, budget_change: -4, dfa_change: 2, sanity_change: -2},
                {text: "Expect assembly to work around it", result: "A mounting operation now depends on improvised tooling.", hours_cost: 1, dfa_change: -6, risk_change: 5, sanity_change: -3, set_flags: ["mount_access_unverified"]}
            ]
        },
        {
            id: "PCB-0019",
            title: "BGA ORIENTATION BLOCKS ESCAPE!",
            description: "The selected BGA orientation funnels high-speed pins toward a dense mechanical boundary.",
            choices: [
                {text: "Rotate or relocate the BGA before routing", result: "Critical escape channels have been opened up.", hours_cost: 8, dfm_change: 4, risk_change: -2, sanity_change: -4},
                {text: "Hold an early escape feasibility review", result: "Routing specialists identify a lower-risk arrangement.", hours_cost: 4, days_cost: 1, dfm_change: 2, sanity_change: -2},
                {text: "Leave the BGA and solve it during routing", result: "The dense pin escape problem is deferred.", hours_cost: 1, risk_change: 7, dfm_change: -4, sanity_change: -3, set_flags: ["bga_escape_deferred"]}
            ]
        },
        {
            id: "PCB-0020",
            title: "TEST FIXTURE COLLISION!",
            description: "An underside component collides with a bed-of-nails fixture support position.",
            choices: [
                {text: "Clear the test fixture support zone", result: "The fixture can support and probe the board correctly.", hours_cost: 6, dft_change: 5, dfa_change: 2, sanity_change: -3},
                {text: "Ask test engineering to redesign the fixture", result: "A different support layout is approved at added cost.", hours_cost: 3, days_cost: 1, budget_change: -6, dft_change: 3, sanity_change: -2},
                {text: "Accept the unsupported fixture region", result: "Fixture alignment and probe consistency are now at risk.", hours_cost: 1, dft_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["fixture_support_unverified"]}
            ]
        },
        {
            id: "PCB-0021",
            title: "CRYSTAL BESIDE THE SWITCH NODE!",
            description: "A sensitive clock crystal sits next to a noisy switching regulator area.",
            choices: [
                {text: "Move the crystal and clean up the placement", result: "The clock circuitry is farther from the switching noise.", hours_cost: 6, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Get a signal-integrity placement review", result: "The review identifies an acceptable clock placement.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Keep it and hope the oscillator is tolerant", result: "Clock integrity will have to be proven later.", hours_cost: 1, risk_change: 7, sanity_change: -4, set_flags: ["clock_noise_unverified"]}
            ]
        },
        {
            id: "PCB-0022",
            title: "HEATSINK CAN'T BE INSTALLED!",
            description: "A connector obstructs the installation path for the regulator's heatsink.",
            choices: [
                {text: "Move components outside the heatsink envelope", result: "The heatsink now fits without damaging neighboring parts.", hours_cost: 7, dfa_change: 5, dfm_change: 2, sanity_change: -3},
                {text: "Review an alternate cooling assembly", result: "Mechanical and thermal teams approve another cooling option.", hours_cost: 4, days_cost: 1, budget_change: -5, dfa_change: 3, sanity_change: -2},
                {text: "Leave assembly to fit the heatsink somehow", result: "The heatsink installation remains unverified.", hours_cost: 1, dfa_change: -7, risk_change: 6, sanity_change: -3, set_flags: ["heatsink_install_unverified"]}
            ]
        },
        {
            id: "PCB-0023",
            title: "SERVICE HEADER IS INACCESSIBLE!",
            description: "The programming and debug header will be covered by the enclosure wall.",
            choices: [
                {text: "Relocate the header into the service zone", result: "Technicians can now reach the programming interface.", hours_cost: 5, dft_change: 4, dfa_change: 2, sanity_change: -3},
                {text: "Approve an alternate programming adapter", result: "An adapter solves access at the expense of tooling cost.", hours_cost: 3, days_cost: 1, budget_change: -4, dft_change: 2, sanity_change: -2},
                {text: "Program boards before enclosure assembly", result: "Post-assembly service access will not be available.", hours_cost: 1, dft_change: -4, risk_change: 5, sanity_change: -3, set_flags: ["programming_access_limited"]}
            ]
        },
        {
            id: "PCB-0024",
            title: "RF ANTENNA IS DETUNED!",
            description: "A metal shield has been placed beside the PCB antenna's clearance region.",
            choices: [
                {text: "Move the shield outside the antenna keep-out", result: "The antenna clearance region is restored.", hours_cost: 7, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Request antenna tuning and enclosure review", result: "RF engineering approves a revised antenna environment.", hours_cost: 4, days_cost: 1, budget_change: -4, risk_change: -2, sanity_change: -2},
                {text: "Ignore the suspected detuning", result: "Wireless performance remains an unverified risk.", hours_cost: 1, risk_change: 8, sanity_change: -4, set_flags: ["rf_antenna_unverified"]}
            ]
        },
        {
            id: "PCB-0025",
            title: "HIGH-VOLTAGE PARTS TOO CLOSE!",
            description: "Two high-voltage components crowd a safety clearance zone in the proposed placement.",
            choices: [
                {text: "Reposition parts to meet reviewed clearances", result: "The component spacing now meets the documented requirement.", hours_cost: 7, dfm_change: 5, risk_change: -3, sanity_change: -3},
                {text: "Request a safety engineering review", result: "Safety engineering provides an approved placement solution.", hours_cost: 4, days_cost: 1, dfm_change: 3, sanity_change: -2},
                {text: "Accept the crowded placement", result: "The safety clearance issue remains unresolved.", hours_cost: 1, risk_change: 9, dfm_change: -7, sanity_change: -4, set_flags: ["hv_spacing_unverified"]}
            ]
        },
        {
            id: "PCB-0026",
            title: "MATING CONNECTOR WON'T FIT!",
            description: "The mating cable connector cannot be inserted with the board inside its enclosure.",
            choices: [
                {text: "Reorient the connector for mating access", result: "The cable can now be inserted without disassembly.", hours_cost: 6, dfa_change: 5, sanity_change: -3},
                {text: "Coordinate a cable assembly change", result: "A new mating harness is qualified at additional cost.", hours_cost: 4, days_cost: 1, budget_change: -5, dfa_change: 3, sanity_change: -2},
                {text: "Tell final assembly to connect it first", result: "Service replacement may require dismantling the unit.", hours_cost: 1, dfa_change: -6, risk_change: 5, sanity_change: -3, set_flags: ["connector_mating_access_limited"]}
            ]
        },
        {
            id: "PCB-0027",
            title: "PANEL RAIL CLEARANCE MISSING!",
            description: "SMD components intrude into the edge clearance required for depanelization rails.",
            choices: [
                {text: "Shift edge components beyond the rail zone", result: "The panel rails and board-edge process are now compatible.", hours_cost: 5, dfm_change: 5, sanity_change: -3},
                {text: "Ask fabrication for another panel strategy", result: "The fabricator approves a revised panel at extra cost.", hours_cost: 3, days_cost: 1, budget_change: -4, dfm_change: 3, sanity_change: -2},
                {text: "Keep the edge components in place", result: "Depanelization damage is now a manufacturing risk.", hours_cost: 1, dfm_change: -6, risk_change: 7, sanity_change: -3, set_flags: ["depanel_clearance_unverified"]}
            ]
        },
        {
            id: "PCB-0028",
            title: "BOTTOM-SIDE PART HITS A STANDOFF!",
            description: "A bottom-side component overlaps an enclosure standoff in the assembly model.",
            choices: [
                {text: "Move the underside component", result: "The standoff and component no longer collide.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Review a shorter standoff", result: "Mechanical engineering approves alternate hardware.", hours_cost: 3, days_cost: 1, budget_change: -3, dfa_change: 2, sanity_change: -2},
                {text: "Assume the enclosure drawing is out of date", result: "Physical fit remains unverified.", hours_cost: 1, dfa_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["standoff_collision_unverified"]}
            ]
        },
        {
            id: "PCB-0029",
            title: "HEAVY COMPONENT NEEDS SUPPORT!",
            description: "Vibration analysis flags a heavy inductor at risk of solder-joint fatigue.",
            choices: [
                {text: "Add mechanical support and revise placement", result: "The heavy component now has a qualified support approach.", hours_cost: 6, budget_change: -3, dfa_change: 3, risk_change: -3, sanity_change: -3},
                {text: "Request a vibration and assembly review", result: "Engineering approves a documented reinforcement solution.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Assume solder joints will hold", result: "The fatigue risk remains on the project register.", hours_cost: 1, risk_change: 7, dfa_change: -4, sanity_change: -4, set_flags: ["vibration_support_unverified"]}
            ]
        },
        {
            // Required final Placement encounter. Never chosen early.
            id: "PLC-REVIEW-001",
            category: EventCategory.MILESTONE,
            title: "PLACEMENT DESIGN REVIEW!",
            description: "Placement is ready for a cross-functional review. Assembly, test, mechanical and electrical teams need a disposition before routing begins.",
            choices: [
                {text: "Sign off the reviewed placement package", result: "The placement review is signed off for routing.", hours_cost: 3, dfa_change: 2, dft_change: 1, sanity_change: -2},
                {text: "Hold a final cross-functional walkthrough", result: "The teams resolve open placement questions and approve routing.", hours_cost: 6, days_cost: 1, dfa_change: 4, dft_change: 2, sanity_change: -3},
                {text: "Approve with remaining issues documented", result: "The placement is released to routing with open action items.", hours_cost: 1, risk_change: 5, dfm_change: -3, sanity_change: -3, set_flags: ["placement_review_open_items"]}
            ]
        }
    ];

    return create_events_from_pack(EventStage.PLACEMENT, _specs);
}
