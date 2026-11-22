/// @description Road to DFX - encounter-aware coworker dialogue and tradeoff text
// STEP 66 PART 5B
// Presentation-only analysis of the ACTUAL current encounter and chosen option.
// This module never charges engineering hours or changes campaign stats.
// NPCs 04-15 retain their temporary names; their lines reflect their roles.

// Identify the engineering issue by its event data, not hallway position.
// Recognized events get a specific topic; other events use a conservative
// keyword fallback, then a generic engineering-review topic.
function advice_get_event_topic(_event)
{
    if (!is_struct(_event))
    {
        return "general";
    }

    switch (_event.id)
    {
        case "PCB-0001": return "cad_recovery";
        case "PCB-0002": return "netlist";
        case "PCB-0003": return "stackup";
        case "PCB-0009": return "assembly";
        case "PCB-0004": return "mechanical";
        case "PCB-0005": return "supply";
        case "PCB-0006": return "footprint";
        case "PCB-0007": return "drill";
        case "PCB-0008": return "clearance";
    }

    var _words = string_lower(_event.title + " " + _event.description);

    if (string_pos("backorder", _words) > 0
    || string_pos("supplier", _words) > 0
    || string_pos("inventory", _words) > 0
    || string_pos("component shortage", _words) > 0)
    {
        return "supply";
    }

    if (string_pos("footprint", _words) > 0
    || string_pos("pad size", _words) > 0)
    {
        return "footprint";
    }

    if (string_pos("drill", _words) > 0
    || string_pos("hole size", _words) > 0)
    {
        return "drill";
    }

    if (string_pos("clearance", _words) > 0
    || string_pos("spacing", _words) > 0)
    {
        return "clearance";
    }

    if (string_pos("enclosure", _words) > 0
    || string_pos("housing", _words) > 0
    || string_pos("mounting", _words) > 0)
    {
        return "mechanical";
    }

    if (string_pos("test", _words) > 0
    || string_pos("fixture", _words) > 0
    || string_pos("probe", _words) > 0
    || string_pos("coverage", _words) > 0)
    {
        return "test";
    }

    if (string_pos("assembly", _words) > 0
    || string_pos("placement", _words) > 0
    || string_pos("pick-and-place", _words) > 0
    || string_pos("solder", _words) > 0)
    {
        return "assembly";
    }

    if (string_pos("stackup", _words) > 0
    || string_pos("impedance", _words) > 0)
    {
        return "stackup";
    }

    if (string_pos("fab", _words) > 0
    || string_pos("cam", _words) > 0
    || string_pos("via", _words) > 0
    || string_pos("copper", _words) > 0
    || string_pos("mask", _words) > 0
    || string_pos("manufactur", _words) > 0)
    {
        return "fabrication";
    }

    if (string_pos("netlist", _words) > 0
    || string_pos("routing", _words) > 0
    || string_pos("net", _words) > 0
    || string_pos("signal", _words) > 0)
    {
        return "netlist";
    }

    if (string_pos("cad", _words) > 0
    || string_pos("software", _words) > 0
    || string_pos("crash", _words) > 0)
    {
        return "cad_recovery";
    }

    if (string_pos("deadline", _words) > 0
    || string_pos("schedule", _words) > 0
    || string_pos("release", _words) > 0)
    {
        return "schedule";
    }

    return "general";
}

// A plain description of the specific problem being discussed.
function advice_issue_name(_topic)
{
    switch (_topic)
    {
        case "cad_recovery": return "the CAD recovery";
        case "netlist": return "the connection and netlist issue";
        case "stackup": return "the stackup and impedance question";
        case "mechanical": return "the enclosure and mechanical revision";
        case "supply": return "the component availability issue";
        case "footprint": return "the footprint mismatch";
        case "drill": return "the unsupported drill size";
        case "clearance": return "the clearance requirement";
        case "assembly": return "the assembly-access problem";
        case "fabrication": return "the fabrication concern";
        case "test": return "the test-coverage problem";
        case "schedule": return "the schedule and release pressure";
        default: return "this engineering decision";
    }
}

