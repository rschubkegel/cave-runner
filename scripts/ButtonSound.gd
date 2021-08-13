extends Button


export (AudioStream) var click_sound
export (AudioStream) var focus_sound


func on_click():
	instantiate_sound(click_sound)


func on_focus():
	instantiate_sound(focus_sound)


func on_hover():
	if not has_focus():
		instantiate_sound(focus_sound)


func instantiate_sound(stream):
	var sound = AudioStreamPlayer.new()
	sound.stream = stream
	sound.bus = "SFX"
	sound.connect("finished", sound, "queue_free")
	get_tree().root.add_child(sound)
	
	sound.play()
