# Iron Reaper — Hook and Reap

Implemented 2026-10-14 (Decisions204–205). This former proposal describes current rules; code/resources are authority. See king-iron-reaper.md for current art and returning-weapon timing.

The return hook (cut2) pulls Light enemies toward King up to24 world pixels, stopping28px from his position. A decaying collision-aware impulse performs the movement; no position teleport is used. Heavy/Elite/Boss tiers retain their ordinary outward knockback/resistance and are not pulled. Blocked, immune or fully absorbed damage does not move a target.

The final reap (cut4) deals25% more ordinary Physical damage when the target's pre-hit HP is strictly below40% maximum. At exactly40% there is no bonus. Critical scaling and defenses still apply. Bosses can receive this bonus but cannot be automatically executed. The rule is basic-cut-only, never a passive multiplier on King's techniques.

Cut3 throws its center124px with50px hurt radius, pauses while spinning, then recalls. Each target takes at most one65% share outward/while lingering and one35% share on recall. The0.96s active window splits30% outward,40% stationary spin,30% return, all scaled by attack speed. Terrain shortens outward travel; recall follows King and cannot strand the weapon.

Basic roll10–12; multipliers1/1/1.2/1.8; clocks0.55/0.55/1.36/0.66s. Chain3.12s and17.6 base DPS if both throw legs connect. Front130px, final136px. Knockback40 with0.5/0.4/0.8/1.6 multipliers. Windup/contact/recovery movement ratios0.4/0/0.65; steps4/3/−3/6px remain collision bounded.

Its role is distance and gathering, with lower nominal single-target DPS than Twinsteel or Greatsword. F9/Weapons/Bag support real equipment; earned recipe/drop acquisition and final campaign balance remain follow-up work.
