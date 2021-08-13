extends TextureButton


var is_pressed
var on_texture
var highlight_texture
var off_texture

export (AudioStream) var click_sound
export (AudioStream) var focus_sound


func _ready():
	is_pressed = false
	on_texture = texture_normal
	highlight_texture = texture_focused
	off_texture = texture_disabled


func _on_pressed():
	is_pressed = not is_pressed
	if is_pressed:
		texture_normal = off_texture
		texture_pressed = off_texture
		texture_hover = off_texture
		texture_disabled = on_texture
		texture_focused = off_texture
	else:
		texture_normal = on_texture
		texture_pressed = on_texture
		texture_hover = highlight_texture
		texture_disabled = off_texture
		texture_focused = highlight_texture
	
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
