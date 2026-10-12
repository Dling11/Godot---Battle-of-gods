# Decision 188: Greatsword impact closure and retirement

Status: implemented 2026-10-07; owner sound/role review remains open. Scythe is preview-only pending design selection.

The owner approves the completed Greatsword V2, authorizes weightier normal hits/a stronger jump hit and real-enemy comparisons, and explicitly requests removal of V1. The earlier original/new comparison requirement in Decisions 186/187 is therefore superseded.

Keep the approved V2 art, combo and gameplay tuning as the sole selectable Royal Greatsword, retaining its V2 save ID. Archive retired definitions/family/obsolete tests instead of deleting shared steel, carry/gait/proud-idle/plant assets. Migrate old ownership and equipped references together for both supported snapshot versions; preserve strict validation of other unknown/unowned IDs and avoid campaign grants. No schema bump or direct player-save writes are necessary.

Select normal/finisher contact audio through optional per-step data with existing fallbacks and the first-contact-per-swing presenter. Reuse retained licensed recordings and offline PCM mixing; no runtime DSP, per-target audio multiplication or animation edits. Compare authentic enemy damage/control and separate moving-horde frame samples before changing balance. Current desktop samples do not establish phone/export/cold campaign performance.

Alternatives: removing V1 without migration rejects supported saves; retaining the old selectable item contradicts the owner's request; deleting shared art breaks accepted V2 idle/gait; hardcoding a Greatsword check in the feedback presenter couples sound to item identity; retuning damage from a short high-HP crowd sample overstates its evidence.

The owner rejects the first scythe board because its silhouettes are too similar. Provide separate iron-hook, crescent-moon and double-ended design concepts, and wait for a chosen design before creating motion/equipment. No scythe content is implemented by this decision.

[Current rules, evidence, archives and concepts](../design/weapon-impact-closure.md).
