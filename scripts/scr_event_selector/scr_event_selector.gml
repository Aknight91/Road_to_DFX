
/// @description Stage-based event eligibility and selection

// --------------------------------------------------
// GET ELIGIBLE EVENTS FOR A PROJECT STAGE
// --------------------------------------------------

function get_eligible_stage_events(
    _library,
    _stage,
    _difficulty,
    _played_event_ids,
    _project_flags = []
)
{
    var _pool = get_event_pool(_library, _stage);
    var _eligible = [];

    for (var _i = 0; _i < array_length(_pool); _i++)
    {
        var _event = _pool[_i];

        // ----------------------------------------------
        // DIFFICULTY ELIGIBILITY
        // ----------------------------------------------

        if (_difficulty < _event.min_difficulty
        || _difficulty > _event.max_difficulty)
        {
            continue;
        }

        // ----------------------------------------------
        // PREVENT UNWANTED REPEATS
        // ----------------------------------------------

        if (array_contains(_played_event_ids, _event.id)
        && !_event.repeatable)
        {
            continue;
        }

        // ----------------------------------------------
        // REQUIRED PROJECT FLAGS
        // ----------------------------------------------

        var _requirements_met = true;

        for (
            var _r = 0;
            _r < array_length(_event.required_flags);
            _r++
        )
        {
            if (!array_contains(
                _project_flags,
                _event.required_flags[_r]
            ))
            {
                _requirements_met = false;
                break;
            }
        }

        if (!_requirements_met)
        {
            continue;
        }

        // ----------------------------------------------
        // BLOCKED PROJECT FLAGS
        // ----------------------------------------------

        var _blocked = false;

        for (
            var _b = 0;
            _b < array_length(_event.blocked_flags);
            _b++
        )
        {
            if (array_contains(
                _project_flags,
                _event.blocked_flags[_b]
            ))
            {
                _blocked = true;
                break;
            }
        }

        if (_blocked)
        {
            continue;
        }

        // Event satisfies all implemented conditions
        array_push(_eligible, _event);
    }

    return _eligible;
}

// --------------------------------------------------
// SELECT A WEIGHTED RANDOM EVENT
// --------------------------------------------------

// Receives an array of eligible events.
// Returns one event without modifying the array.
//
// Events with a weight of zero or less are ignored.
// Returns undefined if nothing can be selected.

function select_weighted_event(_eligible_events)
{
    var _total_weight = 0;
    var _last_valid_event = undefined;

    // Calculate the total available weight
    for (
        var _i = 0;
        _i < array_length(_eligible_events);
        _i++
    )
    {
        var _event = _eligible_events[_i];

        if (_event.weight > 0)
        {
            _total_weight += _event.weight;
            _last_valid_event = _event;
        }
    }

    // Nothing eligible for selection
    if (_total_weight <= 0)
    {
        return undefined;
    }

    // Choose a random point within the total weight
    var _roll = random(_total_weight);
    var _running_weight = 0;

    // Find the event containing that random point
    for (
        var _j = 0;
        _j < array_length(_eligible_events);
        _j++
    )
    {
        var _candidate = _eligible_events[_j];

        if (_candidate.weight <= 0)
        {
            continue;
        }

        _running_weight += _candidate.weight;

        if (_roll < _running_weight)
        {
            return _candidate;
        }
    }

    // Floating-point safety fallback
    return _last_valid_event;
}

// --------------------------------------------------
// SELECT NEXT EVENT FOR A PROJECT STAGE
// --------------------------------------------------

// Combines event eligibility and weighted selection.
//
// This function does not modify campaign history.
// The event will be recorded when it is presented
// to the player in a later implementation step.

function select_next_stage_event(
    _library,
    _stage,
    _difficulty,
    _played_event_ids,
    _project_flags
)
{
    // Get events matching the current campaign state
    var _eligible = get_eligible_stage_events(
        _library,
        _stage,
        _difficulty,
        _played_event_ids,
        _project_flags
    );

    // Select one event using its relative weight
    return select_weighted_event(_eligible);
}

