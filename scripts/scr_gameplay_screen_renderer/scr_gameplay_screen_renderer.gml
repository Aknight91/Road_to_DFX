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


        // The gameplay screen is now a four-panel shell.
        // Title branding belongs to the title screen, not
        // over the event-image/choice panel content.

        // --------------------------------------------------
        // STEP 67B - SHARED FOUR-PANEL FRAMES
        // --------------------------------------------------
        // Geometry comes exclusively from scr_ui_regions.
        // The HUD, scene, choices, review and activities now
        // obtain their positions from these shared regions.

        draw_gameplay_panel_frames();


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
    var _choices_panel = get_ui_regions().panels.choices;
    var _left = _choices_panel.x + 12;
    var _width = _choices_panel.width - 24;

    draw_set_color(c_black);
    draw_text(_left, _choices_panel.y + 25, "ROAD TO DFX");
    draw_text_ext(
        _left,
        _choices_panel.y + 60,
        game_message,
        -1,
        _width
    );
    draw_text_ext(
        _left,
        _choices_panel.y + 130,
        result_message,
        -1,
        _width
    );
}

       

        
// --------------------------------------------------
// STEP 67B2 - SHARED BOTTOM-RIGHT ACTIVITY BUTTONS
// --------------------------------------------------
// Draws Hunt and a disabled Water Cooler placeholder.
// The Advice button remains owned by scr_advice_hallway.
// All hitboxes come from scr_ui_regions.

draw_gameplay_activity_bar(id, _phase);




    }
}
