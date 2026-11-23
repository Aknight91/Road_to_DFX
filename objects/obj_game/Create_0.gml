// Initialize random behavior once at game startup
randomize();
// Set the game window to a landscape size
window_set_size(960, 540);

// Set the reference resolution for GUI elements
display_set_gui_size(960, 540);

// --------------------------------------------------
// SCREEN MANAGEMENT
// --------------------------------------------------

// Initialize screen navigation
// Start at the title screen before beginning a campaign
screen_manager = new ScreenManager(ScreenId.TITLE);	

// --------------------------------------------------
// CAMPAIGN SETUP SELECTION
// --------------------------------------------------


// No difficulty is selected automatically.
// The player must make an explicit choice.

selected_campaign_difficulty = CampaignDifficulty.NONE;

// --------------------------------------------------
// EVENT LIBRARY INITIALIZATION
// --------------------------------------------------

// Create the stage-based event library
event_library = create_event_library();

// --------------------------------------------------
// TEMPORARY DELAYED CONSEQUENCE SELECTOR TEST
// --------------------------------------------------

// Independent session. Does not modify real gameplay.

var _consequence_session = {
    event_library: event_library,
    current_event_stage: EventStage.ROUTING,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: []
};

// TEST 1: No consequence during Routing
var _routing_consequence =
    select_stage_consequence_event(_consequence_session);

var _routing_clear =
    !is_struct(_routing_consequence);

// TEST 2: Manufacturer Review without the flag
_consequence_session.current_event_stage =
    EventStage.MANUFACTURER_REVIEW;

var _without_flag =
    select_stage_consequence_event(_consequence_session);

var _no_flag_clear =
    !is_struct(_without_flag);

// TEST 3: Flag permits the delayed consequence
_consequence_session.project_flags = [
    "cad_changes_unverified"
];

var _with_flag =
    select_stage_consequence_event(_consequence_session);

var _flag_eligible = false;

if (is_struct(_with_flag))
{
    _flag_eligible =
        _with_flag.id == "PCB-0002";
}

// TEST 4: Already-played consequence cannot repeat
_consequence_session.played_event_ids = [
    "PCB-0002"
];

var _already_played =
    select_stage_consequence_event(_consequence_session);

var _repeat_rejected =
    !is_struct(_already_played);

