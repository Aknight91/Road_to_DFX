
/// @description Render the gameplay choice panel

function draw_gameplay_choice_panel(
    _event,
    _game_message
)
{
    // --------------------------------------------------
    // CHOICE PANEL HEADING
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(
        370,
        230,
        "SELECT YOUR RESPONSE:"
    );


    // --------------------------------------------------
    // LEGACY CHOICE TEXT FALLBACK
    // --------------------------------------------------

    // Choice buttons normally handle their own drawing.
    // Preserve the existing fallback in case no
    // choice-button instances are available.

    if (instance_number(obj_choice_button) == 0)
    {
        for (var _i = 0;
             _i < array_length(_event.choices);
             _i++)
        {
            draw_text(
                370,
                265 + (_i * 40),
                string(_i + 1) + ". "
                + _event.choices[_i].text
            );
        }
    }


    // --------------------------------------------------
    // GAMEPLAY MESSAGES
    // --------------------------------------------------

    // Display messages such as insufficient
    // engineering hours.

    draw_text(
        370,
        385,
        _game_message
    );
}
