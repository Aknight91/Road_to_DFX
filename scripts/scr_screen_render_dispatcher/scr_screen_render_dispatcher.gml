
/// @description Dispatch rendering to the active screen

function draw_primary_screen(_screen_id, _game)
{
    // --------------------------------------------------
    // PRIMARY SCREEN RENDERING
    // --------------------------------------------------

    switch (_screen_id)
    {
        // ----------------------------------------------
        // TITLE SCREEN
        // ----------------------------------------------

        case ScreenId.TITLE:

            draw_title_screen();

            break;


        // ----------------------------------------------
        // GAMEPLAY SCREEN
        // ----------------------------------------------

        case ScreenId.GAMEPLAY:

            draw_gameplay_screen(_game);

            break;


      
        // ----------------------------------------------
        // CAMPAIGN SETUP SCREEN
        // ----------------------------------------------

        case ScreenId.CAMPAIGN_SETUP:

            draw_campaign_setup_screen();

            break;


        // ----------------------------------------------
        // FUTURE PRIMARY SCREENS
        // ----------------------------------------------

        // ScreenId.CAMPAIGN_RESULTS
        //
        // This will be connected when its
        // renderer is implemented.

        // ----------------------------------------------
        // UNHANDLED SCREEN
        // ----------------------------------------------

        default:

            // No renderer registered for this screen.

            break;
    }
}

