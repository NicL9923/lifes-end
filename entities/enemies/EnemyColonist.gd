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
onready var line_of_sight = $LineOfSight
onready var weapon = $Position2D/Rifle
onready var col_det = $CollisionDetector

export var health := 100
export var max_health := 100
export var speed := 125
export var accuracy := 50
export var bullets_to_take_cover := 10
export var dist_to_advance := 15.0
export var dist_to_follow_bullet := 1000
var cur_state = STATE.IDLE

var timer := -1.0 # a value of -1.0 is "null" state
var last_movement_dir
var next_patrol_point: Vector2
var last_known_player_team_pos
var hostiles_in_los := []
var num_bullets_in_los := 0
var nearby_col_objects := []

func _ready():
	self.add_to_group("enemy")

func _physics_process(delta):
	handle_healthbar()
	process_states(delta)

func handle_healthbar():
	$Healthbar.value = health
	
	if health < max_health:
		$Healthbar.visible = true
	else:
		$Healthbar.visible = false

func process_states(delta):
	match(cur_state):
		STATE.IDLE: process_idle(delta)
		STATE.PATROLLING: process_patrolling(delta)
		STATE.TAKING_COVER: process_taking_cover(delta)
		STATE.ADVANCING: process_advancing(delta)
		STATE.ATTACKING: process_attacking(delta)
		STATE.FLEEING: process_fleeing(delta)

func enter_state(new_state):
	var states = ["idle", "patrolling", "taking cover", "advancing", "attacking", "fleeing"]
	print(states[new_state])
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

func get_closest_col_object():
	if nearby_col_objects.size() == 0:
		return null
	
	var closest_col_object = nearby_col_objects[0]
	
	for col_obj in nearby_col_objects:
		if col_obj.global_position.distance_to(self.global_position) < closest_col_object.global_position.distance_to(self.global_position):
			closest_col_object = col_obj
	
	return closest_col_object

func handle_idle_anim():
	if last_movement_dir == MOVEMENT_DIR.UP:
		anim_sprt.play("idle_up")
	elif last_movement_dir == MOVEMENT_DIR.LEFT:
		anim_sprt.play("idle_left")
	elif last_movement_dir == MOVEMENT_DIR.RIGHT:
		anim_sprt.play("idle_right")
	else:
		anim_sprt.play("idle_down")

func set_new_patrol_point():
	randomize()
	
	var next_x := self.global_position.x + rand_range(-100, 100)
	var next_y := self.global_position.y + rand_range(-100, 100)
	next_patrol_point = Vector2(next_x, next_y)

# Can go to/from patrolling
func process_idle(delta):
	if timer == -1.0:
		set_timer(3.0)
	
	handle_idle_anim()
	
	if timer <= 0.0:
		set_timer(-1.0)
		
		set_new_patrol_point()
		
		enter_state(STATE.PATROLLING)
	else:
		timer -= delta
	
	handle_enemies_in_line_of_sight()

# Can go to/from idle, attacking
func process_patrolling(delta):
	handle_enemies_in_line_of_sight()
	
	# NOTE: The below two if statements use 5 as the value because the entity can't always get perfectly close to the point
	if last_known_player_team_pos and self.global_position.distance_to(last_known_player_team_pos) > 5:
		pathfind_to_point(delta, last_known_player_team_pos)
	elif self.global_position.distance_to(next_patrol_point) > 5:
		last_known_player_team_pos = null
		pathfind_to_point(delta, next_patrol_point)
	else:
		last_known_player_team_pos = null
		enter_state(STATE.IDLE)

# Can go to/from patrolling, attacking
func process_taking_cover(delta):
	# TODO: Find nearest static body(?), and get on the opposite side of it as the player
	# for x amt of time, or until there's less bullets in LoS
	
	# If there isn't static body in LoS, just switch back to attacking
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
	
	handle_idle_anim()
	
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
			
			# Mke sure we're not running into something, and if we are, run perpendicular to it in the direction closest to the original
			if nearby_col_objects.size() > 0:
				var obj_to_avoid = get_closest_col_object()
				var angle_to_obj := get_angle_to(obj_to_avoid.global_position) # self.global_position.angle_to_point(obj_to_avoid.global_position)
				
				var move1 = self.global_position + Vector2(speed, 0).rotated(angle_to_obj + deg2rad(90))
				var move2 = self.global_position + Vector2(speed, 0).rotated(angle_to_obj - deg2rad(90))
				
				# Check which distance is shorter, and make sure the difference is great enough so we eliminate MOST (not all) indecisive glitching in place
				if move1.distance_to(path[0]) < move2.distance_to(path[0]) and abs(move1.distance_to(path[0]) - move2.distance_to(path[0])) > 20:
					move_rot = angle_to_obj + deg2rad(90)
				else:
					move_rot = angle_to_obj - deg2rad(90)
			
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
	if body.is_in_group("player_team"):
		hostiles_in_los.append(body)

func _on_LineOfSight_body_exited(body):
	if body.is_in_group("player_team"):
		hostiles_in_los.erase(body)

func _on_LineOfSight_area_entered(area):
	if area.is_in_group("bullets"):
		num_bullets_in_los += 1
		
		# Patrol (roughly) towards source of incoming bullet
		if cur_state == STATE.IDLE or cur_state == STATE.PATROLLING:
			enter_state(STATE.PATROLLING)
			last_known_player_team_pos = (area.global_position - self.global_position).normalized() * dist_to_follow_bullet

func _on_LineOfSight_area_exited(area):
	if area.is_in_group("bullets"):
		num_bullets_in_los -= 1


func _on_CollisionDetector_body_entered(body):
	if body.is_in_group("building"):
		nearby_col_objects.append(body)

func _on_CollisionDetector_body_exited(body):
	if body.is_in_group("building"):
		nearby_col_objects.erase(body)
