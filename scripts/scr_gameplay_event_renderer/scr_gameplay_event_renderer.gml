/// @description Draw event scene art placeholder and event narrative

function draw_gameplay_event_header(_event)
{
    if (!is_struct(_event))
    {
        return;
    }

    var _region = get_ui_regions(_event).scene_content;
    var _text_width = _region.width;

    // Preserve room for the entire event description on common
    // events. Longer descriptions shorten the art placeholder.
    var _description_height = string_height_ext(
        _event.description,
        -1,
        _text_width
    );

    var _art_height = clamp(
        _region.height - _description_height - 54,
        90,
        250
    );

    // --------------------------------------------------
    // PLACEHOLDER IMAGE AREA
    // --------------------------------------------------
    // This area will eventually show the event artwork using
    // the encounter's artwork_key, which already exists in
    // our event schema. No sprites are required for this step.

    draw_set_color(make_color_rgb(160, 166, 160));
    draw_rectangle(
        _region.x,
        _region.y,
        _region.x + _region.width,
        _region.y + _art_height,
        false
    );

    draw_set_color(make_color_rgb(74, 76, 74));
    draw_rectangle(
        _region.x,
        _region.y,
        _region.x + _region.width,
        _region.y + _art_height,
        true
    );

    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(
        _region.x + _region.width / 2,
        _region.y + _art_height / 2,
        "EVENT ARTWORK PLACEHOLDER"
    );
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // --------------------------------------------------
    // EVENT TITLE AND DESCRIPTION
    // --------------------------------------------------

    var _title_y = _region.y + _art_height + 11;
    var _description_y = _title_y + 25;

    draw_set_color(c_black);
    draw_text(_region.x, _title_y, _event.title);

    draw_text_ext(
        _region.x,
        _description_y,
        _event.description,
        -1,
        _text_width
    );
}
