/// @description Ask for Advice - paid consultations and temporary follow choices
// Step 66 Part 5. This module owns advice costs, records, and choice unlocks.
// The core controller already exposes calendar and choice-button functions.

// Provisional cost. A consultation adds two HOURS to the existing
// eight-hour workday calendar, not a forced full-day delay.
function advice_consultation_cost_hours()
{
    return 2;
}

// Find a coworker by stable ID in this campaign's assigned group.
function advice_find_coworker(_state, _coworker_id)
{
    if (!is_struct(_state))
    {
        return undefined;
    }

    for (var _i = 0; _i < array_length(_state.coworkers); _i++)
    {
        if (_state.coworkers[_i].id == _coworker_id)
        {
            return _state.coworkers[_i];
        }
    }

    return undefined;
}

// Coworkers now recommend according to their roles or personalities.
// The recommendation starts from an ORIGINAL encounter option so its
// flags, backfire rules, and other engineering consequences stay intact.
// Only a small profile bonus is applied to a clone of that option.
function advice_create_follow_choice(_state, _encounter, _coworker_id)
{
    if (!is_struct(_state) || !is_struct(_encounter)
    || !is_array(_encounter.choices))
    {
        return undefined;
    }

    var _npc = advice_find_coworker(_state, _coworker_id);
    if (!is_struct(_npc))
    {
        return undefined;
    }

    var _base_count = _state.original_choice_count;
    var _profile = advice_get_profile(_npc);
    var _source_index = advice_choose_source_index(
        _encounter, _base_count, _profile
    );

    if (_source_index < 0)
    {
        return undefined;
    }

    var _source = _encounter.choices[_source_index];
    var _follow = variable_clone(_source);
    var _bonus_text = advice_apply_profile_bonus(_follow, _profile);

    // Explain the actual event and recommended option in the coworker's
    // voice. Tradeoffs are calculated from the FINAL cloned choice.
    var _talk = advice_build_dialogue(_npc, _encounter, _follow);

    // This option belongs to the current encounter only.
    _follow.id = "ADVICE-" + _encounter.id + "-" + _npc.id;
    _follow.text = "Follow " + _npc.name + "'s advice";
    _follow.result = _talk.line
        + "\n" + _talk.context
        + "\nRecommended approach: " + _source.text
        + "\nTradeoffs: " + _talk.tradeoffs
        + "\nSkill modifier if followed: " + _bonus_text
        + "\n\n" + _source.result;

    _follow.advice_coworker_id = _npc.id;
    _follow.advice_source_choice_id = _source.id;
    _follow.advice_source_text = _source.text;
    _follow.advice_focus_text = _profile.label;
    _follow.advice_bonus_text = _bonus_text;
    _follow.advice_dialogue = _talk.line;
    _follow.advice_context = _talk.context;
    _follow.advice_tradeoffs = _talk.tradeoffs;
    _follow.advice_topic = _talk.topic;

    return _follow;
}

// Perform exactly one consultation for this coworker and encounter.
// Returns false without charging time or adding choices on failure.
function advice_consult_coworker(_game, _coworker_id)
{
    if (!instance_exists(_game)
    || !is_struct(_game.advice_state)
    || !is_struct(_game.active_encounter)
    || _game.get_campaign_phase() != CampaignPhase.CHOOSING)
    {
        return false;
    }

    var _state = _game.advice_state;
    var _encounter = _game.active_encounter;

    // Do not apply a consultation to a different or resolved encounter.
    if (_state.encounter_ref != _encounter
    || !advice_can_consult(_state, _coworker_id))
    {
        return false;
    }

    var _cost = advice_consultation_cost_hours();
    if (_game.engineering_hours < _cost)
    {
        return false;
    }

    // Fully construct and validate the new option before spending time.
    var _new_choice = advice_create_follow_choice(
        _state, _encounter, _coworker_id
    );

    if (!is_struct(_new_choice))
    {
        return false;
    }

    // Record first to guard against charging a second time.
    if (!advice_record_consultation(_state, _coworker_id))
    {
        return false;
    }

    // Use exactly the same working-hours and overdue mechanics as
    // other activities. The calendar date rolls over at eight hours.
    _game.engineering_hours -= _cost;
    _game.advance_project_work_hours(_cost);
    _game.days_remaining = _game.get_workdays_until_deadline();
    _game.apply_overdue_sanity_penalty();

    // Overdue penalties may start, but do not tick down, a crisis.
    if (_game.sanity <= 0 && !_game.sanity_zero_active)
    {
        _game.sanity_zero_active = true;
        _game.sanity_zero_turns_remaining = 3;
        _game.software_instability = 5;
    }

    // Append to the ACTIVE encounter only, never the event library.
    // Use a local array and explicitly reassign for GML array semantics.
    var _choices = _encounter.choices;
    array_push(_choices, _new_choice);
    _encounter.choices = _choices;

    var _unlocked = _state.unlocked_choices;
    array_push(_unlocked, _new_choice);
    _state.unlocked_choices = _unlocked;

    // The verified Flex Panel and Step 67C scrolling UI own all layout.
    _game.refresh_choice_buttons();

    show_debug_message(
        "ADVICE: Consulted " + _coworker_id
        + " for " + string(_cost) + " engineering hours."
    );

    return true;
}
