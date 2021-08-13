extends Sprite


export (int) var frames


func _ready():
	self.frame += randi() % frames
