
/// @description Calculate choice positions using Flex Panels

function calculate_choice_layout_flex(_choices, _region)
{
    var _padding = 8;
    var _gap = 10;
    var _minimum_height = 30;

    // Create a layout container within the supplied region
    var _root = flexpanel_create_node({
        width: _region.width,
        height: _region.height,
        flexDirection: "column",
        gap: _gap
    });

    // Create one layout node per choice
    for (var _i = 0; _i < array_length(_choices); _i++)
    {
        var _label =
            string(_i + 1) + ". " + _choices[_i].text;

        var _text_height = string_height_ext(
            _label,
            -1,
            _region.width - (_padding * 2)
        );

        var _button_height = max(
            _minimum_height,
            _text_height + (_padding * 2)
        );

        
		var _node = flexpanel_create_node({
		    width: "100%",
		    height: _button_height,
		    flexGrow: 0,
		    flexShrink: 0
		});


        flexpanel_node_insert_child(_root, _node, _i);
    }

    // Calculate all positions and dimensions
    flexpanel_calculate_layout(
        _root,
        _region.width,
        _region.height,
        flexpanel_direction.LTR
    );

    var _buttons = [];

    // Convert Flex Panel positions into GUI rectangles
    for (var _i = 0; _i < array_length(_choices); _i++)
    {
        var _node = flexpanel_node_get_child(_root, _i);

        var _position =
            flexpanel_node_layout_get_position(_node, false);

        array_push(_buttons, {
            x: _region.x + _position.left,
            y: _region.y + _position.top,
            width: _position.width,
            height: _position.height
        });
    }

    // Detect whether the contents exceed the available region
    var _root_position =
        flexpanel_node_layout_get_position(_root);

    var _overflow = _root_position.hadOverflow;

    // Release temporary layout nodes
    flexpanel_delete_node(_root, true);

    return {
        buttons: _buttons,
        overflow: _overflow
    };
}
