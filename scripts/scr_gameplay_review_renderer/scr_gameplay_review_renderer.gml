/// @description Render the complete decision-review panel

function draw_gameplay_review_panel(
    _game_message,
    _result_message,
    _scroll_offset
)
{
    var _regions = get_ui_regions();
    var _panel = _regions.panels.choices;
    var _layout = calculate_result_layout(
        _game_message,
        _result_message,
        _regions.results
    );

    draw_set_color(c_black);
    draw_text(_regions.results.x, _panel.y + 20, "EVENT RESOLVED");
    draw_text(_regions.results.x, _panel.y + 42, "ENTER or click CONTINUE");

    // Existing clipped result text and scrollbar logic.
    draw_text(
        _regions.results.x,
        _layout.message_y,
        _game_message
    );

    draw_clipped_result_text(
        _result_message,
        _regions.results,
        _layout.result_y,
        _scroll_offset
    );

    var _scrollbar = calculate_result_scrollbar_layout(
        _layout,
        _regions.result_scrollbar,
        _scroll_offset
    );

    draw_result_scrollbar_ui(_scrollbar);
}
