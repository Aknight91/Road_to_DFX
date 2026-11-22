/// @description Water Cooler - independent input/navigation and chat consequences
// All activity behavior lives here. obj_game calls one function per Step.

function water_cooler_entry_bounds()
{
    return get_ui_regions().activity_buttons.water;
}

function water_cooler_back_bounds()
{
    return { x: 35, y: 475, width: 270, height: 45 };
}

function water_cooler_option_bounds(_index)
{
    return {
        x: 115,
        y: 157 + (91 * _index),
        width: 730,
        height: 78
    };
}

function water_cooler_hit(_mx, _my, _bounds)
{
    return point_in_rectangle(
        _mx, _my,
        _bounds.x, _bounds.y,
        _bounds.x + _bounds.width,
        _bounds.y + _bounds.height
    );
}

// Apply one chat choice AT MOST ONCE per campaign stage.
// Does not affect normal event choice resolution or Sanity Crisis turn count.
function water_cooler_choose(_game, _option)
{
    if (!instance_exists(_game)
    || !is_struct(_option)
    || !variable_instance_exists(_game, "water_cooler_state"))
    {
        return false;
    }

    var _state = _game.water_cooler_state;
    var _stage = _game.current_event_stage;

    if (!is_struct(_state)
    || _state.viewing_stage != _stage
    || _state.visit_complete
    || water_cooler_stage_used(_state, _stage)
    || _game.get_campaign_phase() != CampaignPhase.CHOOSING)
    {
        return false;
    }

    if (_game.engineering_hours < _option.hours_cost)
    {
        _state.last_error = "Not enough engineering hours for that conversation.";
        return false;
    }

    // Mark the stage as used BEFORE applying any changes.
    var _used = _state.used_stages;
    array_push(_used, _stage);
    _state.used_stages = _used;
    _state.visit_complete = true;
    _state.last_error = "";

    var _old_sanity = _game.sanity;
    var _old_risk = _game.manufacturing_risk;

    // Reuse the same engineering-hours calendar as other activities.
    _game.engineering_hours -= _option.hours_cost;
    _game.advance_project_work_hours(_option.hours_cost);
    _game.days_remaining = _game.get_workdays_until_deadline();

    // Apply the chat outcome. Shared manufacturing logic also updates DFM
    // if manufacturing risk changes, just like normal engineering decisions.
    _game.sanity = clamp(
        _game.sanity + _option.sanity_change, 0, 100
    );
    if (_option.risk_change != 0)
    {
        _game.apply_manufacturing_changes(0, _option.risk_change, 0);
    }

    // Preserve existing overdue Sanity penalties and crisis rules.
    _game.apply_overdue_sanity_penalty();
    if (_game.sanity <= 0 && !_game.sanity_zero_active)
    {
        _game.sanity_zero_active = true;
        _game.sanity_zero_turns_remaining = 3;
        _game.software_instability = 5;
    }

    // Sanity Crisis remains active if it was already triggered. A chat
    // does NOT consume one of its three subsequent design decisions.
    _state.last_result = _option.result
        + "\n\nEngineering hours spent: " + string(_option.hours_cost)
        + "\nSanity: " + string(_old_sanity)
        + "% -> " + string(_game.sanity) + "%"
        + "\nManufacturing risk: " + string(_old_risk)
        + " -> " + string(_game.manufacturing_risk)
        + "\nThis milestone's Water Cooler visit is now used.";

    show_debug_message(
        "WATER COOLER: Stage " + string(_stage)
        + ", option " + _option.id
        + ", hours " + string(_option.hours_cost)
    );
    return true;
}

// Called ONCE from obj_game Step after advice_handle_input.
function water_cooler_handle_input(_game, _screen_at_start)
{
    var _manager = _game.screen_manager;

    if (_screen_at_start == ScreenId.GAMEPLAY)
    {
        if (!_manager.can_receive_input(ScreenId.GAMEPLAY)
        || _game.debug_panel_open
        || !mouse_check_button_pressed(mb_left))
        {
            return;
        }

        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        if (!water_cooler_hit(_mx, _my, water_cooler_entry_bounds()))
        {
            return;
        }

        // Consume the click even if the activity is not available.
        mouse_clear(mb_left);
        if (!water_cooler_can_enter(_game))
        {
            return;
        }

        var _state = _game.water_cooler_state;
        _state.viewing_stage = _game.current_event_stage;
        _state.visit_complete = false;
        _state.last_result = "";
        _state.last_error = "";
        _manager.navigate_to(ScreenId.WATER_COOLER);
        return;
    }

    if (_screen_at_start != ScreenId.WATER_COOLER
    || !_manager.can_receive_input(ScreenId.WATER_COOLER))
    {
        return;
    }

    if (keyboard_check_pressed(vk_escape))
    {
        _manager.navigate_to(ScreenId.GAMEPLAY);
        return;
    }

    if (!mouse_check_button_pressed(mb_left))
    {
        return;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (water_cooler_hit(_mx, _my, water_cooler_back_bounds()))
    {
        _manager.navigate_to(ScreenId.GAMEPLAY);
        mouse_clear(mb_left);
        return;
    }

    var _state = _game.water_cooler_state;
    if (!is_struct(_state) || _state.visit_complete)
    {
        return;
    }

    var _options = water_cooler_get_options(_state.viewing_stage);
    for (var _i = 0; _i < array_length(_options); _i++)
    {
        if (water_cooler_hit(_mx, _my, water_cooler_option_bounds(_i)))
        {
            water_cooler_choose(_game, _options[_i]);
            mouse_clear(mb_left);
            return;
        }
    }
}
