
/// @description Standardized event and choice definitions

// --------------------------------------------------
// EVENT CATEGORIES
// --------------------------------------------------

enum EventCategory
{
    ENGINEERING = 0,
    SETBACK,
    OPPORTUNITY,
    RESOURCE,
    MILESTONE
}


// --------------------------------------------------
// CREATE A PLAYER CHOICE
// --------------------------------------------------

// Creates a choice with safe default values.
// Individual events can override the fields they need.

function create_event_choice(_id, _text, _result)
{
    return {
        id: _id,
        text: _text,
        result: _result,

        // Engineering resources
        hours_cost: 0,
        hours_gain: 0,
        days_cost: 0,
        budget_change: 0,
        morale_change: 0,

        // Manufacturing conditions
        drc_change: 0,
        risk_change: 0,

        // DFX and engineer stress
        dfa_change: 0,
        dfm_change: 0,
        dft_change: 0,
        sanity_change: 0,

        // Persistent consequences
        set_flags: [],
        clear_flags: [],
        followup_event_ids: [],

        // Future complication system
        backfire: {
            base_chance_pct: 0,
            outcomes: []
        }
    };
}


// --------------------------------------------------
// CREATE A DECISION EVENT
// --------------------------------------------------

// Decision events contain between 2 and 6 choices.
// Other event types, such as automatic incidents,
// can receive separate builders later.

function create_decision_event(
    _id,
    _stage,
    _category,
    _title,
    _description,
    _choices
)
{
    if (!is_array(_choices))
    {
        show_debug_message(
            "EVENT SCHEMA: Choices must be an array."
        );

        return undefined;
    }

    var _choice_count = array_length(_choices);

    if (_choice_count < 2 || _choice_count > 6)
    {
        show_debug_message(
            "EVENT SCHEMA: Invalid choice count for "
            + string(_id)
        );

        return undefined;
    }

    return {
        // Unique event identity
        id: _id,

        // Classification
        stage: _stage,
        category: _category,

        // Event presentation
        title: _title,
        description: _description,
        choices: _choices,

        // Selection rules
        weight: 1,
        min_difficulty: CampaignDifficulty.EASY,
        max_difficulty: CampaignDifficulty.COW_MODE,
        repeatable: false,

        // Eligibility and continuity
        required_flags: [],
        blocked_flags: [],
        prerequisite_event_ids: [],

        // Future artwork association
        artwork_key: ""
    };
}
