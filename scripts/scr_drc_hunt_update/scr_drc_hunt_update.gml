/// @description DRC Hunting - update bowtie movement and behavior states

// Updates existing bowtie data without accessing campaign state.
// The caller stores the returned target array.
function drc_hunt_update_targets(_targets, _scene)
{
    // Use the shared PCB scene for movement and reappearance.
    var _movement = _scene.movement_bounds;
    var _reappear = _scene.reappear_bounds;

    for (var _i = 0; _i < array_length(_targets); _i++)
    {
        var _target = _targets[_i];

        if (_target.active)
        {
            // ----------------------------------------------
            // PAUSED BEHAVIOR
            // ----------------------------------------------

            if (_target.behavior == "pause")
            {
                _target.behavior_frames_remaining -= 1;

                if (_target.behavior_frames_remaining <= 0)
                {
                    _target.behavior = "scurry";
                    _target.behavior_frames_remaining = 0;
                }
            }

            // ----------------------------------------------
            // HIDDEN BEHAVIOR
            // ----------------------------------------------

            else if (_target.behavior == "hide")
            {
                _target.behavior_frames_remaining -= 1;

                if (_target.behavior_frames_remaining <= 0)
                {
                    // Reappear somewhere else on the PCB.
                    _target.x = irandom_range(_reappear.x1, _reappear.x2);
                    _target.y = irandom_range(_reappear.y1, _reappear.y2);

                    _target.behavior = "scurry";
                    _target.behavior_frames_remaining = 0;
                }
            }

            // ----------------------------------------------
            // SCURRYING BEHAVIOR
            // ----------------------------------------------

            else
            {
                // Occasionally disappear.
                if (irandom(479) == 0)
                {
                    _target.behavior = "hide";
                    _target.behavior_frames_remaining =
                        irandom_range(24, 42);
                }
                // Occasionally stop briefly.
                else if (irandom(239) == 0)
                {
                    _target.behavior = "pause";
                    _target.behavior_frames_remaining =
                        irandom_range(18, 30);
                }
                else
                {
                    // Occasionally change direction and speed.
                    if (irandom(89) == 0)
                    {
                        var _angle = random(360);
                        var _speed = random_range(1.3, 2.7);

                        _target.dx = lengthdir_x(_speed, _angle);
                        _target.dy = lengthdir_y(_speed, _angle);
                    }

                    _target.x += _target.dx;
                    _target.y += _target.dy;

                    // Horizontal boundaries.
                    if (_target.x <= _movement.x1 || _target.x >= _movement.x2)
                    {
                        _target.dx = -_target.dx;
                        _target.x = clamp(_target.x, _movement.x1, _movement.x2);
                    }

                    // Vertical boundaries.
                    if (_target.y <= _movement.y1 || _target.y >= _movement.y2)
                    {
                        _target.dy = -_target.dy;
                        _target.y = clamp(_target.y, _movement.y1, _movement.y2);
                    }
                }
            }

            // Save all position and behavior changes.
            _targets[_i] = _target;
        }
    }

    return _targets;
}
