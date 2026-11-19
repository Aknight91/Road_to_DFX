/// @description Build and validate data-driven event packs

// Turn a pack of compact event definitions into standard
// Road to DFX events. Every choice receives a stable ID:
// PCB-0010-A, PCB-0010-B, etc.
function create_events_from_pack(_stage, _specs)
{
    var _events = [];

    if (!is_array(_specs))
    {
        show_debug_message("EVENT PACK ERROR: Pack is not an array");
        return _events;
    }

    var _choice_fields = [
        "hours_cost", "hours_gain", "days_cost", "budget_change",
        "morale_change", "drc_change", "risk_change",
        "dfa_change", "dfm_change", "dft_change", "sanity_change",
        "set_flags", "clear_flags", "followup_event_ids", "backfire"
    ];

    var _event_fields = [
        "weight", "min_difficulty", "max_difficulty", "repeatable",
        "required_flags", "blocked_flags", "prerequisite_event_ids",
        "artwork_key", "is_consequence"
    ];

    for (var _i = 0; _i < array_length(_specs); _i++)
    {
        var _spec = _specs[_i];

        if (!is_struct(_spec)
        || !variable_struct_exists(_spec, "id")
        || !variable_struct_exists(_spec, "title")
        || !variable_struct_exists(_spec, "description")
        || !variable_struct_exists(_spec, "choices"))
        {
            show_debug_message("EVENT PACK ERROR: Missing event fields at index " + string(_i));
            continue;
        }

        if (!is_string(_spec.id) || _spec.id == ""
        || !is_string(_spec.title) || _spec.title == ""
        || !is_string(_spec.description) || _spec.description == ""
        || !is_array(_spec.choices))
        {
            show_debug_message("EVENT PACK ERROR: Invalid event data at index " + string(_i));
            continue;
        }

        // Reject misspelled event metadata before registration.
        var _valid_spec = true;
        var _spec_keys = variable_struct_get_names(_spec);

        for (var _s = 0; _s < array_length(_spec_keys); _s++)
        {
            var _spec_key = _spec_keys[_s];

            if (_spec_key == "id" || _spec_key == "title"
            || _spec_key == "description" || _spec_key == "choices"
            || _spec_key == "category"
            || array_contains(_event_fields, _spec_key))
            {
                continue;
            }

            show_debug_message("EVENT PACK ERROR: Unknown event field " + _spec.id + ": " + _spec_key);
            _valid_spec = false;
        }

        if (!_valid_spec)
        {
            continue;
        }

        var _count = array_length(_spec.choices);

        if (_count < 2 || _count > 6)
        {
            show_debug_message("EVENT PACK ERROR: Invalid choice count for " + _spec.id);
            continue;
        }

        var _choices = [];
        var _valid = true;

        for (var _j = 0; _j < _count; _j++)
        {
            var _raw = _spec.choices[_j];

            if (!is_struct(_raw)
            || !variable_struct_exists(_raw, "text")
            || !variable_struct_exists(_raw, "result"))
            {
                _valid = false;
                break;
            }

            if (!is_string(_raw.text) || _raw.text == ""
            || !is_string(_raw.result) || _raw.result == "")
            {
                _valid = false;
                break;
            }

            var _choice = create_event_choice(
                _spec.id + "-" + chr(65 + _j),
                _raw.text,
                _raw.result
            );

            var _keys = variable_struct_get_names(_raw);

            for (var _k = 0; _k < array_length(_keys); _k++)
            {
                var _key = _keys[_k];

                if (_key == "text" || _key == "result")
                {
                    continue;
                }

                if (!array_contains(_choice_fields, _key))
                {
                    show_debug_message(
                        "EVENT PACK ERROR: Unknown choice field "
                        + _spec.id + ": " + _key
                    );
                    _valid = false;
                    break;
                }

                variable_struct_set(
                    _choice,
                    _key,
                    variable_struct_get(_raw, _key)
                );
            }

            if (!_valid)
            {
                break;
            }

            array_push(_choices, _choice);
        }

        if (!_valid)
        {
            show_debug_message("EVENT PACK ERROR: Invalid choices in " + _spec.id);
            continue;
        }

        var _category = EventCategory.ENGINEERING;

        if (variable_struct_exists(_spec, "category"))
        {
            _category = _spec.category;
        }

        var _event = create_decision_event(
            _spec.id,
            _stage,
            _category,
            _spec.title,
            _spec.description,
            _choices
        );

        if (!is_struct(_event))
        {
            continue;
        }

        // Copy supported optional event metadata.
        for (var _m = 0; _m < array_length(_event_fields); _m++)
        {
            var _field = _event_fields[_m];

            if (variable_struct_exists(_spec, _field))
            {
                variable_struct_set(
                    _event,
                    _field,
                    variable_struct_get(_spec, _field)
                );
            }
        }

        array_push(_events, _event);
    }

    return _events;
}


