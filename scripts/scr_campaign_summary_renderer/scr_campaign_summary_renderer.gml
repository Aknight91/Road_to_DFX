/// @description Draw final campaign outcomes within the shared four-panel UI
/// Project bars and dates remain in the permanent lower-left HUD.
/// Content geometry comes from scr_ui_regions; scrolling is UI-owned.

function draw_campaign_summary(
    _outcome,
    _game_message,
    _result_message,
    _stats
)
{
    if (_outcome == CampaignOutcome.NONE)
    {
        return;
    }

    // Keep the original function signature for existing callers.
    // The lower-left project-status HUD already renders _stats.
    var _summary = get_ui_regions().campaign_summary;
    var _heading = _game_message;

    if (_outcome == CampaignOutcome.FAILURE)
    {
        _heading = "PROJECT FAILURE!";
    }

    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_text(
        _summary.title.x,
        _summary.title.y,
        "ROAD TO DFX"
    );

    // Constrain unusually long outcome headings to their region.
    var _previous = ui_clip_begin(_summary.heading);

    draw_text_ext(
        _summary.heading.x,
        _summary.heading.y,
        _heading,
        -1,
        _summary.heading.width
    );

    ui_clip_end(_previous);

    // Display the full message via the existing clipped-result
    // renderer, with independent final-outcome scroll state.
    var _scroll = campaign_summary_scroll_state();
    var _metrics = campaign_summary_scroll_metrics(
        _result_message, _scroll.offset
    );

    draw_clipped_result_text(
        _result_message,
        _summary.message,
        _summary.message.y,
        _scroll.offset
    );

    draw_result_scrollbar_ui(_metrics.scrollbar);
    draw_set_color(c_white);
}
