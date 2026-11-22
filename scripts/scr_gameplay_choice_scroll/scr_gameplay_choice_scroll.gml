/// @description Scroll management and clipping for gameplay decision choices
/// Step 67C - UI subsystem; no obj_game state or input handlers.

// One shared scroll state for the currently presented event.
// A different event struct automatically resets the scroll offset.
function gameplay_choice_scroll_state(_event)
{
    static _state = {
        event_ref: undefined,
        offset: 0
    };

    if (_state.event_ref != _event)
    {
        _state.event_ref = _event;
        _state.offset = 0;
    }

    return _state;
}

// Calculate content height from the already-verified Flex Panel layout.
function gameplay_choice_scroll_metrics(_event)
{
    var _region = get_ui_regions(_event).choices;
    var _content_height = 0;

    if (is_struct(_event) && is_array(_event.choices)
    && array_length(_event.choices) > 0)
    {
        var _layout = calculate_choice_layout_flex(
            _event.choices,
            _region
        );

        var _buttons = _layout.buttons;
        var _last = _buttons[array_length(_buttons) - 1];
        _content_height = (_last.y + _last.height) - _region.y;
    }

    return {
        region: _region,
        content_height: _content_height,
        max_offset: max(0, _content_height - _region.height)
    };
}

// Run once per Step, using choice button 0 as the input coordinator.
// Only handles the wheel while the mouse is over the choice viewport.
function gameplay_choice_scroll_update(_event)
{
    var _state = gameplay_choice_scroll_state(_event);
    var _metrics = gameplay_choice_scroll_metrics(_event);
    var _region = _metrics.region;

    _state.offset = clamp(_state.offset, 0, _metrics.max_offset);

    if (_metrics.max_offset <= 0)
    {
        _state.offset = 0;
        return;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (point_in_rectangle(
        _mx, _my,
        _region.x, _region.y,
        _region.x + _region.width,
        _region.y + _region.height
    ))
    {
        if (mouse_wheel_down())
        {
            _state.offset = min(
                _metrics.max_offset,
                _state.offset + 44
            );
        }
        else if (mouse_wheel_up())
        {
            _state.offset = max(0, _state.offset - 44);
        }
    }
}

// GameMaker's GPU scissor uses back-buffer pixels rather than GUI pixels.
// Convert the shared GUI region before clipping a Draw GUI button.
// The returned value must be restored with gameplay_choice_end_clip().
function gameplay_choice_begin_clip(_region)
{
    var _previous = gpu_get_scissor();

    var _sx = window_get_width() / max(1, display_get_gui_width());
    var _sy = window_get_height() / max(1, display_get_gui_height());

    gpu_set_scissor(
        floor(_region.x * _sx),
        floor(_region.y * _sy),
        max(1, ceil(_region.width * _sx)),
        max(1, ceil(_region.height * _sy))
    );

    return _previous;
}

function gameplay_choice_end_clip(_previous)
{
    gpu_set_scissor(_previous);
}

// A small, non-interactive scrollbar beside the choices.
function gameplay_choice_draw_scrollbar(_event)
{
    var _metrics = gameplay_choice_scroll_metrics(_event);

    if (_metrics.max_offset <= 0)
    {
        return;
    }

    var _state = gameplay_choice_scroll_state(_event);
    var _region = _metrics.region;
    var _track_x = _region.x + _region.width + 3;
    var _track_y = _region.y;
    var _track_w = 7;
    var _track_h = _region.height;

    var _thumb_h = max(
        24,
        floor(_track_h * _track_h / _metrics.content_height)
    );
    _thumb_h = min(_thumb_h, _track_h);

    var _travel = _track_h - _thumb_h;
    var _thumb_y = _track_y;

    if (_metrics.max_offset > 0)
    {
        _thumb_y += round(
            _travel * _state.offset / _metrics.max_offset
        );
    }

    draw_set_color(make_color_rgb(120, 120, 120));
    draw_rectangle(
        _track_x, _track_y,
        _track_x + _track_w, _track_y + _track_h,
        false
    );

    draw_set_color(make_color_rgb(25, 25, 110));
    draw_rectangle(
        _track_x, _thumb_y,
        _track_x + _track_w, _thumb_y + _thumb_h,
        false
    );
}
