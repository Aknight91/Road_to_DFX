/// @description

// Background
draw_set_color(make_color_rgb(192, 192, 192));
draw_rectangle(0, 0, 960, 540, false);

// Title bar
draw_set_color(make_color_rgb(0, 0, 128));
draw_rectangle(20, 20, 940, 75, false);

draw_set_color(c_white);
draw_text(35, 35, "ROAD TO DFX");

// --------------------------------------------------
// PROJECT STATUS PANEL
// --------------------------------------------------

draw_set_color(c_black);
draw_text(35, 100, "PROJECT STATUS");

if (get_overdue_workdays() > 0)
{
    draw_text(
        35, 125,
        "Workdays overdue: " + string(get_overdue_workdays())
    );
}
else
{
    draw_text(
        35, 125,
        "Workdays remaining: " + string(days_remaining)
    );
}



// DFA BAR
draw_text(35, 160, "DFA - Design for Assembly: " + string(dfa) + "%");

draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(35, 185, 285, 201, false);

draw_set_color(make_color_rgb(0, 128, 0));
draw_rectangle(35, 185, 35 + (250 * dfa / 100), 201, false);


// DFM BAR
draw_set_color(c_black);
draw_text(35, 220, "DFM - Design for Manufacturing: " + string(dfm) + "%");

draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(35, 245, 285, 261, false);

draw_set_color(make_color_rgb(0, 128, 0));
draw_rectangle(35, 245, 35 + (250 * dfm / 100), 261, false);


// DFT BAR
draw_set_color(c_black);
draw_text(35, 280, "DFT - Design for Test: " + string(dft) + "%");

draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(35, 305, 285, 321, false);

draw_set_color(make_color_rgb(0, 128, 0));
draw_rectangle(35, 305, 35 + (250 * dft / 100), 321, false);


// SANITY BAR
draw_set_color(c_black);
draw_text(35, 340, "TEAM SANITY: " + string(sanity) + "%");

draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(35, 365, 285, 381, false);

draw_set_color(make_color_rgb(0, 128, 0));
draw_rectangle(35, 365, 35 + (250 * sanity / 100), 381, false);


// --------------------------------------------------
// PROJECT CALENDAR
// --------------------------------------------------

draw_set_color(c_black);
draw_text(
    35, 405,
    "Current date: " + format_project_date(project_current_date)
 );


draw_text(
    35, 425,
    "Deadline: " + format_project_date(project_deadline_date)
);


// --------------------------------------------------
// EVENT DISPLAY
// --------------------------------------------------

if (event_active)
{
    var _event = design_events[current_event_index];

    draw_set_color(c_black);

    draw_text(370, 120, _event.title);

    draw_text_ext(
        370, 155,
        _event.description,
        -1, 520
    );

    if (!event_resolved)
    {
        draw_text(370, 230, "SELECT YOUR RESPONSE:");

       
     // Legacy choice display
	// Used only until reusable buttons are active
        if (instance_number(obj_choice_button) == 0)
        {
            for (var i = 0; i < array_length(_event.choices); i++)
            {
                draw_text(
                    370,
                    265 + (i * 40),
                    string(i + 1) + ". " + _event.choices[i].text
                );
            }
        }

    }
    else
    {
        draw_text(370, 265, "EVENT RESOLVED");

        draw_text(370, 500, "Press ENTER to continue.");

    }

    draw_text(370, 385, game_message);

    
	if (result_message != "")
	{
	    draw_text_ext(
	        370, 405,
	        result_message,
	        -1, 520
	    );
	}

}

// --------------------------------------------------
// CAMPAIGN VICTORY
// --------------------------------------------------

else if (campaign_complete)
{
    draw_set_color(c_black);

    draw_text(370, 160, "ROAD TO DFX");

    draw_text(370, 210, game_message);

    draw_text_ext(
        370, 260,
        result_message,
        -1, 520
    );

    draw_text(370, 350, "FINAL PROJECT STATUS:");

    draw_text(370, 390, "DFA: " + string(dfa) + "%");
    draw_text(370, 420, "DFM: " + string(dfm) + "%");
    draw_text(370, 450, "DFT: " + string(dft) + "%");
    draw_text(370, 480, "Sanity: " + string(sanity) + "%");
}

// --------------------------------------------------
// CAMPAIGN FAILURE
// --------------------------------------------------

else if (campaign_failed)
{
    draw_set_color(c_black);

    draw_text(370, 160, "ROAD TO DFX");

    draw_text(370, 210, "PROJECT FAILURE!");

    draw_text_ext(
        370, 260,
        result_message,
        -1, 520
    );

    draw_text(370, 350, "FINAL PROJECT STATUS:");

    draw_text(370, 390, "DFA: " + string(dfa) + "%");
    draw_text(370, 420, "DFM: " + string(dfm) + "%");
    draw_text(370, 450, "DFT: " + string(dft) + "%");
    draw_text(370, 480, "Sanity: " + string(sanity) + "%");
}

// Prototype label
draw_set_color(c_black);
draw_text(35, 475, "ROAD TO DFX - PROTOTYPE");


// --------------------------------------------------
// DEBUG PANEL
// --------------------------------------------------

if (debug_panel_open)
{
    // Panel background
    draw_set_color(make_color_rgb(25, 25, 35));
    draw_rectangle(600, 85, 950, 525, false);

    // Panel header
    draw_set_color(make_color_rgb(0, 0, 128));
    draw_rectangle(600, 85, 950, 115, false);

    draw_set_color(c_white);
    draw_text(610, 93, "ROAD TO DFX - DEBUG");

    // PLAYER RESOURCES
    draw_set_color(c_yellow);
    draw_text(610, 125, "PLAYER RESOURCES");

    draw_set_color(c_white);
    draw_text(610, 145, "Days remaining: " + string(days_remaining));
    draw_text(610, 163, "Engineering hours: " + string(engineering_hours));
    draw_text(610, 181, "Budget: " + string(budget));
    draw_text(610, 199, "Morale: " + string(morale));

    // DFX STATUS
    draw_set_color(c_yellow);
    draw_text(610, 225, "DFX STATUS");

    draw_set_color(c_white);
    draw_text(610, 245, "DFA: " + string(dfa) + "%");
    draw_text(610, 263, "DFM: " + string(dfm) + "%");
    draw_text(610, 281, "DFT: " + string(dft) + "%");

   
    // ENGINEERING STATUS
    draw_set_color(c_yellow);
    draw_text(610, 327, "ENGINEERING STATUS");

    draw_set_color(c_white);
    draw_text(610, 347, "DRC violations: " + string(drc_violations));
    draw_text(610, 365, "Manufacturing risk: " + string(manufacturing_risk));
    draw_text(610, 383, "Software instability: " + string(software_instability));

    // EVENT AND SANITY CRISIS
    draw_set_color(c_yellow);
    draw_text(610, 409, "EVENT / SANITY CRISIS");

    draw_set_color(c_white);
    draw_text(610, 429, "Current event: " + string(current_event_index + 1));
    draw_text(610, 447, "Event active: " + string(event_active));
    draw_text(610, 465, "Event resolved: " + string(event_resolved));
    draw_text(610, 483, "Crisis active: " + string(sanity_zero_active));
    draw_text(610, 501, "Turns remaining: " + string(sanity_zero_turns_remaining));

}
