/// @description Manufacturer Review conditional consequence events
// Owns PCB-0002, the netlist audit caused by unverified CAD recovery.
// Normal manufacturer review events will be added in a later pack.

function create_pcb_manufacturer_review()
{
    var _specs = [
        {
            id: "PCB-0002",
            category: EventCategory.SETBACK,
            title: "NETLIST AUDIT: CONNECTIONS HAVE VANISHED",
            description: "CAM compares the routed database to the netlist after the CAD crash and finds missing electrical connections. The nets did not move. They simply ceased to exist, which management is calling a documentation discrepancy.",
            required_flags: ["cad_changes_unverified"],
            is_consequence: true,
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
            ]
        }
    ];

    return create_events_from_pack(EventStage.MANUFACTURER_REVIEW, _specs);
}
