/// @description Placement content pack 01: PCB-0010 to PCB-0029
// 20 ordinary encounters plus one required Placement Review.
// Data only: decisions use the existing standard event schema.

function create_pcb_placement_pack_01()
{
    var _specs = [
        {
            id: "PCB-0010",
            title: "THERMAL HOTSPOT: A VERY LOCAL SUMMER",
            description: "A power regulator is cooking the temperature-sensitive parts next door. Placement is nearly frozen, making this a wonderful time to discover that heat spreads.",
            choices: [
                {text: "Move the regulator somewhere sensible", result: "The regulator moves and its neighbors can breathe again. Thermal management is no longer a neighborhood dispute.", hours_cost: 8, dfm_change: 4, risk_change: -2, sanity_change: -4},
                {text: "Improve copper and thermal-via coverage", result: "Heat spreading improves. The fab quote rises, but the temperature plot is considerably less exciting.", hours_cost: 6, budget_change: -5, dfm_change: 3, sanity_change: -3},
                {text: "Waive the thermal issue and ship the layout", result: "The hotspot stays. Reliability now has a calendar reminder titled 'inevitable.'", hours_cost: 1, risk_change: 8, dfm_change: -6, sanity_change: -4, set_flags: ["thermal_risk_unresolved"]}
            ]
        },
        {
            id: "PCB-0011",
            title: "TEST POINTS HIDDEN BY COMPONENTS",
            description: "Large components block the fixture probes from critical nets. The test points are technically present, in the same way treasure is present under a parking garage.",
            choices: [
                {text: "Rearrange placement and add accessible probes", result: "The critical nets are reachable again. The bed-of-nails fixture no longer needs a tunnel-boring machine.", hours_cost: 7, dft_change: 6, dfa_change: 1, sanity_change: -3},
                {text: "Qualify an alternate test fixture", result: "Test engineering approves a custom fixture. Access is restored at the sort of price that earns its own meeting.", hours_cost: 4, days_cost: 1, budget_change: -6, dft_change: 4, sanity_change: -2},
                {text: "Keep placement and accept reduced coverage", result: "Several nets remain inaccessible. The production test strategy now includes the phrase 'probably fine.'", hours_cost: 1, dft_change: -7, risk_change: 6, sanity_change: -4, set_flags: ["test_access_unverified"]}
            ]
        },
        {
            id: "PCB-0012",
            title: "FIDUCIAL UNDERCOVER: CAMERA SEES NOTHING",
            description: "A tall connector blocks the assembly camera's view of a global fiducial. The marker is exactly where the drawing says it is, which is not where the camera can see it.",
            choices: [
                {text: "Move the fiducial into clear sight", result: "The vision system sees the target. A bold breakthrough in the science of unobstructed lines of sight.", hours_cost: 4, dfa_change: 4, sanity_change: -2},
                {text: "Have assembly qualify an alternate target", result: "Assembly approves another camera target. The machine can locate the board without psychic powers.", hours_cost: 2, days_cost: 1, dfa_change: 2, budget_change: -3, sanity_change: -2},
                {text: "Leave the fiducial behind the connector", result: "The fiducial remains invisible. The pick-and-place machine politely refuses to imagine it.", hours_cost: 1, dfa_change: -5, risk_change: 5, sanity_change: -3, set_flags: ["fiducial_visibility_unverified"]}
            ]
        },
        {
            id: "PCB-0013",
            title: "DECOUPLERS: CLOSE IN THE SCHEMATIC",
            description: "The bypass capacitors sit far from the IC power pins. On a schematic everything was next to everything. Copper, unfortunately, measures distance in real units.",
            choices: [
                {text: "Move decouplers next to the power pins", result: "The local bypass paths improve. The capacitors are finally doing more than decorating the BOM.", hours_cost: 6, dfm_change: 2, risk_change: -3, sanity_change: -3},
                {text: "Review the PDN before changing placement", result: "The PDN analysis identifies a controlled fix. Someone prints the plots and calls it collaboration.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Leave capacitors where they look tidy", result: "The bypassing remains questionable. The IC will have to appreciate the visual symmetry.", hours_cost: 1, risk_change: 7, sanity_change: -3, set_flags: ["pdn_placement_unverified"]}
            ]
        },
        {
            id: "PCB-0014",
            title: "KEEP-OUT ZONE: COMPONENTS DID NOT GET THE MEMO",
            description: "Parts have wandered into the enclosure keepout. The mechanical model calls it a collision; the placement report calls it efficient use of space.",
            choices: [
                {text: "Move components out of the keepout", result: "The enclosure and PCB now agree on what occupies physical space. This is surprisingly good news.", hours_cost: 5, dfa_change: 4, sanity_change: -3},
                {text: "Negotiate a documented mechanical exception", result: "Mechanical engineering approves a revised interface. The exception exists in CAD, not just in an email.", hours_cost: 3, days_cost: 1, dfa_change: 2, sanity_change: -2},
                {text: "Assume the enclosure team will move its walls", result: "The components stay. Mechanical engineering has not volunteered to redesign the laws of geometry.", hours_cost: 1, dfa_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["placement_keepout_unresolved"]}
            ]
        },
        {
            id: "PCB-0015",
            title: "POLARITY MARKS: WHICH WAY IS UP?",
            description: "Several polarized components disagree with the assembly drawing about orientation. The plus signs and rotation arrows have started a small but consequential civil war.",
            choices: [
                {text: "Audit and correct component orientations", result: "The rotations match approved polarity data. Assembly can populate the board without a guessing contest.", hours_cost: 6, dfa_change: 5, risk_change: -2, sanity_change: -3},
                {text: "Get CAD library and assembly to verify them", result: "The librarian and assembler agree on the orientation. Everybody takes a screenshot for historical preservation.", hours_cost: 3, days_cost: 1, dfa_change: 3, sanity_change: -2},
                {text: "Let assembly interpret the rotations", result: "The ambiguity remains. The assembler has been promoted, without consent, to electrical design authority.", hours_cost: 1, dfa_change: -7, risk_change: 6, sanity_change: -4, set_flags: ["polarity_orientation_unverified"]}
            ]
        },
        {
            id: "PCB-0016",
            title: "AOI CAMERA: NOW INSPECTING THE SHIELD",
            description: "The new shield blocks optical inspection of nearby solder joints. The AOI camera can confirm that the shield looks lovely; the joints remain a mystery.",
            choices: [
                {text: "Rearrange parts to expose the solder joints", result: "AOI can see the joints. The inspection plan once again contains actual inspection.", hours_cost: 6, dfa_change: 3, dft_change: 4, sanity_change: -3},
                {text: "Qualify an alternate inspection method", result: "Quality approves another inspection path. It takes more effort, but it does involve looking at the joints.", hours_cost: 3, days_cost: 1, budget_change: -4, dft_change: 3, sanity_change: -2},
                {text: "Skip inspection where the camera cannot see", result: "The hidden joints go unchecked. Manufacturing quality has been asked to trust their personalities.", hours_cost: 1, dft_change: -6, risk_change: 7, sanity_change: -3, set_flags: ["aoi_coverage_incomplete"]}
            ]
        },
        {
            id: "PCB-0017",
            title: "REWORK ACCESS: THE TOOL IS NOT A GHOST",
            description: "The service engineer cannot get a hot-air tool to a likely replacement part. The layout looks great until somebody needs to repair anything on it.",
            choices: [
                {text: "Create a proper rework-access corridor", result: "The component is reachable. Service engineering briefly considers sending a thank-you card.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Review a specialized rework method", result: "A qualified rework approach is documented. The repair technician gets a procedure instead of an obstacle course.", hours_cost: 3, days_cost: 1, budget_change: -3, dfa_change: 2, sanity_change: -2},
                {text: "Accept that this part is basically permanent", result: "Repairability stays limited. The field-service plan now relies heavily on the word 'disposable.'", hours_cost: 1, dfa_change: -5, risk_change: 4, sanity_change: -3, set_flags: ["rework_access_limited"]}
            ]
        },
        {
            id: "PCB-0018",
            title: "SCREWDRIVER CLEARANCE: A NEW THEORY",
            description: "A tall component blocks the tool path to a mounting screw. The screw itself fits perfectly. Unfortunately, the person installing it must exist in three dimensions.",
            choices: [
                {text: "Move the part out of the tool envelope", result: "A screwdriver now reaches the screw. Manufacturing celebrates the return of normal hand geometry.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Qualify a different fastener or tool", result: "Mechanical engineering approves another tool path. Assembly no longer needs the fingers of a watchmaker.", hours_cost: 3, days_cost: 1, budget_change: -4, dfa_change: 2, sanity_change: -2},
                {text: "Tell assembly to be more flexible", result: "The obstacle remains. The technician has been advised to rotate their wrist through solid matter.", hours_cost: 1, dfa_change: -6, risk_change: 5, sanity_change: -3, set_flags: ["mount_access_unverified"]}
            ]
        },
        {
            id: "PCB-0019",
            title: "BGA ROTATION: AN ESCAPE ROOM WITHOUT EXITS",
            description: "The BGA orientation drives high-speed nets straight into a crowded mechanical boundary. Routing has not started, making this the cheapest moment to admit the mistake.",
            choices: [
                {text: "Rotate or relocate the BGA now", result: "The escape channels are restored. Routing engineers stop drawing tiny angry arrows on the placement.", hours_cost: 8, dfm_change: 4, risk_change: -2, sanity_change: -4},
                {text: "Hold an early escape-feasibility review", result: "The team approves a workable fanout plan. Disaster is canceled before its scheduled appearance.", hours_cost: 4, days_cost: 1, dfm_change: 2, sanity_change: -2},
                {text: "Keep the BGA; future routing can deal with it", result: "The BGA stays put. Future You has been nominated for an award in impossible trace geometry.", hours_cost: 1, risk_change: 7, dfm_change: -4, sanity_change: -3, set_flags: ["bga_escape_deferred"]}
            ]
        },
        {
            id: "PCB-0020",
            title: "TEST FIXTURE AND COMPONENT CLAIM SAME SPACE",
            description: "A bottom-side component occupies a bed-of-nails fixture support location. Both objects insist they belong there. The mechanical model is unwilling to arbitrate.",
            choices: [
                {text: "Move the part away from the fixture support", result: "The fixture support clears the PCB. Both designs now fit in the same universe.", hours_cost: 6, dft_change: 5, dfa_change: 2, sanity_change: -3},
                {text: "Ask test to redesign the support", result: "Test engineering approves a new fixture. The added cost is the price of negotiating with a finished layout.", hours_cost: 3, days_cost: 1, budget_change: -6, dft_change: 3, sanity_change: -2},
                {text: "Leave the fixture support unsupported", result: "The fixture now has a weak spot. Test engineering begins investigating whether wishful thinking has a load rating.", hours_cost: 1, dft_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["fixture_support_unverified"]}
            ]
        },
        {
            id: "PCB-0021",
            title: "CRYSTAL NEXT TO A SWITCHING CONVERTER",
            description: "The reference crystal sits beside a noisy switch node. It is an excellent location if the goal is to teach the oscillator about electromagnetic interference.",
            choices: [
                {text: "Move the crystal to a quieter location", result: "The crystal moves away from the noise source. Clock stability gets a fighting chance.", hours_cost: 6, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Request a signal-integrity placement review", result: "The team verifies a cleaner placement. The oscillator is no longer the power stage's closest friend.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Trust the oscillator to be understanding", result: "The crystal remains beside the switching node. Jitter has been given an open invitation.", hours_cost: 1, risk_change: 7, sanity_change: -4, set_flags: ["clock_noise_unverified"]}
            ]
        },
        {
            id: "PCB-0022",
            title: "HEATSINK INSTALLATION: ACCESS DENIED",
            description: "A connector blocks the installation path for the regulator heatsink. The heatsink works beautifully, provided somebody can pass it through the connector.",
            choices: [
                {text: "Clear the heatsink installation envelope", result: "The heatsink can be fitted normally. The assembly instructions become much shorter.", hours_cost: 7, dfa_change: 5, dfm_change: 2, sanity_change: -3},
                {text: "Qualify a different thermal assembly", result: "Engineering approves an alternate cooler. Thermals remain acceptable and assembly no longer requires magic.", hours_cost: 4, days_cost: 1, budget_change: -5, dfa_change: 3, sanity_change: -2},
                {text: "Let assembly figure out how to insert it", result: "The interference stays. The assembly team has received an impossible instruction with a due date.", hours_cost: 1, dfa_change: -7, risk_change: 6, sanity_change: -3, set_flags: ["heatsink_install_unverified"]}
            ]
        },
        {
            id: "PCB-0023",
            title: "DEBUG HEADER: SEALED FOR YOUR PROTECTION",
            description: "The enclosure wall covers the programming header. The finished product will be very secure against firmware updates, including authorized ones.",
            choices: [
                {text: "Relocate the header to a serviceable spot", result: "The programming connector is accessible. Field technicians can now do their jobs without opening a hole in the housing.", hours_cost: 5, dft_change: 4, dfa_change: 2, sanity_change: -3},
                {text: "Approve a qualified programming adapter", result: "A special adapter solves the access problem. It even has a drawing that shows how it fits.", hours_cost: 3, days_cost: 1, budget_change: -4, dft_change: 2, sanity_change: -2},
                {text: "Program everything before final enclosure assembly", result: "The header stays buried. Every future firmware fix will be an interesting logistical event.", hours_cost: 1, dft_change: -4, risk_change: 5, sanity_change: -3, set_flags: ["programming_access_limited"]}
            ]
        },
        {
            id: "PCB-0024",
            title: "ANTENNA KEEP-OUT: NOW WITH BONUS METAL",
            description: "A shield sits beside the PCB antenna clearance region. RF engineering requested free space; placement interpreted that as an invitation to put metal there.",
            choices: [
                {text: "Move the shield outside the antenna region", result: "The clearance is restored. The radio has a chance to communicate beyond the enclosure.", hours_cost: 7, risk_change: -3, dfm_change: 2, sanity_change: -3},
                {text: "Request antenna tuning and enclosure review", result: "RF engineering qualifies a revised arrangement. The range estimate once again has evidence behind it.", hours_cost: 4, days_cost: 1, budget_change: -4, risk_change: -2, sanity_change: -2},
                {text: "Ignore the detuning and trust the antenna", result: "The metal stays. The antenna has been asked to negotiate with physics over the air.", hours_cost: 1, risk_change: 8, sanity_change: -4, set_flags: ["rf_antenna_unverified"]}
            ]
        },
        {
            id: "PCB-0025",
            title: "HIGH-VOLTAGE CLEARANCE: TOO CLOSE FOR COMFORT",
            description: "Two high-voltage components encroach on a required safety spacing zone. This is no longer a layout preference; it is a potential safety failure. The keepout is not merely decorative.",
            choices: [
                {text: "Move components to meet the safety limits", result: "The spacing now meets reviewed requirements. The board no longer treats arcing as a connectivity feature.", hours_cost: 7, dfm_change: 5, risk_change: -3, sanity_change: -3},
                {text: "Request a formal safety engineering review", result: "Safety engineering approves a compliant disposition. The requirements outrank the placement aesthetics.", hours_cost: 4, days_cost: 1, dfm_change: 3, sanity_change: -2},
                {text: "Keep the crowded parts and sign a waiver", result: "The clearance risk remains. A waiver is paperwork, not an insulator.", hours_cost: 1, risk_change: 9, dfm_change: -7, sanity_change: -4, set_flags: ["hv_spacing_unverified"]}
            ]
        },
        {
            id: "PCB-0026",
            title: "MATING CONNECTOR: CONNECTOR CANNOT MATE",
            description: "The mating cable cannot be inserted once the board is inside the enclosure. The connector fits the PCB perfectly, which was apparently the only geometry anyone checked.",
            choices: [
                {text: "Reorient the connector for cable access", result: "The cable can now be installed. Product assembly may proceed without an interpretive dance.", hours_cost: 6, dfa_change: 5, sanity_change: -3},
                {text: "Coordinate a revised cable assembly", result: "The cable team approves a workable mating solution. Another drawing finally reflects reality.", hours_cost: 4, days_cost: 1, budget_change: -5, dfa_change: 3, sanity_change: -2},
                {text: "Connect the cable before closing the housing", result: "The assembly sequence becomes fragile. Repair technicians will one day read this instruction in disbelief.", hours_cost: 1, dfa_change: -6, risk_change: 5, sanity_change: -3, set_flags: ["connector_mating_access_limited"]}
            ]
        },
        {
            id: "PCB-0027",
            title: "PANEL RAILS VS. EDGE COMPONENTS",
            description: "SMD components invade the clearance needed for depanelization rails. The board looks compact, but the panel tooling would like somewhere to exist.",
            choices: [
                {text: "Move edge parts outside the rail area", result: "Fabrication has room for the panel rails. Components are no longer the sacrificial tooling.", hours_cost: 5, dfm_change: 5, sanity_change: -3},
                {text: "Ask fabrication for a new panel layout", result: "The fab approves a different panel strategy. It costs more than moving a part, but at least it is buildable.", hours_cost: 3, days_cost: 1, budget_change: -4, dfm_change: 3, sanity_change: -2},
                {text: "Leave the parts and hope depanelization is gentle", result: "Edge components remain at risk. The router has not promised to steer around them out of courtesy.", hours_cost: 1, dfm_change: -6, risk_change: 7, sanity_change: -3, set_flags: ["depanel_clearance_unverified"]}
            ]
        },
        {
            id: "PCB-0028",
            title: "BOTTOM-SIDE PART MEETS ENCLOSURE STANDOFF",
            description: "The assembly model shows a bottom-side component overlapping an enclosure standoff. Both occupy the same coordinates. One of them will lose, and it will probably be expensive.",
            choices: [
                {text: "Move the component away from the standoff", result: "The collision is removed. The PCB can now sit flat without turning the component into a mechanical fuse.", hours_cost: 5, dfa_change: 5, sanity_change: -3},
                {text: "Review a shorter approved standoff", result: "Mechanical engineering accepts a revised standoff. The enclosure and PCB are back on speaking terms.", hours_cost: 3, days_cost: 1, budget_change: -3, dfa_change: 2, sanity_change: -2},
                {text: "Assume the enclosure drawing must be wrong", result: "The collision remains because blaming the drawing does not move the metal.", hours_cost: 1, dfa_change: -6, risk_change: 6, sanity_change: -3, set_flags: ["standoff_collision_unverified"]}
            ]
        },
        {
            id: "PCB-0029",
            title: "HEAVY INDUCTOR: GRAVITY FILED A REPORT",
            description: "Vibration analysis predicts solder-joint fatigue on a heavy inductor. The component is doing an excellent impression of a pendulum. The solder joints were not hired as structural brackets.",
            choices: [
                {text: "Add support and adjust the placement", result: "The inductor is mechanically supported. Solder joints can return to their electrical duties.", hours_cost: 6, budget_change: -3, dfa_change: 3, risk_change: -3, sanity_change: -3},
                {text: "Review vibration and reinforcement options", result: "Engineering approves a reinforcement plan. The heavy part is now supported by something other than confidence.", hours_cost: 4, days_cost: 1, risk_change: -2, sanity_change: -2},
                {text: "Trust the solder joints to hold forever", result: "The vibration risk remains. Gravity appreciates your optimism but declines to sign the waiver.", hours_cost: 1, risk_change: 7, dfa_change: -4, sanity_change: -4, set_flags: ["vibration_support_unverified"]}
            ]
        },
        {
            // Required final Placement encounter. Never chosen early.
            id: "PLC-REVIEW-001",
            category: EventCategory.MILESTONE,
            title: "PLACEMENT REVIEW: EVERYONE HAS OPINIONS",
            description: "Placement is ready for signoff. Assembly, mechanical, electrical and test teams each have final comments, several of which begin with 'one quick thing.' Routing cannot start without a disposition.",
            choices: [
                {text: "Sign off the reviewed placement", result: "Placement is approved for routing. The component positions have earned more signatures than some mortgages.", hours_cost: 3, dfa_change: 2, dft_change: 1, sanity_change: -2},
                {text: "Hold one last cross-functional walkthrough", result: "The teams close open questions. One more meeting prevents a far more entertaining failure later.", hours_cost: 6, days_cost: 1, dfa_change: 4, dft_change: 2, sanity_change: -3},
                {text: "Approve with open issues clearly documented", result: "Placement advances with unresolved items. The action register is long, but at least it knows who owns the trouble.", hours_cost: 1, risk_change: 5, dfm_change: -3, sanity_change: -3, set_flags: ["placement_review_open_items"]}
            ]
        }
    ];

    return create_events_from_pack(EventStage.PLACEMENT, _specs);
}
