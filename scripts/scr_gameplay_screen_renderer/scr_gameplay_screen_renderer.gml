/// @description Coordinate rendering of the gameplay screen

function draw_gameplay_screen(_game)
{
    // Execute in the controller's instance context.
    // This preserves access to its campaign functions,
    // resources, and state variables.

    with (_game)
    {
        // --------------------------------------------------
        // BACKGROUND
        // --------------------------------------------------

        draw_set_color(make_color_rgb(192, 192, 192));
        draw_rectangle(0, 0, 960, 540, false);


        // --------------------------------------------------
        // TITLE BAR
        // --------------------------------------------------

        draw_set_color(make_color_rgb(0, 0, 128));
        draw_rectangle(20, 20, 940, 75, false);

        draw_set_color(c_white);
        draw_text(35, 35, "ROAD TO DFX");


        // --------------------------------------------------
        // PROJECT STATUS HUD
        // --------------------------------------------------

        draw_gameplay_hud(id);


        // --------------------------------------------------
        // CAMPAIGN PHASE
        // --------------------------------------------------

        var _phase = get_campaign_phase();

        if (_phase != CampaignPhase.FINISHED)
        {
            // Read the event through the verified event bridge.
            // Dynamic encounters are preferred when active;
            // otherwise the four-event prototype is used.
            var _event = get_current_campaign_event();

            // Draw scenario information
            draw_gameplay_event_header(_event);


            // --------------------------------------------------
            // CHOOSING PHASE
            // --------------------------------------------------

            if (_phase == CampaignPhase.CHOOSING)
            {
                draw_gameplay_choice_panel(
                    _event,
                    game_message
                );
            }


            // --------------------------------------------------
            // REVIEWING PHASE
            // --------------------------------------------------

            else if (_phase == CampaignPhase.REVIEWING)
            {
                draw_gameplay_review_panel(
                    game_message,
                    result_message,
                    result_scroll_offset
                );
            }
        }


        // --------------------------------------------------
        // FINISHED CAMPAIGN
        // --------------------------------------------------

        else if (get_campaign_outcome() != CampaignOutcome.NONE)
        {
            var _final_stats = {
                dfa: dfa,
                dfm: dfm,
                dft: dft,
                sanity: sanity
            };

            draw_campaign_summary(
                get_campaign_outcome(),
                game_message,
                result_message,
                _final_stats
            );
        }


// --------------------------------------------------
// DEVELOPMENT BUILD: INCOMPLETE EVENT LIBRARY
// --------------------------------------------------

// Gameplay stopped without a release outcome.
// Display a neutral stopping point, not a victory
// or failure screen.

else
{
    draw_set_color(c_black);

    draw_text(370, 160, "ROAD TO DFX");

    draw_text(370, 210, game_message);

    draw_text_ext(
        370,
        260,
        result_message,
        -1,
        520
    );

    draw_text(
        370,
        455,
        "Press ESC for the Pause menu."
    );
}

        // --------------------------------------------------
        // PROTOTYPE LABEL
        // --------------------------------------------------

        draw_set_color(c_black);

        draw_text(
            35,
            475,
            "ROAD TO DFX - PROTOTYPE"
        );


        // --------------------------------------------------
        // DEBUG PANEL
        // --------------------------------------------------

        draw_gameplay_debug_panel(id);
    }
}
