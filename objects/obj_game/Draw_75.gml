/// @description Render modal overlays above gameplay UI

// --------------------------------------------------
// DRAW ACTIVE OVERLAYS
// --------------------------------------------------

var _top_overlay = screen_manager.get_top_overlay();

// Draw pause beneath its confirmation dialog
if (_top_overlay == OverlayId.PAUSE_MENU
|| _top_overlay == OverlayId.CONFIRMATION)
{
    draw_pause_menu_overlay();
}

// Draw confirmation above the pause menu
if (_top_overlay == OverlayId.CONFIRMATION)
{
    draw_pause_confirmation_overlay();
}
