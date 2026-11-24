/// @description Stage-based event registration for Road to DFX
// Content ownership is stage-specific. This library owns registration,
// not event choice definitions, scheduling, or controller state.
// Keep public EventStage values and library keys stable.

enum EventStage
{
    DESIGN_SETUP = 0,
    PLACEMENT,
    ROUTING,
    MANUFACTURER_REVIEW,
    RELEASE
}

function create_event_library()
{
    var _library = {
        design_setup: [],
        placement: [],
        routing: [],
        manufacturer_review: [],
        release: []
    };

    // One owner per project phase, each producing standard event structs.
    var _sources = [
        create_pcb_design(),
        create_pcb_placement(),
        create_pcb_routing(),
        create_pcb_manufacturer_review(),
        create_pcb_release()
    ];

    for (var _s = 0; _s < array_length(_sources); _s++)
    {
        var _events = _sources[_s];

        if (!is_array(_events))
        {
            show_debug_message("EVENT LIBRARY ERROR: Invalid source " + string(_s));
            continue;
        }

        for (var _e = 0; _e < array_length(_events); _e++)
        {
            var _event = _events[_e];

            if (!is_struct(_event))
            {
                show_debug_message("EVENT LIBRARY ERROR: Invalid event from source " + string(_s));
                continue;
            }

            switch (_event.stage)
            {
                case EventStage.DESIGN_SETUP:
                    array_push(_library.design_setup, _event);
                    break;

                case EventStage.PLACEMENT:
                    array_push(_library.placement, _event);
                    break;

                case EventStage.ROUTING:
                    array_push(_library.routing, _event);
                    break;

                case EventStage.MANUFACTURER_REVIEW:
                    array_push(_library.manufacturer_review, _event);
                    break;

                case EventStage.RELEASE:
                    array_push(_library.release, _event);
                    break;

                default:
                    show_debug_message(
                        "EVENT LIBRARY ERROR: Unknown stage for " + _event.id
                    );
                    break;
            }
        }
    }

    static _qa_reported = false;

    if (!_qa_reported)
    {
        _qa_reported = true;
        validate_event_library(_library);
    }

    return _library;
}

// Existing public selector API. Do not change keys or enum indices.
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
