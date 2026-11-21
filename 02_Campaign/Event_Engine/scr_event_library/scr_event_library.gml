/// @description Stage-based event library for Road to DFX

// --------------------------------------------------
// PCB DESIGN PROJECT STAGES
// --------------------------------------------------

enum EventStage
{
    DESIGN_SETUP = 0,
    PLACEMENT,
    ROUTING,
    MANUFACTURER_REVIEW,
    RELEASE
}


// --------------------------------------------------
// CREATE EVENT LIBRARY
// --------------------------------------------------

function create_event_library()
{
    // Preserve the original verified event pools.
    var _pcb_events = create_pcb_design_event_pool();
    var _placement_events = create_pcb_placement_event_pool();

    var _design_setup_events = [];
    var _routing_events = [];
    var _manufacturer_events = [];

    for (var _i = 0; _i < array_length(_pcb_events); _i++)
    {
        var _event = _pcb_events[_i];

        switch (_event.stage)
        {
            case EventStage.DESIGN_SETUP:
                array_push(_design_setup_events, _event);
                break;

            case EventStage.ROUTING:
                array_push(_routing_events, _event);
                break;

            case EventStage.MANUFACTURER_REVIEW:
                array_push(_manufacturer_events, _event);
                break;
        }
    }

    // Load new Placement encounters from a separate data pack.
    // Future packs can be appended here without changing selection.
    var _placement_pack_01 = create_pcb_placement_pack_01();

    for (var _p = 0; _p < array_length(_placement_pack_01); _p++)
    {
        array_push(_placement_events, _placement_pack_01[_p]);
    }

    var _library = {
        design_setup: _design_setup_events,
        placement: _placement_events,
        routing: _routing_events,
        manufacturer_review: _manufacturer_events,
        release: []
    };

    // Run a complete library audit once at startup, not on every
    // temporary library built by the existing regression tests.
    static _qa_reported = false;

    if (!_qa_reported)
    {
        _qa_reported = true;
        if (array_length(_placement_pack_01) == 21)
        {
            show_debug_message("EVENT PACK QA: Placement pack 01 count = 21 (PASS)");
        }
        else
        {
            show_debug_message(
                "EVENT PACK QA: Expected 21, loaded "
                + string(array_length(_placement_pack_01)) + " (FAILED)"
            );
        }
        validate_event_library(_library);
    }

    return _library;
}


// --------------------------------------------------
// GET EVENT POOL FOR A PROJECT STAGE
// --------------------------------------------------

function get_event_pool(_library, _stage)
{
    switch (_stage)
    {
        case EventStage.DESIGN_SETUP:
            return _library.design_setup;

        case EventStage.PLACEMENT:
            return _library.placement;

        case EventStage.ROUTING:
            return _library.routing;

        case EventStage.MANUFACTURER_REVIEW:
            return _library.manufacturer_review;

        case EventStage.RELEASE:
            return _library.release;
    }

    return [];
}
