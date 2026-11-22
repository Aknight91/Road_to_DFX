/// @description Water Cooler - activity bar button and independent chat screen
// Presentation only. State and consequences live in the other cooler scripts.

function draw_water_cooler_entry_button(_game)
{
    var _b = water_cooler_entry_bounds();
    var _can_enter = water_cooler_can_enter(_game);
    var _used = false;
    if (variable_instance_exists(_game, "water_cooler_state")
    && is_struct(_game.water_cooler_state))
    {
        _used = water_cooler_stage_used(
            _game.water_cooler_state, _game.current_event_stage
        );
    }

    draw_set_color(_can_enter
        ? make_color_rgb(225, 225, 225)
        : make_color_rgb(155, 155, 155));
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, false);
    draw_set_color(c_black);
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, true);
    draw_set_halign(fa_center);
    draw_text(_b.x + _b.width / 2, _b.y + 9, "WATER");
    draw_text(_b.x + _b.width / 2, _b.y + 39, "COOLER");
    draw_text(_b.x + _b.width / 2, _b.y + 59,
        _used ? "USED" : (_can_enter ? "READY" : "LOCKED"));
    draw_set_halign(fa_left);
}

function draw_water_cooler_screen(_game)
{
    draw_set_color(make_color_rgb(192, 192, 192));
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_color(make_color_rgb(0, 0, 128));
    draw_rectangle(20, 20, 940, 75, false);
    draw_set_color(c_white);
    draw_text(35, 35, "ROAD TO DFX - WATER COOLER CHAT");

    var _state = _game.water_cooler_state;
    if (!is_struct(_state))
    {
        return;
    }

    draw_set_color(c_black);
    draw_text(115, 99, "MILESTONE: "
        + water_cooler_stage_label(_state.viewing_stage));
    draw_text(115, 120,
        "One optional conversation per milestone. Leaving without chatting is free.");

    if (_state.visit_complete)
    {
        draw_text(115, 164, "CONVERSATION COMPLETE");
        draw_text_ext(115, 207, _state.last_result, -1, 715);
        draw_text(115, 429, "Return to your unresolved engineering encounter.");
    }
    else
    {
        var _options = water_cooler_get_options(_state.viewing_stage);
        for (var _i = 0; _i < array_length(_options); _i++)
        {
            var _o = _options[_i];
            var _b = water_cooler_option_bounds(_i);
            var _available = _game.engineering_hours >= _o.hours_cost;
            draw_set_color(_available
                ? make_color_rgb(225, 225, 225)
                : make_color_rgb(155, 155, 155));
            draw_rectangle(_b.x, _b.y,
                _b.x + _b.width, _b.y + _b.height, false);
            draw_set_color(c_black);
            draw_rectangle(_b.x, _b.y,
                _b.x + _b.width, _b.y + _b.height, true);
            draw_text(_b.x + 12, _b.y + 7,
                string(_i + 1) + ". " + _o.text);
            draw_text(_b.x + 12, _b.y + 29, _o.description);
            var _effects = string(_o.hours_cost) + " engineering hour(s)"
                + "    Sanity " + (_o.sanity_change >= 0 ? "+" : "")
                + string(_o.sanity_change);
            if (_o.risk_change != 0)
            {
                _effects += "    Manufacturing risk "
                    + string(_o.risk_change);
            }
            draw_text(_b.x + 12, _b.y + 52, _effects);
        }

        if (_state.last_error != "")
        {
            draw_set_color(c_red);
            draw_text(115, 438, _state.last_error);
        }
    }

    // Same Back button is used for free skip and completed visits.
    var _back = water_cooler_back_bounds();
    draw_set_color(make_color_rgb(225, 225, 225));
    draw_rectangle(_back.x, _back.y,
        _back.x + _back.width, _back.y + _back.height, false);
    draw_set_color(c_black);
    draw_rectangle(_back.x, _back.y,
        _back.x + _back.width, _back.y + _back.height, true);
    draw_text(_back.x + 14, _back.y + 13,
        _state.visit_complete ? "RETURN TO DESIGN" : "SKIP / RETURN TO DESIGN");
}
