
/// @description Handle choice button mouse interaction

// Reset hover state each frame
is_hovered = false;

// Stop if the controller no longer exists
if (!instance_exists(controller))
{
    exit;
}


 // Only allow interaction during the CHOOSING phase
 if (controller.get_campaign_phase() != CampaignPhase.CHOOSING)
 {
     exit;
 }


// Reject uninitialized buttons
if (choice_index < 0)
{
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

// Forward the selection to the game controller
if (is_hovered && mouse_check_button_pressed(mb_left))
{
    controller.apply_player_choice(choice_index);
}
