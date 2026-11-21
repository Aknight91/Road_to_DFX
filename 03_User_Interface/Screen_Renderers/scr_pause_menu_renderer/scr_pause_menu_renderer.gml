/// @description Render the Road to DFX pause menu

// --------------------------------------------------
// SHARED PAUSE MENU BUTTON GEOMETRY
// --------------------------------------------------

function get_pause_menu_button_bounds(_index)
{
    var _button_x = 330;
    var _button_y = 133;
    var _button_width = 300;
    var _button_height = 36;
    var _button_gap = 8;

    return {
        x: _button_x,
        y: _button_y
            + (_index * (_button_height + _button_gap)),
        width: _button_width,
        height: _button_height
    };
}

function draw_pause_menu_overlay()
{
    // --------------------------------------------------
    // DIM THE UNDERLYING GAMEPLAY SCREEN
    // --------------------------------------------------

    draw_set_color(c_black);
    draw_set_alpha(0.55);

    draw_rectangle(
        0, 0,
        960, 540,
        false
    );

    // Restore full opacity for the pause panel
    draw_set_alpha(1);


    // --------------------------------------------------
    // PAUSE PANEL
    // --------------------------------------------------

    var _panel_x = 290;
    var _panel_y = 65;
    var _panel_width = 380;
    var _panel_height = 405;

    draw_set_color(make_color_rgb(192, 192, 192));

    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        false
    );

    draw_set_color(c_black);

    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        true
    );


    // --------------------------------------------------
    // TITLE BAR
    // --------------------------------------------------

    draw_set_color(make_color_rgb(0, 0, 128));

    draw_rectangle(
        _panel_x + 10,
        _panel_y + 10,
        _panel_x + _panel_width - 10,
        _panel_y + 55,
        false
    );

    var _title = "ROAD TO DFX - PAUSED";

    draw_set_color(c_white);

    draw_text(
        480 - string_width(_title) / 2,
        _panel_y + 25,
        _title
    );


    // --------------------------------------------------
    // MENU OPTIONS
    // --------------------------------------------------

    var _labels = [
        "RESUME",
        "SAVE",
        "LOAD",
        "RESTART CAMPAIGN",
        "SETTINGS",
        "RETURN TO TITLE",
        "QUIT TO DESKTOP"
    ];

   
	for (var _i = 0; _i < array_length(_labels); _i++)
	{
	    // Get shared button geometry
	    var _button = get_pause_menu_button_bounds(_i);

	    var _button_x = _button.x;
	    var _y = _button.y;
	    var _button_width = _button.width;
	    var _button_height = _button.height;


        // Save, Load and Settings are placeholders
        var _disabled = (
            _i == 1
            || _i == 2
            || _i == 4
        );

        if (_disabled)
        {
            draw_set_color(make_color_rgb(165, 165, 165));
        }
        else
        {
            draw_set_color(make_color_rgb(220, 220, 220));
        }

        draw_rectangle(
            _button_x,
            _y,
            _button_x + _button_width,
            _y + _button_height,
            false
        );

        draw_set_color(c_black);

        draw_rectangle(
            _button_x,
            _y,
            _button_x + _button_width,
            _y + _button_height,
            true
        );

        if (_disabled)
        {
            draw_set_color(make_color_rgb(105, 105, 105));
        }
        else
        {
            draw_set_color(c_black);
        }

        var _label = _labels[_i];

        draw_text(
            _button_x
                + (_button_width - string_width(_label)) / 2,
            _y
                + (_button_height - string_height(_label)) / 2,
            _label
        );
    }


    // Restore default drawing color
    draw_set_color(c_white);
}

// --------------------------------------------------
// RESTART CAMPAIGN CONFIRMATION
// --------------------------------------------------

// --------------------------------------------------
// SHARED CONFIRMATION BUTTON GEOMETRY
// --------------------------------------------------

function get_pause_confirmation_button_bounds(_index)
{
    var _button_width = 150;
    var _button_height = 34;
    var _button_gap = 24;

    var _total_width =
        (2 * _button_width) + _button_gap;

    var _start_x = (960 - _total_width) / 2;

    return {
        x: _start_x
            + (_index * (_button_width + _button_gap)),
        y: 303,
        width: _button_width,
        height: _button_height
    };
}



function draw_pause_confirmation_overlay(_action)
{
    // Darken the pause menu behind the dialog
    draw_set_color(c_black);
    draw_set_alpha(0.35);

    draw_rectangle(0, 0, 960, 540, false);

    draw_set_alpha(1);


    // Confirmation panel
    var _panel_x = 280;
    var _panel_y = 185;
    var _panel_width = 400;
    var _panel_height = 170;

    draw_set_color(make_color_rgb(192, 192, 192));

    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        false
    );

    draw_set_color(c_black);

    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _panel_width,
        _panel_y + _panel_height,
        true
    );


    // Dialog title bar
    draw_set_color(make_color_rgb(0, 0, 128));

    draw_rectangle(
        290, 195,
        670, 233,
        false
    );

    	
	var _title = "RESTART CAMPAIGN?";

	if (_action == "title")
	{
	    _title = "RETURN TO TITLE?";
	}
	else if (_action == "quit")
	{
	    _title = "QUIT TO DESKTOP?";
	}



    draw_set_color(c_white);

    draw_text(
        480 - string_width(_title) / 2,
        207,
        _title
    );


    // Warning message
    var _warning = "All unsaved progress will be lost.";

    draw_set_color(c_black);

    draw_text(
        480 - string_width(_warning) / 2,
        256,
        _warning
    );


    
// --------------------------------------------------
// CONFIRMATION BUTTONS
// --------------------------------------------------

var _confirm_label = "RESTART";

if (_action == "title")
{
    _confirm_label = "RETURN";
}
else if (_action == "quit")
{
    _confirm_label = "QUIT";
}


var _labels = [
    _confirm_label,
    "CANCEL"
];


for (var _i = 0; _i < array_length(_labels); _i++)
{
    var _button =
        get_pause_confirmation_button_bounds(_i);

    // Button background
    draw_set_color(make_color_rgb(220, 220, 220));

    draw_rectangle(
        _button.x,
        _button.y,
        _button.x + _button.width,
        _button.y + _button.height,
        false
    );

    // Button border
    draw_set_color(c_black);

    draw_rectangle(
        _button.x,
        _button.y,
        _button.x + _button.width,
        _button.y + _button.height,
        true
    );

    // Centered label
    var _label = _labels[_i];

    draw_text(
        _button.x
            + (_button.width - string_width(_label)) / 2,
        _button.y
            + (_button.height - string_height(_label)) / 2,
        _label
    );
}

// Restore drawing color
draw_set_color(c_white);

}
