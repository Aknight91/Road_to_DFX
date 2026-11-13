
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
