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

// Stores every available event, grouped by PCB design phase.
//
// This is NOT the active campaign event sequence.
// Events will be selected from these pools as the
// player progresses through a campaign.

function create_event_library()
{
    return {
        design_setup: [],
        placement: [],
        routing: create_pcb_design_event_pool(),
        manufacturer_review: [],
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
