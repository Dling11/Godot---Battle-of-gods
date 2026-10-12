# 157 - Promote the reviewed King kit and retire old skill variants

Date: 2026-09-26. Status: implemented in the production Player and Combat Lab; campaign form unlocks and Skill 4 redesign remain open.

## Context

The campaign still loaded the older King body, Echoing Sever, Riftbreak and Pursuit ground art while the accepted King C body and newer Skills 1-3 required separate Lab toggles. The four extra Oath techniques were also equippable, making the kit difficult to understand. The owner explicitly requested the latest character and a single clean skill set, and chose to retire all four Oath techniques.

## Decision

`player.tscn` now loads the approved King C body and outline from `assets/characters/playable/king/spellward/`, the production `king_spellward_animation.gd`, Earthsplitter Foundation on 1, blue Molten Crash Foundation on 2, and the blade-cut Sovereign Pursuit art on 3. Skill 4 remains the current Worldsplitter placeholder until its next design pass. King's physical scale, collisions, ten input slots, equipment speed, mastery and targeting authority are preserved. The character menu paper doll uses the same current body.

F7 now shows the active kit directly. It can cycle Skill 1 Foundation/Fan/Cascade and Skill 2 Foundation/Advanced/Awakened/Mature **for session-only testing**; it no longer swaps to old Echoing Sever, Riftbreak, targeted Riftbreak, old Pursuit art or the previous King body. Campaign starts at both Foundation forms; stage unlock and persistence for later forms are not introduced by this cleanup. Pursuit's proposed multi-charge progression also remains unimplemented.

The four Oath techniques, their riposte, old visual observers, obsolete comparison adapters, older sprite atlases, old-specific tests and builders are removed from live scenes and moved to `art_source/archive/king_retired_2026_09_26/`. This folder is beneath `art_source/.gdignore`, so Godot does not import those files. Stable internal IDs `echoing_sever` and `riftbreak` remain for the first two slots because existing saves and combat links use them; display names and gameplay are Earthsplitter and Molten Crash. `KingSkillCatalog` accepts old Oath IDs only while reading a save and maps them by slot family to the four current IDs, discarding collisions. The next profile save writes the normalized slots. Historical story flags remain harmless data and cannot equip an archived skill.

The legacy-named `EchoingSeverComponent` and `RiftbreakComponent` files remain live as base classes used by Earthsplitter and Molten Crash; they are not extra equippable skills. The generic directional targeting helper likewise remains player infrastructure even though no current King skill uses its former wedge presentation. The obsolete alternate Pursuit effect and greatsword trail switches were removed from production presenters.

## Consequences and verification

The new default content is visible in normal stages, Sanctuary, the character menu and Combat Lab. The live kit has four learned techniques in a ten-slot collection; Skill 4 can be redesigned next without reopening Skills 1-3. `king_production_kit_smoke.gd` covers body/resource wiring, Lab form switching, two live casts and old-save normalization. Character menu, short input-buffer, F9 cooldown, Worldsplitter and Stage V boss checks pass. Godot 4.7 editor import, main scene and Lab launch pass. Owner combat feel, campaign upgrade gates, phone performance and final Skill 4 art are still open. No commit or push was made.
