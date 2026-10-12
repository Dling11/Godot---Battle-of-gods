# Character Animation Pixel Contract

**King current authority (Decision195):** [Complete-body reuse and verification](king-shared-body-library.md). body_library/v1 owns whole standing/walking poses with exact hashes. All four families share eight-frame gait bodies; player.tscn and Bag select shared_bodies/sword/frames.tres for locomotion, retaining legacy Spellward actions. Height/head-only tracing is insufficient. New action anatomy needs complete-pose native review and a separate reviewed version.

This contract applies to generated, downloaded, and hand-authored character animation before it becomes a runtime Godot asset.

## Runtime Cell Contracts

| Actor or effect | Runtime cell | Direction and frame contract |
|---|---:|---|
| King current Sword | 192x128, Body scene scale0.5 | player.tscn/Bag select shared_bodies/sword/frames.tres: complete canonical standing/walking body texels; historical Spellward action art stays |
| King simple reboot (historical) | 32x32 locomotion target | Historical turnaround/foot reference; not the active player sheet or a new equipment-family canvas requirement |
| King equipment families | 192x128, four columns, presentation scale0.5 | Sole94, native upright54–57texels; immutable complete body_library/v1 poses and full turnaround/gait board. All four weapons share exact walking bodies; steel remains separate. Height/head alone cannot certify torso size |
| Small forest creatures | 32x32 | Fixed scale and foot baseline across all direction rows |
| Existing extended enemy attacks | 64x48 | Use only when a validated action cannot fit the locomotion cell |
| Examiner locomotion/idle | `192x128` debug cell | Six-column source with two idle plus four walk poses across `down/left/right/up`; compact-pixel V3 style, `0.42` scale, `y=120` cell baseline, and `-56 px` visual origin are the current F7 proof values |
| Examiner extended weapon actions | `192x128` debug cell | Separate thrust, sweep, Zero Interval, Refutation, and reaction/withdrawal sheets preserve the same scale; Axiom composes accepted body poses while its lane energy remains a synchronized secondary layer |
| Executioner future locomotion/idle | Unset; documentation only | Show only in the preview concept as larger/broader than the Examiner; no direction grid, runtime cell, or generation until separately approved |
| Rootbound Husk walk | 72x64 | Four direction rows; contact A/pass A/contact B/pass B with leg exchange and arm counter-swing; 56-pixel actor scale |
| Rootbound Husk reaction | 64x64 | Four direction rows; 56-pixel upright target including antlers; 2-pixel foot margin |
| Rootbound Husk root-attack body | 96x64 | Six action columns; wider canvas preserves the 56-pixel actor scale |
| Rootbound Husk root-ground VFX | 128x64 | Effect-only cells aligned to the authoritative 112x20 forward lane |

Runtime PNG dimensions must equal `cell width * columns` by `cell height * rows`. Runtime sheets use nearest-neighbor scaling, binary alpha, no dithering, no smoothing, and no partially transparent edge residue.

## Source Board Requirements

- State the exact column count, row count, direction order, action order, intended runtime cell, and actor target height in every generation prompt or download review.
- Prefer source dimensions exactly divisible by the requested grid. A 6x4 board may use 1536x1024 for 256x256 source cells; a 4x4 board may use 1024x1024 for 256x256 source cells.
- Leave at least 12.5% of a source cell as clear safety margin around the actor. Long limbs, antlers, weapons, and collapse poses must not touch or cross an ideal cell boundary.
- Keep one character identity, palette, lighting direction, body proportion, pivot, and foot baseline across the complete board.
- For King and later visible-limbed characters, require readable shoulder-to-forearm-to-hand continuity and one stable hand-to-signature-weapon grip. Reject changing limb count/length, disconnected hands, changing weapon length, or a face/costume that drifts between actions.
- A straight blade is insufficient when its handle occupies a parallel or offset rail. For rigid simple weapons, preserve parallel blade edges, fixed blade/guard/grip dimensions, and one action-owned pivot across frames. King's simple reboot deliberately avoids detailed grip anatomy; its signature sword may use a controlled presentation layer, while body and weapon must still read as one coherent action at runtime.
- King's body identity authority is `art_source/generated/characters/playable/king/king_turnaround_direction_reference_approved.png`; the weapon design and approved attack-effect authority come from the two `greatsword_proofs`. Do not copy the turnaround proof's rejected up/back grip: a lowered sword-side hand makes the blade read as mounted on the back. The corrected rear pose requires a bent sword-side arm, visible hand on the hilt at shoulder height, guard outside the shoulder, cord at the pommel/grip, and only the off-hand hanging down.
- Prefer one exact-grid PNG per action family with canonical `down/left/right/up` direction rows and time across columns. Avoid both unwieldy one-row strips and giant atlases that combine unrelated idle, walk, attack, and skill actions.
- A runtime action sheet is valid only when it uses exact equal cells and its full dimensions are exact cell-count multiples. For example, four `64x64` frames across four direction rows require `256x256`; a visually organized generated review board is not a production sprite sheet.
- King's cardinal poses use a top-down three-quarter RPG perspective: down/up remain attack-lane readable with shallow shoulder/foot offsets, and side poses retain a small top plane. Reject pure front portrait staging, pure side-view platformer staging, or angle drift that makes the authoritative cardinal direction ambiguous.
- Do not request a complete production sheet before approving one four-direction turnaround and one short side attack strip at gameplay scale. Generate action-owned boards after that proof so a failed identity does not contaminate every action.
- For a bilaterally symmetrical actor, author one approved side cycle and derive the opposite direction by exact horizontal mirroring after normalization. Do not independently generate left and right when equipment or anatomy does not require asymmetry.
- Inspect feet separately from torso motion at nearest-neighbor scale. A four-frame walk must at least show contact, passing, opposite contact, and opposite passing; add recoil/reach frames only when they create real motion. Body sway alone does not count as a gait, and duplicated filler never satisfies a frame target.
- If a multi-frame generation repeats one stance, approve contact and passing poses individually and assemble the source board at one shared row scale. Do not simulate locomotion later by shifting or lifting otherwise unchanged feet.
- Do not include labels, grid lines, shadows, detached debris, neighboring fragments, alternate costumes, or attack VFX in a reusable body sheet.
- Generated output with indivisible dimensions is legacy input, not an approved runtime grid. The processor may recover it with rounded cell boundaries, but a new board should target an exact divisible size.

