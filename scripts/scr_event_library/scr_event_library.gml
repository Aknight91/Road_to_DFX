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

// Organizes PCB events into their engineering stages.
// Consequence events remain in their appropriate
// stage pool but are not scheduled milestones.


function create_event_library()
{
    var _pcb_events = create_pcb_design_event_pool();

    var _design_setup_events = [];
	var _routing_events = [];
	var _manufacturer_events = [];

    // Organize each event by its engineering stage.
    for (
        var _i = 0;
        _i < array_length(_pcb_events);
        _i++
    )
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

    return {
        design_setup: _design_setup_events,
        placement: [],
        routing: _routing_events,
        manufacturer_review: _manufacturer_events,
        release: []
    };
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

    // Invalid stages return an empty array.
    return [];
}
