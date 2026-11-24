/// @description Shared Draw GUI clipping for all Road to DFX UI
/// Scissor coordinates use window pixels, while UI regions use GUI pixels.
/// Always pair ui_clip_begin() with ui_clip_end() in the same draw call.

function ui_clip_begin(_gui_region)
{
    var _previous = gpu_get_scissor();
    var _sx = window_get_width() / max(1, display_get_gui_width());
    var _sy = window_get_height() / max(1, display_get_gui_height());

    gpu_set_scissor(
        floor(_gui_region.x * _sx),
        floor(_gui_region.y * _sy),
        max(1, ceil(_gui_region.width * _sx)),
        max(1, ceil(_gui_region.height * _sy))
    );

    return _previous;
}

function ui_clip_end(_previous)
{
    gpu_set_scissor(_previous);
}
