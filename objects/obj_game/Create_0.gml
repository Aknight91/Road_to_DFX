/// @description Initial Game State

display_set_gui_size(960, 540);

// Set the game window to a landscape size
window_set_size(960, 540);

days_remaining = 30;
engineering_hours = 100;
budget = 100;
morale = 80;
drc_violations = 25;
manufacturing_readiness = 40;

// Current event
event_active = true;
event_resolved = false;

event_title = "INCOMING DESIGN CHANGE!";

event_description =
    "Engineering has received a late pin assignment change. "
    + "How will you respond?";

game_message = "Choose your response below.";
result_message = "";

// Choice consequences will be added next.
