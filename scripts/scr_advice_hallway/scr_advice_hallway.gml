/// @description Ask for Advice - hallway and office preview screens
// Standalone input and rendering. No campaign resource costs yet.

function advice_entry_bounds()
{
    // Layout comes from the shared gameplay region system.
    return get_ui_regions().activity_buttons.advice;
}

function advice_back_bounds()
{
    return { x: 35, y: 475, width: 230, height: 45 };
}

function advice_coworker_bounds(_index)
{
    return {
        x: 140,
        y: 173 + (78 * _index),
        width: 680,
        height: 64
    };
}

function advice_point_in_bounds(_x, _y, _bounds)
{
    return point_in_rectangle(
        _x, _y,
        _bounds.x,
        _bounds.y,
        _bounds.x + _bounds.width,
        _bounds.y + _bounds.height
    );
}

// Called from obj_game Step once per frame.
// All hallway and office input handling stays in this script.
function advice_handle_input(_game, _screen_at_start)
{
    var _manager = _game.screen_manager;

    // ENTER HALLWAY FROM AN UNRESOLVED GAMEPLAY ENCOUNTER.
    if (_screen_at_start == ScreenId.GAMEPLAY)
    {
        if (!_manager.can_receive_input(ScreenId.GAMEPLAY)
        || _game.get_campaign_phase() != CampaignPhase.CHOOSING
        || !is_struct(_game.active_encounter)
        || !is_struct(_game.advice_state)
        || _game.debug_panel_open)
        {
            return;
        }

        if (mouse_check_button_pressed(mb_left))
        {
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);

            if (advice_point_in_bounds(_mx, _my, advice_entry_bounds()))
            {
                if (advice_begin_encounter(
                    _game.advice_state,
                    _game.active_encounter.id
                ))
                {
                    _manager.navigate_to(ScreenId.ADVICE_HALLWAY);
                    mouse_clear(mb_left);
                }
            }
        }
        return;
    }

    // SELECT COWORKER OR RETURN TO THE UNRESOLVED ENCOUNTER.
    if (_screen_at_start == ScreenId.ADVICE_HALLWAY)
    {
        if (!_manager.can_receive_input(ScreenId.ADVICE_HALLWAY))
        {
            return;
        }

        var _click = mouse_check_button_pressed(mb_left);
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        if (keyboard_check_pressed(vk_escape)
        || (_click && advice_point_in_bounds(
            _mx, _my, advice_back_bounds()
        )))
        {
            _manager.navigate_to(ScreenId.GAMEPLAY);
            mouse_clear(mb_left);
            return;
        }

        if (!_click || !is_struct(_game.advice_state))
        {
            return;
        }

        var _coworkers = _game.advice_state.coworkers;
        for (var _i = 0; _i < array_length(_coworkers); _i++)
        {
            var _npc = _coworkers[_i];
            if (advice_point_in_bounds(_mx, _my, advice_coworker_bounds(_i))
            && advice_can_consult(_game.advice_state, _npc.id))
            {
                // Selecting an office does not count as consultation.
                _game.advice_state.selected_coworker_id = _npc.id;
                _manager.navigate_to(ScreenId.ADVICE_OFFICE);
                mouse_clear(mb_left);
                return;
            }
        }
        return;
    }

    // OFFICE PREVIEW: navigation only, no time cost or advice yet.
    if (_screen_at_start == ScreenId.ADVICE_OFFICE)
    {
        if (!_manager.can_receive_input(ScreenId.ADVICE_OFFICE))
        {
            return;
        }

        if (keyboard_check_pressed(vk_escape))
        {
            _manager.navigate_to(ScreenId.ADVICE_HALLWAY);
            return;
        }

        if (mouse_check_button_pressed(mb_left))
        {
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            if (advice_point_in_bounds(_mx, _my, advice_back_bounds()))
            {
                _manager.navigate_to(ScreenId.ADVICE_HALLWAY);
                mouse_clear(mb_left);
            }
        }
    }
}

