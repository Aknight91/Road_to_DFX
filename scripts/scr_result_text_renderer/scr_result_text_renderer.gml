/// @description Draw clipped decision-result text

function draw_clipped_result_text(
    _result_text,
    _region,
    _result_y,
    _scroll_offset
)
{
    // Nothing to draw when the message is empty
    if (_result_text == "")
    {
        return;
    }

    // Calculate the available visible height
    var _visible_height = max(
        0,
        _region.y + _region.height - _result_y
    );

    // Don't draw when no vertical space remains
    if (_visible_height <= 0)
    {
        return;
    }

    // Save the current clipping region
    var _previous_scissor = gpu_get_scissor();

    // Restrict drawing to the results viewport
    gpu_set_scissor(
        _region.x,
        _result_y,
        _region.width,
        _visible_height
    );

    // Draw the complete result text with scrolling
    draw_set_color(c_black);

    draw_text_ext(
        _region.x,
        _result_y - _scroll_offset,
        _result_text,
        -1,
        _region.width
    );

    // Restore the previous clipping region
    gpu_set_scissor(_previous_scissor);
}
