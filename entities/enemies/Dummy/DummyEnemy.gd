extends KinematicBody2D

func _ready():
	randomize()
	var x_rand = randi() % 100
	var y_rand = randi() % 100
	
	move_and_slide(Vector2(x_rand, y_rand))

func die():
	queue_free()
