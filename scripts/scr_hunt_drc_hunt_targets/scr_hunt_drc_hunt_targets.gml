/// @description DRC Hunting - initialize a new group of bowties

// Returns new target data without changing campaign state.
// The session controller stores this array when a hunt starts.

// Create a fresh group of bowties.
function drc_hunt_create_targets(_max_hits, _violations, _scene)
{
    var _targets = [];

    // Spawn positions and velocities come from the selected PCB scene.
    var _starting_targets = _scene.spawns;

    // Never create more targets than can be cleared.
    var _target_count = min(
        array_length(_starting_targets),
        _max_hits,
        _violations
    );

    for (var _i = 0; _i < _target_count; _i++)
    {
        var _spawn = _starting_targets[_i];

        // Create independent target data; do not modify scene templates.
        var _target = {
            x: _spawn.x,
            y: _spawn.y,
            dx: _spawn.dx,
            dy: _spawn.dy,
            active: true,
            behavior: "scurry",
            behavior_frames_remaining: 0
        };

        array_push(_targets, _target);
    }


    show_debug_message(
        "DRC HUNT: Targets initialized = "
        + string(array_length(_targets))
    );

    return _targets;
}
