# Continue weapons

2026-10-13. Read PROJECT_CONTEXT.md, ROADMAP.md, KNOWN_ISSUES.md and current weapon guides first. Old archives, review recordings, prototype frames/builders and dated comparison fixtures are intentionally removed. Decision 197 owns cleanup; older evidence is in Git history.

Current equipment: signature Sword, Iron Beard, Royal Greatsword V2, Twinsteel V2. Save/catalog IDs and gameplay tuning are unchanged. Greatsword's four-cut heavy sequence, steel, body motion and idle are owner-approved. Axe retains chop → rise → head thrust → jump slam → spin. Twinsteel retains five-cut diagonal → return → rising cross → hop spin → crossing finish and proud planted/folded/slow-glance rest.

Twinsteel walking is the current review candidate: assets/characters/playable/king/shared_bodies/dual_carry_v3. Fixed complete approved upper anatomy, canonical side legs/new front-back steps, matching ready/run blades and actual travel-driven cycling. Do not select removed gait_v2/prototype families. Frozen body-library/v1, current contacts and native 0.5 scale remain protected.

Rebuild only current carry with tools/build_king_twinsteel_carry.gd; keep its generated gait source, registration and native helper. Other approved families have no active legacy regeneration chain. Edit/currently regenerate them as a separately reviewed complete pose version, not by restoring old scripts.

Test F5 → F9 → F7 → Weapons → selected family. WASD, held LMB, Space, Tab and Escape are normal controls. Direct non-saving launchers exist for axe/Greatsword/Twinsteel; pass -GodotPath on another PC. Maintained anatomy, real-input gait, family gameplay, idle, roles and save-migration tests write to tmp/review/.

Next: owner review of Twinsteel; then Iron Reaper design/motion before equipment promotion. Campaign unlock/crafting rules, balance and phone profiling remain separate. Scythe implementation is outside this cleanup. The owner subsequently authorized logical cleanup commits and an ordinary push to the existing repository on 2026-10-13.
