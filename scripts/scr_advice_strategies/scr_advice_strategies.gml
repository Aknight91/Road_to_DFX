/// @description Step 66 Part 5 - role-informed coworker advice strategies
// All recommendation scoring and small skill bonuses live in this module.
// Existing encounter choices remain the authoritative engineering actions.

// A focus describes HOW this coworker thinks about a design problem.
// The bonus is a small, provisional skill benefit on the FOLLOW choice,
// not an immediate reward for visiting or paying for consultation.
function advice_get_profile(_npc)
{
    var _profile = {
        focus: "verification",
        label: "Verification and risk",
        observation: "Double-check what could go wrong before release.",
        bonus_field: "risk_change",
        bonus_amount: -1
    };

    // Stable IDs, not randomized hallway positions, determine the profile.
    switch (_npc.id)
    {
        case "npc_moose":
            _profile.focus = "verification";
            _profile.label = "Careful verification";
            _profile.observation = "Moose insists on checking the design assumptions.";
            break;

        case "npc_sparky":
            _profile.focus = "speed";
            _profile.label = "Fast practical rework";
            _profile.observation = "Sparky knows a shorter way through the problem.";
            _profile.bonus_field = "hours_cost";
            _profile.bonus_amount = -1;
            break;

        case "npc_tyler":
            _profile.focus = "stress";
            _profile.label = "Keeping the team sane";
            _profile.observation = "Tyler offers an unconventional morale boost.";
            _profile.bonus_field = "sanity_change";
            _profile.bonus_amount = 2;
            break;

        case "npc_004":  // Electrical engineer
            _profile.focus = "verification";
            _profile.label = "Electrical integrity";
            _profile.observation = "Verify the nets and electrical consequences.";
            _profile.bonus_field = "drc_change";
            _profile.bonus_amount = -1;
            break;

        case "npc_005":  // Mechanical engineer
            _profile.focus = "assembly";
            _profile.label = "Mechanical fit";
            _profile.observation = "Watch clearances and assembly access.";
            _profile.bonus_field = "dfa_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_006":  // Firmware engineer
            _profile.focus = "test";
            _profile.label = "Debug and test access";
            _profile.observation = "Make the problem observable during bring-up.";
            _profile.bonus_field = "dft_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_007":  // CAM engineer
            _profile.focus = "fabrication";
            _profile.label = "CAM manufacturability";
            _profile.observation = "Check the data the fabricator will actually receive.";
            _profile.bonus_field = "risk_change";
            _profile.bonus_amount = -1;
            break;

        case "npc_008":  // Fabrication operator
            _profile.focus = "fabrication";
            _profile.label = "Fabrication practicality";
            _profile.observation = "Choose the approach the shop can repeat.";
            _profile.bonus_field = "dfm_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_009":  // Process engineer
            _profile.focus = "fabrication";
            _profile.label = "Repeatable process";
            _profile.observation = "Reduce process variation and rework.";
            _profile.bonus_field = "dfm_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_010":  // SMT assembly technician
            _profile.focus = "assembly";
            _profile.label = "Assembly-floor access";
            _profile.observation = "Make the board easier to build.";
            _profile.bonus_field = "dfa_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_011":  // Test engineer
            _profile.focus = "test";
            _profile.label = "Test coverage";
            _profile.observation = "Leave a way to detect the defect later.";
            _profile.bonus_field = "dft_change";
            _profile.bonus_amount = 1;
            break;

        case "npc_012":  // Quality engineer
            _profile.focus = "verification";
            _profile.label = "Defect prevention";
            _profile.observation = "Prevent the next escape, not just this one.";
            _profile.bonus_field = "drc_change";
            _profile.bonus_amount = -1;
            break;

        case "npc_013":  // Supply chain specialist
            _profile.focus = "speed";
            _profile.label = "Practical sourcing";
            _profile.observation = "Find a solution that uses what's available.";
            _profile.bonus_field = "hours_cost";
            _profile.bonus_amount = -1;
            break;

        case "npc_014":  // Program manager
            _profile.focus = "speed";
            _profile.label = "Schedule protection";
            _profile.observation = "Keep the work moving toward the deadline.";
            _profile.bonus_field = "hours_cost";
            _profile.bonus_amount = -1;
            break;

        case "npc_015":  // Reliability engineer
            _profile.focus = "verification";
            _profile.label = "Long-term reliability";
            _profile.observation = "Think about the failure that shows up later.";
            _profile.bonus_field = "risk_change";
            _profile.bonus_amount = -1;
            break;
    }

    return _profile;
}

// Score only fields ALREADY processed by apply_player_choice() in obj_game.
// This is intentionally small and easy to rebalance. Negative DRC/risk
// changes and positive DFX changes are normally desirable.
function advice_score_source_choice(_choice, _profile)
{
    var _time = -_choice.hours_cost - (8 * _choice.days_cost);
    var _verification = (-3 * _choice.drc_change)
        - (2 * _choice.risk_change) + _choice.dfm_change;
    var _assembly = (3 * _choice.dfa_change) + _choice.dfm_change;
    var _fabrication = (3 * _choice.dfm_change)
        - (2 * _choice.drc_change) - _choice.risk_change;
    var _test = 4 * _choice.dft_change - _choice.risk_change;
    var _stress = 3 * _choice.sanity_change;

    switch (_profile.focus)
    {
        case "speed":
            return (5 * _time) + _stress;

        case "stress":
            return (4 * _stress) + _time;

        case "assembly":
            return (4 * _assembly) + _verification;

        case "fabrication":
            return (4 * _fabrication) + _time;

        case "test":
            return (4 * _test) + _verification;

        default:
            return (4 * _verification) + _test;
    }
}

// Find the best original option for the coworker's focus.
// NEVER score advice options added by another consultation.
function advice_choose_source_index(_encounter, _base_count, _profile)
{
    if (!is_struct(_encounter)
    || !is_array(_encounter.choices)
    || _base_count < 1
    || array_length(_encounter.choices) < _base_count)
    {
        return -1;
    }

    var _best_index = -1;
    var _best_score = -1000000000;

    for (var _i = 0; _i < _base_count; _i++)
    {
        var _candidate = _encounter.choices[_i];
        if (!is_struct(_candidate))
        {
            continue;
        }

        var _score = advice_score_source_choice(_candidate, _profile);
        if (_best_index < 0 || _score > _best_score)
        {
            _best_score = _score;
            _best_index = _i;
        }
    }

    return _best_index;
}

// Apply ONE small bonus to a cloned option. The original option is untouched.
// Return exact text to explain what the player receives.
function advice_apply_profile_bonus(_choice, _profile)
{
    switch (_profile.bonus_field)
    {
        case "hours_cost":
            if (_choice.hours_cost > 0)
            {
                _choice.hours_cost = max(0, _choice.hours_cost - 1);
                return "Decision costs 1 fewer engineering hour";
            }

            // A zero-hour original choice cannot become negative.
            _choice.sanity_change += 1;
            return "Sanity +1 (original decision costs 0 hours)";

        case "drc_change":
            _choice.drc_change -= 1;
            return "DRC violations -1 (DFM follows existing calculation)";

        case "risk_change":
            _choice.risk_change -= 1;
            return "Manufacturing risk -1 (DFM follows existing calculation)";

        case "dfa_change":
            _choice.dfa_change += 1;
            return "DFA +1";

        case "dfm_change":
            _choice.dfm_change += 1;
            return "DFM +1";

        case "dft_change":
            _choice.dft_change += 1;
            return "DFT +1";

        case "sanity_change":
            _choice.sanity_change += 2;
            return "Sanity +2";
    }

    return "No additional engineering change";
}
