
/// @description Define GUI regions for Road to DFX

function get_ui_regions(_event = undefined)
{
    var _gui_width = display_get_gui_width();

    // Shared horizontal layout boundaries
    var _content_left = 370;
    var _right_margin = 40;

    // --------------------------------------------------
    // DYNAMIC CHOICE AREA
    // --------------------------------------------------

    var _choice_top = 250;
    var _choice_bottom = 458;

    // Move choices below longer event descriptions.
    if (is_struct(_event))
    {
        var _description_height = string_height_ext(
            _event.description,
            -1,
            520
        );

        _choice_top = max(
            250,
            155 + _description_height + 35
        );
    }

    var _choice_height = max(
        0,
        _choice_bottom - _choice_top
    );

    // --------------------------------------------------
    // RESULTS AND SCROLLBAR
    // --------------------------------------------------

    var _scrollbar_width = 12;
    var _scrollbar_gap = 8;

    var _content_width =
        _gui_width - _content_left - _right_margin;

    return {
        choices: {
            x: _content_left,
            y: _choice_top,
            width: _content_width,
            height: _choice_height
        },

        results: {
            x: _content_left,
            y: 300,
            width: _content_width
                - _scrollbar_width
                - _scrollbar_gap,
            height: 135
        },

        result_scrollbar: {
            x: _content_left
                + _content_width
                - _scrollbar_width,
            width: _scrollbar_width
        },

        continue_button: {
            x: _content_left,
            y: 450,
            width: 180,
            height: 38
        }
    };
}
