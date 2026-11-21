/// @description Coordinate rendering of the gameplay screen

function draw_gameplay_screen(_game)
{
    // Execute in the controller's instance context.
    // This preserves access to its campaign functions,
    // resources, and state variables.

    with (_game)
    {
        // --------------------------------------------------
        // BACKGROUND
        // --------------------------------------------------

        draw_set_color(make_color_rgb(192, 192, 192));
        draw_rectangle(0, 0, 960, 540, false);


        // --------------------------------------------------
        // TITLE BAR
        // --------------------------------------------------

        draw_set_color(make_color_rgb(0, 0, 128));
        draw_rectangle(20, 20, 940, 75, false);

        draw_set_color(c_white);
        draw_text(35, 35, "ROAD TO DFX");


        // --------------------------------------------------
        // PROJECT STATUS HUD
        // --------------------------------------------------

        draw_gameplay_hud(id);


        // --------------------------------------------------
        // CAMPAIGN PHASE
        // --------------------------------------------------

        var _phase = get_campaign_phase();

        if (_phase != CampaignPhase.FINISHED)
        {
            // Read the event through the verified event bridge.
            // Dynamic encounters are preferred when active;
            // otherwise the four-event prototype is used.
            var _event = get_current_campaign_event();

            // Draw scenario information
            draw_gameplay_event_header(_event);


            // --------------------------------------------------
            // CHOOSING PHASE
            // --------------------------------------------------

            if (_phase == CampaignPhase.CHOOSING)
            {
                draw_gameplay_choice_panel(
                    _event,
                    game_message
                );
            }


            // --------------------------------------------------
            // REVIEWING PHASE
            // --------------------------------------------------

            else if (_phase == CampaignPhase.REVIEWING)
            {
                draw_gameplay_review_panel(
                    game_message,
                    result_message,
                    result_scroll_offset
                );
            }
        }


        // --------------------------------------------------
        // FINISHED CAMPAIGN
        // --------------------------------------------------

        else if (get_campaign_outcome() != CampaignOutcome.NONE)
        {
            var _final_stats = {
                dfa: dfa,
                dfm: dfm,
                dft: dft,
                sanity: sanity
            };

            draw_campaign_summary(
                get_campaign_outcome(),
                game_message,
                result_message,
                _final_stats
            );
        }


// --------------------------------------------------
// DEVELOPMENT BUILD: INCOMPLETE EVENT LIBRARY
// --------------------------------------------------

// Gameplay stopped without a release outcome.
// Display a neutral stopping point, not a victory
// or failure screen.

else
{
    draw_set_color(c_black);

    draw_text(370, 160, "ROAD TO DFX");

    draw_text(370, 210, game_message);

    draw_text_ext(
        370,
        260,
        result_message,
        -1,
        520
    );

    draw_text(
        370,
        455,
        "Press ESC for the Pause menu."
    );
}

       
        // --------------------------------------------------
        // PROTOTYPE LABEL
        // --------------------------------------------------

        // Relocate the label into the title bar.
        draw_set_color(c_white);

        draw_text(
            35,
            55,
            "ROAD TO DFX - PROTOTYPE"
        );

        
// --------------------------------------------------
// DRC HUNT ENTRY BUTTON
// --------------------------------------------------

if (_phase == CampaignPhase.CHOOSING)
{
    var _hunt_used = false;

    if (is_struct(active_encounter))
    {
        _hunt_used =
            drc_hunt_last_event_id == active_encounter.id;
    }

    var _hunt_available =
        is_struct(active_encounter)
        && !_hunt_used
        && drc_violations > 0
        && engineering_hours > drc_hunt_cost_hours;

    // Available and unavailable button colors.
    if (_hunt_available)
    {
        draw_set_color(make_color_rgb(225, 225, 225));
    }
    else
    {
        draw_set_color(make_color_rgb(155, 155, 155));
    }

    draw_rectangle(35, 480, 305, 520, false);

    draw_set_color(c_black);
    draw_rectangle(35, 480, 305, 520, true);

    if (_hunt_used)
    {
        draw_text(55, 490, "HUNT ALREADY USED");
    }
    else if (_hunt_available)
    {
        draw_text(
            55,
            490,
            "HUNT DRCs - " + string(drc_hunt_cost_hours) + " HOURS"
        );
    }
    else
    {
        draw_text(55, 490, "HUNT UNAVAILABLE");
    }
}




    }
}

// --------------------------------------------------
// DRAW DRC HUNT SCREEN
// --------------------------------------------------

