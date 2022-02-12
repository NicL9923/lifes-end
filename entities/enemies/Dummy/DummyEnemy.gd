extends KinematicBody2D

export var health := 100
export var speed := 75
var cur_state = STATE.IDLE
var path_to_player: PoolVector2Array

enum STATE {
	IDLE,
	PATROLLING,
	TAKING_COVER,
	SEARCHING_FOR_NEAREST_GOOD_GUY,
	ADVANCING,
	ATTACKING,
	FLEEING
}


func _ready():
	pass

func _physics_process(delta):
	process_states(delta)

func process_states(delta):
	match(cur_state):
		STATE.IDLE: process_idle()
		STATE.PATROLLING: process_patrolling()
		STATE.TAKING_COVER: process_taking_cover()
		STATE.SEARCHING_FOR_NEAREST_GOOD_GUY: process_searching_for_nearest_good_guy()
		STATE.ADVANCING: process_advancing()
		STATE.ATTACKING: process_attacking(delta)
		STATE.FLEEING: process_fleeing()

func process_idle():
	pass

func process_patrolling():
	pass

func process_taking_cover():
	pass

func process_searching_for_nearest_good_guy():
	pass

func process_advancing():
	pass

func process_attacking(delta):
	move_towards_player(delta)

func process_fleeing():
	pass

func move_towards_player(delta):
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
