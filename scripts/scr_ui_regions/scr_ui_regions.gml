
/// @description Define GUI regions for Road to DFX

function get_ui_regions(_event = undefined)
{
    var _gui_width = display_get_gui_width();

    // --------------------------------------------------
    // STEP 67 - FOUR-PANEL GAMEPLAY SHELL
    // --------------------------------------------------
    // All coordinates are GUI-space pixels. Change these
    // values here to resize the future gameplay panels.
    // The 960 x 540 design scales if GUI size changes.
    //
    // Event, choice, review and Continue content regions
    // are derived from the panel geometry below.

    var _gui_height = display_get_gui_height();
    var _sx = _gui_width / 960;
    var _sy = _gui_height / 540;

    var _margin_x = round(10 * _sx);
    var _margin_y = round(10 * _sy);
    var _gap_x = max(1, round(4 * _sx));
    var _gap_y = max(1, round(5 * _sy));

    // Primary editable layout proportions.
    var _left_width = round(613 * _sx);
    var _top_height = round(404 * _sy);

    var _right_x = _margin_x + _left_width + _gap_x;
    var _bottom_y = _margin_y + _top_height + _gap_y;
    var _right_width = _gui_width - _right_x - _margin_x;
    var _bottom_height = _gui_height - _bottom_y - _margin_y;

    // Bottom-right activity strip: three equally sized
    // controls, all using the same shared geometry.
    var _activity_pad = round(10 * _sx);
    var _activity_gap = round(6 * _sx);
    var _activity_button_width = floor(
        (_right_width - (2 * _activity_pad) - (2 * _activity_gap)) / 3
    );
    var _activity_button_y = _bottom_y + round(12 * _sy);
    var _activity_button_height = _bottom_height - round(24 * _sy);
    var _activity_button_x = _right_x + _activity_pad;

    // --------------------------------------------------
    // STEP 67B3 - SCENE, CHOICE AND REVIEW CONTENT
    // --------------------------------------------------
    // Frame geometry remains above. These are inset content
    // rectangles and are reused by rendering and input.

    var _scene_x = _margin_x + round(12 * _sx);
    var _scene_y = _margin_y + round(12 * _sy);
    var _scene_width = _left_width - round(24 * _sx);
    var _scene_height = _top_height - round(24 * _sy);

    var _choice_x = _right_x + round(12 * _sx);
    var _choice_width = _right_width - round(24 * _sx);
    var _choice_top = _margin_y + round(52 * _sy);
    var _choice_bottom = _margin_y + _top_height - round(14 * _sy);

    var _scrollbar_width = max(10, round(12 * _sx));
    var _scrollbar_gap = round(8 * _sx);
    var _review_top = _margin_y + round(76 * _sy);
    var _review_bottom = _margin_y + _top_height - round(58 * _sy);

    return {
        // Future Oregon Trail-style panel boundaries.
        // Border colors and artwork are NOT defined here.
        panels: {
            event_scene: {
                x: _margin_x, y: _margin_y,
                width: _left_width, height: _top_height
            },
            choices: {
                x: _right_x, y: _margin_y,
                width: _right_width, height: _top_height
            },
            project_status: {
                x: _margin_x, y: _bottom_y,
                width: _left_width, height: _bottom_height
            },
            activities: {
                x: _right_x, y: _bottom_y,
                width: _right_width, height: _bottom_height
            }
        },

        // Shared hitboxes for the three bottom-right
        // activity controls. Their modules own their actions.
        activity_buttons: {
            hunt: {
                x: _activity_button_x,
                y: _activity_button_y,
                width: _activity_button_width,
                height: _activity_button_height
            },
            advice: {
                x: _activity_button_x + _activity_button_width
                    + _activity_gap,
                y: _activity_button_y,
                width: _activity_button_width,
                height: _activity_button_height
            },
            water: {
                x: _activity_button_x + (2 * (
                    _activity_button_width + _activity_gap
                )),
                y: _activity_button_y,
                width: _activity_button_width,
                height: _activity_button_height
            }
        },

        // Scene art and narrative share the upper-left panel.
        // The art height is measured from event text by its renderer.
        scene_content: {
            x: _scene_x,
            y: _scene_y,
            width: _scene_width,
            height: _scene_height
        },

        // Right-side choice list; obj_game.refresh_choice_buttons
        // and the choice renderer both use these exact bounds.
        choices: {
            x: _choice_x,
            y: _choice_top,
            width: _choice_width,
            height: max(0, _choice_bottom - _choice_top)
        },

        // Existing result scroller and Continue button use
        // their original implementations at new coordinates.
        results: {
            x: _choice_x,
            y: _review_top,
            width: _choice_width - _scrollbar_width - _scrollbar_gap,
            height: max(0, _review_bottom - _review_top)
        },

        result_scrollbar: {
            x: _choice_x + _choice_width - _scrollbar_width,
            width: _scrollbar_width
        },

        continue_button: {
            x: _choice_x,
            y: _margin_y + _top_height - round(48 * _sy),
            width: min(_choice_width, round(180 * _sx)),
            height: round(34 * _sy)
        }
    };
}
