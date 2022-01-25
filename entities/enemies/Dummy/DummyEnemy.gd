extends KinematicBody2D

var health := 100

func _ready():
	randomize()

func _physics_process(delta):
	var x_rand := rand_range(-100, 100)
	var y_rand := rand_range(-100, 100)
	
	move_and_slide(Vector2(x_rand, y_rand))

func take_damage(dmg_amt):
	health -= dmg_amt
	
	if health <= 0:
		die()

func die():
	queue_free()
