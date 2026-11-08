
/// @description Draw reusable choice button

// Draw only when connected to a valid game controller
if (instance_exists(controller) && choice_index >= 0)
{
    if (controller.event_active && !controller.event_resolved)
    {
        var _choices =
            controller.design_events[controller.current_event_index].choices;

        if (choice_index < array_length(_choices))
        {
            // Button background
            if (is_hovered)
            {
                draw_set_color(make_color_rgb(190, 210, 235));
            }
            else
            {
                draw_set_color(make_color_rgb(225, 225, 225));
            }

            draw_rectangle(
                button_x,
                button_y,
                button_x + button_width,
                button_y + button_height,
                false
            );

            // Button border
            draw_set_color(c_black);

            draw_rectangle(
                button_x,
                button_y,
                button_x + button_width,
                button_y + button_height,
                true
            );

          
            // Choice text with automatic wrapping
            var _button_label =
                string(choice_index + 1) + ". "
                + _choices[choice_index].text;

            draw_text_ext(
                button_x + 8,
                button_y + 8,
                _button_label,
                -1,
                button_width - 16
            );

        }
    }
}
