
/// @description Campaign difficulty definitions

// --------------------------------------------------
// CAMPAIGN DIFFICULTY
// --------------------------------------------------
/// @description Campaign difficulty definitions

enum CampaignDifficulty
{
    NONE = -1,
    EASY = 0,
    MEDIUM,
    HARD,
    COW_MODE
}

// --------------------------------------------------
// CAMPAIGN DIFFICULTY PROFILE
// --------------------------------------------------

// Defines the available starting ranges for a difficulty.
// Actual randomization and resource initialization
// will be connected in later steps.

function get_campaign_difficulty_profile(_difficulty)
{
    // Reject invalid or unselected difficulties
    if (_difficulty != CampaignDifficulty.EASY
    && _difficulty != CampaignDifficulty.MEDIUM
    && _difficulty != CampaignDifficulty.HARD
    && _difficulty != CampaignDifficulty.COW_MODE)
    {
        return undefined;
    }

    // Current verified prototype starting conditions.
    // Min and max are equal until difficulty balancing.
    var _profile = {
        engineering_hours_min: 100,
        engineering_hours_max: 100,

        budget_min: 100,
        budget_max: 100,

        morale_min: 80,
        morale_max: 80,

        drc_violations_min: 25,
        drc_violations_max: 25,

        manufacturing_risk_min: 10,
        manufacturing_risk_max: 10,

        dfa_min: 50,
        dfa_max: 50,

        dfm_min: 50,
        dfm_max: 50,

        dft_min: 50,
        dft_max: 50,

        sanity_start: 100,

        hide_project_details: false
    };

    // COW Mode will conceal selected project information.
    if (_difficulty == CampaignDifficulty.COW_MODE)
    {
        _profile.hide_project_details = true;
    }

    return _profile;
}


// --------------------------------------------------
// GET DIFFICULTY DISPLAY NAME
// --------------------------------------------------

function get_campaign_difficulty_name(_difficulty)
{
    switch (_difficulty)
    {
        case CampaignDifficulty.EASY:
            return "EASY";

        case CampaignDifficulty.MEDIUM:
            return "MEDIUM";

        case CampaignDifficulty.HARD:
            return "HARD";

        case CampaignDifficulty.COW_MODE:
            return "COW MODE";

        default:
            return "UNKNOWN DIFFICULTY";
    }
}
