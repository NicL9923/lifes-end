extends KinematicBody2D

export var health := 100
export var speed := 75
var path_to_player: PoolVector2Array

func _ready():
	pass

func _physics_process(delta):
	var move_dist = speed * delta
	path_to_player = Global.world_nav.get_simple_path(self.global_position, Global.player.global_position)
	
	while path_to_player.size() > 0:
		var dist_to_next_point = self.global_position.distance_to(path_to_player[0])
		
		if move_dist <= dist_to_next_point:
			var move_rot = get_angle_to(self.global_position.linear_interpolate(path_to_player[0], move_dist / dist_to_next_point))
			var motion = Vector2(speed, 0).rotated(move_rot)
			move_and_slide(motion)
			break
		
		path_to_player.remove(0)
		move_dist -= dist_to_next_point


func take_damage(dmg_amt):
	health -= dmg_amt
	
	if health <= 0:
		die()

func die():
	queue_free()
