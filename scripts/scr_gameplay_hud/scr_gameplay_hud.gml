
// @description Render the gameplay project status HUD


 // --------------------------------------------------
 // DRAW REUSABLE STATUS BAR
 // --------------------------------------------------

 function draw_hud_status_bar(_x, _y, _label, _value)
 {
     // Status label and percentage
     draw_set_color(c_black);

     draw_text(
         _x,
         _y,
         _label + ": " + string(_value) + "%"
     );

     // Background bar
     draw_set_color(make_color_rgb(80, 80, 80));

     draw_rectangle(
         _x,
         _y + 25,
         _x + 250,
         _y + 41,
         false
     );

     // Filled percentage bar
     draw_set_color(make_color_rgb(0, 128, 0));

     draw_rectangle(
         _x,
         _y + 25,
         _x + (250 * _value / 100),
         _y + 41,
         false
     );
 }


 // --------------------------------------------------
 // DRAW PROJECT STATUS AND CALENDAR
 // --------------------------------------------------

 function draw_gameplay_hud(_game)
 {
     // Project status heading
     draw_set_color(c_black);
     draw_text(35, 100, "PROJECT STATUS");

     // Remaining or overdue workdays
     var _overdue = _game.get_overdue_workdays();

     if (_overdue > 0)
     {
         draw_text(
             35,
             125,
             "Workdays overdue: " + string(_overdue)
         );
     }
     else
     {
         draw_text(
             35,
             125,
             "Workdays remaining: " + string(_game.days_remaining)
         );
     }

     // DFX and Sanity bars
     draw_hud_status_bar(
         35, 160, "DFA - Design for Assembly", _game.dfa
     );

     draw_hud_status_bar(
         35, 220, "DFM - Design for Manufacturing", _game.dfm
     );

     draw_hud_status_bar(
         35, 280, "DFT - Design for Test", _game.dft
     );

     draw_hud_status_bar(
         35, 340, "TEAM SANITY", _game.sanity
     );

     // Project calendar
     draw_set_color(c_black);

     draw_text(
         35,
         405,
         "Current date: "
         + _game.format_project_date(_game.project_current_date)
     );

     draw_text(
         35,
         425,
         "Deadline: "
         + _game.format_project_date(_game.project_deadline_date)
     );
 }
