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

// --------------------------------------------------
// OVERLAY VALIDATION
// --------------------------------------------------

is_valid_overlay = function(_overlay)
{
    return (
        _overlay == OverlayId.PAUSE_MENU
        || _overlay == OverlayId.SAVE_LOAD
        || _overlay == OverlayId.CONFIRMATION
    );
};


// --------------------------------------------------
// GET TOP OVERLAY
// --------------------------------------------------

get_top_overlay = function()
{
    var _count = array_length(overlay_stack);

    if (_count == 0)
    {
        return noone;
    }

    return overlay_stack[_count - 1];
};


// --------------------------------------------------
// OPEN OVERLAY
// --------------------------------------------------

open_overlay = function(_overlay)
{
    // Reject unknown overlays
    if (!is_valid_overlay(_overlay))
    {
        show_debug_message(
            "SCREEN MANAGER: Invalid overlay requested."
        );

        return false;
    }

    // Prevent opening the same overlay twice in a row
    if (get_top_overlay() == _overlay)
    {
        return false;
    }

    array_push(overlay_stack, _overlay);

    return true;
};


// --------------------------------------------------
// CLOSE TOP OVERLAY
// --------------------------------------------------

close_top_overlay = function()
{
    var _count = array_length(overlay_stack);

    // Nothing to close
    if (_count == 0)
    {
        return noone;
    }

    // Remember which overlay is being closed
    var _closed_overlay = overlay_stack[_count - 1];

    // Remove only the top overlay
    array_delete(overlay_stack, _count - 1, 1);

    return _closed_overlay;
};


}
