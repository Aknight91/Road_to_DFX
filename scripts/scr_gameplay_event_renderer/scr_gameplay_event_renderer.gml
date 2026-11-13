// @description Render gameplay event information


 // --------------------------------------------------
 // DRAW EVENT HEADER
 // --------------------------------------------------

 function draw_gameplay_event_header(_event)
 {
     // Event title
     draw_set_color(c_black);

     draw_text(
         370,
         120,
         _event.title
     );

     // Event description with text wrapping
     draw_text_ext(
         370,
         155,
         _event.description,
         -1,
         520
     );
 }
