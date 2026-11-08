
/// @description Calculate layout for event choice buttons

function calculate_choice_layout(_choices)
{
    // Layout boundaries in GUI coordinates
    var _left = 370;
    var _top = 260;
    var _right_margin = 40;

    // Button spacing and dimensions
    var _padding = 8;
    var _gap = 10;
    var _minimum_height = 30;

    // Determine button width from the GUI dimensions
    var _gui_width = display_get_gui_width();
    var _button_width = _gui_width - _left - _right_margin;

    // Build a rectangle for each available choice
    var _layout = [];
    var _current_y = _top;

    for (var _i = 0; _i < array_length(_choices); _i++)
    {
        var _label = string(_i + 1) + ". " + _choices[_i].text;

        // Measure wrapped text height
        var _text_height = string_height_ext(
            _label,
            -1,
            _button_width - (_padding * 2)
        );

        var _button_height = max(
            _minimum_height,
            _text_height + (_padding * 2)
        );

        // Store this button's calculated rectangle
        _layout[_i] = {
            x: _left,
            y: _current_y,
            width: _button_width,
            height: _button_height
        };

        // Position the next button below this one
        _current_y += _button_height + _gap;
    }

    return _layout;
}
