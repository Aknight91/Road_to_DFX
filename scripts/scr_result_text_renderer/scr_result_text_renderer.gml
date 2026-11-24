/// @description Draw clipped, scrollable text inside a shared UI region
/// Used by both decision review and final campaign outcomes.

function draw_clipped_result_text(
    _result_text,
    _region,
    _result_y,
    _scroll_offset
)
{
    if (_result_text == "")
    {
        return;
    }

    var _visible_height = max(
        0,
        _region.y + _region.height - _result_y
    );

    if (_visible_height <= 0)
    {
        return;
    }

    var _viewport = {
        x: _region.x,
        y: _result_y,
        width: _region.width,
        height: _visible_height
    };

    var _previous = ui_clip_begin(_viewport);

    draw_set_color(c_black);
    draw_text_ext(
        _region.x,
        _result_y - _scroll_offset,
        _result_text,
        -1,
        _region.width
    );

    ui_clip_end(_previous);
}
