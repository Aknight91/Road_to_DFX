/// @description DRC Hunting - initialize a new group of bowties

// Returns new target data without changing campaign state.
// The session controller stores this array when a hunt starts.

// Create a fresh group of bowties.
function drc_hunt_create_targets(_max_hits, _violations)
{
    var _targets = [];

    // Initial target positions and velocities.
    var _starting_targets = [
        {
            x: 210,
            y: 220,
            dx: 1.8,
            dy: 1.2,
            active: true
        },
        {
            x: 470,
            y: 310,
            dx: -2.1,
            dy: 1.4,
            active: true
        },
        {
            x: 730,
            y: 190,
            dx: 1.6,
            dy: -1.1,
            active: true
        }
    ];

    // Never create more targets than can be cleared.
    var _target_count = min(
        array_length(_starting_targets),
        _max_hits,
        _violations
    );

    for (var _i = 0; _i < _target_count; _i++)
    {
        // Retrieve the target.
        var _target = _starting_targets[_i];

        // Every bowtie starts in its normal scurrying state.
        _target.behavior = "scurry";

        // Duration remaining in a temporary behavior.
        // Zero means no temporary behavior is active.
        _target.behavior_frames_remaining = 0;

        // Add the initialized target to the hunt.
        array_push(_targets, _target);
    }


    show_debug_message(
        "DRC HUNT: Targets initialized = "
        + string(array_length(_targets))
    );

    return _targets;
}
