extends Node2D


export var score_multiplier = 10
export var initial_speed = 450
export var initial_speed_increase = 30
export var max_speed = 900
export var initial_spawn_time = 1.0
export var initial_spawn_time_decrease = 0.05
export var min_spawn_time = 0.32
export var game_over_time = 0.9

export (Array, PackedScene) var obstacles
export (Array, int) var obstacle_probabilities

var playing
var score
var speed
var speed_increase
var spawn_time_decrease


func _ready():
	
	randomize()
	start_countdown()


func start_countdown():
	playing = false
	
	# reset game variables
	score = 0.0
	speed = initial_speed
	speed_increase = initial_speed_increase
	spawn_time_decrease = initial_spawn_time_decrease
	$SpawnTimer.wait_time = initial_spawn_time
	
	# show/hide UI
	$UI/ScoreLabel.text = "Score: 0"
	$UI/ScoreLabel.show()
	$UI/GameOverLabel.hide()
	$UI/ReplayButton.hide()
	$UI/MenuButton.hide()
	
	# remove any obstacles from previous game
	get_tree().call_group("obstacle", "queue_free")
	
	# show player
	$Player.show()
	$Player/AnimationPlayer.play("start")
	
	# coundown sequence
	$StartAudio.play()
	yield(get_tree().create_timer(0.1), "timeout")
	$UI/StartLabel.show()
	$UI/StartLabel.text = "3"
	yield(get_tree().create_timer(1.0), "timeout")
	$UI/StartLabel.text = "2"
	yield(get_tree().create_timer(1.0), "timeout")
	$UI/StartLabel.text = "1"
	yield(get_tree().create_timer(1.0), "timeout")
	$UI/StartLabel.hide()
	start_game()


func start_game():
	playing = true
	$SpawnTimer.start()
	spawn_object()
	
	# enable touchscreen controls
	$UI/TouchButtonJump.show()
	$UI/TouchButtonSlide.show()


func _process(delta):
	
	if playing:
		
		# update score and UI
		score += delta * score_multiplier
		$UI/ScoreLabel.text = "Score: %d" % int(score)


func spawn_object():
	
	# choose random obstacle to spawn using probabilities
	var sum = 0
	for num in obstacle_probabilities:
		sum += num
	var rand = randi() % sum
	var i = 0
	rand -= obstacle_probabilities[i]
	while rand >= 0:
		i += 1
		rand -= obstacle_probabilities[i]
	var o = obstacles[i].instance()
	add_child(o)
	
	# set y position to top or bottom of cave
	if o.get_groups().find("high_obstacle") > -1:
		o.position.y = $HiSpawnPt.position.y
	else:
		o.position.y = $LoSpawnPt.position.y
	
	# set x position to right of player (offscreen)
	o.position.x = $Player.position.x + get_viewport().size.x
	
	# increase game speed
	speed = min(speed + speed_increase, max_speed)
	speed_increase *= 0.98
	$SpawnTimer.wait_time = \
		max($SpawnTimer.wait_time - spawn_time_decrease, min_spawn_time)
	spawn_time_decrease *= 0.98


func _on_game_over():
	
	# get rid of double-signal bug
	if not playing:
		return
	
	playing = false
	get_parent().save_new_score()
	$SpawnTimer.stop()
	$Player.hide()
	
	# disable touchscreen controls
	$UI/TouchButtonJump.hide()
	$UI/TouchButtonSlide.hide()
	
	# game over sequence
	yield(get_tree().create_timer(game_over_time), "timeout")
	$UI/ReplayButton.show()
	$UI/ReplayButton.grab_focus()
	yield(get_tree().create_timer(game_over_time / 3), "timeout")
	$UI/MenuButton.show()
	$UI/ReplayButton.on_focus()