// Run once at startup after all packs have been registered.
// Checks duplicate IDs, required fields, choice costs and
// links to other events. Does not change any campaign state.
function validate_event_library(_library)
{
    var _seen_events = ds_map_create();
    var _seen_choices = ds_map_create();
    var _events = [];
    var _choices = [];
    var _counts = array_create(5, 0);
    var _errors = 0;

    var _number_fields = [
        "hours_cost", "hours_gain", "days_cost", "budget_change",
        "morale_change", "drc_change", "risk_change",
        "dfa_change", "dfm_change", "dft_change", "sanity_change"
    ];

    for (var _stage = EventStage.DESIGN_SETUP;
         _stage <= EventStage.RELEASE;
         _stage++)
    {
        var _pool = get_event_pool(_library, _stage);

        if (!is_array(_pool))
        {
            show_debug_message("EVENT LIBRARY QA ERROR: Invalid stage pool " + string(_stage));
            _errors++;
            continue;
        }

        _counts[_stage] = array_length(_pool);

        for (var _i = 0; _i < array_length(_pool); _i++)
        {
            var _event = _pool[_i];

            if (!is_struct(_event)
            || !variable_struct_exists(_event, "id")
            || !variable_struct_exists(_event, "stage")
            || !variable_struct_exists(_event, "title")
            || !variable_struct_exists(_event, "description")
            || !variable_struct_exists(_event, "choices"))
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Invalid event in stage " + string(_stage));
                _errors++;
                continue;
            }

            if (!is_string(_event.id) || _event.id == "")
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Empty event ID");
                _errors++;
                continue;
            }

            if (ds_map_exists(_seen_events, _event.id))
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Duplicate event " + _event.id);
                _errors++;
            }
            else
            {
                ds_map_add(_seen_events, _event.id, true);
            }

            array_push(_events, _event);

            if (_event.stage != _stage
            || !is_string(_event.title) || _event.title == ""
            || !is_string(_event.description) || _event.description == "")
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Bad stage or text for " + _event.id);
                _errors++;
            }

            if (!variable_struct_exists(_event, "category")
            || !variable_struct_exists(_event, "weight")
            || !is_real(_event.weight) || _event.weight < 0)
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Category/weight missing for " + _event.id);
                _errors++;
            }

            var _list_fields = [
                "required_flags", "blocked_flags", "prerequisite_event_ids"
            ];

            for (var _lf = 0; _lf < array_length(_list_fields); _lf++)
            {
                var _fname = _list_fields[_lf];

                if (!variable_struct_exists(_event, _fname)
                || !is_array(variable_struct_get(_event, _fname)))
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Invalid " + _fname + " in " + _event.id);
                    _errors++;
                }
            }

            if (!is_array(_event.choices)
            || array_length(_event.choices) < 2
            || array_length(_event.choices) > 6)
            {
                show_debug_message("EVENT LIBRARY QA ERROR: Invalid choices for " + _event.id);
                _errors++;
                continue;
            }

            for (var _j = 0; _j < array_length(_event.choices); _j++)
            {
                var _choice = _event.choices[_j];

                if (!is_struct(_choice)
                || !variable_struct_exists(_choice, "id")
                || !variable_struct_exists(_choice, "text")
                || !variable_struct_exists(_choice, "result"))
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Invalid choice in " + _event.id);
                    _errors++;
                    continue;
                }

                if (!is_string(_choice.id) || _choice.id == "")
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Empty choice ID in " + _event.id);
                    _errors++;
                    continue;
                }

                if (string_pos(_event.id + "-", _choice.id) != 1)
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Choice ID does not match " + _event.id);
                    _errors++;
                }

                if (ds_map_exists(_seen_choices, _choice.id))
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Duplicate choice " + _choice.id);
                    _errors++;
                }
                else
                {
                    ds_map_add(_seen_choices, _choice.id, true);
                }

                if (!is_string(_choice.text) || _choice.text == ""
                || !is_string(_choice.result) || _choice.result == "")
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Missing choice text in " + _choice.id);
                    _errors++;
                }

                for (var _nf = 0; _nf < array_length(_number_fields); _nf++)
                {
                    var _name = _number_fields[_nf];

                    if (!variable_struct_exists(_choice, _name)
                    || !is_real(variable_struct_get(_choice, _name)))
                    {
                        show_debug_message("EVENT LIBRARY QA ERROR: Invalid " + _name + " in " + _choice.id);
                        _errors++;
                    }
                }

                if (variable_struct_exists(_choice, "hours_cost")
                && variable_struct_exists(_choice, "days_cost")
                && is_real(_choice.hours_cost)
                && is_real(_choice.days_cost))
                {
                    if (_choice.hours_cost < 0 || _choice.days_cost < 0)
                    {
                        show_debug_message("EVENT LIBRARY QA ERROR: Negative time cost in " + _choice.id);
                        _errors++;
                    }
                }

                var _flag_fields = ["set_flags", "clear_flags", "followup_event_ids"];

                for (var _ff = 0; _ff < array_length(_flag_fields); _ff++)
                {
                    var _flag_name = _flag_fields[_ff];

                    if (!variable_struct_exists(_choice, _flag_name)
                    || !is_array(variable_struct_get(_choice, _flag_name)))
                    {
                        show_debug_message("EVENT LIBRARY QA ERROR: Invalid " + _flag_name + " in " + _choice.id);
                        _errors++;
                    }
                }

                array_push(_choices, _choice);
            }
        }
    }

    // Validate reference IDs after every event has been indexed.
    for (var _e = 0; _e < array_length(_events); _e++)
    {
        var _check_event = _events[_e];

        if (variable_struct_exists(_check_event, "prerequisite_event_ids")
        && is_array(_check_event.prerequisite_event_ids))
        {
            for (var _p = 0; _p < array_length(_check_event.prerequisite_event_ids); _p++)
            {
                var _ref = _check_event.prerequisite_event_ids[_p];

                if (!is_string(_ref) || !ds_map_exists(_seen_events, _ref))
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Unknown prerequisite " + string(_ref));
                    _errors++;
                }
            }
        }
    }

    for (var _c = 0; _c < array_length(_choices); _c++)
    {
        var _check_choice = _choices[_c];

        if (variable_struct_exists(_check_choice, "followup_event_ids")
        && is_array(_check_choice.followup_event_ids))
        {
            for (var _f = 0; _f < array_length(_check_choice.followup_event_ids); _f++)
            {
                var _next_id = _check_choice.followup_event_ids[_f];

                if (!is_string(_next_id) || !ds_map_exists(_seen_events, _next_id))
                {
                    show_debug_message("EVENT LIBRARY QA ERROR: Unknown follow-up " + string(_next_id));
                    _errors++;
                }
            }
        }
    }

    ds_map_destroy(_seen_events);
    ds_map_destroy(_seen_choices);

    show_debug_message(
        "EVENT LIBRARY QA: Stage counts = "
        + string(_counts[0]) + "/" + string(_counts[1])
        + "/" + string(_counts[2]) + "/" + string(_counts[3])
        + "/" + string(_counts[4])
    );

    show_debug_message(
        "EVENT LIBRARY QA: Events=" + string(array_length(_events))
        + " Choices=" + string(array_length(_choices))
        + " Errors=" + string(_errors)
    );

    if (_errors == 0)
    {
        show_debug_message("EVENT LIBRARY QA: PASS");
        return true;
    }

    show_debug_message("EVENT LIBRARY QA: FAILED");
    return false;
}
