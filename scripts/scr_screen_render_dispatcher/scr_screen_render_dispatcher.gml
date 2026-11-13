/// @description Dispatch rendering to the active screen

function draw_primary_screen(_screen_id, _game)
{
    // --------------------------------------------------
    // PRIMARY SCREEN RENDERING
    // --------------------------------------------------

    switch (_screen_id)
    {
        // ----------------------------------------------
        // GAMEPLAY SCREEN
        // ----------------------------------------------

        case ScreenId.GAMEPLAY:

            draw_gameplay_screen(_game);

            break;


        // ----------------------------------------------
        // FUTURE PRIMARY SCREENS
        // ----------------------------------------------

        // ScreenId.TITLE
        // ScreenId.CAMPAIGN_SETUP
        // ScreenId.CAMPAIGN_RESULTS
        //
        // These will be connected as their
        // individual renderers are implemented.


        // ----------------------------------------------
        // UNHANDLED SCREEN
        // ----------------------------------------------

        default:

            // No renderer registered for this screen.
            // Navigation to unfinished screens will
            // remain disabled until implementation.

            break;
    }
}
