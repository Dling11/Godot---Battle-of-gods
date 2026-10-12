# Sovereign Pursuit: trained range and stored uses

**Current terrain/aim correction (2026-10-03,Decision177):** Slot1/5 keep full authored reach through scenery; Slot3 flies over any intervening obstacle to clear, real-foot/nav/bounds-valid ground. Silver/slate/violet circles and hardware pointers replace gold/blue targeting and use actor feet/render-frame aim. This supersedes earlier terrain-aware/clipped or LOS-stopped descriptions below. Current rule/validation: king-targeting-and-terrain.md.

Status: implemented 2026-09-27 (Decision 158). Owner combat feel and representative-phone performance remain to be reviewed.

Pursuit is King's separately aimed, aggressive movement skill. Each confirmed cast consumes one stored use, performs one collision-safe leap and resolves one compact landing hit. Its current blade-cut travel/landing frames are reused at all ranks so the actor identity and contact timing stay consistent.

| Rank | Maximum aim range | Stored uses | Training requirement |
| --- | ---: | ---: | --- |
| Foundation | 220px | 1 | Starting form |
| Advanced | 250px | 2 | Speak to Eira at Level 5 |
| Mature | 280px | 3 | Speak to Eira at Level 8 |

The existing level cap means Level 5 requires enough progression beyond Stage II; Level 8 requires the Stage V cap increase. Eira's Technique Collection performs the manual upgrade and saves the rank. The normal Tab menu shows the next requirement but cannot grant it. F7 can preview all three ranks without saving. Older profiles load at Foundation. A new player scene restores the saved rank; individual charge stock is session-local and starts full on scene entry.

One use refills every **8.5 seconds, sequentially**. Spending another use does not restart a refill already in progress. Empty Mature stock takes 25.5 seconds to become full. The HUD shows available/maximum uses and a small next-use refill bar. F9's unlimited-skill helper fills all uses for its non-saving debug session.

The .14-second windup, .28-second collision-safe travel, .24-second recovery, 52px landing radius and 125% weapon hit remain per cast. Travel-only invulnerability never covers the interval between uses. Rejected casts and canceled targeting spend nothing; an accepted cast spends exactly one use, even if interrupted afterward. Multiple landings can each hit, but their Pursuit-to-Molten Crash combo window refreshes rather than stacking. Existing Resolve, mastery, equipment, input buffering and ten-slot rules still apply.

Remaining review: test three-use boss burst, enemy pressure between leaps, any-obstacle flight and safe landing, Eira discoverability, actual level pacing, HUD legibility and representative-phone frame time. Range and recharge values are owner-approved starting values and can be tuned from combat measurements.
