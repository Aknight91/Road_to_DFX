
/// @description Dynamic campaign event scheduling

// --------------------------------------------------
// GET CAMPAIGN EVENT TARGET
// --------------------------------------------------

// Returns a randomly selected campaign event count
// based on the player's selected difficulty.
//
// Call this ONCE when a new campaign begins.
//
// Returns 0 if no valid difficulty has been selected.

function get_campaign_event_target(_difficulty)
{
    switch (_difficulty)
    {
        case CampaignDifficulty.EASY:
            return irandom_range(25, 27);

        case CampaignDifficulty.MEDIUM:
            return irandom_range(28, 30);

        case CampaignDifficulty.HARD:
            return irandom_range(31, 33);

        case CampaignDifficulty.COW_MODE:
            return irandom_range(34, 35);

        default:
            return 0;
    }
}

// --------------------------------------------------
// GET CAMPAIGN STAGE TARGETS
// --------------------------------------------------

// Distributes campaign encounters across the
// five PCB design project phases.
//
// Each stage receives at least one encounter.
// Routing receives the remaining encounters,
// ensuring the total matches _total_events.

function get_campaign_stage_targets(_total_events)
{
    if (_total_events < 5)
    {
        return undefined;
    }

    var _targets = array_create(5, 0);

    // Initial phase allocations
    _targets[EventStage.DESIGN_SETUP] = max(
        1,
        floor(_total_events * 0.13 + 0.5)
    );

    _targets[EventStage.PLACEMENT] = max(
        1,
        floor(_total_events * 0.23 + 0.5)
    );

    _targets[EventStage.MANUFACTURER_REVIEW] = max(
        1,
        floor(_total_events * 0.20 + 0.5)
    );

    _targets[EventStage.RELEASE] = max(
        1,
        floor(_total_events * 0.10 + 0.5)
    );

    // Routing receives all remaining encounters
    _targets[EventStage.ROUTING] =
        _total_events
        - _targets[EventStage.DESIGN_SETUP]
        - _targets[EventStage.PLACEMENT]
        - _targets[EventStage.MANUFACTURER_REVIEW]
        - _targets[EventStage.RELEASE];

    if (_targets[EventStage.ROUTING] < 1)
    {
        return undefined;
    }

    return _targets;
}

// --------------------------------------------------
// RECORD A COMPLETED DYNAMIC ENCOUNTER
// --------------------------------------------------

// Records a completed encounter exactly once.
// Returns true if recorded, false otherwise.
//
// Does not advance stages or select another event.

function record_completed_dynamic_encounter(_campaign)
{
    var _encounter = _campaign.active_encounter;

    // No active dynamic encounter
    if (!is_struct(_encounter))
    {
        return false;
    }

    // The player must resolve the encounter first
    if (!_campaign.event_resolved)
    {
        return false;
    }

    // Prevent double-counting
    if (variable_struct_exists(
        _encounter,
        "completion_recorded"
    ))
    {
        if (_encounter.completion_recorded)
        {
            return false;
        }
    }

    // Validate the event's engineering stage
    var _stage = _encounter.stage;

    if (_stage < EventStage.DESIGN_SETUP
    || _stage > EventStage.RELEASE)
    {
        return false;
    }
	
// --------------------------------------------------
// CONSEQUENCE EVENTS DO NOT ADVANCE THE TIMELINE
// --------------------------------------------------

// A consequence event is an additional interruption.
// It can affect resources, DFX, and project conditions,
// but does not consume a scheduled engineering slot.

if (variable_struct_exists(
    _encounter,
    "is_consequence"
))
{
    if (_encounter.is_consequence)
    {
        // Record completion to prevent double-processing.
        _encounter.completion_recorded = true;

        return true;
    }
}

    // Record progress for this stage
    var _counts = _campaign.campaign_stage_events_completed;

    _counts[_stage] += 1;

    _campaign.campaign_stage_events_completed = _counts;

    // Record overall campaign progress
    _campaign.campaign_events_completed += 1;

    // Mark this particular encounter as recorded
    _encounter.completion_recorded = true;
	
// --------------------------------------------------
// RECORD COMPLETED MANDATORY CHECKPOINTS
// --------------------------------------------------

// Checkpoints are recorded only after the encounter
// has been resolved and its completion is accepted.

switch (_encounter.id)
{
    case "PLC-REVIEW-001":
    case "RTE-REVIEW-001":
    case "REL-SIGNOFF-001":

        if (!array_contains(
            _campaign.completed_checkpoint_ids,
            _encounter.id
        ))
        {
            array_push(
                _campaign.completed_checkpoint_ids,
                _encounter.id
            );
        }

        break;
}

    return true;
}

// --------------------------------------------------
// CHECK DYNAMIC CAMPAIGN STAGE COMPLETION
// --------------------------------------------------

// Returns true when the current stage has reached
// its scheduled number of completed encounters.
//
// Does not change the current stage or campaign state.

function is_dynamic_stage_complete(_campaign)
{
    var _stage = _campaign.current_event_stage;

    var _targets = _campaign.campaign_stage_targets;
    var _completed = _campaign.campaign_stage_events_completed;

    // Reject missing or uninitialized schedules
    if (!is_array(_targets) || !is_array(_completed))
    {
        return false;
    }

    // Validate the current stage
    if (_stage < EventStage.DESIGN_SETUP
    || _stage > EventStage.RELEASE)
    {
        return false;
    }

    // Verify both arrays contain the current stage
    if (_stage >= array_length(_targets)
    || _stage >= array_length(_completed))
    {
        return false;
    }

    // A stage must have a valid positive target
    if (_targets[_stage] < 1)
    {
        return false;
    }

    // Stage is complete when its target is reached
    return _completed[_stage] >= _targets[_stage];
}

