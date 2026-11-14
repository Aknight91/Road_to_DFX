
/// @description Stage-based event library for Road to DFX

// --------------------------------------------------
// ENGINEERING PROJECT STAGES
// --------------------------------------------------

enum EventStage
{
    PLANNING = 0,
    PCB_DESIGN,
    FABRICATION,
    ASSEMBLY_TEST,
    RELEASE
}


// --------------------------------------------------
// CREATE EVENT LIBRARY
// --------------------------------------------------

// Stores every available event, grouped by project stage.
//
// This is NOT the active campaign event sequence.
// Events will be selected from these pools as the
// player progresses through a campaign.

function create_event_library()
{
    return {
        planning: [],
		pcb_design: create_pcb_design_event_pool(),
        fabrication: [],
        assembly_test: [],
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
        case EventStage.PLANNING:
            return _library.planning;

        case EventStage.PCB_DESIGN:
            return _library.pcb_design;

        case EventStage.FABRICATION:
            return _library.fabrication;

        case EventStage.ASSEMBLY_TEST:
            return _library.assembly_test;

        case EventStage.RELEASE:
            return _library.release;
    }

    // Invalid stages return an empty array.
    return [];
}
