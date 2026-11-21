
/// @description Render the Road to DFX title screen

function draw_title_screen()
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
    // GAME TITLE
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(
        370,
        165,
        "ROAD TO DFX"
    );

    draw_text(
        370,
        210,
        "A PCB DESIGN ADVENTURE"
    );


    // --------------------------------------------------
    // GAME DESCRIPTION
    // --------------------------------------------------

    draw_text(
        300,
        275,
        "Design. Review. Survive the schedule."
    );


    // --------------------------------------------------
    // DEVELOPMENT PLACEHOLDER
    // --------------------------------------------------

    // This will become the interactive title menu
    // once screen navigation is connected.

   

// --------------------------------------------------
// START NEW CAMPAIGN BUTTON
// --------------------------------------------------

	// Get shared button geometry
	var _button = get_title_start_button_bounds();

	// Get mouse position in GUI coordinates
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);

	// Determine whether the button is hovered
	var _hovered = point_in_rectangle(
	    _mouse_x,
	    _mouse_y,
	    _button.x,
	    _button.y,
	    _button.x + _button.width,
	    _button.y + _button.height
	);

	// Draw button background
	if (_hovered)
	{
	    draw_set_color(make_color_rgb(180, 205, 245));
	}
	else
	{
	    draw_set_color(make_color_rgb(220, 220, 220));
	}

	draw_rectangle(
	    _button.x,
	    _button.y,
	    _button.x + _button.width,
	    _button.y + _button.height,
	    false
	);

	// Draw button border
	draw_set_color(c_black);

	draw_rectangle(
	    _button.x,
	    _button.y,
	    _button.x + _button.width,
	    _button.y + _button.height,
	    true
	);

	// Draw button label
	draw_text(
	    _button.x + 20,
	    _button.y + 14,
	    "START NEW CAMPAIGN"
	);

	// Preserve keyboard navigation
	draw_text(
	    370,
	    405,
	    "Or press ENTER"
	);




    // --------------------------------------------------
    // PROTOTYPE LABEL
    // --------------------------------------------------

    draw_text(
        35,
        475,
        "ROAD TO DFX - PROTOTYPE"
    );
}
