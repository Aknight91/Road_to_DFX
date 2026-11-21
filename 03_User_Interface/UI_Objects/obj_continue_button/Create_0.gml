/// @description Initialize the Continue button

// Reference to the main game controller
controller = noone;

// Button position and dimensions (GUI coordinates)

// Get the Continue button's layout region
var _region = get_ui_regions().continue_button;

// Apply the shared layout dimensions
button_x = _region.x;
button_y = _region.y;
button_width = _region.width;
button_height = _region.height;


// Mouse hover state
is_hovered = false;
