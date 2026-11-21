
/// @description Render the gameplay choice panel

function draw_gameplay_choice_panel(
    _event,
    _game_message
)
{
    // --------------------------------------------------
    // CHOICE PANEL POSITION
    // --------------------------------------------------

    var _choice_region = get_ui_regions(_event).choices;

    // --------------------------------------------------
    // CHOICE PANEL HEADING
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(
        370,
        max(230, _choice_region.y - 25),
        "SELECT YOUR RESPONSE:"
    );

    // --------------------------------------------------
    // LEGACY CHOICE TEXT FALLBACK
    // --------------------------------------------------

    // Choice buttons normally handle their own drawing.
    // Preserve the existing fallback when no buttons exist.

    if (instance_number(obj_choice_button) == 0)
    {
        for (
            var _i = 0;
            _i < array_length(_event.choices);
            _i++
        )
        {
            draw_text(
                _choice_region.x,
                _choice_region.y + 5 + (_i * 40),
                string(_i + 1) + ". "
                + _event.choices[_i].text
            );
        }
    }

    // --------------------------------------------------
    // GAMEPLAY MESSAGES
    // --------------------------------------------------

    draw_text(
        370,
        385,
        _game_message
    );
}
