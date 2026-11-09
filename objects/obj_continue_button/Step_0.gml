/// @description Handle Continue button mouse interaction

// Verify the game controller exists
if (!instance_exists(controller))
{
    exit;
}

// Disable interaction unless a decision has been resolved
if (!controller.event_active || !controller.event_resolved)
{
    is_hovered = false;
    exit;
}

// Get mouse position in GUI coordinates
var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);

// Check whether the mouse is inside the button
is_hovered = point_in_rectangle(
    _mouse_x,
    _mouse_y,
    button_x,
    button_y,
    button_x + button_width,
    button_y + button_height
);

// Request progression when clicked
if (is_hovered && mouse_check_button_pressed(mb_left))
{
    controller.continue_requested = true;
}
