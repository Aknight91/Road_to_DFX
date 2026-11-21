
/// @description Draw reusable choice button

// Verify the controller exists
if (!instance_exists(controller))
{
    exit;
}

// Only draw choice buttons on the gameplay screen
if (controller.screen_manager.get_current_screen()
    != ScreenId.GAMEPLAY)
{
    exit;
}


// Only draw buttons during the CHOOSING phase
if (controller.get_campaign_phase() != CampaignPhase.CHOOSING)
{
    exit;
}


// Reject uninitialized buttons
if (choice_index < 0)
{
    exit;
}

// --------------------------------------------------
// BUTTON BACKGROUND
// --------------------------------------------------

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

// --------------------------------------------------
// BUTTON BORDER
// --------------------------------------------------

draw_set_color(c_black);

draw_rectangle(
    button_x,
    button_y,
    button_x + button_width,
    button_y + button_height,
    true
);

// --------------------------------------------------
// BUTTON TEXT
// --------------------------------------------------

// Display the label assigned by the controller
draw_text_ext(
    button_x + 8,
    button_y + 8,
    choice_label,
    -1,
    button_width - 16
);
