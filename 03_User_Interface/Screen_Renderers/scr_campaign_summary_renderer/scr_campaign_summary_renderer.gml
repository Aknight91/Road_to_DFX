// Script assets have changed for v2.3.0 see
/// @description Render final campaign results

function draw_campaign_summary(
    _outcome,
    _game_message,
    _result_message,
    _stats
)
{
    // Do not render when there is no campaign outcome
    if (_outcome == CampaignOutcome.NONE)
    {
        return;
    }

    // --------------------------------------------------
    // CAMPAIGN HEADING
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(370, 160, "ROAD TO DFX");

    // Preserve the existing failure heading behavior
    var _heading = _game_message;

    if (_outcome == CampaignOutcome.FAILURE)
    {
        _heading = "PROJECT FAILURE!";
    }

    draw_text(370, 210, _heading);

    // --------------------------------------------------
    // CAMPAIGN RESULT MESSAGE
    // --------------------------------------------------

    draw_text_ext(
        370,
        260,
        _result_message,
        -1,
        520
    );

    // --------------------------------------------------
    // FINAL PROJECT STATISTICS
    // --------------------------------------------------

    draw_text(370, 350, "FINAL PROJECT STATUS:");

    draw_text(370, 390, "DFA: " + string(_stats.dfa) + "%");
    draw_text(370, 420, "DFM: " + string(_stats.dfm) + "%");
    draw_text(370, 450, "DFT: " + string(_stats.dft) + "%");
    draw_text(370, 480, "Sanity: " + string(_stats.sanity) + "%");
}
