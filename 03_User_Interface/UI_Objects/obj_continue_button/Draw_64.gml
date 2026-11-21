/// @description Draw the Continue button

// Only draw when the controller exists
if (!instance_exists(controller))
{
    exit;
}

// Only show Continue during the result-review phase
if (controller.get_campaign_phase() != CampaignPhase.REVIEWING)
{
    exit;
}


// Button background
if (is_hovered)
{
    draw_set_color(make_color_rgb(0, 0, 128));
}
else
{
    draw_set_color(make_color_rgb(220, 220, 220));
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

// Center the button label
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (is_hovered)
{
    draw_set_color(c_white);
}
else
{
    draw_set_color(c_black);
}

draw_text(
    button_x + button_width / 2,
    button_y + button_height / 2,
    "CONTINUE"
);

// Restore default text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);
