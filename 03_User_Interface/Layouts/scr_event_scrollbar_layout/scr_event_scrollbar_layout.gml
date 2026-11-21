/// @description Calculate shared result scrollbar geometry

function calculate_result_scrollbar_layout(
    _result_layout,
    _bar_region,
    _scroll_offset
)
{
    // Scrollbar track dimensions
    var _track = {
        x: _bar_region.x,
        y: _result_layout.result_y,
        width: _bar_region.width,
        height: max(0, _result_layout.available_result_height)
    };

    // Maximum permitted text scrolling distance
    var _max_scroll = max(
        0,
        _result_layout.result_height - _track.height
    );

    // Determine whether a scrollbar is necessary
    var _visible = (
        _result_layout.overflow
        && _track.height > 0
        && _max_scroll > 0
    );

    // Default thumb geometry
    var _thumb_height = 0;
    var _thumb_y = _track.y;
    var _thumb_travel = 0;

    if (_visible)
    {
        // Calculate proportional thumb height
        _thumb_height = min(
            _track.height,
            max(
                18,
                (_track.height * _track.height)
                / _result_layout.result_height
            )
        );

        // Available movement within the track
        _thumb_travel = _track.height - _thumb_height;

        // Normalize the current scroll position
        var _scroll_ratio = clamp(
            _scroll_offset / _max_scroll,
            0,
            1
        );

        // Calculate thumb position
        _thumb_y = _track.y
            + _scroll_ratio * _thumb_travel;
    }

    // Return all shared scrollbar measurements
    return {
        visible: _visible,
        max_scroll: _max_scroll,
        thumb_travel: _thumb_travel,

        track: _track,

        thumb: {
            x: _track.x,
            y: _thumb_y,
            width: _track.width,
            height: _thumb_height
        }
    };
}
