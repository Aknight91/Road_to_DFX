/// @description

// Background
draw_set_color(make_color_rgb(192, 192, 192));
draw_rectangle(0, 0, 960, 540, false);

// Title bar
draw_set_color(make_color_rgb(0, 0, 128));
draw_rectangle(20, 20, 940, 75, false);

draw_set_color(c_white);
draw_text(35, 35, "ROAD TO DFX");

// Project status panel
draw_set_color(c_black);
draw_text(35, 100, "PROJECT STATUS");

draw_text(35, 135,
    "Days remaining: " + string(days_remaining));

draw_text(35, 165,
    "Engineering hours: " + string(engineering_hours));

draw_text(35, 195,
    "Budget: " + string(budget));

draw_text(35, 225,
    "Team morale: " + string(morale));

draw_text(35, 255,
    "DRC violations: " + string(drc_violations));

draw_text(35, 285,
    "Manufacturing readiness: "
    + string(manufacturing_readiness) + "%");

// Event panel
draw_set_color(c_white);
draw_rectangle(350, 105, 920, 420, false);

draw_set_color(c_black);

draw_text(370, 120, event_title);

draw_text_ext(
    370, 155,
    event_description,
    -1, 520);

draw_text(370, 230, "SELECT YOUR RESPONSE:");

draw_text(370, 265,
    "1. Rework placement and routing");

draw_text(370, 305,
    "2. Apply a quick patch");

draw_text(370, 345,
    "3. Request a design review");

draw_text(370, 385, game_message);

if (result_message != "")
{
    draw_text(370, 405, result_message);
}

// Instructions
draw_text(35, 475, "PROTOTYPE 0.1");
draw_text(35, 505, "Next: add your first design event.");
