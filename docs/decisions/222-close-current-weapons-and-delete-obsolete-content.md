# 222 - Close current weapon artwork and delete obsolete content

Source retention/build-tool policy is superseded by Decision223 at the owner’s clarification. Historical verification below describes the earlier cleanup.

Status: implemented, 2026-10-16. The owner provisionally settles the five current weapons and requests cleanup before committing.

## Context

Superseded Twinsteel gait/actions, axe experiments, Reaper previews and Greatsword concepts accumulated after Decision197. Older generators still referenced those experiments, while the current game used the accepted complete actors. Folder suffixes alone cannot establish whether an asset is obsolete.

## Decision

Delete retired trials and their exclusive tools, unused presentation variants, unused runtime frames/icons and obsolete Bag concepts. Do not create a replacement archive. Preserve current complete actors, palette, proportions, audio, collision, contacts, timing and acquisition rules. Keep legacy Sword/Spellward frames used by skills, reactions and Varkuun.

Use canonical royal_greatsword and twinsteel family directories and canonical Greatsword/Twinsteel swing, test and launcher names. The stable saved item ID weapon_king_royal_greatsword_v2 and the old Greatsword migration remain unchanged. Rename the frozen reference directory baseline; its ten complete body PNG hashes remain immutable. Its old paired reference texture is retained beside the reference resources, with no retired weapon route.

The current Reaper builder directly owns approved style actions and the three approved running boards. Extract only shared raster registration helpers into king_raster_baker.gd; remove inherited preview/rejected-action build routes. The axe uses the same small helper without depending on Reaper previews. Current Node builders retain their actual current inputs. Keep complete actors intact; no anatomical transplantation or new generation is part of cleanup.

## Alternatives

Keeping every v1/v2 folder preserves rejected routes and storage growth. Deleting everything with a version suffix breaks save IDs, active content and frozen references. Keep only verified dependencies, with canonical current names where safe.

## Consequences and verification

Production rasters/audio must match the pre-cleanup SHA256s. Resource text changes are limited to routing and names. Refresh preservation manifests after verifying those changes; deleted records cannot keep retired files alive. art_source/production-assets.json records the canonical production baseline. Existing source-ownership/anatomy/contact/phase tests remain required.

Run fresh import, all-resource loading, immutable-body checks, current builders, native family/gameplay/save regressions and a fresh playable source-copy import/launch. Record exact results and storage savings in docs/maintenance/repository-cleanup.md. Keep fixture teardown warnings separate from assertions, and desktop samples separate from phone/stress certification. Do not stop the user's Godot editor to prune ignored cache. No commit or push is authorized by this request.
