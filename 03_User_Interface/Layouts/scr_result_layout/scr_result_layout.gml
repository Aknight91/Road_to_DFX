
/// @description Calculate decision result text layout

function calculate_result_layout(_game_message, _result_message, _region)
{
    // Calculate the position of the result message
    var _message_height = string_height(_game_message);

    var _result_y = _region.y + _message_height + 10;

    // Measure the wrapped result text
    var _result_height = 0;

    if (_result_message != "")
    {
        _result_height = string_height_ext(
            _result_message,
            -1,
            _region.width
        );
    }

   
	// Determine the available space for result text
	var _region_bottom = _region.y + _region.height;

	var _available_result_height = max(
	    0,
	    _region_bottom - _result_y
	);

	// Return positions and text measurements
	return {
	    message_y: _region.y,
	    result_y: _result_y,
	    result_height: _result_height,
	    available_result_height: _available_result_height,
	    overflow: (
	        _result_y > _region_bottom
	        || _result_height > _available_result_height
	    )
	};

}
