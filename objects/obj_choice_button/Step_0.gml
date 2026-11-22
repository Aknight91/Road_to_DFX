/// @description Handle choice button mouse interaction and choice scrolling

is_hovered = false;

// Stop if the controller no longer exists.
if (!instance_exists(controller))
{
    exit;
}

// Only handle mouse interaction when gameplay owns input.
if (!controller.screen_manager.can_receive_input(ScreenId.GAMEPLAY))
{
    exit;
}

// Only allow interaction during the CHOOSING phase.
if (controller.get_campaign_phase() != CampaignPhase.CHOOSING)
{
    exit;
}

// Reject uninitialized buttons.
if (choice_index < 0)
{
    exit;
}

var _event = controller.get_current_campaign_event();
if (!is_struct(_event))
{
    exit;
}

// One button coordinates mouse-wheel input so scrolling
// cannot occur once for every available choice.
if (choice_index == 0)
{
    gameplay_choice_scroll_update(_event);
}

var _region = get_ui_regions(_event).choices;
var _scroll = gameplay_choice_scroll_state(_event).offset;
var _visible_y = button_y - _scroll;

var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);

// A button may only be clicked within the visible choice viewport.
// This also prevents off-screen buttons from overlapping activities.
var _inside_viewport = point_in_rectangle(
    _mouse_x,
    _mouse_y,
    _region.x,
    _region.y,
    _region.x + _region.width,
    _region.y + _region.height
);

is_hovered = _inside_viewport && point_in_rectangle(
    _mouse_x,
    _mouse_y,
    button_x,
    _visible_y,
    button_x + button_width,
    _visible_y + button_height
);

if (is_hovered && mouse_check_button_pressed(mb_left))
{
    controller.apply_player_choice(choice_index);
}
