/// @description Render the campaign setup screen

function draw_campaign_setup_screen()
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
    // CAMPAIGN SETUP
    // --------------------------------------------------

    draw_set_color(c_black);

    draw_text(
        370,
        150,
        "NEW CAMPAIGN"
    );

    draw_text(
        370,
        200,
        "Prepare for your engineering journey."
    );


    // --------------------------------------------------
    // FUTURE DIFFICULTY SELECTION
    // --------------------------------------------------

    draw_text(
        370,
        270,
        "CAMPAIGN DIFFICULTY"
    );

    draw_text(
        370,
        310,
        "Difficulty selection coming soon."
    );


    // --------------------------------------------------
    // DEVELOPMENT PLACEHOLDER
    // --------------------------------------------------

    draw_text(
        370,
        400,
        "CAMPAIGN SETUP - LAYOUT PREVIEW"
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
