/// @description Render the gameplay choice panel and overflow indicator

function draw_gameplay_choice_panel(_event, _game_message)
{
    var _layout = get_ui_regions(_event);
    var _choice_region = _layout.choices;
    var _panel = _layout.panels.choices;

    draw_set_color(c_black);
    draw_text(
        _choice_region.x,
        _panel.y + 20,
        "SELECT YOUR RESPONSE:"
    );

    // Choice buttons handle their own scroll-aware rendering and input.
    // Keep a clipped text fallback if button creation ever fails.
    if (instance_number(obj_choice_button) == 0)
    {
        var _flex = calculate_choice_layout_flex(
            _event.choices, _choice_region
        );
        var _offset = gameplay_choice_scroll_state(_event).offset;
        var _previous_scissor = gameplay_choice_begin_clip(_choice_region);

        for (var _i = 0; _i < array_length(_event.choices); _i++)
        {
            var _button = _flex.buttons[_i];

            draw_set_color(c_black);
            draw_text_ext(
                _button.x,
                _button.y - _offset + 5,
                string(_i + 1) + ". " + _event.choices[_i].text,
                -1,
                _choice_region.width
            );
        }

        gameplay_choice_end_clip(_previous_scissor);
    }

    // Only visible when choice content exceeds its region.
    gameplay_choice_draw_scrollbar(_event);
}
