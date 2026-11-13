
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
// START INSTRUCTIONS
// --------------------------------------------------

draw_text(
    370,
    350,
    "PRESS ENTER TO BEGIN"
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
