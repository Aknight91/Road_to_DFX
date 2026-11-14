
/// @description Shared campaign setup menu geometry


// --------------------------------------------------
// DIFFICULTY BUTTON GEOMETRY
// --------------------------------------------------

function get_campaign_setup_difficulty_options()
{
    var _difficulties = [
        CampaignDifficulty.EASY,
        CampaignDifficulty.MEDIUM,
        CampaignDifficulty.HARD,
        CampaignDifficulty.COW_MODE
    ];

    var _options = [];

    // Shared button dimensions
    var _button_width = 240;
    var _button_height = 28;
    var _button_gap = 8;

    // Center horizontally in the 960px GUI
    var _start_x = (960 - _button_width) / 2;
    var _start_y = 242;

    // Create one vertical column
    for (var _i = 0; _i < array_length(_difficulties); _i++)
    {
        var _button_y = _start_y
            + (_i * (_button_height + _button_gap));

        array_push(_options, {
            difficulty: _difficulties[_i],
            x: _start_x,
            y: _button_y,
            width: _button_width,
            height: _button_height
        });
    }

    return _options;
}


// --------------------------------------------------
// BACK BUTTON GEOMETRY
// --------------------------------------------------

function get_campaign_setup_back_button_bounds()
{
    return {
        x: 490,
        y: 390,
        width: 220,
        height: 44
    };
}

 // --------------------------------------------------
 // BEGIN CAMPAIGN BUTTON GEOMETRY
 // --------------------------------------------------

function get_campaign_setup_begin_button_bounds()
{
    return {
        x: 250,
        y: 390,
        width: 220,
        height: 44
    };
}
