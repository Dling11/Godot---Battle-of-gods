# Recorded weapon contact source

Original source: [Impact](https://opengameart.org/content/impact) by Iwan “qubodup” Gabovitch, CC0, verified/downloaded2026-10-06. Source page retained as source_page.html. Attachment qubodupImpact.7z SHA25698D72B55D6F78A32072439ED4D052FC43FDD80B8B409D18A9BB3150FC2CCD97B. Both upstream Freesound entries linked by the author also currently publish CC0.

The original shared three-contact layer uses Meat01/Meat02. Later family-owned axe/scythe mixes also use wood/stone; Greatsword215 additionally uses recorded Metal with body/wood/stone. See ../greatsword_heavy_2026_10_15/manifest.json and assets/audio/ATTRIBUTION.md for current processing. The full extracted pack/FLAC stays source provenance under.gdignore, outside runtime imports.

Rebuild with Godot --headless --audio-driver Dummy --path . --script res://tools/build_weapon_contact_audio.gd. This offline tool decodes stereo, trims near silence, converts mono, blends a third variant40/60, normalizes peak to-4dBFS and fades the tail. Runtime uses the three WAV files and weapon-owned pitch/gain; no runtime synthesis. Source durations, processing and hashes are in the review audio_manifest.json.

synthetic_prototype contains the initial original JS/noise prototype and three WAVs; it was superseded when the owner authorized web recordings. Its builder is deliberately absent from live tools. It is archived provenance, not runtime dependency.
