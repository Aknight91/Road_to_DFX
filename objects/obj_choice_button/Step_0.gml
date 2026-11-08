
/// @description Handle choice button mouse interaction

// Reset hover state each frame
is_hovered = false;

// Only process valid buttons
if (instance_exists(controller) && choice_index >= 0)
{
    if (controller.event_active && !controller.event_resolved)
    {
        var _choices =
            controller.design_events[controller.current_event_index].choices;

        if (choice_index < array_length(_choices))
        {
            // Get mouse position in GUI coordinates
            var _mouse_x = device_mouse_x_to_gui(0);
            var _mouse_y = device_mouse_y_to_gui(0);

            // Use the same rectangle as our drawing code
            is_hovered = point_in_rectangle(
                _mouse_x,
                _mouse_y,
                button_x,
                button_y,
                button_x + button_width,
                button_y + button_height
            );

            // Send the selected choice to the controller
            if (is_hovered && mouse_check_button_pressed(mb_left))
            {
                controller.apply_player_choice(choice_index);
            }
        }
    }
}
