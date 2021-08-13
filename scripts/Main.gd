extends Node


export (String) var scores_path
export (PackedScene) var menu_scene
export (PackedScene) var game_scene

var high_scores


func _ready():
	load_high_scores()
	show_menu()


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		if get_node_or_null("Game"):
			show_menu()
		else:
			quit_game()


func load_high_scores():
	high_scores = [0, 0, 0]
	var file = File.new()
	if file.file_exists(scores_path):
		var error = file.open(scores_path, File.READ)
		if error == OK:
			high_scores = file.get_var()
			file.close()


func save_high_scores():
	var file = File.new()
	file.open(scores_path, File.WRITE)
	high_scores.sort()
	file.store_var(high_scores)
	file.close()


func save_new_score():
	
	# add score to high scores if applicable
	var score = get_node("Game").score
	var i = 0
	while i < high_scores.size():
		if score > high_scores[i]:
			high_scores[i] = score
			i = high_scores.size() # exit loop
		i += 1
	save_high_scores()


func play_game():
	
	# remove menu node and add game node
	$Menu.queue_free()
	var game = game_scene.instance()
	add_child(game)
	
	# make sure clicking "menu" will return to menu
	game.get_node("UI/MenuButton").connect("pressed", self, "show_menu")


func show_menu():
	
	# remove game node and add menu node
	if get_node_or_null("Game"):
		$Game.queue_free()
	var menu = menu_scene.instance()
	add_child(menu)
	
	# show high scores
	var high_scores_text = "High Scores:\n"
	var i = high_scores.size() - 1
	while i >= 0:
		high_scores_text += "%d\n" % high_scores[i]
		i -= 1
	menu.get_node("Control/HighScores").text = high_scores_text
	
	# ensure menu buttons do what their supposed to LOL
	menu.get_node("Control/PlayButton").connect("pressed", self, "play_game")
	menu.get_node("Control/ExitButton").connect("pressed", self, "quit_game")
	menu.get_node("Control/MuteMusic").connect("pressed", self, "toggle_music")
	menu.get_node("Control/MuteSFX").connect("pressed", self, "toggle_sfx")
	
	# ensure mute buttons match whether sound is muted or not
	if AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")):
		menu.get_node("Control/MuteMusic")._on_pressed()
	if AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")):
		menu.get_node("Control/MuteSFX")._on_pressed()
	
	# add buttons over time (replace with aniamation later)
	# if play button is pressed quickly by player, the menu won't exist
	# by the time the other UI elements appear
	var delay = 0.3
	menu.get_node("Control/PlayButton").hide()
	menu.get_node("Control/ExitButton").hide()
	menu.get_node("Control/HighScores").hide()
	yield(get_tree().create_timer(delay), "timeout")
	menu.get_node("Control/PlayButton").show()
	menu.get_node("Control/PlayButton").grab_focus()
	yield(get_tree().create_timer(delay), "timeout")
	if menu != null:
		menu.get_node("Control/ExitButton").show()
		menu.get_node("Control/ExitButton").on_focus()
	yield(get_tree().create_timer(delay), "timeout")
	if menu != null:
		menu.get_node("Control/HighScores").show()
		menu.get_node("Control/PlayButton").on_focus()


func quit_game():
	get_tree().quit()


func toggle_music():
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus_index, not AudioServer.is_bus_mute(bus_index))


func toggle_sfx():
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus_index, not AudioServer.is_bus_mute(bus_index))