// Entry button is drawn by the screen dispatcher after gameplay renders.
function draw_advice_entry_button(_game)
{
    if (_game.get_campaign_phase() != CampaignPhase.CHOOSING
    || !is_struct(_game.active_encounter)
    || !is_struct(_game.advice_state))
    {
        return;
    }

    var _b = advice_entry_bounds();
    draw_set_color(make_color_rgb(225, 225, 225));
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, false);
    draw_set_color(c_black);
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, true);

    // Temporary icon/label for the narrower activity slot.
    // Both drawing and hit testing use advice_entry_bounds().
    draw_set_halign(fa_center);
    draw_text(_b.x + _b.width / 2, _b.y + 9, "?");
    draw_text(_b.x + _b.width / 2, _b.y + 45, "ADVICE");
    draw_set_halign(fa_left);
}

function advice_draw_back_button(_caption)
{
    var _b = advice_back_bounds();
    draw_set_color(make_color_rgb(225, 225, 225));
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, false);
    draw_set_color(c_black);
    draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, true);
    draw_text(_b.x + 16, _b.y + 14, _caption);
}

function advice_draw_background(_heading)
{
    draw_set_color(make_color_rgb(192, 192, 192));
    draw_rectangle(0, 0, 960, 540, false);
    draw_set_color(make_color_rgb(0, 0, 128));
    draw_rectangle(20, 20, 940, 75, false);
    draw_set_color(c_white);
    draw_text(35, 35, "ROAD TO DFX - " + _heading);
}

function draw_advice_hallway_screen(_game)
{
    advice_draw_background("ASK FOR ADVICE");

    draw_set_color(c_black);
    draw_text(140, 110, "YOUR COWORKERS");
    draw_text(140, 132, "Select an office to visit. No engineering time is charged yet.");

    if (is_struct(_game.advice_state))
    {
        var _coworkers = _game.advice_state.coworkers;
        for (var _i = 0; _i < array_length(_coworkers); _i++)
        {
            var _npc = _coworkers[_i];
            var _b = advice_coworker_bounds(_i);
            var _available = advice_can_consult(_game.advice_state, _npc.id);
            draw_set_color(_available
                ? make_color_rgb(228, 228, 220)
                : make_color_rgb(155, 155, 155));
            draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, false);
            draw_set_color(c_black);
            draw_rectangle(_b.x, _b.y, _b.x + _b.width, _b.y + _b.height, true);
            draw_text(_b.x + 12, _b.y + 9, _npc.name);
            draw_text(_b.x + 12, _b.y + 34, _npc.role);
            draw_text(_b.x + 530, _b.y + 22,
                _available ? "VISIT OFFICE" : "CONSULTED");
        }
    }

    advice_draw_back_button("RETURN TO DESIGN");
}

function draw_advice_office_screen(_game)
{
    advice_draw_background("COWORKER OFFICE");

    var _npc = undefined;
    if (is_struct(_game.advice_state)
    && variable_struct_exists(_game.advice_state, "selected_coworker_id"))
    {
        var _selected = _game.advice_state.selected_coworker_id;
        var _coworkers = _game.advice_state.coworkers;

        for (var _i = 0; _i < array_length(_coworkers); _i++)
        {
            if (_coworkers[_i].id == _selected)
            {
                _npc = _coworkers[_i];
                break;
            }
        }
    }

    draw_set_color(c_black);
    if (is_struct(_npc))
    {
        draw_text(140, 140, _npc.name);
        draw_text(140, 175, _npc.role);
    }
    else
    {
        draw_text(140, 140, "No coworker selected.");
    }

    draw_text(140, 250, "OFFICE PREVIEW - CONSULTATION NOT IMPLEMENTED YET");
    draw_text(140, 287, "No hours spent, no advice recorded, no event choices changed.");
    advice_draw_back_button("BACK TO HALLWAY");
}
