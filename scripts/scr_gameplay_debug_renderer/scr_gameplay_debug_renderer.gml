/// @description Draw the gameplay debug panel

function draw_gameplay_debug_panel(_game)
{
    // Only render when the debug panel is enabled
    if (!_game.debug_panel_open)
    {
        return;
    }

    // --------------------------------------------------
    // PANEL BACKGROUND
    // --------------------------------------------------

    draw_set_color(make_color_rgb(25, 25, 35));
    draw_rectangle(600, 85, 950, 525, false);


    // --------------------------------------------------
    // PANEL HEADER
    // --------------------------------------------------

    draw_set_color(make_color_rgb(0, 0, 128));
    draw_rectangle(600, 85, 950, 115, false);

    draw_set_color(c_white);
    draw_text(610, 93, "ROAD TO DFX - DEBUG");


    // --------------------------------------------------
    // PLAYER RESOURCES
    // --------------------------------------------------

    draw_set_color(c_yellow);
    draw_text(610, 125, "PLAYER RESOURCES");

    draw_set_color(c_white);

    draw_text(
        610, 145,
        "Days remaining: " + string(_game.days_remaining)
    );

    draw_text(
        610, 163,
        "Engineering hours: " + string(_game.engineering_hours)
    );

    draw_text(
        610, 181,
        "Budget: " + string(_game.budget)
    );

    draw_text(
        610, 199,
        "Morale: " + string(_game.morale)
    );


    // --------------------------------------------------
    // DFX STATUS
    // --------------------------------------------------

    draw_set_color(c_yellow);
    draw_text(610, 225, "DFX STATUS");

    draw_set_color(c_white);

    draw_text(610, 245, "DFA: " + string(_game.dfa) + "%");
    draw_text(610, 263, "DFM: " + string(_game.dfm) + "%");
    draw_text(610, 281, "DFT: " + string(_game.dft) + "%");


    // --------------------------------------------------
    // ENGINEERING STATUS
    // --------------------------------------------------

    draw_set_color(c_yellow);
    draw_text(610, 327, "ENGINEERING STATUS");

    draw_set_color(c_white);

    draw_text(
        610, 347,
        "DRC violations: " + string(_game.drc_violations)
    );

    draw_text(
        610, 365,
        "Manufacturing risk: " + string(_game.manufacturing_risk)
    );

    draw_text(
        610, 383,
        "Software instability: " + string(_game.software_instability)
    );


    // --------------------------------------------------
    // EVENT AND SANITY CRISIS
    // --------------------------------------------------

    draw_set_color(c_yellow);
    draw_text(610, 409, "EVENT / SANITY CRISIS");

    draw_set_color(c_white);

    draw_text(
        610, 429,
        "Current event: " + string(_game.current_event_index + 1)
    );

    draw_text(
        610, 447,
        "Event active: " + string(_game.event_active)
    );

    draw_text(
        610, 465,
        "Event resolved: " + string(_game.event_resolved)
    );

    draw_text(
        610, 483,
        "Crisis active: " + string(_game.sanity_zero_active)
    );

    draw_text(
        610, 501,
        "Turns remaining: "
        + string(_game.sanity_zero_turns_remaining)
    );
}
