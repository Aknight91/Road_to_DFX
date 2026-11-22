/// @description Draw a scrollable, clipped gameplay choice button

if (!instance_exists(controller))
{
    exit;
}

if (controller.screen_manager.get_current_screen()
    != ScreenId.GAMEPLAY)
{
    exit;
}

if (controller.get_campaign_phase() != CampaignPhase.CHOOSING)
{
    exit;
}

if (choice_index < 0)
{
    exit;
}

var _event = controller.get_current_campaign_event();
if (!is_struct(_event))
{
    exit;
}

var _region = get_ui_regions(_event).choices;
var _scroll = gameplay_choice_scroll_state(_event).offset;
var _visible_y = button_y - _scroll;

// Skip fully out-of-view buttons.
if (_visible_y + button_height <= _region.y
|| _visible_y >= _region.y + _region.height)
{
    exit;
}

// Clip partially visible buttons to the shared choice panel.
var _previous_scissor = gameplay_choice_begin_clip(_region);

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
    _visible_y,
    button_x + button_width,
    _visible_y + button_height,
    false
);

draw_set_color(c_black);
draw_rectangle(
    button_x,
    _visible_y,
    button_x + button_width,
    _visible_y + button_height,
    true
);

draw_text_ext(
    button_x + 8,
    _visible_y + 8,
    choice_label,
    -1,
    button_width - 16
);

// Always restore GPU state before drawing the next UI element.
gameplay_choice_end_clip(_previous_scissor);
