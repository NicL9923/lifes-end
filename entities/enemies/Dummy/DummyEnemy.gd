extends KinematicBody2D

var health := 100
onready var nav = get_tree().get_node("Navigation2D")
var path_to_player: PoolVector2Array

func _ready():
	pass

func _physics_process(delta):
	path_to_player = nav.get_simple_path(self.global_position, Global.player.global_position)
	
	if path_to_player.size() > 0:
		pass #move_and_slide(Vector2(x_rand, y_rand))


func take_damage(dmg_amt):
	health -= dmg_amt
	
	if health <= 0:
		die()

func die():
	queue_free()
