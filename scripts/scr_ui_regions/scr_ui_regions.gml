
/// @description Define GUI regions for Road to DFX

function get_ui_regions()
{
    var _gui_width = display_get_gui_width();

    // Shared horizontal layout boundaries
    var _content_left = 370;
    var _right_margin = 40;

    // Choice area boundaries
    var _choice_top = 250;
    var _choice_height = 135;
	// Results scrollbar dimensions
	var _scrollbar_width = 12;
	var _scrollbar_gap = 8;

	// Total available width of the event content area
	var _content_width = _gui_width - _content_left - _right_margin;
    return {
        // Interactive choice buttons
        choices: {
            x: _content_left,
            y: _choice_top,
            width: _gui_width - _content_left - _right_margin,
            height: _choice_height
        },
		
		
        
		// Decision results text area
		results: {
		    x: _content_left,
		    y: 300,
		    width: _content_width - _scrollbar_width - _scrollbar_gap,
		    height: 135
		},

		// Scrollbar position
		result_scrollbar: {
		    x: _content_left + _content_width - _scrollbar_width,
		    width: _scrollbar_width
		},

        // Continue button
        continue_button: {
            x: _content_left,
            y: 450,
            width: 180,
            height: 38
        }
    };
}
	