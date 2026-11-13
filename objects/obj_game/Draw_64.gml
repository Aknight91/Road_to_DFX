
/// @description Controller UI - Screen Rendering Dispatcher

// --------------------------------------------------
// PRIMARY SCREEN RENDERING
// --------------------------------------------------

// ScreenManager owns the current screen.
// The dispatcher selects its renderer.

draw_primary_screen(
    screen_manager.get_current_screen(),
    id
);
