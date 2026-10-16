# King complete-body library v1

Immutable approved complete body atlases, copied from the live accepted Greatsword and relaxed dual presentation on2026-10-11. Source paths and body PNG SHA256s are recorded in `contract.json`. The matching resources retain camera-specific head/palm provenance for offline registration. Whole poses own the head, torso, scarf, connected arms and boots together.

192×128 cells; four columns; scale0.5; visual position(0,-16); sole source pixel94. All four weapon families share these exact walking bodies. New equipment must reuse them, never resize the body to fit the blade. Different relaxed/planted/crouched actions may use another reviewed complete pose.

The special `side_axe_ready_body.png` repeats `side_relaxed` cel0 through ready keys0–3 and retains the complete existing folded-rest keys4–7. It adds no new anatomy. Its checksum is also frozen.

Run `tools/check_king_body.gd` and `tests/king_shared_body_smoke.gd` before promotion. Changed bodies require a reviewed new version, not edited checksums. [Full pipeline, source board and limitations](../../../../../../docs/design/king-shared-body-library.md).
