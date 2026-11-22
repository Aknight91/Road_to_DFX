/// @description Ask for Advice - campaign roster and per-encounter consultation state
/// @note Standalone module. No obj_game Create/Step code is required for Part 1.

// Select three distinct coworkers from the full 15-person roster.
// This is called ONCE per campaign, not on every visit to the advice screen.
function advice_create_campaign_state(_roster)
{
    if (!is_array(_roster) || array_length(_roster) != 15)
    {
        show_debug_message("ADVICE: Expected exactly 15 coworkers in the roster.");
        return undefined;
    }

    // Validate stable, unique IDs so characters cannot appear twice.
    var _seen_ids = [];

    for (var _i = 0; _i < array_length(_roster); _i++)
    {
        var _npc = _roster[_i];

        if (!is_struct(_npc)
        || !variable_struct_exists(_npc, "id")
        || !is_string(_npc.id)
        || _npc.id == "")
        {
            show_debug_message("ADVICE: Missing or invalid coworker ID.");
            return undefined;
        }

        for (var _j = 0; _j < array_length(_seen_ids); _j++)
        {
            if (_seen_ids[_j] == _npc.id)
            {
                show_debug_message("ADVICE: Duplicate coworker ID: " + _npc.id);
                return undefined;
            }
        }

        array_push(_seen_ids, _npc.id);
    }

    var _shuffled = array_shuffle(_roster);
    var _selected = [];

    for (var _k = 0; _k < 3; _k++)
    {
        array_push(_selected, variable_clone(_shuffled[_k]));
    }

    return {
        coworkers: _selected,
        encounter_id: "",
        consulted_ids: [],
        unlocked_choices: []
    };
}

// Move into a new encounter without rerolling the campaign's three coworkers.
// Returning from an office to the SAME encounter preserves consultation history.
function advice_begin_encounter(_state, _encounter_id)
{
    if (!is_struct(_state) || !is_string(_encounter_id) || _encounter_id == "")
    {
        return false;
    }

    if (_state.encounter_id != _encounter_id)
    {
        _state.encounter_id = _encounter_id;
        _state.consulted_ids = [];
        _state.unlocked_choices = [];
    }

    return true;
}

// A coworker can be consulted once per encounter, but all three are eligible.
function advice_can_consult(_state, _coworker_id)
{
    if (!is_struct(_state) || _state.encounter_id == "")
    {
        return false;
    }

    var _assigned = false;

    for (var _i = 0; _i < array_length(_state.coworkers); _i++)
    {
        if (_state.coworkers[_i].id == _coworker_id)
        {
            _assigned = true;
            break;
        }
    }

    if (!_assigned)
    {
        return false;
    }

    for (var _j = 0; _j < array_length(_state.consulted_ids); _j++)
    {
        if (_state.consulted_ids[_j] == _coworker_id)
        {
            return false;
        }
    }

    return true;
}

// Call only AFTER the separate consultation-cost logic succeeds.
// This function deliberately does not change hours, calendar, or choices.
function advice_record_consultation(_state, _coworker_id)
{
    if (!advice_can_consult(_state, _coworker_id))
    {
        return false;
    }

    array_push(_state.consulted_ids, _coworker_id);
    return true;
}
