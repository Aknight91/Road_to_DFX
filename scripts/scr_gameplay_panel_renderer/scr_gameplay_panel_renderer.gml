/// @description Road to DFX - four-panel gameplay frame renderer

// Paints only the shared panel outlines. It does NOT draw
// backgrounds or move existing content yet. Later UI passes
// will place the HUD, event art, choices and activities here.
// All geometry comes from scr_ui_regions, not this script.

function draw_gameplay_panel_frames()
{
    var _panels = get_ui_regions().panels;

    // Temporary visual-identification colors based on the
    // approved layout sketch. They can be themed later.
    var _items = [
        { bounds: _panels.event_scene,    color: make_color_rgb(0, 140, 190) },
        { bounds: _panels.choices,        color: make_color_rgb(150, 90, 55) },
        { bounds: _panels.project_status, color: make_color_rgb(230, 176, 0) },
        { bounds: _panels.activities,     color: make_color_rgb(155, 65, 160) }
    ];

    for (var _i = 0; _i < array_length(_items); _i++)
    {
        var _part = _items[_i];
        var _r = _part.bounds;

        draw_set_color(_part.color);
        draw_rectangle(
            _r.x,
            _r.y,
            _r.x + _r.width,
            _r.y + _r.height,
            true
        );
    }

    draw_set_color(c_white);
}
