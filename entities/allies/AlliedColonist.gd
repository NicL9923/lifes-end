extends KinematicBody2D

enum STATE {
	IDLE,
	CONVERSING,
	PATROLLING,
	TAKING_COVER,
	ADVANCING,
	ATTACKING
}

enum MOVEMENT_DIR { UP, DOWN, LEFT, RIGHT }

onready var anim_sprt = $AnimatedSprite
onready var line_of_sight = $LineOfSight
onready var weapon = $Position2D/Rifle

export var health := 100
export var speed := 125
export var accuracy := 50
export var bullets_to_take_cover := 10
export var dist_to_advance := 15.0
var cur_state = STATE.IDLE

var timer := -1.0 # a value of -1.0 is "null" state
var last_movement_dir
var next_patrol_point: Vector2
var last_known_player_team_pos
var hostiles_in_los := []
var num_bullets_in_los := 0

# TODO: maybe do like RimWorld does where enemies know where you/allies are at all times (in place of current LoS system *still good for bullets though...?*)
# TODO: handle pathing around buildings (these silly bois get stuck on them currently - tilemap collisions should be fine though)

func _ready():
	self.add_to_group("enemy")

func _physics_process(delta):
	process_states(delta)

func process_states(delta):
	match(cur_state):
		STATE.IDLE: process_idle(delta)
		STATE.CONVERSING: process_conversing(delta)
		STATE.PATROLLING: process_patrolling(delta)
		STATE.TAKING_COVER: process_taking_cover(delta)
		STATE.ADVANCING: process_advancing(delta)
		STATE.ATTACKING: process_attacking(delta)

func enter_state(new_state):
	cur_state = new_state

func set_timer(seconds: float):
	timer = seconds

func handle_enemies_in_line_of_sight():
	if hostiles_in_los.size() > 0:
		enter_state(STATE.ATTACKING)

func get_closest_hostile():
	if hostiles_in_los.size() == 0:
		return null
	
	var closest_hostile = hostiles_in_los[0]
	
	for hostile in hostiles_in_los:
		if hostile.global_position.distance_to(self.global_position) < closest_hostile.global_position.distance_to(self.global_position):
			closest_hostile = hostile
	
	last_known_player_team_pos = closest_hostile.global_position
	return closest_hostile

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
		set_timer(-1.0)
		
		var next_x := self.global_position.x + rand_range(-100, 100)
		var next_y := self.global_position.y + rand_range(-100, 100)
		next_patrol_point = Vector2(next_x, next_y)
		
		enter_state(STATE.PATROLLING)
	else:
		timer -= delta
	
	handle_enemies_in_line_of_sight()

func process_conversing(delta):
	pass

# Can go to/from idle, attacking
func process_patrolling(delta):
	handle_enemies_in_line_of_sight()
	
	# NOTE: The below two if statements use 5 as the value because the entity can't always get perfectly close to the point
	if last_known_player_team_pos and self.global_position.distance_to(last_known_player_team_pos) > 5:
		pathfind_to_point(delta, last_known_player_team_pos)
	elif self.global_position.distance_to(next_patrol_point) > 5:
		pathfind_to_point(delta, next_patrol_point)
	else:
		last_known_player_team_pos = null
		enter_state(STATE.IDLE)

# Can go to/from patrolling, attacking
func process_taking_cover(delta):
	# TODO: Find nearest static body(?), and get on the opposite side of it as the player
	# for x amt of time, or until there's less bullets in LoS
	pass

# Can go to/from taking_cover, attacking, patrolling
func process_advancing(delta):
	if hostiles_in_los.size() == 0:
		enter_state(STATE.PATROLLING)
		return
	
	# Advance towards closest hostile
	var closest_hostile = get_closest_hostile()
	
	if self.global_position.distance_to(closest_hostile.global_position) < dist_to_advance:
		enter_state(STATE.ATTACKING)
	else:
		pathfind_to_point(delta, closest_hostile.global_position)

# Can go to/from advancing, taking_cover
func process_attacking(delta):
	# If no more enemies present in LoS, enter_state(patrolling)
	if hostiles_in_los.size() == 0:
		enter_state(STATE.PATROLLING)
		return
	
	# Find closest hostile and engage them
	var closest_hostile = get_closest_hostile()
	
	# Rotate weapon towards entity we're attacking
		# TODO: predict player_team entities position w/ var accuracy
	$Position2D.look_at(closest_hostile.global_position)
	weapon.shoot(closest_hostile.global_position.angle_to_point(weapon.global_position))
	
	# Take cover if lots of bullets are flying around (in LoS)
	if num_bullets_in_los > bullets_to_take_cover:
		enter_state(STATE.TAKING_COVER)
	
	# Advance if closest hostile reaches a certain distance away (within LoS)
	if self.global_position.distance_to(closest_hostile.global_position) >= dist_to_advance:
		enter_state(STATE.ADVANCING)

func pathfind_to_point(delta, pos: Vector2):
	var move_dist = speed * delta
	var path := Global.world_nav.get_simple_path(self.global_position, pos)
	
	while path.size() > 0:
		var dist_to_next_point = self.global_position.distance_to(path[0])
		
		if move_dist <= dist_to_next_point:
			var move_rot = get_angle_to(self.global_position.linear_interpolate(path[0], move_dist / dist_to_next_point))
			line_of_sight.rotation = move_rot
			var motion = Vector2(speed, 0).rotated(move_rot)
			move_and_slide(motion)
			
			if motion.x > 0 and abs(motion.x) > abs(motion.y):
				last_movement_dir = MOVEMENT_DIR.RIGHT
				anim_sprt.play("run_right")
			elif motion.x < 0 and abs(motion.x) > abs(motion.y):
				anim_sprt.play("run_left")
				last_movement_dir = MOVEMENT_DIR.LEFT
			elif motion.y < 0:
				anim_sprt.play("run_up")
				last_movement_dir = MOVEMENT_DIR.UP
			elif motion.y > 0:
				anim_sprt.play("run_down")
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

func _on_LineOfSight_body_entered(body):
	if body.is_in_group("enemy"):
		hostiles_in_los.append(body)

func _on_LineOfSight_body_exited(body):
	if body.is_in_group("enemy"):
		hostiles_in_los.erase(body)

func _on_LineOfSight_area_entered(area):
	if area.is_in_group("bullets"):
		num_bullets_in_los += 1

func _on_LineOfSight_area_exited(area):
	if area.is_in_group("bullets"):
		num_bullets_in_los -= 1
