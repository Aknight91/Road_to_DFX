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

// --------------------------------------------------
// EVENT DISPLAY
// --------------------------------------------------

if (event_active)
{
    var _event = design_events[current_event_index];

    draw_text(370, 120, _event.title);

    draw_text_ext(
        370, 155,
        _event.description,
        -1, 520
    );

    if (!event_resolved)
    {
        draw_text(370, 230, "SELECT YOUR RESPONSE:");

        for (var i = 0; i < array_length(_event.choices); i++)
        {
            draw_text(
                370,
                265 + (i * 40),
                string(i + 1) + ". " + _event.choices[i].text
            );
        }
    }
    else
    {
        draw_text(370, 265, "EVENT RESOLVED");

        draw_text(370, 450, "Press ENTER to continue.");
    }

    draw_text(370, 385, game_message);

    if (result_message != "")
    {
        draw_text(370, 405, result_message);
    }
}

// --------------------------------------------------
// CAMPAIGN COMPLETION
// --------------------------------------------------

else if (campaign_complete)
{
    draw_text(370, 160, "ROAD TO DFX");

    draw_text(370, 210, "CAMPAIGN COMPLETE!");

    draw_text_ext(
        370, 260,
        result_message,
        -1, 520
    );

    draw_text(370, 350, "Final project status:");

    draw_text(
        370, 390,
        "Days remaining: " + string(days_remaining)
    );

    draw_text(
        370, 420,
        "Engineering hours: " + string(engineering_hours)
    );

    draw_text(
        370, 450,
        "Manufacturing readiness: "
        + string(manufacturing_readiness) + "%"
    );
}

// Instructions
draw_text(35, 475, "PROTOTYPE 0.1");
draw_text(35, 505, "Next: add your first design event.");
