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

        // Relocate the label into the title bar.
        draw_set_color(c_white);

        draw_text(
            35,
            55,
            "ROAD TO DFX - PROTOTYPE"
        );

        
// --------------------------------------------------
// DRC HUNT ENTRY BUTTON
// --------------------------------------------------

if (_phase == CampaignPhase.CHOOSING)
{
    var _hunt_used = false;

    if (is_struct(active_encounter))
    {
        _hunt_used =
            drc_hunt_last_event_id == active_encounter.id;
    }

    var _hunt_available =
        is_struct(active_encounter)
        && !_hunt_used
        && drc_violations > 0
        && engineering_hours > drc_hunt_cost_hours;

    // Available and unavailable button colors.
    if (_hunt_available)
    {
        draw_set_color(make_color_rgb(225, 225, 225));
    }
    else
    {
        draw_set_color(make_color_rgb(155, 155, 155));
    }

    draw_rectangle(35, 480, 305, 520, false);

    draw_set_color(c_black);
    draw_rectangle(35, 480, 305, 520, true);

    if (_hunt_used)
    {
        draw_text(55, 490, "HUNT ALREADY USED");
    }
    else if (_hunt_available)
    {
        draw_text(
            55,
            490,
            "HUNT DRCs - " + string(drc_hunt_cost_hours) + " HOURS"
        );
    }
    else
    {
        draw_text(55, 490, "HUNT UNAVAILABLE");
    }
}




    }
}
