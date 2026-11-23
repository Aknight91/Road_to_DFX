/// @description Road to DFX - shared gameplay activity bar

// Visual presentation only. The DRC Hunting and coworker chat systems
// retain ownership of their own input and gameplay consequences.
// All button positions are provided by scr_ui_regions.

function draw_gameplay_activity_bar(_game, _phase)
{
    if (_phase != CampaignPhase.CHOOSING)
    {
        return;
    }

    var _buttons = get_ui_regions().activity_buttons;

    // --------------------------------------------------
    // HUNT DRCs: existing availability rules, new position.
    // --------------------------------------------------

    var _used = false;
    if (is_struct(_game.active_encounter))
    {
        _used = _game.drc_hunt_last_event_id
            == _game.active_encounter.id;
    }

    var _available = is_struct(_game.active_encounter)
        && !_used
        && _game.drc_violations > 0
        && _game.engineering_hours > _game.drc_hunt_cost_hours;

    var _hunt = _buttons.hunt;

    draw_set_color(_available
        ? make_color_rgb(225, 225, 225)
        : make_color_rgb(155, 155, 155));
    draw_rectangle(
        _hunt.x, _hunt.y,
        _hunt.x + _hunt.width, _hunt.y + _hunt.height,
        false
    );

    draw_set_color(c_black);
    draw_rectangle(
        _hunt.x, _hunt.y,
        _hunt.x + _hunt.width, _hunt.y + _hunt.height,
        true
    );

    draw_set_halign(fa_center);
    draw_text(_hunt.x + _hunt.width / 2, _hunt.y + 9, "DRC");
    draw_text(_hunt.x + _hunt.width / 2, _hunt.y + 39, "HUNT");
    if (_used)
    {
        draw_text(_hunt.x + _hunt.width / 2, _hunt.y + 59, "USED");
    }
    else if (_available)
    {
        draw_text(
            _hunt.x + _hunt.width / 2,
            _hunt.y + 59,
            string(_game.drc_hunt_cost_hours) + " HRS"
        );
    }
    else
    {
        draw_text(_hunt.x + _hunt.width / 2, _hunt.y + 59, "LOCKED");
    }

    // --------------------------------------------------
    // THIRD ACTIVITY: reserved for a future mechanic.
    // Disabled placeholder; no mouse handler is registered.
    // --------------------------------------------------

    var _water = _buttons.water;
    draw_set_color(make_color_rgb(155, 155, 155));
    draw_rectangle(
        _water.x, _water.y,
        _water.x + _water.width, _water.y + _water.height,
        false
    );
    draw_set_color(c_black);
    draw_rectangle(
        _water.x, _water.y,
        _water.x + _water.width, _water.y + _water.height,
        true
    );

    draw_text(_water.x + _water.width / 2, _water.y + 9, "ACTIVITY");
    draw_text(_water.x + _water.width / 2, _water.y + 39, "TBD");
    draw_text(_water.x + _water.width / 2, _water.y + 59, "DISABLED");

    // The middle slot (Water Cooler Chat) is drawn by the advice subsystem.
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
