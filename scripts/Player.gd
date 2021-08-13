extends Area2D


signal game_over

export (AudioStream) var run_sound
export (Array, AudioStream) var jump_sounds
export (Array, AudioStream) var slide_sounds

var to_jump = false
var to_slide = false
var to_fall = false
var to_rise = false


func _process(delta):
	
	if not get_parent().playing:
		return
	
	# move player to right
	position.x += delta * get_parent().speed
	
	# basic moves
	if Input.is_action_just_pressed("jump"):
			queue_jump()
	elif Input.is_action_just_pressed("slide"):
			queue_slide()
	
	# cancel move
	if Input.is_action_just_released("jump"):
		queue_fall()
	elif Input.is_action_just_released("slide"):
		queue_rise()
	
	# only while running...
	if $AnimationPlayer.current_animation == "run":
		
		# jumping and sliding
		if to_jump:
			jump()
		elif to_slide:
			slide()


func run():
	to_fall = false
	to_rise = false
	
	$AnimationPlayer.play("run", -1, get_anim_playback_speed())


func queue_jump():
	to_jump = true


func queue_fall():
	if $AnimationPlayer.current_animation == "jump":
		to_fall = true
	elif $AnimationPlayer.current_animation == "":
		fall()


func queue_slide():
	to_slide = true


func queue_rise():
	if $AnimationPlayer.current_animation == "slide":
		to_rise = true
	elif $AnimationPlayer.current_animation == "":
		rise()


func jump():
	to_jump = false
	
	$AnimationPlayer.play("jump")
	
	$VoiceAudio.stream = jump_sounds[randi() % jump_sounds.size()]
	$VoiceAudio.play()
	
	$JumpTimer.start()


func slide():
	to_slide = false
	
	$AnimationPlayer.play("slide")
	
	$VoiceAudio.stream = slide_sounds[randi() % slide_sounds.size()]
	$VoiceAudio.play()
	
	$SlideTimer.start()


func fall():
	$AnimationPlayer.play("fall")
	$JumpTimer.stop()


func rise():
	$AnimationPlayer.play("rise")
	$SlideTimer.stop()


func _on_AnimationPlayer_animation_finished(anim_name):
	if not get_parent().playing:
		return
	
	if anim_name == "fall" or anim_name == "rise":
		run()
	elif anim_name == "jump" and to_fall:
		fall()
		to_jump = false
		to_slide = false
	elif anim_name == "slide" and to_rise:
		rise()
		to_jump = false
		to_slide = false


func _on_Player_area_entered(area):
	
	# if Area2D entered by a collider w/obstacle group/tag, game over
	if area.get_groups().find("obstacle") > -1:
		emit_signal("game_over")
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.play("die")


func get_anim_playback_speed():
	return 1 + ((get_parent().speed / get_parent().initial_speed) / 10)
