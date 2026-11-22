/// @description Road to DFX - compact project status / schedule

// Render four status bars inside the lower-left panel.
// Labels, bars and values stay together when the panel moves.
function draw_hud_compact_bar(_x, _y, _bar_x, _bar_width, _label, _value)
{
    draw_set_color(c_black);
    draw_text(_x, _y, _label);

    draw_set_color(make_color_rgb(80, 80, 80));
    draw_rectangle(
        _bar_x, _y + 3,
        _bar_x + _bar_width, _y + 13,
        false
    );

    draw_set_color(make_color_rgb(0, 128, 0));
    draw_rectangle(
        _bar_x, _y + 3,
        _bar_x + (_bar_width * clamp(_value, 0, 100) / 100),
        _y + 13,
        false
    );

    draw_set_color(c_black);
    draw_text(_bar_x + _bar_width + 7, _y, string(_value) + "%");
}

function draw_gameplay_hud(_game)
{
    var _panel = get_ui_regions().panels.project_status;
    var _left = _panel.x + 12;
    var _bar_x = _panel.x + 82;
    var _bar_width = round(_panel.width * 0.285);
    var _schedule_x = _panel.x + round(_panel.width * 0.52);
    var _heading_y = _panel.y + 3;
    var _first_y = _panel.y + 23;
    var _row_height = 21;

    draw_set_color(c_black);
    draw_text(_left, _heading_y, "PROJECT STATUS");
    draw_text(_schedule_x, _heading_y, "SCHEDULE");

    // Four compact resource rows.
    draw_hud_compact_bar(_left, _first_y,
        _bar_x, _bar_width, "DFA", _game.dfa);
    draw_hud_compact_bar(_left, _first_y + _row_height,
        _bar_x, _bar_width, "DFM", _game.dfm);
    draw_hud_compact_bar(_left, _first_y + (_row_height * 2),
        _bar_x, _bar_width, "DFT", _game.dft);
    draw_hud_compact_bar(_left, _first_y + (_row_height * 3),
        _bar_x, _bar_width, "SANITY", _game.sanity);

    // Schedule and DRC count, always in the same right column.
    draw_set_color(c_black);
    draw_text(_schedule_x, _first_y,
        "Date: " + _game.format_project_date(_game.project_current_date));
    draw_text(_schedule_x, _first_y + _row_height,
        "Deadline: " + _game.format_project_date(_game.project_deadline_date));

    var _overdue = _game.get_overdue_workdays();
    if (_overdue > 0)
    {
        draw_text(_schedule_x, _first_y + (_row_height * 2),
            "Workdays overdue: " + string(_overdue));
    }
    else
    {
        draw_text(_schedule_x, _first_y + (_row_height * 2),
            "Workdays left: " + string(_game.days_remaining));
    }

    draw_text(_schedule_x, _first_y + (_row_height * 3),
        "DRCs: " + string(_game.drc_violations));

    draw_set_color(c_white);
}
