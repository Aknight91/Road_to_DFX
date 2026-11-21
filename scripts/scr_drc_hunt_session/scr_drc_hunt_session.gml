/// @description DRC Hunting - session setup, costs, and timer

// Starts a hunt using the existing campaign rules.
// Returns true only when the hunt was successfully initialized.
// The calling controller handles screen navigation and input.
function drc_hunt_begin_session(_game)
{
    if (!is_struct(_game.active_encounter))
    {
        return false;
    }

    // Only one hunt per encounter. Preserve the existing
    // strict hours check: enough time must remain after the cost.
    if (_game.drc_hunt_last_event_id == _game.active_encounter.id
    || _game.drc_violations <= 0
    || _game.engineering_hours <= _game.drc_hunt_cost_hours)
    {
        return false;
    }

    // Record this encounter as used and charge engineering time.
    _game.drc_hunt_last_event_id = _game.active_encounter.id;
    _game.engineering_hours -= _game.drc_hunt_cost_hours;

    // Apply the existing project calendar and overdue rules.
    _game.advance_project_work_hours(_game.drc_hunt_cost_hours);
    _game.days_remaining = _game.get_workdays_until_deadline();
    _game.apply_overdue_sanity_penalty();

    // Overdue penalties can trigger the existing Sanity Crisis.
    if (_game.sanity <= 0 && !_game.sanity_zero_active)
    {
        _game.sanity_zero_active = true;
        _game.sanity_zero_turns_remaining = 3;
        _game.software_instability = 5;
    }

    // Begin a fresh hunting session.
    _game.drc_hunt_shots = 0;
    _game.drc_hunt_hits = 0;
    _game.drc_hunt_frames_remaining =
        _game.drc_hunt_duration_seconds
        * game_get_speed(gamespeed_fps);

    // Build a fresh set of bowties for this hunt.
    _game.drc_hunt_targets = drc_hunt_create_targets(
        _game.drc_hunt_max_hits,
        _game.drc_violations,
        _game.drc_hunt_scene
    );

    return true;
}

// Tick the timer once, preserving the established stopping rules.
// The caller decides whether the DRC Hunt screen can receive input.
function drc_hunt_tick_timer(_frames_remaining, _hits, _max_hits, _violations)
{
    if (_frames_remaining > 0
    && _hits < _max_hits
    && _violations > 0)
    {
        return _frames_remaining - 1;
    }

    return _frames_remaining;
}