// FINAL VALIDATION
if (_routing_clear
&& _no_flag_clear
&& _flag_eligible
&& _repeat_rejected)
{
    show_debug_message(
        "DELAYED CONSEQUENCE SELECTOR: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "DELAYED CONSEQUENCE SELECTOR: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY CONSEQUENCE INTERRUPTION TEST
// --------------------------------------------------

// Independent test session. Does not alter gameplay.
// Manufacturer Review currently has one consequence
// and no scheduled events in its pool.

var _interrupt_test = {
    event_library: event_library,
    current_event_stage: EventStage.MANUFACTURER_REVIEW,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: ["cad_changes_unverified"],
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0),
    campaign_events_completed: 0,
    active_encounter: undefined,
    event_resolved: false,
    completed_checkpoint_ids: []
};

// TEST 1: With zero chance, no interruption starts.
var _interrupt_zero_started =
    begin_scheduled_campaign_encounter(_interrupt_test, 0);

var _interrupt_zero_ok =
    !_interrupt_zero_started
    && !is_struct(_interrupt_test.active_encounter);

// TEST 2: Force the eligible interruption.
var _interrupt_started =
    begin_scheduled_campaign_encounter(_interrupt_test, 100);

var _interrupt_selected_ok = false;

if (_interrupt_started && is_struct(_interrupt_test.active_encounter))
{
    _interrupt_selected_ok =
        _interrupt_test.active_encounter.id == "PCB-0002"
        && _interrupt_test.active_encounter.is_consequence;
}

// TEST 3: A consequence does not consume a scheduled slot.
var _interrupt_count_ok = false;

if (_interrupt_selected_ok)
{
    _interrupt_test.event_resolved = true;

    var _interrupt_recorded =
        record_completed_dynamic_encounter(_interrupt_test);

    _interrupt_count_ok =
        _interrupt_recorded
        && _interrupt_test.campaign_events_completed == 0
        && _interrupt_test.campaign_stage_events_completed[
            EventStage.MANUFACTURER_REVIEW
        ] == 0;
}

// TEST 4: Previously played consequences cannot repeat.
_interrupt_test.active_encounter = undefined;
_interrupt_test.event_resolved = false;

var _interrupt_repeat_started =
    begin_scheduled_campaign_encounter(_interrupt_test, 100);

var _interrupt_repeat_ok =
    !_interrupt_repeat_started
    && !is_struct(_interrupt_test.active_encounter);

// TEST 5: The unresolved CAD flag is required.
_interrupt_test.played_event_ids = [];
_interrupt_test.project_flags = [];

var _interrupt_missing_flag_started =
    begin_scheduled_campaign_encounter(_interrupt_test, 100);

var _interrupt_missing_flag_ok =
    !_interrupt_missing_flag_started
    && !is_struct(_interrupt_test.active_encounter);

// FINAL VALIDATION
if (_interrupt_zero_ok
&& _interrupt_selected_ok
&& _interrupt_count_ok
&& _interrupt_repeat_ok
&& _interrupt_missing_flag_ok)
{
    show_debug_message(
        "CONSEQUENCE INTERRUPTION TEST: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CONSEQUENCE INTERRUPTION TEST: Tests FAILED"
    );

    show_debug_message("INTERRUPTION DEBUG: Zero chance = "
        + string(_interrupt_zero_ok));
    show_debug_message("INTERRUPTION DEBUG: Forced event = "
        + string(_interrupt_selected_ok));
    show_debug_message("INTERRUPTION DEBUG: Slot unchanged = "
        + string(_interrupt_count_ok));
    show_debug_message("INTERRUPTION DEBUG: No repeat = "
        + string(_interrupt_repeat_ok));
    show_debug_message("INTERRUPTION DEBUG: Flag required = "
        + string(_interrupt_missing_flag_ok));
}

// --------------------------------------------------
// TEMPORARY DELAYED CONSEQUENCE STAGE TEST
// --------------------------------------------------

// Verify the consequence is eligible during
// Manufacturer Review only when its flag exists.

var _review_without_flag = get_eligible_stage_events(
    event_library,
    EventStage.MANUFACTURER_REVIEW,
    CampaignDifficulty.MEDIUM,
    [],
    []
);

var _review_with_flag = get_eligible_stage_events(
    event_library,
    EventStage.MANUFACTURER_REVIEW,
    CampaignDifficulty.MEDIUM,
    [],
    ["cad_changes_unverified"]
);

// Verify the Routing pool still contains PCB-0001.
var _routing_pool_test = get_event_pool(
    event_library,
    EventStage.ROUTING
);

var _routing_ok = false;
var _consequence_ok = false;

if (array_length(_routing_pool_test) == 1)
{
    _routing_ok =
        _routing_pool_test[0].id == "PCB-0001";
}

if (array_length(_review_with_flag) == 1)
{
    _consequence_ok =
        _review_with_flag[0].id == "PCB-0002"
        && _review_with_flag[0].is_consequence;
}

if (_routing_ok
&& _consequence_ok
&& array_length(_review_without_flag) == 0)
{
    show_debug_message(
        "DELAYED CONSEQUENCE STAGE: PASS"
    );
}

else
{
    show_debug_message(
        "DELAYED CONSEQUENCE STAGE: FAILED"
    );

    show_debug_message(
        "DELAYED DEBUG: Routing valid = "
        + string(_routing_ok)
    );

    show_debug_message(
        "DELAYED DEBUG: Routing pool count = "
        + string(array_length(_routing_pool_test))
    );

    show_debug_message(
        "DELAYED DEBUG: Review without flag = "
        + string(array_length(_review_without_flag))
    );

    show_debug_message(
        "DELAYED DEBUG: Review with flag = "
        + string(array_length(_review_with_flag))
    );

    show_debug_message(
        "DELAYED DEBUG: Consequence valid = "
        + string(_consequence_ok)
    );

    // List all registered Manufacturer Review events
    var _manufacturer_pool = get_event_pool(
        event_library,
        EventStage.MANUFACTURER_REVIEW
    );

    for (
        var _i = 0;
        _i < array_length(_manufacturer_pool);
        _i++
    )
    {
        show_debug_message(
            "DELAYED DEBUG: Manufacturer event = "
            + _manufacturer_pool[_i].id
        );
    }
}


// --------------------------------------------------
// TEMPORARY FINAL RELEASE SIGNOFF TEST
// --------------------------------------------------

// Create an independent test campaign.
// The active campaign is not modified.

var _release_test = {
    current_event_stage: EventStage.RELEASE,
    campaign_event_target: 30,
    campaign_events_completed: 30,
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: get_campaign_stage_targets(30),
    completed_checkpoint_ids: [
        "PLC-REVIEW-001",
        "RTE-REVIEW-001"
    ]
};

// TEST 1: Missing final signoff must block release
var _release_missing_signoff =
    !is_dynamic_campaign_release_ready(_release_test);

// TEST 2: All completed requirements permit release
array_push(
    _release_test.completed_checkpoint_ids,
    "REL-SIGNOFF-001"
);

var _release_approved =
    is_dynamic_campaign_release_ready(_release_test);

// TEST 3: Incomplete Release stage must block release
_release_test.campaign_stage_events_completed[
    EventStage.RELEASE
] -= 1;

var _release_incomplete =
    !is_dynamic_campaign_release_ready(_release_test);

// Restore completed Release stage
_release_test.campaign_stage_events_completed[
    EventStage.RELEASE
] += 1;

// TEST 4: Missing Routing Review must block release
_release_test.completed_checkpoint_ids = [
    "PLC-REVIEW-001",
    "REL-SIGNOFF-001"
];

var _release_missing_review =
    !is_dynamic_campaign_release_ready(_release_test);

// TEST 5: Earlier stage cannot finish campaign
_release_test.completed_checkpoint_ids = [
    "PLC-REVIEW-001",
    "RTE-REVIEW-001",
    "REL-SIGNOFF-001"
];

_release_test.current_event_stage = EventStage.ROUTING;

var _release_wrong_stage =
    !is_dynamic_campaign_release_ready(_release_test);

// FINAL VALIDATION
if (_release_missing_signoff
&& _release_approved
&& _release_incomplete
&& _release_missing_review
&& _release_wrong_stage)
{
    show_debug_message(
        "FINAL SIGNOFF: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "FINAL SIGNOFF: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY CHECKPOINT COMPLETION RECORD TEST
// --------------------------------------------------

var _cp_record_test = {
    active_encounter: {
        id: "RTE-REVIEW-001",
        stage: EventStage.ROUTING
    },
    event_resolved: false,
    campaign_events_completed: 0,
    campaign_stage_events_completed: array_create(5, 0),
    completed_checkpoint_ids: []
};

// Unresolved review cannot count as completed
var _cp_unresolved_ok =
    !record_completed_dynamic_encounter(_cp_record_test)
    && array_length(
        _cp_record_test.completed_checkpoint_ids
    ) == 0;

// Resolve and record the review
_cp_record_test.event_resolved = true;

var _cp_recorded =
    record_completed_dynamic_encounter(_cp_record_test);

var _cp_recorded_ok =
    _cp_recorded
    && array_length(
        _cp_record_test.completed_checkpoint_ids
    ) == 1
    && array_contains(
        _cp_record_test.completed_checkpoint_ids,
        "RTE-REVIEW-001"
    )
    && _cp_record_test.campaign_events_completed == 1;

// Repeated completion must not count twice
var _cp_duplicate_ok =
    !record_completed_dynamic_encounter(_cp_record_test)
    && array_length(
        _cp_record_test.completed_checkpoint_ids
    ) == 1;

// Final validation
if (_cp_unresolved_ok
&& _cp_recorded_ok
&& _cp_duplicate_ok)
{
    show_debug_message(
        "CHECKPOINT COMPLETION: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CHECKPOINT COMPLETION: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY SCHEDULED ENCOUNTER PIPELINE TEST
// --------------------------------------------------

// Create an independent event library
var _pipe_library = create_event_library();
var _pipe_pool = _pipe_library.routing;

// Create a temporary Routing Review
var _pipe_review = variable_clone(_pipe_pool[0]);

_pipe_review[$ "id"] = "RTE-REVIEW-001";
_pipe_review.category = EventCategory.MILESTONE;

array_push(_pipe_pool, _pipe_review);

_pipe_library.routing = _pipe_pool;

// Create an independent test campaign
var _pipe_session = {
    event_library: _pipe_library,
    current_event_stage: EventStage.ROUTING,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: [],
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0),
    active_encounter: undefined
};

// TEST 1: Ordinary encounter begins successfully
var _pipe_normal_started =
    begin_scheduled_campaign_encounter(_pipe_session);

var _pipe_normal_ok = false;

if (_pipe_normal_started
&& is_struct(_pipe_session.active_encounter))
{
    _pipe_normal_ok =
        _pipe_session.active_encounter.id == "PCB-0001"
        && array_length(_pipe_session.active_encounter.choices) == 4
        && array_length(_pipe_session.played_event_ids) == 1;
}

// TEST 2: Cannot overwrite an active encounter
var _pipe_overwrite_rejected =
    !begin_scheduled_campaign_encounter(_pipe_session)
    && array_length(_pipe_session.played_event_ids) == 1;

// Clear the encounter for the next independent test
_pipe_session.active_encounter = undefined;

// Simulate reaching the final Routing slot
_pipe_session.campaign_stage_events_completed[
    EventStage.ROUTING
] = _pipe_session.campaign_stage_targets[
    EventStage.ROUTING
] - 1;

// TEST 3: Required checkpoint begins successfully
var _pipe_review_started =
    begin_scheduled_campaign_encounter(_pipe_session);

var _pipe_review_ok = false;

if (_pipe_review_started
&& is_struct(_pipe_session.active_encounter))
{
    _pipe_review_ok =
        _pipe_session.active_encounter.id == "RTE-REVIEW-001"
        && array_length(_pipe_session.active_encounter.choices) == 4
        && array_length(_pipe_session.played_event_ids) == 2;
}

// TEST 4: No encounter beyond the completed stage
_pipe_session.active_encounter = undefined;

_pipe_session.campaign_stage_events_completed[
    EventStage.ROUTING
] += 1;

var _pipe_stage_limit_ok =
    !begin_scheduled_campaign_encounter(_pipe_session)
    && !is_struct(_pipe_session.active_encounter)
    && array_length(_pipe_session.played_event_ids) == 2;

// Final validation
if (_pipe_normal_ok
&& _pipe_overwrite_rejected
&& _pipe_review_ok
&& _pipe_stage_limit_ok)
{
    show_debug_message(
        "CHECKPOINT PIPELINE: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CHECKPOINT PIPELINE: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY CHECKPOINT SELECTION TEST
// --------------------------------------------------

// Create an independent library for testing.
var _cp_sel_library = create_event_library();
var _cp_sel_pool = _cp_sel_library.routing;

// Create a temporary Routing Review from the
// existing test event. The real library is unchanged.
var _cp_sel_review = variable_clone(_cp_sel_pool[0]);

_cp_sel_review[$ "id"] = "RTE-REVIEW-001";
_cp_sel_review.category = EventCategory.MILESTONE;

array_push(_cp_sel_pool, _cp_sel_review);
_cp_sel_library.routing = _cp_sel_pool;

// Independent test campaign
var _cp_sel_session = {
    event_library: _cp_sel_library,
    current_event_stage: EventStage.ROUTING,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: [],
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0)
};

// Test 1: Ordinary encounter selected before review
var _cp_sel_normal = select_scheduled_stage_event(
    _cp_sel_session
);

var _cp_sel_normal_ok = (
    is_struct(_cp_sel_normal)
    && _cp_sel_normal.id == "PCB-0001"
);

// Test 2: Mandatory review selected in final slot
_cp_sel_session.campaign_stage_events_completed[
    EventStage.ROUTING
] = _cp_sel_session.campaign_stage_targets[
    EventStage.ROUTING
] - 1;

var _cp_sel_due = select_scheduled_stage_event(
    _cp_sel_session
);

var _cp_sel_due_ok = (
    is_struct(_cp_sel_due)
    && _cp_sel_due.id == "RTE-REVIEW-001"
);

// Test 3: Missing review cannot be replaced
_cp_sel_session.event_library = create_event_library();

var _cp_sel_missing = select_scheduled_stage_event(
    _cp_sel_session
);

var _cp_sel_missing_ok = !is_struct(_cp_sel_missing);

// Test 4: Already-played review cannot be repeated
_cp_sel_session.event_library = _cp_sel_library;
_cp_sel_session.played_event_ids = ["RTE-REVIEW-001"];

var _cp_sel_repeat = select_scheduled_stage_event(
    _cp_sel_session
);

var _cp_sel_repeat_ok = !is_struct(_cp_sel_repeat);

// Test 5: No additional event after stage completion
_cp_sel_session.played_event_ids = [];

_cp_sel_session.campaign_stage_events_completed[
    EventStage.ROUTING
] += 1;

var _cp_sel_finished = select_scheduled_stage_event(
    _cp_sel_session
);

var _cp_sel_finished_ok = !is_struct(_cp_sel_finished);

// Final validation
if (_cp_sel_normal_ok
&& _cp_sel_due_ok
&& _cp_sel_missing_ok
&& _cp_sel_repeat_ok
&& _cp_sel_finished_ok)
{
    show_debug_message(
        "CHECKPOINT SELECTOR: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CHECKPOINT SELECTOR: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY MANDATORY CHECKPOINT TEST
// --------------------------------------------------

var _checkpoint_test = {
    current_event_stage: EventStage.PLACEMENT,
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0)
};

// Test 1: No checkpoint at the start of Placement
var _cp_early = (
    get_due_stage_checkpoint_id(_checkpoint_test) == ""
);

// Test 2: Placement Review occupies the final slot
_checkpoint_test.campaign_stage_events_completed[
    EventStage.PLACEMENT
] = _checkpoint_test.campaign_stage_targets[
    EventStage.PLACEMENT
] - 1;

var _cp_placement = (
    get_due_stage_checkpoint_id(_checkpoint_test)
    == "PLC-REVIEW-001"
);

// Test 3: Checkpoint no longer due after completion
_checkpoint_test.campaign_stage_events_completed[
    EventStage.PLACEMENT
] += 1;

var _cp_finished = (
    get_due_stage_checkpoint_id(_checkpoint_test) == ""
);

// Test 4: Routing Review
_checkpoint_test.current_event_stage = EventStage.ROUTING;

_checkpoint_test.campaign_stage_events_completed[
    EventStage.ROUTING
] = _checkpoint_test.campaign_stage_targets[
    EventStage.ROUTING
] - 1;

var _cp_routing = (
    get_due_stage_checkpoint_id(_checkpoint_test)
    == "RTE-REVIEW-001"
);

// Test 5: Final Design Release
_checkpoint_test.current_event_stage = EventStage.RELEASE;

_checkpoint_test.campaign_stage_events_completed[
    EventStage.RELEASE
] = _checkpoint_test.campaign_stage_targets[
    EventStage.RELEASE
] - 1;

var _cp_release = (
    get_due_stage_checkpoint_id(_checkpoint_test)
    == "REL-SIGNOFF-001"
);

// Test 6: Manufacturer Review has no mandatory slot
_checkpoint_test.current_event_stage =
    EventStage.MANUFACTURER_REVIEW;

var _cp_no_review = (
    get_due_stage_checkpoint_id(_checkpoint_test) == ""
);

// Final validation
if (_cp_early
&& _cp_placement
&& _cp_finished
&& _cp_routing
&& _cp_release
&& _cp_no_review)
{
    show_debug_message(
        "CHECKPOINT SCHEDULE: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CHECKPOINT SCHEDULE: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY STAGE TRANSITION TEST
// --------------------------------------------------

// Independent test data.
// Does not modify the actual campaign.

var _transition_test = {
    current_event_stage: EventStage.DESIGN_SETUP,
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0),
	completed_checkpoint_ids: []
};

// TEST 1: Reject advancement before completion

_transition_test.campaign_stage_events_completed[
    EventStage.DESIGN_SETUP
] = 3;

var _early_rejected =
    !advance_dynamic_campaign_stage(_transition_test);

// TEST 2: Advance when Design Setup is complete

_transition_test.campaign_stage_events_completed[
    EventStage.DESIGN_SETUP
] = 4;

var _placement_reached =
    advance_dynamic_campaign_stage(_transition_test)
    && _transition_test.current_event_stage
        == EventStage.PLACEMENT;

// TEST 3: Cannot immediately skip Placement

var _skip_rejected =
    !advance_dynamic_campaign_stage(_transition_test);

// TEST 4: Advance through all remaining stages

var _sequence_passed = true;

for (
    var _stage = EventStage.PLACEMENT;
    _stage < EventStage.RELEASE;
    _stage++
)
{
    // Complete the current stage
    _transition_test.campaign_stage_events_completed[
        _stage
    ] = _transition_test.campaign_stage_targets[_stage];
	
// Verify mandatory reviews prevent early advancement
var _required_review = "";

if (_stage == EventStage.PLACEMENT)
{
    _required_review = "PLC-REVIEW-001";
}
else if (_stage == EventStage.ROUTING)
{
    _required_review = "RTE-REVIEW-001";
}

if (_required_review != "")
{
    // The stage target is met, but the review
    // has not been completed. Reject advancement.
    if (advance_dynamic_campaign_stage(_transition_test)
    || _transition_test.current_event_stage != _stage)
    {
        _sequence_passed = false;
        break;
    }

    // Simulate successful review completion
    array_push(
        _transition_test.completed_checkpoint_ids,
        _required_review
    );
}

    // Advance exactly one stage
    if (!advance_dynamic_campaign_stage(_transition_test)
    || _transition_test.current_event_stage != _stage + 1)
    {
        _sequence_passed = false;
        break;
    }
}

// TEST 5: Cannot advance beyond Release

_transition_test.campaign_stage_events_completed[
    EventStage.RELEASE
] = _transition_test.campaign_stage_targets[
    EventStage.RELEASE
];

var _release_stops =
    !advance_dynamic_campaign_stage(_transition_test)
    && _transition_test.current_event_stage
        == EventStage.RELEASE;

// FINAL VALIDATION

if (_early_rejected
&& _placement_reached
&& _skip_rejected
&& _sequence_passed
&& _release_stops)
{
    show_debug_message(
        "STAGE TRANSITION: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "STAGE TRANSITION: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY STAGE COMPLETION TEST
// --------------------------------------------------

// Independent test data.
// Does not modify the active campaign.

var _stage_test = {
    current_event_stage: EventStage.DESIGN_SETUP,
    campaign_stage_targets: get_campaign_stage_targets(30),
    campaign_stage_events_completed: array_create(5, 0)
};

// Test 1: Three of four encounters completed
_stage_test.campaign_stage_events_completed[
    EventStage.DESIGN_SETUP
] = 3;

var _stage_incomplete =
    is_dynamic_stage_complete(_stage_test);

// Test 2: Four of four encounters completed
_stage_test.campaign_stage_events_completed[
    EventStage.DESIGN_SETUP
] = 4;

var _stage_complete =
    is_dynamic_stage_complete(_stage_test);

// Test 3: Exceeding the target still counts
_stage_test.campaign_stage_events_completed[
    EventStage.DESIGN_SETUP
] = 5;

var _stage_exceeded =
    is_dynamic_stage_complete(_stage_test);

// Test 4: A new stage starts incomplete
_stage_test.current_event_stage = EventStage.PLACEMENT;

var _next_stage_incomplete =
    is_dynamic_stage_complete(_stage_test);

// Verify all conditions
if (!_stage_incomplete
&& _stage_complete
&& _stage_exceeded
&& !_next_stage_incomplete)
{
    show_debug_message(
        "STAGE COMPLETION: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "STAGE COMPLETION: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY DYNAMIC ENCOUNTER COMPLETION TEST
// --------------------------------------------------

// Independent test data; does not modify the
// player's actual campaign.

var _progress_test = {
    active_encounter: {
        id: "TEST-001",
        stage: EventStage.ROUTING
    },
    event_resolved: false,
    campaign_events_completed: 0,
    campaign_stage_events_completed: array_create(5, 0)
};

// Test 1: Unresolved encounters must not count
var _test_unresolved =
    record_completed_dynamic_encounter(_progress_test);

// Test 2: Resolve and record the encounter
_progress_test.event_resolved = true;

var _test_completed =
    record_completed_dynamic_encounter(_progress_test);

// Test 3: Attempt to record the same encounter again
var _test_duplicate =
    record_completed_dynamic_encounter(_progress_test);

// Verify all conditions
if (!_test_unresolved
&& _test_completed
&& !_test_duplicate
&& _progress_test.campaign_events_completed == 1
&& _progress_test.campaign_stage_events_completed[
    EventStage.ROUTING
] == 1)
{
    show_debug_message(
        "DYNAMIC PROGRESS: Completion tracking = PASS"
    );
}
else
{
    show_debug_message(
        "DYNAMIC PROGRESS: Completion tracking = FAIL"
    );
}

// --------------------------------------------------
// TEMPORARY STAGE SCHEDULE TEST
// --------------------------------------------------

var _schedule_test = get_campaign_stage_targets(30);

if (is_array(_schedule_test))
{
    var _schedule_total = 0;

    for (var _i = 0; _i < array_length(_schedule_test); _i++)
    {
        _schedule_total += _schedule_test[_i];
    }

    show_debug_message(
        "STAGE SCHEDULE: Total = "
        + string(_schedule_total)
    );

    show_debug_message(
        "STAGE SCHEDULE: Setup/Placement/Routing/Review/Release = "
        + string(_schedule_test[EventStage.DESIGN_SETUP]) + "/"
        + string(_schedule_test[EventStage.PLACEMENT]) + "/"
        + string(_schedule_test[EventStage.ROUTING]) + "/"
        + string(_schedule_test[EventStage.MANUFACTURER_REVIEW]) + "/"
        + string(_schedule_test[EventStage.RELEASE])
    );
}
else
{
    show_debug_message(
        "STAGE SCHEDULE: ERROR - Invalid schedule"
    );
}


// --------------------------------------------------
// TEMPORARY CAMPAIGN SCHEDULE RANGE TEST
// --------------------------------------------------

// Verify every possible campaign length from 25 to 35.
// Each schedule must have:
// - Exactly five stages
// - At least one event in every stage
// - A total matching the requested event count

var _schedule_range_passed = true;

for (var _count = 25; _count <= 35; _count++)
{
    var _targets = get_campaign_stage_targets(_count);

    if (!is_array(_targets))
    {
        _schedule_range_passed = false;
        show_debug_message(
            "SCHEDULE ERROR: Invalid target = "
            + string(_count)
        );
        continue;
    }

    var _sum = 0;
    var _valid = (array_length(_targets) == 5);

    for (var _stage = 0;
         _stage < array_length(_targets);
         _stage++)
    {
        _sum += _targets[_stage];

        if (_targets[_stage] < 1)
        {
            _valid = false;
        }
    }

    if (_sum != _count || !_valid)
    {
        _schedule_range_passed = false;

        show_debug_message(
            "SCHEDULE ERROR: Target = "
            + string(_count)
            + " Actual = "
            + string(_sum)
        );
    }
}

if (_schedule_range_passed)
{
    show_debug_message(
        "STAGE SCHEDULE: All lengths 25-35 = PASS"
    );
}
else
{
    show_debug_message(
        "STAGE SCHEDULE: Range validation FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY EVENT LIBRARY DIAGNOSTICS
// --------------------------------------------------

// Retrieve the PCB Design event pool
var _pcb_pool = get_event_pool(
    event_library,
    EventStage.ROUTING
);

// Report the number of registered events
show_debug_message(
    "EVENT LIBRARY: PCB Design events = "
    + string(array_length(_pcb_pool))
);

// Verify the first event and its choices
if (array_length(_pcb_pool) > 0)
{
    show_debug_message(
        "EVENT LIBRARY: First event ID = "
        + _pcb_pool[0].id
    );

    show_debug_message(
        "EVENT LIBRARY: Choice count = "
        + string(array_length(_pcb_pool[0].choices))
    );
}

// --------------------------------------------------
// TEMPORARY EVENT ELIGIBILITY TEST
// --------------------------------------------------

// Test with no previously played events
var _eligible_new = get_eligible_stage_events(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    []
);

show_debug_message(
    "EVENT SELECTOR: New campaign eligible = "
    + string(array_length(_eligible_new))
);


// Simulate PCB-0001 having already been played
var _eligible_played = get_eligible_stage_events(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    ["PCB-0001"]
);

show_debug_message(
    "EVENT SELECTOR: After PCB-0001 eligible = "
    + string(array_length(_eligible_played))
);

// --------------------------------------------------
// TEMPORARY FLAG ELIGIBILITY TEST
// --------------------------------------------------

// Create a separate library for testing.
// The active campaign library remains unchanged.
var _flag_test_library = create_event_library();

var _flag_test_event =
    _flag_test_library.routing[0];

// Simulate a follow-up event that requires an
// unresolved CAD issue and becomes unavailable
// once that issue has been verified.
_flag_test_event.required_flags = [
    "cad_changes_unverified"
];

_flag_test_event.blocked_flags = [
    "cad_changes_verified"
];

// Test 1: Required flag is missing
var _test_missing = get_eligible_stage_events(
    _flag_test_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    [],
    []
);

// Test 2: Required flag is present
var _test_matching = get_eligible_stage_events(
    _flag_test_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    [],
    ["cad_changes_unverified"]
);

// Test 3: Required and blocked flags are present
var _test_blocked = get_eligible_stage_events(
    _flag_test_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    [],
    [
        "cad_changes_unverified",
        "cad_changes_verified"
    ]
);

show_debug_message(
    "EVENT FLAGS: Missing required = "
    + string(array_length(_test_missing))
);

show_debug_message(
    "EVENT FLAGS: Required present = "
    + string(array_length(_test_matching))
);

show_debug_message(
    "EVENT FLAGS: Blocked condition = "
    + string(array_length(_test_blocked))
);

// --------------------------------------------------
// TEMPORARY WEIGHTED EVENT SELECTION TEST
// --------------------------------------------------

// Test selection using our registered PCB Design event
var _weighted_eligible = get_eligible_stage_events(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    [],
    []
);

var _weighted_selected = select_weighted_event(
    _weighted_eligible
);

if (is_struct(_weighted_selected))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Selected = "
        + _weighted_selected.id
    );
}

// Verify that zero-weight events cannot be selected
var _weight_test = select_weighted_event([
    { id: "ZERO", weight: 0 },
    { id: "VALID", weight: 10 }
]);

if (is_struct(_weight_test))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Positive weight = "
        + _weight_test.id
    );
}

// Verify that an empty pool is handled safely
var _empty_selection = select_weighted_event([]);

if (!is_struct(_empty_selection))
{
    show_debug_message(
        "WEIGHTED SELECTOR: Empty pool handled"
    );
}



// Tracks the action awaiting player confirmation.
// Valid actions for now: "restart" and "title".

pause_confirmation_action = "";


// --------------------------------------------------
// DRC HUNT - SHOOTING STATISTICS
// --------------------------------------------------

drc_hunt_shots = 0;
drc_hunt_hits = 0;
drc_hunt_max_hits = 3;
drc_hunt_cost_hours = 2;
drc_hunt_duration_seconds = 20;
drc_hunt_frames_remaining = 0;

// --------------------------------------------------
// DRC HUNT - MULTIPLE BOWTIE TARGETS
// --------------------------------------------------

// Stores the active bowties for each hunting session.
drc_hunt_targets = [];

// Target initialization is handled by scr_drc_hunt_targets.

// Shared PCB geometry used by the DRC Hunting renderer.
drc_hunt_scene = drc_hunt_create_scene();









/// @description Initialize campaign starting statistics

// --------------------------------------------------
// CAMPAIGN STATISTICS INITIALIZATION
// --------------------------------------------------

initialize_campaign_stats = function()
{
    // Player resources
    days_remaining = 25;
    engineering_hours = 100;
    budget = 100;
    morale = 80;

    // Manufacturing conditions
    drc_violations = 25;
    manufacturing_risk = 10;

    // Primary DFX status bars
    dfa = 50;
    dfm = 50;
    dft = 50;
    sanity = 100;

    // Sanity Crisis
    sanity_zero_active = false;
    sanity_zero_turns_remaining = 3;
    sanity_zero_failure_pending = false;

    // Software instability
    software_instability = 1;
	
// --------------------------------------------------
// APPLY SELECTED CAMPAIGN DIFFICULTY
// --------------------------------------------------

// NONE returns undefined during initial game setup.
var _profile = get_campaign_difficulty_profile(
    selected_campaign_difficulty
);

// Apply starting conditions only when a valid
// difficulty has been explicitly selected.
if (is_struct(_profile))
{
    // Player resources
    engineering_hours = irandom_range(
        _profile.engineering_hours_min,
        _profile.engineering_hours_max
    );

    budget = irandom_range(
        _profile.budget_min,
        _profile.budget_max
    );

    morale = irandom_range(
        _profile.morale_min,
        _profile.morale_max
    );

    // Manufacturing conditions
    drc_violations = irandom_range(
        _profile.drc_violations_min,
        _profile.drc_violations_max
    );

    manufacturing_risk = irandom_range(
        _profile.manufacturing_risk_min,
        _profile.manufacturing_risk_max
    );

    // DFX starting values
    dfa = irandom_range(_profile.dfa_min, _profile.dfa_max);
    dfm = irandom_range(_profile.dfm_min, _profile.dfm_max);
    dft = irandom_range(_profile.dft_min, _profile.dft_max);

    // Sanity always starts at 100 for every difficulty
    sanity = _profile.sanity_start;

    // Diagnostic confirmation
    show_debug_message(
        "CAMPAIGN: Applied difficulty profile - "
        + get_campaign_difficulty_name(
            selected_campaign_difficulty
        )
    );
}

};


// Debug Panel
debug_panel_open = false;


 // --------------------------------------------------
 // CAMPAIGN PROGRESSION INITIALIZATION
 // --------------------------------------------------

 initialize_campaign_progress = function()
 {
     
	// --------------------------------------------------
	// CAMPAIGN EVENT HISTORY AND PROJECT CONDITIONS
	// --------------------------------------------------

	// Events encountered during this campaign
	played_event_ids = [];

	// Persistent conditions created by player decisions
	project_flags = [];

	// Stage and encounter state for the future dynamic campaign
	// Do not select a new encounter until the stage pools are populated.
	current_event_stage = EventStage.DESIGN_SETUP;
	active_encounter = undefined;
	
// Track which encounter has used DRC Hunting.
// Reset whenever a new campaign begins.
drc_hunt_last_event_id = "";

// --------------------------------------------------
// DYNAMIC CAMPAIGN PROGRESS TRACKING
// --------------------------------------------------

// Total number of completed dynamic encounters.
// This is separate from the legacy event index.
campaign_events_completed = 0;

// Completed encounters in each of the five stages.
// Array indices correspond to the EventStage enum.
campaign_stage_events_completed = array_create(5, 0);

// Mandatory reviews completed during this campaign
completed_checkpoint_ids = [];

// Temporary initialization diagnostics
show_debug_message(
    "STAGE PROGRESS: Stage count = "
    + string(array_length(campaign_stage_events_completed))
);

show_debug_message(
    "STAGE PROGRESS: Completed encounters = "
    + string(campaign_events_completed)
);

show_debug_message(
    "STAGE PROGRESS: Current stage completed = "
    + string(campaign_stage_events_completed[current_event_stage])
);

// --------------------------------------------------
// INITIALIZE DYNAMIC CAMPAIGN SCHEDULE
// --------------------------------------------------

// Select the campaign length once per new campaign.
campaign_event_target = get_campaign_event_target(
    selected_campaign_difficulty
);

// No schedule exists before difficulty selection.
campaign_stage_targets = undefined;

// Create the schedule only for a valid difficulty.
if (campaign_event_target > 0)
{
    campaign_stage_targets = get_campaign_stage_targets(
        campaign_event_target
    );

    if (is_array(campaign_stage_targets))
    {
        // Verify that stage allocations match the target.
        var _scheduled_total = 0;

        for (
            var _s = 0;
            _s < array_length(campaign_stage_targets);
            _s++
        )
        {
            _scheduled_total += campaign_stage_targets[_s];
        }

        show_debug_message(
            "CAMPAIGN SCHEDULE: Difficulty = "
            + get_campaign_difficulty_name(
                selected_campaign_difficulty
            )
        );

        show_debug_message(
            "CAMPAIGN SCHEDULE: Target = "
            + string(campaign_event_target)
        );

        show_debug_message(
            "CAMPAIGN SCHEDULE: Allocation = "
            + string(_scheduled_total)
        );

        if (_scheduled_total == campaign_event_target)
        {
            show_debug_message(
                "CAMPAIGN SCHEDULE: PASS"
            );
        }
        else
        {
            show_debug_message(
                "CAMPAIGN SCHEDULE: FAIL"
            );
        }
    }
    else
    {
        show_debug_message(
            "CAMPAIGN SCHEDULE: ERROR - Invalid allocation"
        );
    }
}

	// Temporary diagnostic: confirms initialization and restart reset
	show_debug_message(
	    "CAMPAIGN STATE: Dynamic encounter state initialized"
	);

	// Temporary initialization diagnostics
	show_debug_message(
	    "CAMPAIGN STATE: Played events = "
	    + string(array_length(played_event_ids))
	);

	show_debug_message(
	    "CAMPAIGN STATE: Project flags = "
	    + string(array_length(project_flags))
	);


     // Initial gameplay state
     event_active = true;
     event_resolved = false;

     // Clear pending progression requests
     continue_requested = false;

     // Reset campaign outcomes
     campaign_complete = false;
     campaign_failed = false;
     campaign_half_victory = false;
 };


/// @description Request progression to the next event

request_continue = function()
{
    // Reject progression when gameplay does not own input
    if (!screen_manager.can_receive_input(ScreenId.GAMEPLAY))
    {
        return;
    }

    // Only allow progression during the REVIEWING phase
    if (get_campaign_phase() != CampaignPhase.REVIEWING)
    {
        return;
    }

    // Register the request for the Step Event
    continue_requested = true;
};





 // --------------------------------------------------
 // CAMPAIGN STATE INTERFACE
 // --------------------------------------------------

 // Return the current gameplay phase
 get_campaign_phase = function()
 {
     if (!event_active)
     {
         return CampaignPhase.FINISHED;
     }

     if (event_resolved)
     {
         return CampaignPhase.REVIEWING;
     }

     return CampaignPhase.CHOOSING;
 };


// --------------------------------------------------
// CURRENT CAMPAIGN EVENT ACCESS
// --------------------------------------------------

// The dynamic encounter system is the only
// source of gameplay events.

get_current_campaign_event = function()
{
    if (is_struct(active_encounter))
    {
        return active_encounter;
    }

    return undefined;
};

// --------------------------------------------------
// GET CAMPAIGN OUTCOME
// --------------------------------------------------

// Shared campaign outcome interface.
// Used by the gameplay renderer and final results UI.

get_campaign_outcome = function()
{
    if (campaign_failed)
    {
        return CampaignOutcome.FAILURE;
    }

    if (campaign_complete)
    {
        if (campaign_half_victory)
        {
            return CampaignOutcome.HALF_VICTORY;
        }

        return CampaignOutcome.VICTORY;
    }

    // Includes unfinished campaigns and development
    // builds that have exhausted their event pools.
    return CampaignOutcome.NONE;
};


required_dfa = 50;
required_dfm = 50;
required_dft = 50;
required_sanity = 1;

// --------------------------------------------------
// EVALUATE FINAL DESIGN RELEASE OUTCOME
// --------------------------------------------------

// Returns the campaign outcome without changing
// any player resources or campaign state.
//
// Shared rules for the legacy and dynamic campaigns.

evaluate_release_outcome = function(
    _dfa,
    _dfm,
    _dft,
    _sanity,
    _overdue_workdays
)
{
    // All three DFX requirements are mandatory.
    if (_dfa < required_dfa
    || _dfm < required_dfm
    || _dft < required_dft)
    {
        return CampaignOutcome.FAILURE;
    }

    // Special outcome: Design released successfully,
    // but the engineer has zero sanity and is overdue.
    if (_overdue_workdays > 0
    && _sanity < required_sanity)
    {
        return CampaignOutcome.HALF_VICTORY;
    }

    // Full victory requires at least 1% sanity.
    if (_sanity < required_sanity)
    {
        return CampaignOutcome.FAILURE;
    }

    return CampaignOutcome.VICTORY;
};

// --------------------------------------------------
// TEMPORARY RELEASE OUTCOME REGRESSION TEST
// --------------------------------------------------

var _outcome_full = (
    evaluate_release_outcome(50, 50, 50, 1, 0)
    == CampaignOutcome.VICTORY
);

var _outcome_dfx_failure = (
    evaluate_release_outcome(50, 50, 49, 80, 0)
    == CampaignOutcome.FAILURE
);

var _outcome_half = (
    evaluate_release_outcome(50, 50, 50, 0, 2)
    == CampaignOutcome.HALF_VICTORY
);

var _outcome_sanity_failure = (
    evaluate_release_outcome(50, 50, 50, 0, 0)
    == CampaignOutcome.FAILURE
);

var _outcome_failure_precedence = (
    evaluate_release_outcome(50, 49, 50, 0, 2)
    == CampaignOutcome.FAILURE
);

if (_outcome_full
&& _outcome_dfx_failure
&& _outcome_half
&& _outcome_sanity_failure
&& _outcome_failure_precedence)
{
    show_debug_message(
        "RELEASE OUTCOME: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "RELEASE OUTCOME: Tests FAILED"
    );
}

 // --------------------------------------------------
 // FINALIZE DYNAMIC CAMPAIGN
 // --------------------------------------------------

 // Completes a dynamic campaign only after all
 // scheduled encounters and checkpoints are finished.
 //
 // Returns true when the campaign was finalized.
 // Returns false when finalization is not permitted.

 finalize_dynamic_campaign = function(
     _campaign,
     _overdue_workdays
 )
 {
     // Prevent premature or repeated finalization.
     if (!_campaign.event_active
     || !_campaign.event_resolved
     || _campaign.campaign_complete
     || _campaign.campaign_failed
     || !is_dynamic_campaign_release_ready(_campaign))
     {
         return false;
     }

     // Evaluate the existing release requirements.
     var _outcome = evaluate_release_outcome(
         _campaign.dfa,
         _campaign.dfm,
         _campaign.dft,
         _campaign.sanity,
         _overdue_workdays
     );

     // Reset the outcome flags.
     _campaign.campaign_complete = false;
     _campaign.campaign_failed = false;
     _campaign.campaign_half_victory = false;
     _campaign.failure_reason = "";

     switch (_outcome)
     {
         case CampaignOutcome.VICTORY:

             _campaign.campaign_complete = true;
             _campaign.game_message =
                 "DESIGN RELEASE APPROVED!";

             _campaign.result_message =
                 "Congratulations! All DFX release "
                 + "requirements were met.";

             break;

         case CampaignOutcome.HALF_VICTORY:

             _campaign.campaign_complete = true;
             _campaign.campaign_half_victory = true;

             _campaign.game_message =
                 "DESIGN RELEASED - HALF VICTORY!";

             _campaign.result_message =
                 "The design met all DFX release requirements. "
                 + "However, the project was delivered late "
                 + "and the engineer was terminated.";

             break;

         case CampaignOutcome.FAILURE:

             _campaign.campaign_failed = true;
             _campaign.game_message = "PROJECT FAILURE!";

             if (_campaign.dfa < required_dfa)
             {
                 _campaign.failure_reason +=
                     "ASSEMBLY FAILURE: DFA below release requirement.\n";
             }

             if (_campaign.dfm < required_dfm)
             {
                 _campaign.failure_reason +=
                     "MANUFACTURING FAILURE: DFM below release requirement.\n";
             }

             if (_campaign.dft < required_dft)
             {
                 _campaign.failure_reason +=
                     "TEST FAILURE: DFT below release requirement.\n";
             }

             if (_campaign.sanity < required_sanity
             && _overdue_workdays <= 0)
             {
                 _campaign.failure_reason +=
                     "SANITY FAILURE: Release requirements not met.\n";
             }

             _campaign.result_message =
                 _campaign.failure_reason;

             break;

         default:
             return false;
     }

     // End gameplay and clear the active encounter.
     _campaign.event_active = false;
     _campaign.active_encounter = undefined;

     return true;
 };


 // --------------------------------------------------
 // TEMPORARY DYNAMIC FINALIZATION REGRESSION TEST
 // --------------------------------------------------

 // Create independent campaign test data.
 var _finalize_targets = get_campaign_stage_targets(30);

 var _finalize_base = {
     current_event_stage: EventStage.RELEASE,
     campaign_stage_targets: _finalize_targets,
     campaign_stage_events_completed: array_create(5, 0),
     campaign_event_target: 30,
     campaign_events_completed: 30,
     completed_checkpoint_ids: [
         "PLC-REVIEW-001",
         "RTE-REVIEW-001",
         "REL-SIGNOFF-001"
     ],
     event_active: true,
     event_resolved: true,
     campaign_complete: false,
     campaign_failed: false,
     campaign_half_victory: false,
     dfa: 50,
     dfm: 50,
     dft: 50,
     sanity: 80,
     failure_reason: "",
     game_message: "",
     result_message: "",
     active_encounter: undefined
 };

 // Simulate all five stages being completed.
 for (var _fi = 0; _fi < 5; _fi++)
 {
     _finalize_base.campaign_stage_events_completed[_fi] =
         _finalize_targets[_fi];
 }

 // TEST 1: Missing signoff blocks finalization.
 var _finalize_blocked = variable_clone(_finalize_base);

 _finalize_blocked.completed_checkpoint_ids = [
     "PLC-REVIEW-001",
     "RTE-REVIEW-001"
 ];

 var _finalize_block_ok =
     !finalize_dynamic_campaign(_finalize_blocked, 0)
     && _finalize_blocked.event_active
     && !_finalize_blocked.campaign_complete;

 // TEST 2: Full victory.
 var _finalize_full = variable_clone(_finalize_base);

 var _finalize_full_ok =
     finalize_dynamic_campaign(_finalize_full, 0)
     && _finalize_full.campaign_complete
     && !_finalize_full.campaign_failed
     && !_finalize_full.campaign_half_victory
     && !_finalize_full.event_active;

 // TEST 3: Finished campaigns cannot finalize twice.
 var _finalize_repeat_ok =
     !finalize_dynamic_campaign(_finalize_full, 0);

 // TEST 4: Late release at zero sanity.
 var _finalize_half = variable_clone(_finalize_base);
 _finalize_half.sanity = 0;

 var _finalize_half_ok =
     finalize_dynamic_campaign(_finalize_half, 2)
     && _finalize_half.campaign_complete
     && _finalize_half.campaign_half_victory
     && !_finalize_half.campaign_failed;

 // TEST 5: DFX failure takes precedence.
 var _finalize_failed = variable_clone(_finalize_base);
 _finalize_failed.dft = 49;
 _finalize_failed.sanity = 0;

 var _finalize_failure_ok =
     finalize_dynamic_campaign(_finalize_failed, 2)
     && _finalize_failed.campaign_failed
     && !_finalize_failed.campaign_complete;

 // Final validation.
 if (_finalize_block_ok
 && _finalize_full_ok
 && _finalize_repeat_ok
 && _finalize_half_ok
 && _finalize_failure_ok)
 {
     show_debug_message(
         "DYNAMIC FINALIZATION: All tests = PASS"
     );
 }
 else
 {
     show_debug_message(
         "DYNAMIC FINALIZATION: Tests FAILED"
     );
 }


// --------------------------------------------------
// CAMPAIGN MESSAGE INITIALIZATION
// --------------------------------------------------

initialize_campaign_messages = function()
{
    // Clear previous campaign failure information
    failure_reason = "";

    // Clear event and campaign messages
    game_message = "";
    result_message = "";
};


/// @description Reset decision result scrolling state

// --------------------------------------------------
// RESULT SCROLLING INITIALIZATION
// --------------------------------------------------

reset_result_scroll_state = function()
{
    // Reset the visible position of result text
    result_scroll_offset = 0;

    // Cancel any active scrollbar dragging
    result_scroll_dragging = false;

    // Clear the previous mouse grab position
    result_scroll_grab_offset = 0;
};



 // --------------------------------------------------
 // CAMPAIGN CALENDAR INITIALIZATION
 // --------------------------------------------------

 initialize_campaign_calendar = function()
 {
     // Project dates
     project_start_date = date_create_datetime(
         2027, 1, 4, 0, 0, 0
     );

     project_current_date = project_start_date;

     project_deadline_date = date_create_datetime(
         2027, 2, 8, 0, 0, 0
     );

     // Standard engineering workday
     hours_per_workday = 8;

     // Engineering time tracking
     project_work_hours_elapsed = 0;
     project_work_hours_today = 0;
     project_schedule_delay_days = 0;

     // Overdue Sanity penalty configuration
     overdue_sanity_penalty_per_day = 20;

     // Number of overdue workdays already penalized
     overdue_days_penalized = 0;
 };


 // --------------------------------------------------
 // ADVANCE PROJECT TIME USING ENGINEERING HOURS
 // --------------------------------------------------

 advance_project_work_hours = function(_hours)
 {
     // Record engineering hours consumed
     project_work_hours_elapsed += _hours;
     project_work_hours_today += _hours;

     // Advance one workday for every 8 hours accumulated
     while (project_work_hours_today >= hours_per_workday)
     {
         project_work_hours_today -= hours_per_workday;

         // Move to the next calendar day
         project_current_date = date_inc_day(
             project_current_date, 1
         );

         // Skip Saturday and Sunday
         while (date_get_weekday(project_current_date) == 0
         || date_get_weekday(project_current_date) == 6)
         {
             project_current_date = date_inc_day(
                 project_current_date, 1
             );
         }
     }
 };


 // --------------------------------------------------
 // ADVANCE PROJECT CALENDAR FOR SCHEDULE DELAYS
 // --------------------------------------------------

 advance_project_schedule_days = function(_days)
 {
	 // Record cumulative schedule delays
	 project_schedule_delay_days += max(0, floor(_days));
	 
     // Advance one working day for each day of delay
     repeat (max(0, floor(_days)))
     {
         project_current_date = date_inc_day(
             project_current_date, 1
         );

         // Skip Saturday and Sunday
         while (date_get_weekday(project_current_date) == 0
         || date_get_weekday(project_current_date) == 6)
         {
             project_current_date = date_inc_day(
                 project_current_date, 1
             );
         }
     }
 };


 // --------------------------------------------------
 // FORMAT PROJECT DATES AS MM/DD/YYYY
 // --------------------------------------------------

 format_project_date = function(_date)
 {
     var _month = string(date_get_month(_date));
     var _day = string(date_get_day(_date));
     var _year = string(date_get_year(_date));

     // Add leading zeros when necessary
     if (string_length(_month) < 2)
     {
         _month = "0" + _month;
     }

     if (string_length(_day) < 2)
     {
         _day = "0" + _day;
     }

     return _month + "/" + _day + "/" + _year;
 };



 // --------------------------------------------------
 // CALCULATE WORKDAYS UNTIL PROJECT DEADLINE
 // --------------------------------------------------

 get_workdays_until_deadline = function()
 {
     var _date = project_current_date;
     var _workdays_remaining = 0;

     // Count working days between current date and deadline
     while (_date < project_deadline_date)
     {
         _date = date_inc_day(_date, 1);

         var _weekday = date_get_weekday(_date);

         // Count Monday through Friday only
         if (_weekday != 0 && _weekday != 6)
         {
             _workdays_remaining += 1;
         }
     }

     return _workdays_remaining;
 };


 // --------------------------------------------------
 // CALCULATE WORKDAYS PAST PROJECT DEADLINE
 // --------------------------------------------------

 get_overdue_workdays = function()
 {
     var _date = project_deadline_date;
     var _overdue_days = 0;

     // Count working days after the deadline
     while (_date < project_current_date)
     {
         _date = date_inc_day(_date, 1);

         var _weekday = date_get_weekday(_date);

         // Count Monday through Friday only
         if (_weekday != 0 && _weekday != 6)
         {
             _overdue_days += 1;
         }
     }

     return _overdue_days;
 };


 // --------------------------------------------------
 // APPLY OVERDUE SANITY PENALTIES
 // --------------------------------------------------

 apply_overdue_sanity_penalty = function()
 {
     // Calculate total overdue working days
     var _overdue_days = get_overdue_workdays();

     // Determine how many days have not been penalized
     var _new_overdue_days = max(
         0,
         _overdue_days - overdue_days_penalized
     );

     // Apply penalties only for newly overdue days
     if (_new_overdue_days > 0)
     {
         var _sanity_penalty =
             _new_overdue_days * overdue_sanity_penalty_per_day;

         // Apply penalty without allowing negative sanity
         sanity = clamp(
             sanity - _sanity_penalty,
             0,
             100
         );

         // Record the days already penalized
         overdue_days_penalized = _overdue_days;
     }
 };


// --------------------------------------------------
// APPLY MANUFACTURING CHANGES
// --------------------------------------------------

// Shared by engineering decisions and future DRC Hunting.
// Updates DRC violations, manufacturing risk, and DFM.

apply_manufacturing_changes = function(
    _drc_change,
    _risk_change,
    _dfm_change
)
{
    // Calculate the manufacturing penalty before changes.
    var _old_penalty =
        (drc_violations * 2) + manufacturing_risk;

    // Apply the requested changes.
    drc_violations = max(
        0,
        drc_violations + _drc_change
    );

    manufacturing_risk = max(
        0,
        manufacturing_risk + _risk_change
    );

    // Calculate the penalty after changes.
    var _new_penalty =
        (drc_violations * 2) + manufacturing_risk;

    // Update DFM without double-counting the changes.
    dfm = clamp(
        dfm + _dfm_change
        + (_old_penalty - _new_penalty),
        0,
        100
    );
};


 // --------------------------------------------------
 // APPLY PLAYER CHOICE
 // --------------------------------------------------


apply_player_choice = function(_choice_index)
{
	
    // Prevent decisions while the debug panel is open.
    if (debug_panel_open)
    {
        exit;
    }

	// Reject player decisions when gameplay does not own input
	if (!screen_manager.can_receive_input(ScreenId.GAMEPLAY))
	{
	    exit;
	}

	// Only process decisions during the CHOOSING phase
	if (get_campaign_phase() != CampaignPhase.CHOOSING)
	{
	    exit;
	}


    
	var _event = get_current_campaign_event();

	// Reject choice indices outside the current event's choices
	if (_choice_index < 0
	|| _choice_index >= array_length(_event.choices))
	{
	    show_debug_message(
	        "WARNING: Invalid choice index: "
	        + string(_choice_index)
	    );

	    exit;
	}

	var _choice = _event.choices[_choice_index];


    if (engineering_hours >= _choice.hours_cost)

     {
         // Was the sanity crisis already active?
         var _crisis_was_active = sanity_zero_active;

         // Apply engineering resource costs
         engineering_hours -= _choice.hours_cost;

         // Advance calendar based on engineering effort
         advance_project_work_hours(_choice.hours_cost);

         // Advance calendar for additional schedule delays
         advance_project_schedule_days(_choice.days_cost);

         // Update remaining workdays
         days_remaining = get_workdays_until_deadline();

        
        // --------------------------------------------------
        // APPLY MANUFACTURING CHANGES
        // --------------------------------------------------

        // Update DRC violations, manufacturing risk,
        // and DFM using the shared calculation.

        apply_manufacturing_changes(
            _choice.drc_change,
            _choice.risk_change,
            _choice.dfm_change
        );

        // Apply DFA change
        dfa = clamp(
            dfa + _choice.dfa_change,
            0,
            100
        );


         dft = clamp(dft + _choice.dft_change, 0, 100);

         // Apply sanity change
         sanity = clamp(sanity + _choice.sanity_change, 0, 100);

         // Apply overdue Sanity penalties
         apply_overdue_sanity_penalty();

         // Start the Sanity Crisis
         if (sanity <= 0 && !sanity_zero_active)
         {
             sanity_zero_active = true;
             sanity_zero_turns_remaining = 3;
             software_instability = 5;
         }
         // Count subsequent decisions during the crisis
         else if (_crisis_was_active
         && sanity_zero_turns_remaining > 0)
         {
             sanity_zero_turns_remaining -= 1;

             if (sanity_zero_turns_remaining <= 0)
             {
                 sanity_zero_turns_remaining = 0;
                 sanity_zero_failure_pending = true;

                // The final Release checkpoint is the last
				// scheduled decision in a dynamic campaign.
				//
				// Allow final release evaluation to determine
				// the outcome if the crisis expires here.

				var _is_final_release_decision =
				    is_struct(active_encounter)
				    && current_event_stage == EventStage.RELEASE
				    && active_encounter.id == "REL-SIGNOFF-001"
				    && get_due_stage_checkpoint_id(id) == "REL-SIGNOFF-001";

				if (!_is_final_release_decision)
				{
				    campaign_failed = true;
				    event_active = false;

				    failure_reason =
				        "SPECIAL FAILURE: Sanity crisis deadline exceeded.";
				}
             }
         }

         event_resolved = true;

         game_message = "Decision applied.";
         result_message = _choice.result;
			
// --------------------------------------------------
// APPLY PERSISTENT DYNAMIC EVENT CONSEQUENCES
// --------------------------------------------------

// Only dynamic encounters use project flags.
// Preserve existing prototype choice behavior.

if (is_struct(active_encounter))
{
    // ----------------------------------------------
    // CLEAR PROJECT FLAGS
    // ----------------------------------------------

    if (is_array(_choice.clear_flags))
    {
        for (
            var _c = 0;
            _c < array_length(_choice.clear_flags);
            _c++
        )
        {
            var _clear_flag = _choice.clear_flags[_c];

            // Search backward so removals are safe.
            for (
                var _f = array_length(project_flags) - 1;
                _f >= 0;
                _f--
            )
            {
                if (project_flags[_f] == _clear_flag)
                {
                    array_delete(project_flags, _f, 1);
                }
            }
        }
    }

    // ----------------------------------------------
    // SET PROJECT FLAGS
    // ----------------------------------------------

    if (is_array(_choice.set_flags))
    {
        for (
            var _s = 0;
            _s < array_length(_choice.set_flags);
            _s++
        )
        {
            var _new_flag = _choice.set_flags[_s];

            // Prevent duplicate flags.
            if (!array_contains(project_flags, _new_flag))
            {
                array_push(project_flags, _new_flag);
            }
        }
    }

    // ----------------------------------------------
    // TEMPORARY DIAGNOSTICS
    // ----------------------------------------------

    show_debug_message(
        "DYNAMIC FLAGS: Total = "
        + string(array_length(project_flags))
    );

    if (array_contains(
        project_flags,
        "cad_changes_unverified"
    ))
    {
        show_debug_message(
            "DYNAMIC FLAGS: cad_changes_unverified = SET"
        );
    }
    else
    {
        show_debug_message(
            "DYNAMIC FLAGS: cad_changes_unverified = NOT SET"
        );
    }
}

         // Immediate engineering resource exhaustion check
         if (engineering_hours <= 0)
         {
             campaign_failed = true;
             event_active = false;

             failure_reason =
                 "Project failed: Engineering hours exhausted.";
         }

         if (campaign_failed)
         {
             game_message = "PROJECT FAILURE!";
             result_message = failure_reason;
         }
		 
		// Start each new decision result at the top
		result_scroll_offset = 0;

     }
     else
     {
         game_message =
             "Insufficient resources for this decision.";
     }
	 
	 
 };


/// --------------------------------------------------
/// REUSABLE CHOICE BUTTON MANAGEMENT
/// --------------------------------------------------

// Track button instances belonging to this controller
choice_button_instances = [];

// Track the Continue button belonging to this controller
continue_button_instance = noone;

 // Destroy all choice buttons owned by this controller
 clear_choice_buttons = function()
 {
     for (var _i = 0; _i < array_length(choice_button_instances); _i++)
     {
         if (instance_exists(choice_button_instances[_i]))
         {
             instance_destroy(choice_button_instances[_i]);
         }
     }

     choice_button_instances = [];
 };


// Create or rebuild buttons for the current event

refresh_choice_buttons = function()
{
    // Remove previously created buttons
    clear_choice_buttons();

    // --------------------------------------------------
    // GET CURRENT EVENT
    // --------------------------------------------------

    var _event = get_current_campaign_event();
    var _choices = _event.choices;

    // Calculate the choice region using the
    // current event's description height.
    var _region = get_ui_regions(_event).choices;

    // --------------------------------------------------
    // CALCULATE FLEX PANEL LAYOUT
    // --------------------------------------------------

    var _flex_layout = calculate_choice_layout_flex(
        _choices,
        _region
    );

    var _layout = _flex_layout.buttons;

    if (_flex_layout.overflow)
    {
        show_debug_message(
            "WARNING: Choice layout exceeds its defined region."
        );
    }

    // --------------------------------------------------
    // CREATE CHOICE BUTTONS
    // --------------------------------------------------

    for (
        var _i = 0;
        _i < array_length(_layout);
        _i++
    )
    {
        var _bounds = _layout[_i];

        var _button = instance_create_depth(
            0,
            0,
            depth - 1,
            obj_choice_button
        );

        // Connect to game controller
        _button.controller = id;
        _button.choice_index = _i;

        // Assign shuffled choice label
        _button.choice_label =
            string(_i + 1) + ". "
            + _choices[_i].text;

        // Apply calculated position and dimensions
        _button.button_x = _bounds.x;
        _button.button_y = _bounds.y;
        _button.button_width = _bounds.width;
        _button.button_height = _bounds.height;

        // Track for future cleanup
        array_push(choice_button_instances, _button);
    }
};

		
		// --------------------------------------------------
		// CENTRALIZED CAMPAIGN STATE INITIALIZATION
		// --------------------------------------------------

		initialize_campaign_state = function()
		{
		    // Reset engineering resources and DFX values
		    initialize_campaign_stats();

		    // Reset dates, work hours, and overdue tracking
		    initialize_campaign_calendar();

		    // Reset event progression and campaign outcome
		    initialize_campaign_progress();

		    // Clear previous campaign messages
		    initialize_campaign_messages();

		    // Reset temporary results UI state
		    reset_result_scroll_state();
		};		


/// @description Start or restart a campaign

// --------------------------------------------------
// START CAMPAIGN
// --------------------------------------------------

start_campaign = function()
{
    // Reset campaign resources, calendar, progress,
    // encounter history, flags, and outcome state.
    initialize_campaign_state();

    // Assign three random coworkers to the new campaign.
    advice_state = advice_start_campaign();


    // --------------------------------------------------
    // BEGIN DYNAMIC CAMPAIGN AUTOMATICALLY
    // --------------------------------------------------

    // The campaign starts at DESIGN_SETUP, as set
    // by initialize_campaign_progress().
    //
    // This replaces the need to press F8.

    if (begin_scheduled_campaign_encounter(id))
    {
        show_debug_message(
            "DYNAMIC CAMPAIGN: Started with "
            + active_encounter.id
        );
    }
    else
    {
        // Temporary safety fallback while the
        // remaining stage libraries are developed.
        //
        // Do not remove the original four events yet.

        show_debug_message(
            "DYNAMIC CAMPAIGN: Initial selection failed"
        );

        show_debug_message(
            "DYNAMIC CAMPAIGN: Using legacy prototype"
        );
    }

    // --------------------------------------------------
    // REBUILD GAMEPLAY BUTTONS
    // --------------------------------------------------

    refresh_choice_buttons();

    // Create the Continue button if necessary.
    if (!instance_exists(continue_button_instance))
    {
        continue_button_instance = instance_create_depth(
            0,
            0,
            depth - 1,
            obj_continue_button
        );
    }

    continue_button_instance.controller = id;

    // Enter the gameplay screen.
    screen_manager.navigate_to(ScreenId.GAMEPLAY);
};



// --------------------------------------------------
// INITIAL CONTROLLER STATE
// --------------------------------------------------

// Initialize campaign variables without starting gameplay.
// The campaign will start through the title/setup menu.

initialize_campaign_state();

// --------------------------------------------------
// TEMPORARY CONSEQUENCE COUNTING TEST
// --------------------------------------------------

// Independent test data.
// Does not modify the player's actual campaign.

var _count_test = {
    event_resolved: true,
    active_encounter: {
        id: "TEST-CONSEQUENCE",
        stage: EventStage.MANUFACTURER_REVIEW,
        is_consequence: true
    },
    campaign_events_completed: 0,
    campaign_stage_events_completed: array_create(5, 0)
};

// TEST 1: Record a consequence event
var _consequence_recorded =
    record_completed_dynamic_encounter(_count_test);

// TEST 2: Consequence must not advance the campaign
var _consequence_not_counted =
    _count_test.campaign_events_completed == 0
    && _count_test.campaign_stage_events_completed[
        EventStage.MANUFACTURER_REVIEW
    ] == 0;

// TEST 3: Consequence must not be counted twice
var _duplicate_rejected =
    !record_completed_dynamic_encounter(_count_test);

// TEST 4: Ordinary events must still count
_count_test.active_encounter = {
    id: "TEST-SCHEDULED",
    stage: EventStage.MANUFACTURER_REVIEW,
    is_consequence: false
};

var _scheduled_recorded =
    record_completed_dynamic_encounter(_count_test);

var _scheduled_counted =
    _count_test.campaign_events_completed == 1
    && _count_test.campaign_stage_events_completed[
        EventStage.MANUFACTURER_REVIEW
    ] == 1;

// FINAL VALIDATION
if (_consequence_recorded
&& _consequence_not_counted
&& _duplicate_rejected
&& _scheduled_recorded
&& _scheduled_counted)
{
    show_debug_message(
        "CONSEQUENCE COUNTING: All tests = PASS"
    );
}
else
{
    show_debug_message(
        "CONSEQUENCE COUNTING: Tests FAILED"
    );
}

// --------------------------------------------------
// TEMPORARY STAGE EVENT SELECTION TEST
// --------------------------------------------------

// Use separate test history and conditions.
// Do not modify the active campaign state.

var _test_played_ids = [];
var _test_flags = [];


// Test 1: Select our registered PCB Design event
var _test_first_event = select_next_stage_event(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (is_struct(_test_first_event))
{
    show_debug_message(
        "STAGE SELECTOR: First event = "
        + _test_first_event.id
    );

    // Simulate recording that event as played
    array_push(
        _test_played_ids,
        _test_first_event.id
    );
}


// Test 2: Confirm the event cannot repeat
var _test_second_event = select_next_stage_event(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (!is_struct(_test_second_event))
{
    show_debug_message(
        "STAGE SELECTOR: Played event excluded"
    );
}


// Test 3: Confirm empty stage pools are safe
var _test_empty_stage = select_next_stage_event(
    event_library,
    EventStage.MANUFACTURER_REVIEW,
    CampaignDifficulty.MEDIUM,
    _test_played_ids,
    _test_flags
);

if (!is_struct(_test_empty_stage))
{
    show_debug_message(
        "STAGE SELECTOR: Empty stage handled"
    );
}


// --------------------------------------------------
// TEMPORARY CHOICE RANDOMIZATION TEST
// --------------------------------------------------

// Retrieve the permanent event definition
var _source_event = event_library.routing[0];

// Create an independent, shuffled encounter
var _test_encounter = prepare_event_encounter(
    _source_event
);

// Display original first choice
show_debug_message(
    "CHOICE TEST: Original first = "
    + _source_event.choices[0].id
);

// Display shuffled choices and associated costs
for (
    var _i = 0;
    _i < array_length(_test_encounter.choices);
    _i++
)
{
    var _choice = _test_encounter.choices[_i];

    show_debug_message(
        "CHOICE TEST: Position "
        + string(_i + 1)
        + " = "
        + _choice.id
        + " | Hours = "
        + string(_choice.hours_cost)
    );
}

// Confirm the permanent library is unchanged
show_debug_message(
    "CHOICE TEST: Original still first = "
    + _source_event.choices[0].id
);


// --------------------------------------------------
// TEMPORARY COMPLETE ENCOUNTER PIPELINE TEST
// --------------------------------------------------

// Independent test history and conditions
var _pipeline_played = [];
var _pipeline_flags = [];

// Select and prepare the first encounter
var _pipeline_event = select_and_prepare_stage_encounter(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    _pipeline_played,
    _pipeline_flags
);

if (is_struct(_pipeline_event))
{
    show_debug_message(
        "ENCOUNTER PIPELINE: Selected = "
        + _pipeline_event.id
    );

    show_debug_message(
        "ENCOUNTER PIPELINE: Choices = "
        + string(array_length(_pipeline_event.choices))
    );

    // Simulate recording the event as played
    array_push(
        _pipeline_played,
        _pipeline_event.id
    );
}

// Check that the same event cannot be selected again
var _pipeline_next = select_and_prepare_stage_encounter(
    event_library,
    EventStage.ROUTING,
    CampaignDifficulty.MEDIUM,
    _pipeline_played,
    _pipeline_flags
);

if (!is_struct(_pipeline_next))
{
    show_debug_message(
        "ENCOUNTER PIPELINE: No repeat available"
    );
}

// --------------------------------------------------
// TEMPORARY CAMPAIGN ENCOUNTER SESSION TEST
// STEP 58, PART 2I
// --------------------------------------------------

// Test using an independent session object, not obj_game state.
var _session_test = {
    event_library: event_library,
    current_event_stage: EventStage.ROUTING,
    selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
    played_event_ids: [],
    project_flags: [],
    active_encounter: undefined
};

var _session_started = begin_campaign_encounter(_session_test);

if (_session_started && is_struct(_session_test.active_encounter))
{
    show_debug_message(
        "SESSION TEST: Active encounter = "
        + _session_test.active_encounter.id
    );

    show_debug_message(
        "SESSION TEST: Played count = "
        + string(array_length(_session_test.played_event_ids))
    );
}
else
{
    show_debug_message("SESSION TEST: Failed to begin encounter");
}

var _session_repeated = begin_campaign_encounter(_session_test);

if (!_session_repeated)
{
    show_debug_message("SESSION TEST: Repeat prevented");
}

show_debug_message(
    "SESSION TEST: Real campaign played count = "
    + string(array_length(played_event_ids))
);
