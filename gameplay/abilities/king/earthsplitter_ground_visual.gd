extends Node2D

## Sequential upright ground eruptions. Presentation follows the damage front.
const Rupture = preload("res://assets/vfx/abilities/king/earthsplitter/rupture.png")
const Pressure = preload("res://assets/vfx/abilities/king/earthsplitter/pressure_v2.png")
const STAMP_SPACING := 18.0
var direction := Vector2.RIGHT
var radius := 17.0
var strength_scale := 1.0
var terminal_scale := 1.22
var aftermath_speed := 1.0
var _age := 0.0
var _end_age := -1.0
var _last := Vector2.ZERO
var _front_position := Vector2.ZERO
var _has_front := false
var _bursts: Array[Dictionary] = []

static func facing_for(vector: Vector2) -> Vector2i:
	var sector := posmod(roundi(vector.angle() / (PI*.25)),8)
	var rows := [0,3,1,3,0,4,2,4]
	return Vector2i(rows[sector], 1 if sector in [3,4,5] else 0)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	y_sort_enabled = true

func advance_front(point: Vector2) -> void:
	var local := to_local(point)
	_front_position = local
	if not _has_front:
		_has_front = true
		_last = local
		_erupt(local, 1.08)
	while _last.distance_to(local) >= STAMP_SPACING:
		_last += _last.direction_to(local) * STAMP_SPACING
		_erupt(_last, .94 + .08*sin(_bursts.size()*2.3))

func finish() -> void:
	if _end_age >= 0.0 or not _has_front:
		return
	_end_age = _age
	# Visual punctuation only. Reuse a nearby stamp to avoid stacked blasts.
	if not _bursts.is_empty() and _last.distance_to(_front_position) < STAMP_SPACING*.6:
		var last: Dictionary = _bursts.back()
		last.sprite.queue_free()
		last.flash.queue_free()
		_bursts.pop_back()
	_erupt(_front_position, terminal_scale)

func _erupt(point: Vector2, strength: float) -> void:
	strength *= strength_scale
	var rock := Sprite2D.new()
	rock.texture = Rupture
	rock.hframes = 4
	rock.vframes = 4
	rock.position = point
	rock.scale = Vector2.ONE * (radius*3.05/220.0) * strength
	# A centered eruption, with stones rising screen-up for every lane.
	rock.flip_h = _bursts.size()%2 == 1
	rock.z_index = 0
	add_child(rock)
	var flash := Sprite2D.new()
	var facing := facing_for(direction)
	flash.texture = Pressure
	flash.hframes = 8
	flash.vframes = 5
	flash.frame_coords = Vector2i(0,facing.x)
	flash.flip_h = facing.y == 1
	flash.position = point
	flash.scale = Vector2.ONE * (radius*2.7/200.0) * strength
	flash.z_index = rock.z_index+1
	add_child(flash)
	_bursts.append({"point":point, "born":_age, "sprite":rock, "flash":flash, "strength":strength})
	queue_redraw()

func _physics_process(delta: float) -> void:
	_age += delta
	for burst in _bursts:
		var elapsed: float = (_age-burst.born)*aftermath_speed
		var rock: Sprite2D = burst.sprite
		var flash: Sprite2D = burst.flash
		# Accelerate into the broken-stone crest, then allow time for settling.
		rock.frame = mini(15, int(elapsed/.022) if elapsed<.11 else 5+int((elapsed-.11)/.035))
		rock.modulate.a = clampf(1.0-maxf(0.0,elapsed-.38)/.20,0.0,1.0)
		flash.frame_coords.x = mini(7,int(elapsed/.027))
		flash.modulate.a = clampf(1.0-maxf(0.0,elapsed-.07)/.15,0.0,1.0)
	queue_redraw()

func _draw() -> void:
	for index in _bursts.size():
		var burst: Dictionary = _bursts[index]
		var elapsed: float = (_age-burst.born)*aftermath_speed
		var point: Vector2 = burst.point
		var strength: float = burst.strength
		if elapsed > .55:
			continue
		var alpha := clampf(1.0-maxf(0.0,elapsed-.16)/.39,0.0,1.0)
		# Connect the flat broken floor independently of the upright stone art.
		# This keeps vertical lanes from reading as separated horizontal steps.
		if index > 0:
			var previous: Vector2 = _bursts[index-1].point
			var side := direction.orthogonal()
			var width := radius*(.5+.12*sin(index*2.2))
			var middle := (previous+point)*.5
			var floor_shape := PackedVector2Array([previous+side*width,middle+side*(width+2.0),point+side*width,point-side*width,middle-side*(width+2.0),previous-side*width])
			draw_colored_polygon(floor_shape,Color(.19,.27,.34,alpha*.78))
			draw_line(middle-side*width,middle+side*(width*.7)+direction*4.0,Color(.51,.78,.9,alpha*.5),1.0)
		# Brief fractured floor pressure; no traveling crescent or laser line.
		if elapsed < .19:
			var progress := clampf(elapsed/.19,0.0,1.0)
			for spoke in 9:
				var angle := TAU*float(spoke)/9.0 + .21*index
				var ray := Vector2(cos(angle),sin(angle)*.48)
				var reach := (9.0+progress*21.0)*strength
				var tangent := Vector2(-sin(angle),cos(angle)*.48)
				var a := point+ray*reach
				var b := point+ray*(reach-7.0*(1.0-progress))
				var width := (1.0-progress)*2.8
				draw_colored_polygon(PackedVector2Array([a,b+tangent*width,b-tangent*width]),Color(.7,.91,1.0,(1.0-progress)*.9))
		# Screen-down gravity keeps the stone chips upright in every direction.
		for chip_index in 5:
			var launch := Vector2((chip_index-2)*24.0,-48.0-float((index+chip_index)%3)*14.0)*strength
			var chip := point+launch*elapsed+Vector2(0,125.0*elapsed*elapsed)
			var size := 2.0 if chip_index%2==0 else 3.0
			draw_rect(Rect2(chip.round(),Vector2(size,size)),Color(.46,.60,.72,alpha))
			if elapsed < .16:
				draw_line(chip,chip-launch.normalized()*4.0,Color(.85,.95,1.0,alpha),1.0)
