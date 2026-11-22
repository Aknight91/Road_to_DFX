/// @description Water Cooler - campaign state, milestone availability and chat data
// Step 68A. Self-contained activity rules; no story or controller logic here.

// Called once by start_campaign() on every NEW or RESTARTED campaign.
function water_cooler_new_campaign_state()
{
    return {
        used_stages: [],
        viewing_stage: -1,
        visit_complete: false,
        last_result: "",
        last_error: ""
    };
}

// "One conversation per milestone stop" means once per EventStage.
// The stage is read from existing campaign progress; no new scheduler.
function water_cooler_stage_used(_state, _stage)
{
    if (!is_struct(_state))
    {
        return true;
    }

    for (var _i = 0; _i < array_length(_state.used_stages); _i++)
    {
        if (_state.used_stages[_i] == _stage)
        {
            return true;
        }
    }
    return false;
}

// Visits are optional and free; the conversation itself costs time.
// Only uncompleted gameplay encounters in a stage offer the activity.
function water_cooler_can_enter(_game)
{
    if (!instance_exists(_game)
    || !variable_instance_exists(_game, "water_cooler_state")
    || !is_struct(_game.water_cooler_state)
    || !is_struct(_game.active_encounter)
    || _game.get_campaign_phase() != CampaignPhase.CHOOSING)
    {
        return false;
    }

    if (water_cooler_stage_used(
        _game.water_cooler_state, _game.current_event_stage
    ))
    {
        return false;
    }

    // At least the one-hour option must be affordable.
    return _game.engineering_hours >= 1;
}
