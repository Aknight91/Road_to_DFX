/// @description Screen manager for Road to DFX

function ScreenManager(_initial_screen) constructor
{
    // The currently displayed primary screen
    current_screen = _initial_screen;

	// Modal overlays, ordered from bottom to top
	overlay_stack = [];

    // --------------------------------------------------
    // SCREEN STATE QUERY
    // --------------------------------------------------

    get_current_screen = function()
    {
        return current_screen;
    };

// --------------------------------------------------
// VALIDATE SCREEN IDENTIFIERS
// --------------------------------------------------

is_valid_screen = function(_screen)
{
    return (
        _screen == ScreenId.TITLE
        || _screen == ScreenId.CAMPAIGN_SETUP
        || _screen == ScreenId.GAMEPLAY
        || _screen == ScreenId.CAMPAIGN_RESULTS
    );
};


// --------------------------------------------------
// REQUEST SCREEN NAVIGATION
// --------------------------------------------------

navigate_to = function(_target_screen)
{
    // Reject unknown screen identifiers
    if (!is_valid_screen(_target_screen))
    {
        show_debug_message(
            "SCREEN MANAGER: Invalid screen requested."
        );

        return false;
    }

    // Avoid unnecessary transitions
    if (current_screen == _target_screen)
    {
        return false;
    }

    // Update the active screen
    current_screen = _target_screen;

    return true;
};

// --------------------------------------------------
// SCREEN INPUT PERMISSION
// --------------------------------------------------

can_receive_input = function(_screen)
{
    // Only the active primary screen can receive input
    if (current_screen != _screen)
    {
        return false;
    }

    // Modal overlays block input to the underlying screen
    if (array_length(overlay_stack) > 0)
    {
        return false;
    }

    return true;
};


}
