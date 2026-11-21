
/// @description Draw the decision-result scrollbar

function draw_result_scrollbar_ui(_scrollbar)
{
    // No scrollbar is needed when the text fits
    if (!_scrollbar.visible)
    {
        return;
    }

    // Use the shared geometry
    var _track = _scrollbar.track;
    var _thumb = _scrollbar.thumb;

    // Draw scrollbar track
    draw_set_color(make_color_rgb(100, 100, 100));

    draw_rectangle(
        _track.x,
        _track.y,
        _track.x + _track.width,
        _track.y + _track.height,
        false
    );

    // Draw scrollbar thumb
    draw_set_color(make_color_rgb(220, 220, 220));

    draw_rectangle(
        _thumb.x,
        _thumb.y,
        _thumb.x + _thumb.width,
        _thumb.y + _thumb.height,
        false
    );

    // Draw thumb border
    draw_set_color(c_black);

    draw_rectangle(
        _thumb.x,
        _thumb.y,
        _thumb.x + _thumb.width,
        _thumb.y + _thumb.height,
        true
    );
}
