/// @description PCB Placement events and existing Placement content pack
// Component sourcing that affects placement belongs here, not database intake.

function create_pcb_placement()
{
    var _specs = [
        {
            id: "PCB-0005",
            category: EventCategory.RESOURCE,
            title: "CONNECTOR LEAD TIME: SIX MONTHS OF NO",
            description: "Purchasing discovers the specified connector has a 26-week lead time. Production starts considerably sooner. The part is available just in time for the next product generation.",
            choices: [
                {
                    text: "Qualify an available alternate connector",
                    result: "An alternate passes engineering review and enters the BOM. A real component replaces a very attractive delivery estimate.",
                    hours_cost: 6,
                    risk_change: -2,
                    dfm_change: 3,
                    sanity_change: -3
                },
                {
                    text: "Pay the premium for the original part",
                    result: "Purchasing finds scarce stock. Finance calls it a learning opportunity; the invoice calls it something else.",
                    hours_cost: 1,
                    days_cost: 1,
                    budget_change: -15,
                    sanity_change: -1
                },
                {
                    text: "Redesign around a stocked connector",
                    result: "The interface is redesigned around available hardware. Extra work now saves a suspense thriller at production release.",
                    hours_cost: 10,
                    dfa_change: 4,
                    dfm_change: 2,
                    sanity_change: -4
                },
                {
                    text: "Keep the BOM and trust the supply chain",
                    result: "The original connector remains unavailable. Your sourcing strategy is now an inspirational poster about patience.",
                    risk_change: 7,
                    dfm_change: -5,
                    sanity_change: -3,
                    set_flags: ["connector_supply_unresolved"]
                }
            ]
        },
        {
            id: "PCB-0009",
            category: EventCategory.ENGINEERING,
            title: "ASSEMBLY TOOLING VS. GIANT CAPACITOR",
            description: "The tall capacitor blocks pick-and-place access to neighboring SMD parts. The machine cannot reach through solid objects, despite what the schedule appears to believe.",
            choices: [
                {
                    text: "Move the capacitor and nearby parts",
                    result: "The placement clears the assembly tooling. Physics wins this meeting without needing a PowerPoint.",
                    hours_cost: 6,
                    dfa_change: 5,
                    dfm_change: 2,
                    sanity_change: -3
                },
                {
                    text: "Ask assembly to qualify special tooling",
                    result: "Assembly approves a more expensive process. The tooling can now do what the layout was supposed to allow.",
                    hours_cost: 3,
                    days_cost: 1,
                    budget_change: -5,
                    dfa_change: 2,
                    sanity_change: -2
                },
                {
                    text: "Select a qualified low-profile capacitor",
                    result: "The replacement fits the assembly envelope. Purchasing receives another unexpected character-development arc.",
                    hours_cost: 8,
                    budget_change: -8,
                    dfa_change: 4,
                    dfm_change: 3,
                    sanity_change: -4
                },
                {
                    text: "Keep it and make assembly work manually",
                    result: "Placement stays. Assembly inherits extra handwork, extra risk, and a fresh reason to hate this board.",
                    hours_cost: 1,
                    risk_change: 7,
                    dfa_change: -6,
                    sanity_change: -3,
                    set_flags: ["assembly_access_unverified"]
                }
            ]
        }
    ];

    var _events = create_events_from_pack(EventStage.PLACEMENT, _specs);

    // Preserved, tested pack in the existing Script33 resource.
    var _pack = create_pcb_placement_pack_01();

    static _pack_qa_reported = false;
    if (!_pack_qa_reported)
    {
        _pack_qa_reported = true;
        show_debug_message(
            "EVENT PACK QA: Placement pack 01 count = "
            + string(array_length(_pack))
            + (array_length(_pack) == 21 ? " (PASS)" : " (FAILED)")
        );
    }

    for (var _i = 0; _i < array_length(_pack); _i++)
    {
        array_push(_events, _pack[_i]);
    }

    return _events;
}

// Compatibility with the previous public function name.
function create_pcb_placement_event_pool()
{
    return create_pcb_placement();
}
