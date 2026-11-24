/// @description Isolated UI input/state for final campaign outcomes
/// No campaign resources or rules are changed by this module.

function campaign_summary_scroll_state()
{
    static _state = {
        active: false,
        outcome: CampaignOutcome.NONE,
        message: "",
        offset: 0,
        dragging: false,
        grab_offset: 0
    };

    return _state;
}

// Reuse the same text measurements and scrollbar geometry
// already used by ordinary decision results.
function campaign_summary_scroll_metrics(_message, _offset)
{
    var _summary = get_ui_regions().campaign_summary;
    var _viewport = _summary.message;
    var _text_height = 0;

    if (_message != "")
    {
        _text_height = string_height_ext(
            _message, -1, _viewport.width
        );
    }

    var _layout = {
        result_y: _viewport.y,
        result_height: _text_height,
        available_result_height: _viewport.height,
        overflow: _text_height > _viewport.height
    };

    var _bar = calculate_result_scrollbar_layout(
        _layout, _summary.scrollbar, _offset
    );

    return {
        viewport: _viewport,
        scrollbar: _bar
    };
}

// Call once per Step from the existing screen input dispatcher.
// The controller only delegates; UI state remains here.
function campaign_summary_scroll_update(_game, _screen_at_step_start)
{
    var _state = campaign_summary_scroll_state();

    // Reset between campaigns, including campaign restarts.
    if (_game.get_campaign_phase() != CampaignPhase.FINISHED)
    {
        _state.active = false;
        _state.dragging = false;
        return;
    }

    var _outcome = _game.get_campaign_outcome();
    var _message = _game.result_message;

    // A new outcome/result starts at the top of the message.
    if (!_state.active
    || _state.outcome != _outcome
    || _state.message != _message)
    {
        _state.active = true;
        _state.outcome = _outcome;
        _state.message = _message;
        _state.offset = 0;
        _state.dragging = false;
        _state.grab_offset = 0;
    }

    // No input while another screen or an overlay owns input.
    if (_screen_at_step_start != ScreenId.GAMEPLAY
    || !_game.screen_manager.can_receive_input(ScreenId.GAMEPLAY))
    {
        _state.dragging = false;
        return;
    }

    var _metrics = campaign_summary_scroll_metrics(
        _message, _state.offset
    );
    var _bar = _metrics.scrollbar;
    var _viewport = _metrics.viewport;

    _state.offset = clamp(_state.offset, 0, _bar.max_scroll);

    if (!_bar.visible)
    {
        _state.dragging = false;
        return;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (point_in_rectangle(
        _mx, _my,
        _viewport.x, _viewport.y,
        _viewport.x + _viewport.width,
        _viewport.y + _viewport.height
    ))
    {
        if (mouse_wheel_down())
        {
            _state.offset += 24;
        }
        else if (mouse_wheel_up())
        {
            _state.offset -= 24;
        }
    }

    // Optional thumb drag uses the existing result scrollbar.
    var _thumb = _bar.thumb;
    var _track = _bar.track;

    if (mouse_check_button_pressed(mb_left)
    && point_in_rectangle(
        _mx, _my,
        _thumb.x, _thumb.y,
        _thumb.x + _thumb.width,
        _thumb.y + _thumb.height
    ))
    {
        _state.dragging = true;
        _state.grab_offset = _my - _thumb.y;
    }

    if (_state.dragging)
    {
        if (mouse_check_button(mb_left))
        {
            var _new_y = clamp(
                _my - _state.grab_offset,
                _track.y,
                _track.y + _bar.thumb_travel
            );

            if (_bar.thumb_travel > 0)
            {
                _state.offset = (
                    (_new_y - _track.y) / _bar.thumb_travel
                ) * _bar.max_scroll;
            }
        }
        else
        {
            _state.dragging = false;
        }
    }

    _state.offset = clamp(_state.offset, 0, _bar.max_scroll);
}