// --------------------------------------------------
// ADVANCE TO THE NEXT ENGINEERING STAGE
// --------------------------------------------------

// Advances only when the current stage is complete.
//
// Returns true if the stage changed.
// Returns false if advancement is not allowed.
//
// Does not select events or change the legacy campaign.

function advance_dynamic_campaign_stage(_campaign)
{
    // Current stage must meet its event target
    if (!is_dynamic_stage_complete(_campaign))
    {
        return false;
    }

    var _current_stage = _campaign.current_event_stage;
	
// --------------------------------------------------
// REQUIRE COMPLETED ENGINEERING REVIEWS
// --------------------------------------------------

var _required_review = "";

switch (_current_stage)
{
    case EventStage.PLACEMENT:
        _required_review = "PLC-REVIEW-001";
        break;

    case EventStage.ROUTING:
        _required_review = "RTE-REVIEW-001";
        break;
}

// Placement and Routing require completed reviews
// before the campaign can advance.

if (_required_review != "")
{
    if (!variable_struct_exists(
        _campaign,
        "completed_checkpoint_ids"
    ))
    {
        return false;
    }

    if (!is_array(_campaign.completed_checkpoint_ids))
    {
        return false;
    }

    if (!array_contains(
        _campaign.completed_checkpoint_ids,
        _required_review
    ))
    {
        return false;
    }
}

    // Release is the final engineering stage
    if (_current_stage >= EventStage.RELEASE)
    {
        return false;
    }

    var _next_stage = _current_stage + 1;
    var _targets = _campaign.campaign_stage_targets;

    // Verify the next stage is properly scheduled
    if (_next_stage >= array_length(_targets)
    || _targets[_next_stage] < 1)
    {
        return false;
    }

    // Advance exactly one stage
    _campaign.current_event_stage = _next_stage;

    return true;
}

// --------------------------------------------------
// GET REQUIRED STAGE CHECKPOINT
// --------------------------------------------------

// Returns a required checkpoint event ID when
// the next encounter is the stage's final slot.
//
// Returns an empty string when no checkpoint is due.
//
// Does not select events or modify campaign state.

function get_due_stage_checkpoint_id(_campaign)
{
    var _stage = _campaign.current_event_stage;
    var _targets = _campaign.campaign_stage_targets;
    var _completed = _campaign.campaign_stage_events_completed;

    // Validate schedule data
    if (!is_array(_targets) || !is_array(_completed))
    {
        return "";
    }

    // Validate stage index
    if (_stage < EventStage.DESIGN_SETUP
    || _stage > EventStage.RELEASE)
    {
        return "";
    }

    if (_stage >= array_length(_targets)
    || _stage >= array_length(_completed))
    {
        return "";
    }

    var _target = _targets[_stage];
    var _done = _completed[_stage];

    // A checkpoint is due only in the final slot.
    if (_target < 1 || _done != _target - 1)
    {
        return "";
    }

    switch (_stage)
    {
        case EventStage.PLACEMENT:
            return "PLC-REVIEW-001";

        case EventStage.ROUTING:
            return "RTE-REVIEW-001";

        case EventStage.RELEASE:
            return "REL-SIGNOFF-001";
    }

    // Other stages do not require a checkpoint.
    return "";
}

// --------------------------------------------------
// CHECK DYNAMIC CAMPAIGN RELEASE READINESS
// --------------------------------------------------

// Verifies that every scheduled engineering stage
// and mandatory review has been completed.
//
// Returns true when the dynamic campaign is ready
// for its final DFX pass/fail evaluation.
//
// Does not end the campaign or change gameplay.

function is_dynamic_campaign_release_ready(_campaign)
{
    // The campaign must have reached Release
    if (_campaign.current_event_stage != EventStage.RELEASE)
    {
        return false;
    }

    var _targets = _campaign.campaign_stage_targets;
    var _completed = _campaign.campaign_stage_events_completed;

    // Reject invalid schedules
    if (!is_array(_targets) || !is_array(_completed))
    {
        return false;
    }

    if (array_length(_targets) != 5
    || array_length(_completed) != 5)
    {
        return false;
    }

    // Verify every stage has completed its target
    var _scheduled_total = 0;

    for (var _stage = EventStage.DESIGN_SETUP;
         _stage <= EventStage.RELEASE;
         _stage++)
    {
        if (_targets[_stage] < 1
        || _completed[_stage] != _targets[_stage])
        {
            return false;
        }

        _scheduled_total += _targets[_stage];
    }

    // The campaign must have completed exactly
    // its scheduled number of encounters
    if (_scheduled_total != _campaign.campaign_event_target
    || _campaign.campaign_events_completed
       != _campaign.campaign_event_target)
    {
        return false;
    }

    // All mandatory engineering checkpoints
    // must have been completed
    var _checkpoints = _campaign.completed_checkpoint_ids;

    if (!is_array(_checkpoints))
    {
        return false;
    }

    return array_contains(
        _checkpoints, "PLC-REVIEW-001"
    )
    && array_contains(
        _checkpoints, "RTE-REVIEW-001"
    )
    && array_contains(
        _checkpoints, "REL-SIGNOFF-001"
    );
}
