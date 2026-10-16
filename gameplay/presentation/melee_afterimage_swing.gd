extends "res://gameplay/presentation/registered_melee_ribbons.gd"

## Generated complete strokes follow authoritative contact. No damage here.
func _phase(phase: int,duration: float) -> void:
	if phase==MeleeAttackComponent.Phase.RECOVERY and is_instance_valid(slash_sprite) and slash_sprite.visible:
		if _tween!=null and _tween.is_valid(): _tween.kill()
		# Four residual afterimage keys finish the cut; collision authority has
		# already ended. A new windup/cancel always clears this short tail.
		_tween=create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		_tween.tween_method(_set_frame,8.0,11.999,minf(.06,duration*.6))
		_tween.tween_callback(slash_sprite.hide)
		return
	clear()
	if phase!=MeleeAttackComponent.Phase.ACTIVE or not _prepare_contact_shape(): return
	_row = clampi(_attack.combo_step,0,4)
	var actor := _attack.owner as Node2D
	_contact_origin = actor.to_local(_attack.collision_shape.global_position)
	_configure_contact_mask()
	_set_frame(0)
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_frame,0.0,7.999,maxf(duration,.0001))
	# Hold the contact endpoint to the phase boundary, then play the separate
	# visual tail. More drawings do not add extra hit ticks or duplicate damage.

func _set_frame(value: float) -> void:
	_frame=clampi(int(value),0,11)
	if not is_instance_valid(slash_sprite): return
	(slash_sprite.texture as AtlasTexture).region=Rect2(_frame*256,_row*256,256,256)
	slash_sprite.transform=layout.for_attack(_attack.get_attack_direction(),_row)
	slash_sprite.position+=_contact_origin
	contact_mask.set_shader_parameter("actor_origin",slash_sprite.transform.origin)
	contact_mask.set_shader_parameter("actor_axis_x",slash_sprite.transform.x)
	contact_mask.set_shader_parameter("actor_axis_y",slash_sprite.transform.y)
	slash_sprite.modulate.a=.9 if _frame<8 else lerpf(.8,.6,(_frame-8)/3.0)
	slash_sprite.show()
