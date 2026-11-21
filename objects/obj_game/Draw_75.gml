
/// @description Render debug panel and modal overlays

// --------------------------------------------------
// DEBUG PANEL
// --------------------------------------------------

// Draw above gameplay controls.
if (screen_manager.get_current_screen() == ScreenId.GAMEPLAY)
{
    draw_gameplay_debug_panel(id);
}

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
    draw_pause_confirmation_overlay(pause_confirmation_action);
}
