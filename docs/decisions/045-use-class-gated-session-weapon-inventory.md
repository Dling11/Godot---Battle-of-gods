# Decision 045: Use a Class-Gated Session Weapon Inventory

- **Date:** 2026-07-18
- **Status:** Accepted

## Context

Opaw needs to buy a second beginner sword, retain both weapons, and switch the live detached weapon from the character inventory. The planned roster separates character identity from Warrior, Mage, and Archer classes, so shared ownership must not allow a character to equip every stored weapon. Skills follow a different rule: level creates eligibility and Eira awakens them for free; shops must never sell them.

Disk-profile structure, armor aggregation, drops, and selling are not approved. Implementing those together would overstate the current save and balance design.

## Alternatives Considered

- Keep the Gear page read-only and delay all weapon ownership.
- Store the equipped sword directly on each scene-local Player.
- Let the shop auto-equip every purchase.
- Duplicate Opaw's body animation for each sword grade.
- Build a complete disk profile, general item inventory, armor stats, drops, and skill shop together.
- Add narrow application-session weapon ownership with explicit class-gated equip commands.

## Decision

`WeaponInventory` owns application-session weapon IDs and the equipped weapon ID per playable character. Every character has an authored `WeaponCatalogDefinition` and one permanent default weapon. Opaw always owns Ashwood Blade; starting a new journey restores Ashwood-only ownership. Weapon state survives scene replacement and defeat reload during that journey but is lost when the application closes.

`EquipmentDefinition` owns item identity, presentation, price, compatible class IDs, and its link to one authoritative `WeaponDefinition`. `Player.equip_owned_weapon()` validates catalog membership, ownership, and class compatibility before synchronizing `MeleeAttackComponent` and `PlayerWeaponVisual` through the idle-only weapon seam. Shared storage may contain another class's weapon, but Warrior Opaw cannot equip it.

Orren sells Iron Sword for 18 run coins. `PlayerProgressionComponent` owns coin deduction, `WeaponInventory` commits ownership, and the shop only requests and presents the transaction. Purchases never auto-equip and there is no selling. Ashwood and Iron reuse Balanced Slash plus the same weaponless Opaw body animation; their weapon data may differ in art, damage, knockback, grip, and timing.

Skills are not equipment and are never sold. Future skills become level-eligible and require a free Eira awakening before use; its ritual presentation is a separate feature.

## Consequences

- Bought weapons and equipped choice survive portal/scene and defeat replacement within the active journey.
- Begin the Awakening clears purchases and restores Ashwood as the safe fallback.
- Closing the game still loses ownership because no disk save exists.
- UI cannot directly edit ownership, coins, damage, or the live weapon.
- Future Mage/Archer items can share storage without bypassing class validation.
- Sword grades reuse Opaw's body/style assets instead of multiplying animation sheets.
- Armor, drops, selling, disk persistence, character switching, and Eira awakening remain separate work.
