/// @description Campaign phase and outcome definitions

// What the player is currently doing
enum CampaignPhase
{
    CHOOSING,
    REVIEWING,
    FINISHED
}

// How the campaign ended
enum CampaignOutcome
{
    NONE,
    VICTORY,
    HALF_VICTORY,
    FAILURE
}
