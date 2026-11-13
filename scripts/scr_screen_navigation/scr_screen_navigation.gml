// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_screen_navigation(){

}
/// @description Screen and overlay identifiers for Road to DFX

// Primary screens - only one is active at a time
enum ScreenId
{
    TITLE,
    CAMPAIGN_SETUP,
    GAMEPLAY,
    CAMPAIGN_RESULTS
}

// Temporary interfaces displayed over an existing screen
enum OverlayId
{
    PAUSE_MENU,
    SAVE_LOAD,
    CONFIRMATION
}
