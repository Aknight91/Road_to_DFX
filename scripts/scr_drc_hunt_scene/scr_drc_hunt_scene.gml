/// @description DRC Hunting - prototype PCB scene data

// One source of truth for PCB geometry.
// For Step 65 Part 1, rendering reads the board and traces.
// Movement and respawn boundaries will be connected in later steps.
function drc_hunt_create_scene()
{
    return {
        name: "Prototype PCB",

        // The visible PCB and the clickable hunting area.
        board: {
            x1: 60,
            y1: 115,
            x2: 900,
            y2: 425
        },

        // Target center boundaries shared by movement.
        movement_bounds: {
            x1: 90,
            y1: 170,
            x2: 870,
            y2: 355
        },

        // Hide/reappear area shared by movement.
        reappear_bounds: {
            x1: 110,
            y1: 185,
            x2: 850,
            y2: 340
        },

        // Starting positions and velocities for this PCB scene.
        // Targets still start as active, scurrying bowties.
        spawns: [
            { x: 210, y: 220, dx: 1.8, dy: 1.2 },
            { x: 470, y: 310, dx: -2.1, dy: 1.4 },
            { x: 730, y: 190, dx: 1.6, dy: -1.1 }
        ],

        // Four independent copper nets with 45-degree bends.
        // Kept separate to avoid a central hooked/cross-shaped motif.
        traces: [
            // Upper-left route
            { x1: 110, y1: 180, x2: 250, y2: 180 },
            { x1: 250, y1: 180, x2: 295, y2: 225 },
            { x1: 295, y1: 225, x2: 435, y2: 225 },

            // Upper-right route
            { x1: 520, y1: 185, x2: 680, y2: 185 },
            { x1: 680, y1: 185, x2: 740, y2: 245 },
            { x1: 740, y1: 245, x2: 850, y2: 245 },

            // Lower-left route
            { x1: 110, y1: 350, x2: 260, y2: 350 },
            { x1: 260, y1: 350, x2: 315, y2: 295 },
            { x1: 315, y1: 295, x2: 440, y2: 295 },

            // Lower-right route
            { x1: 525, y1: 340, x2: 645, y2: 340 },
            { x1: 645, y1: 340, x2: 710, y2: 275 },
            { x1: 710, y1: 275, x2: 850, y2: 275 }
        ]
    };
}
