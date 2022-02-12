extends KinematicBody2D

enum STATE {
	IDLE,
	PATROLLING,
	TAKING_COVER,
	ADVANCING,
	ATTACKING,
	FLEEING
}

enum MOVEMENT_DIR { UP, DOWN, LEFT, RIGHT }

onready var anim_sprt = $AnimatedSprite
export var health := 100
export var speed := 75
export var accuracy := 50
var cur_state = STATE.IDLE

var timer := -1.0 # a value of -1.0 is "null" state
var last_movement_dir
var next_patrol_point: Vector2
var last_known_player_team_pos: Vector2


func _ready():
	pass

func _physics_process(delta):
	process_states(delta)

func process_states(delta):
	match(cur_state):
		STATE.IDLE: process_idle(delta)
		STATE.PATROLLING: process_patrolling(delta)
		STATE.TAKING_COVER: process_taking_cover(delta)
		STATE.ADVANCING: process_advancing(delta)
		STATE.ATTACKING: process_attacking(delta)
		STATE.FLEEING: process_fleeing(delta)

func enter_state(new_state):
	cur_state = new_state

func set_timer(seconds: float):
	timer = seconds

# Can go to/from patrolling
func process_idle(delta):
	if timer == -1.0:
		set_timer(3.0)
	
	# May have to update or even timer code to just let idle animation run like 1-x times
	if last_movement_dir == MOVEMENT_DIR.UP:
		anim_sprt.play("idle_up")
	elif last_movement_dir == MOVEMENT_DIR.LEFT:
		anim_sprt.play("idle_left")
	elif last_movement_dir == MOVEMENT_DIR.RIGHT:
		anim_sprt.play("idle_right")
	else:
		anim_sprt.play("idle_down")
	
	if timer <= 0.0:
		timer = -1.0
		
		var next_x := self.global_position.x + rand_range(-100, 100)
		var next_y := self.global_position.y + rand_range(-100, 100)
		next_patrol_point = Vector2(next_x, next_y)
		
		enter_state(STATE.PATROLLING)
	else:
		timer -= delta

# Can go to/from idle, attacking
func process_patrolling(delta):
	if last_known_player_team_pos and self.global_position.distance_to(last_known_player_team_pos) > 0:
		pathfind_to_point(delta, last_known_player_team_pos)
		
		# TODO: scan for entities in group("player_team"), and switch to state attacking
	if self.global_position.distance_to(next_patrol_point) > 0:
		pathfind_to_point(delta, next_patrol_point)
		
		# TODO: scan for entities in group("player_team"), and switch to state attacking
	else:
		enter_state(STATE.IDLE)

# Can go to/from patrolling, attacking
func process_taking_cover(delta):
	# TODO: Find nearest static body(?), and get on the opposite side of it as the player
	# for x amt of time
	pass

# Can go to/from taking_cover, attacking, patrolling
func process_advancing(delta):
	# TODO: move towards lastKnownPlayerTeamPos
	pathfind_to_point(delta, Global.player.global_position)
	pass

# Can go to/from advancing, taking_cover
func process_attacking(delta):
	# TODO: attack (i.e. predict player_team entities position to accuracy
	pass

# Can go from attacking
func process_fleeing(delta):
	# Disengage from combat and run away from nearest player_team entity
	pass

func pathfind_to_point(delta, pos: Vector2):
	var move_dist = speed * delta
	var path := Global.world_nav.get_simple_path(self.global_position, pos)
	
	while path.size() > 0:
		var dist_to_next_point = self.global_position.distance_to(path[0])
		
		if move_dist <= dist_to_next_point:
			var move_rot = get_angle_to(self.global_position.linear_interpolate(path[0], move_dist / dist_to_next_point))
			var motion = Vector2(speed, 0).rotated(move_rot)
			move_and_slide(motion)
			
			if motion.x > 0:
				last_movement_dir = MOVEMENT_DIR.RIGHT
			elif motion.x < 0:
				last_movement_dir = MOVEMENT_DIR.LEFT
			elif motion.y > 0:
				last_movement_dir = MOVEMENT_DIR.UP
			else:
				last_movement_dir = MOVEMENT_DIR.DOWN
			break
		
		path.remove(0)
		move_dist -= dist_to_next_point

func take_damage(dmg_amt):
	health -= dmg_amt
	
	if health <= 0:
		die()

func die():
	queue_free()
