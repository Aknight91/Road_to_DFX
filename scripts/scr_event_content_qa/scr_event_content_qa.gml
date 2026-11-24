/// @description Independent event-content regression after population of all five stages
// Called only at startup. Never modifies the real campaign or event library.
// Replaces obsolete Create Event tests that assumed empty stage pools.

function run_event_content_qa(_library)
{
    var _ok = true;
    var _max_targets = array_create(5, 0);

    // Every supported campaign length, including the 35-event COW campaign.
    for (var _total = 25; _total <= 35; _total++)
    {
        var _targets = get_campaign_stage_targets(_total);
        if (!is_array(_targets))
        {
            _ok = false;
            continue;
        }
        for (var _stage = EventStage.DESIGN_SETUP;
             _stage <= EventStage.RELEASE; _stage++)
        {
            _max_targets[_stage] = max(_max_targets[_stage], _targets[_stage]);
        }
    }

    var _checkpoint_ids = ["", "PLC-REVIEW-001", "RTE-REVIEW-001", "", "REL-SIGNOFF-001"];

    for (var _s = EventStage.DESIGN_SETUP; _s <= EventStage.RELEASE; _s++)
    {
        var _pool = get_event_pool(_library, _s);
        var _ordinary = 0;
        var _checkpoint_present = (_checkpoint_ids[_s] == "");

        for (var _p = 0; _p < array_length(_pool); _p++)
        {
            var _e = _pool[_p];

            if (_e.id == _checkpoint_ids[_s])
            {
                _checkpoint_present = true;
                continue;
            }

            if (variable_struct_exists(_e, "is_consequence") && _e.is_consequence)
            {
                continue;
            }

            // Only count universally eligible ordinary events.
            if (_e.min_difficulty <= CampaignDifficulty.EASY
            && _e.max_difficulty >= CampaignDifficulty.COW_MODE
            && array_length(_e.required_flags) == 0
            && array_length(_e.blocked_flags) == 0
            && _e.weight > 0)
            {
                _ordinary++;
            }
        }

        var _required_ordinary = _max_targets[_s] - (_checkpoint_ids[_s] != "" ? 1 : 0);
        var _capacity_ok = (_ordinary >= _required_ordinary && _checkpoint_present);
        _ok = _ok && _capacity_ok;

        show_debug_message(
            "EVENT CONTENT QA: Stage=" + string(_s)
            + " ordinary=" + string(_ordinary)
            + " needed=" + string(_required_ordinary)
            + " checkpoint=" + string(_checkpoint_present)
            + (_capacity_ok ? " PASS" : " FAIL")
        );
    }

    // Verify existing CAD corruption consequence remains conditional.
    var _without_flag = select_stage_consequence_event({
        event_library: _library,
        current_event_stage: EventStage.MANUFACTURER_REVIEW,
        selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
        played_event_ids: [],
        project_flags: []
    });
    var _with_flag = select_stage_consequence_event({
        event_library: _library,
        current_event_stage: EventStage.MANUFACTURER_REVIEW,
        selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
        played_event_ids: [],
        project_flags: ["cad_changes_unverified"]
    });
    var _consequence_ok = !is_struct(_without_flag)
        && is_struct(_with_flag)
        && _with_flag.id == "PCB-0002";
    _ok = _ok && _consequence_ok;
    show_debug_message("EVENT CONTENT QA: Conditional consequence "
        + (_consequence_ok ? "PASS" : "FAIL"));

    // Zero consequence probability must select ordinary manufacturer work.
    var _test = {
        event_library: _library,
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
    var _ordinary_started = begin_scheduled_campaign_encounter(_test, 0);
    var _normal_ok = _ordinary_started && is_struct(_test.active_encounter)
        && !(variable_struct_exists(_test.active_encounter, "is_consequence")
             && _test.active_encounter.is_consequence);
    _ok = _ok && _normal_ok;
    show_debug_message("EVENT CONTENT QA: Ordinary review selection "
        + (_normal_ok ? "PASS" : "FAIL"));

    // Force a conditional interruption on a fresh independent session.
    _test.played_event_ids = [];
    _test.active_encounter = undefined;
    var _forced = begin_scheduled_campaign_encounter(_test, 100);
    var _forced_ok = _forced && is_struct(_test.active_encounter)
        && _test.active_encounter.id == "PCB-0002"
        && _test.active_encounter.is_consequence;

    if (_forced_ok)
    {
        _test.event_resolved = true;
        var _recorded = record_completed_dynamic_encounter(_test);
        _forced_ok = _recorded
            && _test.campaign_events_completed == 0
            && _test.campaign_stage_events_completed[EventStage.MANUFACTURER_REVIEW] == 0;
    }
    _ok = _ok && _forced_ok;
    show_debug_message("EVENT CONTENT QA: Interrupt without consuming a slot "
        + (_forced_ok ? "PASS" : "FAIL"));

    // Mandatory Release signoff must be selected only in the final slot.
    var _release_targets = get_campaign_stage_targets(30);
    var _release_test = {
        event_library: _library,
        current_event_stage: EventStage.RELEASE,
        selected_campaign_difficulty: CampaignDifficulty.MEDIUM,
        played_event_ids: [],
        project_flags: [],
        campaign_stage_targets: _release_targets,
        campaign_stage_events_completed: array_create(5, 0)
    };
    _release_test.campaign_stage_events_completed[EventStage.RELEASE] =
        _release_targets[EventStage.RELEASE] - 1;
    var _due = get_due_stage_checkpoint_id(_release_test);
    var _selected = select_scheduled_stage_event(_release_test);
    var _signoff_ok = _due == "REL-SIGNOFF-001"
        && is_struct(_selected) && _selected.id == "REL-SIGNOFF-001";
    _ok = _ok && _signoff_ok;
    show_debug_message("EVENT CONTENT QA: Final signoff scheduling "
        + (_signoff_ok ? "PASS" : "FAIL"));

    show_debug_message("EVENT CONTENT QA: Overall " + (_ok ? "PASS" : "FAILED"));
    return _ok;
}
