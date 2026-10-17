extends RefCounted

## World-space layout. Source-cell dimensions never define actor world height.
const NPC_SCALE := Vector2(.5,.5)
const MENTOR := Vector2(368,80)
const MENTOR_APPROACH := Vector2(368,116)
const PAVILION := Vector2(256,16)
const GATE := Vector2(864,128)
const GATE_APPROACH := Vector2(864,176)
const GROUND_CELLS := Vector2i(36,28)
const TOP_ROW := -4
const MOVEMENT_BOUNDS := Rect2(56,-72,1040,784)
const CAMERA_TOP := -128
const COURT_PAVING := Rect2(160,48,224,144)
const GATE_PAVING := Rect2(768,128,192,64)
const TRIAL_FLOOR := Rect2(160,40,256,152)
const TRIAL_START := Vector2(248,104)
const POSTS := [Vector2(192,88),Vector2(248,56),Vector2(304,88),Vector2(248,144)]
const MENTOR_ROUTE := [Vector2(576,320),Vector2(496,272),Vector2(464,208),Vector2(400,160),MENTOR_APPROACH]
const GATE_ROUTE := [Vector2(576,320),Vector2(672,272),Vector2(704,208),Vector2(752,176),GATE_APPROACH]
