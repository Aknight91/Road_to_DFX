/// @description PCB Release: deliverables and mandatory final signoff
// Stage-specific content only; uses existing event schema and campaign selector.
// Do not add event-selection logic, balancing systems, or release shortcuts here.

function create_pcb_release()
{
    var _specs = [
        {
            id: "PCB-0055",
            title: "FINAL OUTPUTS CONTAIN THREE DIFFERENT REVISIONS",
            description: "The Gerbers, drill data and fabrication drawing each claim a different revision. Every file is named FINAL. A fourth file is named FINAL_FOR_REAL and somehow makes the situation worse.",
            choices: [
                {
                    text: "Rebuild one controlled release package and verify revisions",
                    result: "All manufacturing outputs now match the approved database revision. The word final has regained a small amount of meaning.",
                    hours_cost: 4,
                    dfm_change: 2,
                    risk_change: -3,
                    sanity_change: -2
                },
                {
                    text: "Have engineering and CAM reconcile the release manifest",
                    result: "The release set is reviewed and signed as one revision. One day is lost to preventing six months of arguing.",
                    hours_cost: 2,
                    days_cost: 1,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Send all versions and ask the fabricator to pick",
                    result: "The board shop receives a multiple-choice manufacturing order with no answer key. Congratulations on pioneering collaborative scrap.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfm_change: -5,
                    sanity_change: -4,
                    set_flags: ["mixed_revision_release"]
                }
            ]
        },
        {
            id: "PCB-0056",
            title: "ASSEMBLY DRAWING AND BOM HAVE DIFFERENT OPINIONS",
            description: "The assembly drawing calls out a component that does not match the approved BOM. Both documents have signatures. Procurement would like to know whether a signature is a substitute for a part number.",
            choices: [
                {
                    text: "Reconcile assembly outputs against the approved BOM",
                    result: "The assembly drawing, pick-and-place data and BOM now agree. The line can load actual components without interpreting office politics.",
                    hours_cost: 4,
                    dfa_change: 3,
                    dft_change: 1,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Request a controlled ECAD and assembly review",
                    result: "The teams issue a signed correction and prevent an unintended substitution. The review meeting produces a useful document.",
                    hours_cost: 2,
                    days_cost: 1,
                    dfa_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Release it with a note that the assembler will understand",
                    result: "Assembly must guess which part you meant. The production supervisor is composing an email in all capital letters.",
                    hours_cost: 1,
                    risk_change: 6,
                    dfa_change: -5,
                    sanity_change: -3,
                    set_flags: ["assembly_bom_mismatch"]
                }
            ]
        },
        {
            id: "PCB-0057",
            title: "FINAL TEST PLAN FEATURES AN IMPRESSIVE BLIND SPOT",
            description: "Production test coverage has no meaningful check for a critical reset signal. The report is green because nobody added a test to turn it red. A remarkable achievement in spreadsheet design.",
            choices: [
                {
                    text: "Add and validate production coverage for the reset net",
                    result: "Test engineering validates the new check. The green report now corresponds to something the hardware actually does.",
                    hours_cost: 5,
                    dft_change: 5,
                    risk_change: -2,
                    sanity_change: -3
                },
                {
                    text: "Arrange a documented alternate coverage strategy",
                    result: "Test approves a substitute method and updates release records. The gap is smaller and no longer hiding behind a percent sign.",
                    hours_cost: 3,
                    days_cost: 1,
                    dft_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Declare untested nets a future improvement opportunity",
                    result: "The reset signal remains untested. The phrase future improvement will not help when the production fixture cannot identify a failure.",
                    hours_cost: 1,
                    dft_change: -6,
                    risk_change: 5,
                    sanity_change: -3,
                    set_flags: ["test_release_gap"]
                }
            ]
        },
        {
            id: "PCB-0058",
            title: "CUSTOMER SIGNOFF ARRIVED AS A THUMBS-UP EMOJI",
            description: "The customer approved the latest change by replying with a thumbs-up. Quality requests formal approval against the actual revision. Sales has decided the emoji is legally binding because it is blue.",
            choices: [
                {
                    text: "Get formal, revision-specific customer approval",
                    result: "The authorized reviewer signs the correct revision. The emoji can return to its natural habitat: lunch scheduling.",
                    hours_cost: 2,
                    days_cost: 1,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Escalate the approval gap before release",
                    result: "The project lead obtains documented disposition. The deadline survives less comfortably than the audit trail.",
                    hours_cost: 3,
                    days_cost: 1,
                    risk_change: -1,
                    sanity_change: -2
                },
                {
                    text: "Treat the emoji as a fully approved change order",
                    result: "The release now depends on the legal weight of a cartoon hand. Quality is saving screenshots for reasons unrelated to celebration.",
                    hours_cost: 1,
                    risk_change: 6,
                    sanity_change: -3,
                    set_flags: ["customer_signoff_unverified"]
                }
            ]
        },
        {
            id: "PCB-0059",
            title: "RELEASE ARCHIVE CONTAINS DRAFT, DRAFT2 AND A FINAL FINAL",
            description: "The handoff ZIP contains old plots, a draft stackup and two folders called Do Not Use. The manufacturing team asks for a release manifest. Your archive currently offers archaeology instead.",
            choices: [
                {
                    text: "Build a clean package with a verified file manifest",
                    result: "The package is rebuilt and verified against the released design. Manufacturing no longer needs a degree in forensic file naming.",
                    hours_cost: 4,
                    dfm_change: 2,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Run an independent release-data comparison",
                    result: "A second reviewer removes obsolete outputs and signs the manifest. The handoff is boring in the best possible way.",
                    hours_cost: 2,
                    days_cost: 1,
                    risk_change: -1,
                    sanity_change: -2
                },
                {
                    text: "Send the ZIP as-is and label it urgent",
                    result: "The archive is delivered at impressive speed. The factory receives every draft you ever considered, including several you hoped to forget.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfm_change: -4,
                    sanity_change: -4,
                    set_flags: ["release_archive_unverified"]
                }
            ]
        },
        {
            id: "REL-SIGNOFF-001",
            title: "FINAL DESIGN SIGNOFF: THE POINT OF NO RETURN",
            description: "The design has survived intake, placement, routing and CAM review. Fabrication, test and quality are waiting for the final released revision. Management has already informed the customer that everything is definitely fine. Your signature is the last remaining obstacle to that claim.",
            choices: [
                {
                    text: "Complete the controlled signoff and release the verified package",
                    result: "The final revision is checked, signed and transferred to manufacturing. Whatever happens next will at least happen to the files you intended to ship.",
                    hours_cost: 3,
                    dfm_change: 1,
                    dft_change: 1,
                    risk_change: -2,
                    sanity_change: -2
                },
                {
                    text: "Run one final cross-functional release review",
                    result: "Engineering, CAM, test and quality confirm the released package. The meeting takes longer, but the list of unknowns becomes shorter.",
                    hours_cost: 5,
                    days_cost: 1,
                    dfm_change: 2,
                    dft_change: 2,
                    risk_change: -3,
                    sanity_change: -3
                },
                {
                    text: "Release with the unresolved risks prominently documented",
                    result: "The design is signed and released with open risks. Management can no longer claim it was unaware, although it may make a spirited attempt.",
                    hours_cost: 1,
                    risk_change: 6,
                    dfm_change: -4,
                    sanity_change: -3,
                    set_flags: ["release_signed_with_open_risks"]
                }
            ],
            category: EventCategory.MILESTONE
        }
    ];

    return create_events_from_pack(EventStage.RELEASE, _specs);
}