function draw_drc_hunt_screen(_game)
{
    // Background
    draw_set_color(make_color_rgb(192, 192, 192));
    draw_rectangle(0, 0, 960, 540, false);

    // Title bar
    draw_set_color(make_color_rgb(0, 0, 128));
    draw_rectangle(20, 20, 940, 75, false);

    draw_set_color(c_white);
    draw_text(35, 35, "ROAD TO DFX - DRC HUNT");

    // Temporary PCB playfield
    draw_set_color(make_color_rgb(20, 75, 45));
    draw_rectangle(60, 115, 900, 425, false);

    // Copper traces
    draw_set_color(make_color_rgb(190, 155, 75));

    draw_line(100, 180, 350, 180);
    draw_line(350, 180, 350, 300);
    draw_line(350, 300, 700, 300);

    draw_line(150, 365, 500, 365);
    draw_line(500, 365, 500, 220);
    draw_line(500, 220, 820, 220);
	
// --------------------------------------------------
// DRAW ANIMATED DRC BOWTIE
// --------------------------------------------------


if (_game.drc_hunt_hits < _game.drc_hunt_max_hits
&& _game.drc_violations > 0
&& _game.drc_hunt_frames_remaining > 0)
{

var _bx = _game.drc_hunt_x;
var _by = _game.drc_hunt_y;

// Left and right bowtie wings
draw_set_color(make_color_rgb(225, 55, 55));

draw_triangle(
    _bx - 20, _by - 13,
    _bx,      _by,
    _bx - 20, _by + 13,
    false
);

draw_triangle(
    _bx + 20, _by - 13,
    _bx,      _by,
    _bx + 20, _by + 13,
    false
);

// Dark wing outlines
draw_set_color(c_black);

draw_triangle(
    _bx - 20, _by - 13,
    _bx,      _by,
    _bx - 20, _by + 13,
    true
);

draw_triangle(
    _bx + 20, _by - 13,
    _bx,      _by,
    _bx + 20, _by + 13,
    true
);

// Center of the bowtie
draw_set_color(c_yellow);
draw_circle(_bx, _by, 5, false);
}

// --------------------------------------------------
// DRAW MOUSE CROSSHAIR
// --------------------------------------------------

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Only show the crosshair inside the PCB
if (point_in_rectangle(
    _mx, _my,
    60, 115, 900, 425
))
{
    draw_set_color(c_yellow);

    // Outer aiming ring
    draw_circle(_mx, _my, 13, true);

    // Horizontal crosshair
    draw_line(_mx - 20, _my, _mx - 7, _my);
    draw_line(_mx + 7, _my, _mx + 20, _my);

    // Vertical crosshair
    draw_line(_mx, _my - 20, _mx, _my - 7);
    draw_line(_mx, _my + 7, _mx, _my + 20);
}

    // Placeholder information
    draw_set_color(c_white);

    draw_text(
        90,
        135,
        "DRC VIOLATIONS: "
        + string(_game.drc_violations)
    );
	
	// --------------------------------------------------
	// DRC HUNT - SHOOTING STATISTICS
	// --------------------------------------------------

	draw_set_color(c_white);

	draw_text(
	    560,
	    135,
	    "HITS: " + string(_game.drc_hunt_hits)
	);

	draw_text(
	    710,
	    135,
	    "SHOTS: " + string(_game.drc_hunt_shots)
	);

	
// --------------------------------------------------
// DRC HUNT - TIMER DISPLAY
// --------------------------------------------------

draw_set_color(c_yellow);

if (_game.drc_hunt_hits >= _game.drc_hunt_max_hits
|| _game.drc_violations <= 0)
{
    draw_text(345, 135, "HUNT COMPLETE!");
}
else if (_game.drc_hunt_frames_remaining <= 0)
{
    draw_text(345, 135, "TIME UP!");
}
else
{
    var _seconds_left = ceil(
        _game.drc_hunt_frames_remaining
        / game_get_speed(gamespeed_fps)
    );

    draw_text(
        345,
        135,
        "TIME: " + string(_seconds_left)
    );
}

    draw_text(
        90,
        395,
        "The DRC bowties haven't escaped yet."
    );

    // Return button
    draw_set_color(make_color_rgb(225, 225, 225));
    draw_rectangle(35, 475, 235, 520, false);

    draw_set_color(c_black);
    draw_rectangle(35, 475, 235, 520, true);

    draw_text(53, 488, "RETURN TO DESIGN");
}
