
/// @description Prepare events for player presentation

// --------------------------------------------------
// PREPARE AN EVENT ENCOUNTER
// --------------------------------------------------

// Creates an independent copy of an event and
// randomizes the order of its choices.
//
// Call this ONCE when an event is selected.
// Never call it repeatedly while drawing buttons.

function prepare_event_encounter(_event_definition)
{
    // Reject invalid event definitions
    if (!is_struct(_event_definition))
    {
        return undefined;
    }

    if (!is_array(_event_definition.choices))
    {
        return undefined;
    }

    // Clone the event and all nested choice data.
    // The permanent event library remains unchanged.
    var _encounter = variable_clone(_event_definition);

    // Shuffle whole choice structs, preserving all
    // resource costs, results, flags, and backfire data.
    _encounter.choices = array_shuffle(
        _encounter.choices
    );

    return _encounter;
}

// --------------------------------------------------
// SELECT AND PREPARE A STAGE ENCOUNTER
// --------------------------------------------------

// Selects an eligible event from the current stage
// and prepares an independent shuffled encounter.
//
// Does not modify campaign history or the library.
// Returns undefined when no event is available.

function select_and_prepare_stage_encounter(
    _library,
    _stage,
    _difficulty,
    _played_event_ids,
    _project_flags
)
{
    // Select an event using eligibility and weights
    var _event_definition = select_next_stage_event(
        _library,
        _stage,
        _difficulty,
        _played_event_ids,
        _project_flags
    );

    // No eligible event was found
    if (!is_struct(_event_definition))
    {
        return undefined;
    }

    // Clone the event and shuffle its choices
    var _encounter = prepare_event_encounter(
        _event_definition
    );

    return _encounter;
}

// --------------------------------------------------
// BEGIN A CAMPAIGN ENCOUNTER
// --------------------------------------------------

// Selects and stores an encounter, then records its ID.
// Works with the game controller or an isolated test
// session. Does not modify the event library.

function begin_campaign_encounter(_campaign)
{
    var _encounter = select_and_prepare_stage_encounter(
        _campaign.event_library,
        _campaign.current_event_stage,
        _campaign.selected_campaign_difficulty,
        _campaign.played_event_ids,
        _campaign.project_flags
    );

    // No eligible encounter was available
    if (!is_struct(_encounter))
    {
        return false;
    }

    // Store the prepared encounter.
    // Its shuffled choice order will remain fixed.
    _campaign.active_encounter = _encounter;

    // Record the event so it cannot be selected again.
    var _played = _campaign.played_event_ids;

    array_push(_played, _encounter.id);

    _campaign.played_event_ids = _played;

    return true;
}

// --------------------------------------------------
// BEGIN A SCHEDULED CAMPAIGN ENCOUNTER
// --------------------------------------------------

// Selects an event using the campaign schedule,
// including mandatory review checkpoints.
//
// Prepares the encounter, stores it, and records
// its ID in campaign history.
//
// Returns true when an encounter begins.
// Returns false when selection is not possible.
//
// Does not modify legacy campaign progression.


// --------------------------------------------------
// BEGIN A SCHEDULED CAMPAIGN ENCOUNTER
// --------------------------------------------------

// Consequences may interrupt scheduled engineering
// events without consuming their event slots.
//
// Probability defaults to 25 percent.
// Test calls can override it with 0 or 100.

function begin_scheduled_campaign_encounter(
    _campaign,
    _consequence_chance_percent = 25
)
{
    // Never replace an active encounter
    if (is_struct(_campaign.active_encounter))
    {
        return false;
    }

    // Verify campaign history exists
    if (!is_array(_campaign.played_event_ids))
    {
        return false;
    }

    var _definition = undefined;

    // --------------------------------------------------
    // CHECK FOR A CONSEQUENCE INTERRUPTION
    // --------------------------------------------------

    // Consequences can occur only while the current
    // stage still has scheduled events remaining.
    //
    // Mandatory checkpoints cannot be interrupted.

    if (is_array(_campaign.campaign_stage_targets)
    && is_array(_campaign.campaign_stage_events_completed)
    && !is_dynamic_stage_complete(_campaign)
    && get_due_stage_checkpoint_id(_campaign) == "")
    {
        var _chance = clamp(
            _consequence_chance_percent,
            0,
            100
        );

        if (random(100) < _chance)
        {
            _definition = select_stage_consequence_event(
                _campaign
            );
        }
    }

    // --------------------------------------------------
    // NORMAL ENGINEERING EVENT SELECTION
    // --------------------------------------------------

    // No consequence selected.
    // Continue with the scheduled timeline.

    if (!is_struct(_definition))
    {
        _definition = select_scheduled_stage_event(
            _campaign
        );
    }

    // No eligible encounter exists
    if (!is_struct(_definition))
    {
        return false;
    }

    // --------------------------------------------------
    // PREPARE THE SELECTED ENCOUNTER
    // --------------------------------------------------

    var _encounter = prepare_event_encounter(
        _definition
    );

    if (!is_struct(_encounter))
    {
        return false;
    }

    // Store the prepared encounter
    _campaign.active_encounter = _encounter;

    // Record the event ID to prevent unwanted repeats
    array_push(
        _campaign.played_event_ids,
        _encounter.id
    );

    // --------------------------------------------------
    // CONSEQUENCE DIAGNOSTIC
    // --------------------------------------------------

    if (variable_struct_exists(
        _encounter,
        "is_consequence"
    ))
    {
        if (_encounter.is_consequence)
        {
            show_debug_message(
                "CONSEQUENCE INTERRUPTION: "
                + _encounter.id
            );
        }
    }

    return true;
}

