/// @description Ask for Advice - coworker roster and campaign assignment

// A stable 15-person roster. The first three are established
// characters; the remaining twelve are temporary placeholders
// to make the selection mechanic playable before NPC writing.
function advice_get_roster()
{
    return [
        { id: "npc_moose", name: "Moose", role: "PCB Designer", personality: "methodical", placeholder: false },
        { id: "npc_sparky", name: "Sparky Malone", role: "PCB Designer", personality: "unconventional", placeholder: false },
        { id: "npc_tyler", name: "Tyler 'Rick' James", role: "PCB Designer", personality: "prankster", placeholder: false },

        { id: "npc_004", name: "Coworker 04 (TBD)", role: "Electrical Engineer", personality: "TBD", placeholder: true },
        { id: "npc_005", name: "Coworker 05 (TBD)", role: "Mechanical Engineer", personality: "TBD", placeholder: true },
        { id: "npc_006", name: "Coworker 06 (TBD)", role: "Firmware Engineer", personality: "TBD", placeholder: true },
        { id: "npc_007", name: "Coworker 07 (TBD)", role: "CAM Engineer", personality: "TBD", placeholder: true },
        { id: "npc_008", name: "Coworker 08 (TBD)", role: "PCB Fabrication Operator", personality: "TBD", placeholder: true },
        { id: "npc_009", name: "Coworker 09 (TBD)", role: "Process Engineer", personality: "TBD", placeholder: true },
        { id: "npc_010", name: "Coworker 10 (TBD)", role: "SMT Assembly Technician", personality: "TBD", placeholder: true },
        { id: "npc_011", name: "Coworker 11 (TBD)", role: "Test Engineer", personality: "TBD", placeholder: true },
        { id: "npc_012", name: "Coworker 12 (TBD)", role: "Quality Engineer", personality: "TBD", placeholder: true },
        { id: "npc_013", name: "Coworker 13 (TBD)", role: "Supply Chain Specialist", personality: "TBD", placeholder: true },
        { id: "npc_014", name: "Coworker 14 (TBD)", role: "Program Manager", personality: "TBD", placeholder: true },
        { id: "npc_015", name: "Coworker 15 (TBD)", role: "Reliability Engineer", personality: "TBD", placeholder: true }
    ];
}

// Called once when a new campaign starts or restarts.
// Uses the standalone campaign-state module from Part 1.
function advice_start_campaign()
{
    var _state = advice_create_campaign_state(advice_get_roster());

    if (is_struct(_state))
    {
        show_debug_message(
            "ADVICE: Assigned coworkers: "
            + _state.coworkers[0].name + ", "
            + _state.coworkers[1].name + ", "
            + _state.coworkers[2].name
        );
    }

    return _state;
}
