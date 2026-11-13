
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
            // Get current engineering event
            var _event = design_events[current_event_index];

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
