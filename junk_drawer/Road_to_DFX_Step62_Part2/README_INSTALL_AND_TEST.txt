ROAD TO DFX - STEP 62 PART 2 - SCALABLE PLACEMENT EVENT PACKS

These scripts were based on GitHub main commit d4d1747fded9d4bc9bdc1d6ba7b787b41036b7ba.

GameMaker Asset Browser installation (make all edits IN GameMaker):

1. Create a new Script asset named scr_event_pack_tools.
   Paste the entire contents of scr_event_pack_tools.gml into it.

2. Create a new Script asset named scr_events_pcb_placement_pack_01.
   Paste the entire contents of scr_events_pcb_placement_pack_01.gml into it.

3. Open the EXISTING Script asset scr_event_library.
   Replace its contents with the provided scr_event_library.gml.

Do not replace or modify scr_events_pcb_placement, scr_events_pcb_design,
obj_game Create/Step, or scr_event_selector for this step.

Expected results after pressing F5:

EVENT PACK QA: Placement pack 01 count = 21 (PASS)
EVENT LIBRARY QA: Stage counts = 6/22/1/1/0
EVENT LIBRARY QA: Events=30 Choices=97 Errors=0
EVENT LIBRARY QA: PASS

The pack contains 20 new ordinary Placement encounters (PCB-0010 through
PCB-0029) and one mandatory Placement Review (PLC-REVIEW-001). Together with
PCB-0009, the Placement library has 22 events. Existing Setup/Routing/Review
events are unchanged.

Gameplay smoke test:
- Start a Medium campaign and press F8 in gameplay to enter the dynamic preview.
- Complete four Design Setup encounters; verify transition 0 -> 1.
- Verify several different Placement encounters and their choices.
- Verify PLC-REVIEW-001 appears as the FINAL Placement encounter, never early.
- Complete the Placement Review; verify transition 1 -> 2 (Routing).
- Existing routing remains incomplete, so prototype fallback later is expected.
- Verify PCB-0003 and PCB-0004 are never consecutive.
- Test restart and optionally a COW campaign to confirm no Placement exhaustion.

NOTES:
- Validation runs once at startup. It reports structural mistakes in the
  registered library; it does not test every possible outcome or narrative.
- Event values and consequence flags are provisional; flagged follow-up
  events are still future work.
- GameMaker compilation and in-game testing have NOT been run in this container.