## Processing Guarantees

- For active King equipment, use the [frozen native identity reference](../../art_source/reference/characters/king/native_identity_v1/README.md) before generating or ingesting new art. Historical32px turnaround art is not the equipment-family sizing authority. A head provenance rectangle can contain transparent padding, shoulders or collar; never stretch visible hair/face to fill it.
- Register a whole motion lane from armor width and collar-to-sole distance once. Keep native head pixels unchanged; center X on the collar below the crown, not a moving boot. Raised arms require collar-relative detection. Record any traced socket for a source pose whose collar is genuinely hidden.
- Assign complete source ownership before raster registration. Transparent gutters suit separated guide boards; overlapping body-only boards require complete actor components. Preserve legitimate arms hidden by guide pixels and reject neighboring scarves/boots. Do not assume every generated sheet has the same extraction contract.
- Contact phase windows and release/queue windows belong to each pose resource. Mixed13/16-key clips are valid; neither the viewer nor playback may assume a single global pose count. Gameplay durations belong to combo data.
- Verify every visible grip on actual leather pixels, all head/body connections, native crown identity and atlas safety margins. Compare walking/ready/contact/rest at native scale and in the actual Player before promoting the profile. Technical checks do not establish owner feel approval.

- Derive one scale from the approved standing frame for each direction row and apply that scale unchanged across the row.
- Run containment/debris filtering before accepting the visible scale result. Every upright locomotion frame must still retain the actor's target visible height after filtering; a removed disconnected foot must not silently turn one frame into a smaller body.
- Recover actor pixels from a bounded overlap only when they remain connected to the intended actor.
- Keep the largest eight-connected actor component before and after downscaling so neighboring fragments and detached debris cannot enter runtime cells. An approved identity-owned detached element such as the Examiner's halo is the exception: preserve it only inside the actor-owned gutter crop and reject any unapproved neighbouring fragment.
- Preserve the ideal source-cell horizontal origin for extended attacks; center compact locomotion, reactions, and defeat frames.
- Align every frame to the authored foot margin and fail the build when any frame exceeds its runtime cell.
- Use a wider runtime cell or regenerate the source rather than shrinking one exceptional pose independently.
- Emit or validate per-frame occupied bounds, foot midpoint, body height, and weapon extent. Fail when a frame changes actor scale, jumps off the shared center/pivot, moves the foot baseline, disconnects the hand, or changes greatsword length outside the action's approved motion.
- Remove flat source backgrounds before downscaling, convert runtime edges to binary alpha, and reject any connected or isolated matte-color fringe. Review the result against a checkerboard, living grass, Rootbound lime terrain, and a dark floor so green/lime, magenta, blue, or dark source residue cannot hide.

## Godot Animation Ownership

- Recurring body states use named `SpriteFrames` on `AnimatedSprite2D` so animations remain previewable in the editor.
- Directional names follow `<action>_<direction>`, using `down`, `left`, `right`, and `up`.
- Animation and VFX observe controller signals. Controllers, hitboxes, hurtboxes, and attack profiles own gameplay timing, damage, and contact lanes.

## Review Checklist

1. Preview every named animation at 1x and the 960x540 gameplay scale.
2. Check the first and last frame of each animation for hand, antler, foot, weapon, and collapse clipping.
3. Check for isolated pixels at all four cell edges and beneath the foot baseline.
4. Confirm idle-to-action and action-to-recovery transitions retain body scale and origin.
5. Confirm visible VFX matches but does not define the authoritative contact lane.
6. Archive rejected source boards and superseded runtime derivatives outside Godot imports after active references are removed.
7. For branch, horn, or antler crowns, confirm the first occupied scanline tapers to deliberate tips rather than a broad flat crop.
8. For visible-limbed playable characters, inspect every attack contact frame for connected arms, stable hand choice, coherent grip, and a highlighted VFX edge/tip contained by the authoritative contact shape.
9. Inspect every transparent frame for source-background hue residue at 1x and enlarged nearest-neighbor scale; any lime/green or other matte fringe fails approval.
10. Compare occupied bounds and foot/pivot coordinates across the complete sheet before importing it into `SpriteFrames`.
11. For rigid weapons, extend the blade rails through the guard: the hand, grip, and pommel must remain inside the same rails, and automated builds should sample continuity where deterministic construction is available.
12. For a new playable identity, review one integrated direction/action sheet at a time. Do not multiply directions, split body/weapon art, or import `SpriteFrames` until the current sheet's character quality and weapon construction are explicitly accepted.
