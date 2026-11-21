/// @description Render the complete decision-review panel

function draw_gameplay_review_panel(
    _game_message,
    _result_message,
    _scroll_offset
)
{
    // Get shared UI regions
    var _regions = get_ui_regions();

    // Calculate text layout once
    var _layout = calculate_result_layout(
        _game_message,
        _result_message,
        _regions.results
    );

    // --------------------------------------------------
    // REVIEW HEADINGS
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(370, 265, "EVENT RESOLVED");

    draw_text(370, 500, "Press ENTER to continue.");

    // --------------------------------------------------
    // DECISION MESSAGES
    // --------------------------------------------------

    draw_text(
        _regions.results.x,
        _layout.message_y,
        _game_message
    );

    // Draw result text within its clipping region
    draw_clipped_result_text(
        _result_message,
        _regions.results,
        _layout.result_y,
        _scroll_offset
    );

    // --------------------------------------------------
    // RESULT SCROLLBAR
    // --------------------------------------------------

    // Calculate scrollbar geometry
    var _scrollbar = calculate_result_scrollbar_layout(
        _layout,
        _regions.result_scrollbar,
        _scroll_offset
    );

    // Render scrollbar when necessary
    draw_result_scrollbar_ui(_scrollbar);
}