// The first three characters have distinct voices. Moose remains a LITERAL
// moose: its 'advice' comes through the player's interpretation of gestures,
// never human speech. Placeholder characters have specialty-specific lines.
function advice_npc_line(_npc, _topic)
{
    var _issue = advice_issue_name(_topic);

    switch (_npc.id)
    {
        case "npc_moose":
            if (_topic == "test" || _topic == "netlist")
            {
                return "Moose snorts and noses a page of checks toward you. You take the hint: verify first.";
            }
            return "Moose studies " + _issue
                + ", then nudges your checklist. You interpret that as a warning.";

        case "npc_sparky":
            if (_topic == "cad_recovery")
            {
                return "Sparky: 'Autosave is a theory until you've opened the file. Check it.'";
            }
            return "Sparky: 'I've seen " + _issue
                + " chew up a Friday. Pick the fix you can actually finish.'";

        case "npc_tyler":
            if (_topic == "schedule")
            {
                return "Tyler: 'The deadline isn't a suggestion, but neither is a working circuit.'";
            }
            return "Tyler: 'If " + _issue
                + " makes tomorrow's meeting, at least bring a plan.'";

        case "npc_004":
            return "Electrical: 'Check the net-level impact before signing off on " + _issue + ".'";
        case "npc_005":
            return "Mechanical: 'For " + _issue + ", check fit, clearance, and access before committing.'";
        case "npc_006":
            return "Firmware: 'If " + _issue + " fails at bring-up, how will we isolate it?'";
        case "npc_007":
            return "CAM: 'For " + _issue + ", I build what you send, not what you meant.'";
        case "npc_008":
            return "Fab floor: 'Will the fix for " + _issue + " still work on a full production panel?'";
        case "npc_009":
            return "Process: 'For " + _issue + ", choose a process the next shift can repeat.'";
        case "npc_010":
            return "SMT: 'Check whether " + _issue + " still allows machine placement and inspection.'";
        case "npc_011":
            return "Test: 'What check will catch a failure caused by " + _issue + "?'";
        case "npc_012":
            return "Quality: 'For " + _issue + ", close the escape path, not just the symptom.'";
        case "npc_013":
            return "Supply chain: 'For " + _issue + ", verify stock and qualified alternates.'";
        case "npc_014":
            return "Program: 'Before tackling " + _issue + ", tell me the hours and schedule impact.'";
        case "npc_015":
            return "Reliability: 'What will " + _issue + " look like after thermal cycling?'";
    }

    return "The coworker asks you to consider the risks in " + _issue + ".";
}

// Event-specific engineering warning that works for any advisor.
// This is explanatory text only, not a newly invented game consequence.
function advice_event_caution(_topic)
{
    switch (_topic)
    {
        case "cad_recovery":
            return "Context: recovered design data still needs verification.";
        case "netlist":
            return "Context: a missing connection can survive a clean-looking layout.";
        case "stackup":
            return "Context: a stackup change can alter manufacturing and impedance.";
        case "mechanical":
            return "Context: an enclosure revision can affect mounting, fit, and access.";
        case "supply":
            return "Context: an unavailable component can change cost and schedule.";
        case "footprint":
            return "Context: a footprint mismatch can invalidate assembly assumptions.";
        case "drill":
            return "Context: an unsupported hole size needs fabricator approval.";
        case "clearance":
            return "Context: missing clearance rules can hide physical violations.";
        case "assembly":
            return "Context: assembly access and repeatability affect production.";
        case "fabrication":
            return "Context: fabrication limitations can turn a small detail into scrap.";
        case "test":
            return "Context: a defect you cannot detect may escape to production.";
        case "schedule":
            return "Context: schedule gains are only useful if release remains viable.";
        default:
            return "Context: consider the downstream effects of the chosen action.";
    }
}

// Describe actual NEGATIVE consequences present in the FINAL follow choice.
// Use the existing option's fields, including the previously-applied bonus.
// Keep the office display brief (up to two points plus a qualifier).
function advice_choice_tradeoffs(_choice)
{
    var _items = [];

    if (_choice.drc_change > 0)
    {
        array_push(_items, "DRCs +" + string(_choice.drc_change));
    }
    if (_choice.risk_change > 0)
    {
        array_push(_items, "manufacturing risk +" + string(_choice.risk_change));
    }
    if (_choice.dfa_change < 0)
    {
        array_push(_items, "DFA " + string(_choice.dfa_change));
    }
    if (_choice.dfm_change < 0)
    {
        array_push(_items, "DFM " + string(_choice.dfm_change));
    }
    if (_choice.dft_change < 0)
    {
        array_push(_items, "DFT " + string(_choice.dft_change));
    }
    if (_choice.sanity_change < 0)
    {
        array_push(_items, "Sanity " + string(_choice.sanity_change));
    }
    if (_choice.days_cost > 0)
    {
        array_push(_items, "schedule delay " + string(_choice.days_cost) + " day(s)");
    }
    if (_choice.hours_cost > 0)
    {
        array_push(_items, "decision uses " + string(_choice.hours_cost) + " hour(s)");
    }

    if (array_length(_items) == 0)
    {
        return "No direct negative stat changes in this option.";
    }

    var _count = min(2, array_length(_items));
    var _line = "";
    for (var _i = 0; _i < _count; _i++)
    {
        if (_i > 0)
        {
            _line += "; ";
        }
        _line += _items[_i];
    }

    if (array_length(_items) > _count)
    {
        _line += "; other costs also apply";
    }

    return _line;
}

// Preserve both the event-aware dialogue and its inspectable risk note.
function advice_build_dialogue(_npc, _event, _follow_choice)
{
    var _topic = advice_get_event_topic(_event);

    // Include the ACTIVE encounter in the dialogue itself. The office
    // draws advice_dialogue, not advice_context, so a generic NPC line
    // alone could look identical across consecutive encounters.
    var _current_event = "RE: " + _event.title;
    var _line = advice_npc_line(_npc, _topic);

    // A single diagnostic per actual consultation, never per frame.
    show_debug_message(
        "ADVICE DIALOGUE: " + _event.id
        + " | " + _topic
        + " | " + _npc.id
    );

    return {
        topic: _topic,
        line: _current_event + "\n" + _line,
        context: advice_event_caution(_topic),
        tradeoffs: advice_choice_tradeoffs(_follow_choice)
    };
}
