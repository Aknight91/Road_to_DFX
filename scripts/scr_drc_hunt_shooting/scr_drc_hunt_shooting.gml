
/// @description DRC Hunting - shot validation and target hit detection

// Calculates the result of a click without changing campaign resources.
// The caller applies shot/hit counters and manufacturing consequences.
// A returned hit_index of -1 means no target was hit.
function drc_hunt_process_shot(_targets, _shot_x, _shot_y)
{
    var _result = {
        targets: _targets,
        fired: false,
        hit_index: -1
    };

    // Only clicks inside the PCB count as shots.
    if (!point_in_rectangle(_shot_x, _shot_y, 60, 115, 900, 425))
    {
        return _result;
    }

    _result.fired = true;

    // Check active, visible bowties in their existing array order.
    for (var _i = 0; _i < array_length(_targets); _i++)
    {
        var _target = _targets[_i];

        // Hidden and destroyed targets cannot be shot.
        if (!_target.active || _target.behavior == "hide")
        {
            continue;
        }

        if (point_in_rectangle(
            _shot_x,
            _shot_y,
            _target.x - 20,
            _target.y - 13,
            _target.x + 20,
            _target.y + 13
        ))
        {
            // Mark only the first matching target as destroyed.
            _target.active = false;
            _targets[_i] = _target;
            _result.hit_index = _i;
            break;
        }
    }

    _result.targets = _targets;
    return _result;
}
