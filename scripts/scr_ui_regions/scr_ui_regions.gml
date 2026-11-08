/// @description Define GUI regions for Road to DFX

function get_ui_regions()
{
    var _gui_width = display_get_gui_width();

    // Choice area boundaries
    var _choice_left = 370;
    var _choice_top = 250;
    var _right_margin = 40;
    var _choice_height = 135;

    return {
        choices: {
            x: _choice_left,
            y: _choice_top,
            width: _gui_width - _choice_left - _right_margin,
            height: _choice_height
        }
    };
}
