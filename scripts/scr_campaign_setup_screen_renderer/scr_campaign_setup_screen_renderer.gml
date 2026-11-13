/// @description Render the campaign setup screen

function draw_campaign_setup_screen(_selected_difficulty)

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
// CENTERED CAMPAIGN SETUP HEADINGS
// --------------------------------------------------

	draw_set_color(c_black);

	var _heading = "NEW CAMPAIGN";

	draw_text(
	    480 - string_width(_heading) / 2,
	    120,
	    _heading
	);

	var _description = "Prepare for your engineering journey.";

	draw_text(
	    480 - string_width(_description) / 2,
	    165,
	    _description
	);

	var _difficulty_heading = "CAMPAIGN DIFFICULTY";

	draw_text(
	    480 - string_width(_difficulty_heading) / 2,
	    210,
	    _difficulty_heading
	);


    
// --------------------------------------------------
// DIFFICULTY OPTIONS
// --------------------------------------------------

// Get shared difficulty option geometry
var _options = get_campaign_setup_difficulty_options();

for (var _i = 0; _i < array_length(_options); _i++)
{
    var _option = _options[_i];

    // Determine whether this difficulty is selected
    var _selected =
        _option.difficulty == _selected_difficulty;

    // Selected option uses a dark blue background
    if (_selected)
    {
        draw_set_color(make_color_rgb(0, 0, 128));
    }
    else
    {
        draw_set_color(make_color_rgb(220, 220, 220));
    }

    // Draw option background
    draw_rectangle(
        _option.x,
        _option.y,
        _option.x + _option.width,
        _option.y + _option.height,
        false
    );

    // Draw option border
    draw_set_color(c_black);

    draw_rectangle(
        _option.x,
        _option.y,
        _option.x + _option.width,
        _option.y + _option.height,
        true
    );

    // Selected option uses white text
    if (_selected)
    {
        draw_set_color(c_white);
    }
    else
    {
        draw_set_color(c_black);
    }

    
	// Center difficulty name inside its button
	var _name = get_campaign_difficulty_name(
	    _option.difficulty
	);

	draw_text(
	    _option.x + (_option.width - string_width(_name)) / 2,
	    _option.y + (_option.height - string_height(_name)) / 2,
	    _name
	);

}

   
// --------------------------------------------------
// BACK TO TITLE BUTTON
// --------------------------------------------------

	// Get shared Back button geometry
	var _back_button = get_campaign_setup_back_button_bounds();

	// Get mouse position in GUI coordinates
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);

	// Check whether the mouse is over the button
	var _hovered = point_in_rectangle(
	    _mouse_x,
	    _mouse_y,
	    _back_button.x,
	    _back_button.y,
	    _back_button.x + _back_button.width,
	    _back_button.y + _back_button.height
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
	    _back_button.x,
	    _back_button.y,
	    _back_button.x + _back_button.width,
	    _back_button.y + _back_button.height,
	    false
	);

	// Draw button border
	draw_set_color(c_black);

	draw_rectangle(
	    _back_button.x,
	    _back_button.y,
	    _back_button.x + _back_button.width,
	    _back_button.y + _back_button.height,
	    true
	);

	
	// Center Back button label
	var _back_label = "BACK TO TITLE";

	draw_text(
	    _back_button.x
	        + (_back_button.width - string_width(_back_label)) / 2,
	    _back_button.y
	        + (_back_button.height - string_height(_back_label)) / 2,
	    _back_label
	);


	
	// Center the keyboard shortcut below the Back button
	var _escape_hint = "Or press ESC";

	draw_text(
	    480 - string_width(_escape_hint) / 2,
	    _back_button.y + _back_button.height + 10,
	    _escape_hint
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