// --------------------------------------------------
// SELECT A SCHEDULED STAGE EVENT
// --------------------------------------------------

// Selects an eligible event while reserving mandatory
// stage checkpoints for their scheduled final slot.
//
// Returns undefined if no valid event is available.
// Does not change campaign state or event history.

function select_scheduled_stage_event(_campaign)
{
    var _stage = _campaign.current_event_stage;
    var _targets = _campaign.campaign_stage_targets;
    var _completed = _campaign.campaign_stage_events_completed;

    // Reject invalid schedule data
    if (!is_array(_targets) || !is_array(_completed))
    {
        return undefined;
    }

    if (_stage < EventStage.DESIGN_SETUP
    || _stage > EventStage.RELEASE
    || _stage >= array_length(_targets)
    || _stage >= array_length(_completed))
    {
        return undefined;
    }

    // Do not select events beyond the stage target
    if (_targets[_stage] < 1
    || _completed[_stage] < 0
    || _completed[_stage] >= _targets[_stage])
    {
        return undefined;
    }

    // Determine whether a mandatory review is due
    var _checkpoint_id = get_due_stage_checkpoint_id(
        _campaign
    );

    // Apply the existing eligibility rules
    var _eligible = get_eligible_stage_events(
        _campaign.event_library,
        _stage,
        _campaign.selected_campaign_difficulty,
        _campaign.played_event_ids,
        _campaign.project_flags
    );

    // ----------------------------------------------
    // MANDATORY CHECKPOINT SELECTION
    // ----------------------------------------------

    if (_checkpoint_id != "")
    {
        for (var _i = 0; _i < array_length(_eligible); _i++)
        {
            if (_eligible[_i].id == _checkpoint_id)
            {
                return _eligible[_i];
            }
        }

        // Never replace a missing mandatory checkpoint
        // with a random engineering event.
        show_debug_message(
            "CHECKPOINT SELECTOR: Missing or ineligible "
            + _checkpoint_id
        );

        return undefined;
    }

    // ----------------------------------------------
    // ORDINARY EVENT SELECTION
    // ----------------------------------------------

    var _regular_events = [];

    for (var _j = 0; _j < array_length(_eligible); _j++)
    {
        var _candidate = _eligible[_j];
		
// Consequence events do not occupy scheduled
// engineering event slots.
//
// They will be handled separately as immediate
// or delayed interruptions.

if (variable_struct_exists(
    _candidate,
    "is_consequence"
))
{
    if (_candidate.is_consequence)
    {
        continue;
    }
}


        // Mandatory checkpoints cannot appear early.
        if (_candidate.id == "PLC-REVIEW-001"
        || _candidate.id == "RTE-REVIEW-001"
        || _candidate.id == "REL-SIGNOFF-001")
        {
            continue;
        }

        array_push(_regular_events, _candidate);
    }

    // Preserve existing weighted random selection
    return select_weighted_event(_regular_events);
}

// --------------------------------------------------
// SELECT AN ELIGIBLE CONSEQUENCE EVENT
// --------------------------------------------------

// Finds consequence events available during the
// current engineering stage.
//
// Uses existing difficulty, history, and project
// flag eligibility rules.
//
// Does not select scheduled engineering events.
// Does not modify campaign state.
//
// Returns undefined when no consequence is eligible.

function select_stage_consequence_event(_campaign)
{
    var _eligible = get_eligible_stage_events(
        _campaign.event_library,
        _campaign.current_event_stage,
        _campaign.selected_campaign_difficulty,
        _campaign.played_event_ids,
        _campaign.project_flags
    );

    var _consequences = [];

    for (
        var _i = 0;
        _i < array_length(_eligible);
        _i++
    )
    {
        var _event = _eligible[_i];

        // Only include explicitly marked consequences.
        if (variable_struct_exists(
            _event,
            "is_consequence"
        ))
        {
            if (_event.is_consequence)
            {
                array_push(_consequences, _event);
            }
        }
    }

    // Use the existing weighted event selector.
    // Returns undefined if no consequence qualifies.
    return select_weighted_event(_consequences);
}