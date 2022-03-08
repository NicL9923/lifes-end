extends KinematicBody2D
class_name AIEntity

enum STATE {
	IDLE,
	PATROLLING,
	TAKING_COVER,
	ADVANCING,
	ATTACKING,
	FLEEING,
	COWERING
}

onready var anim_sprt = get_node("AnimatedSprite")
onready var line_of_sight = get_node("LineOfSight")
onready var col_det = get_node("CollisionDetector")
onready var healthbar = get_node("Healthbar")

var speed := 125
var health := 100.0
var max_health := 100
var accuracy := 50

var team_group
var enemy_team_group

var bullets_to_take_cover := 10 # Default: 10
var percent_chance_to_flee := 1 # Default: 1
var dist_to_follow_bullet := 1000
var will_flee_on_low_health := false
var dist_to_advance

var timer := -1.0 # a value of -1.0 is "null" state
var pathfinding_timer := 0.3
var current_path
var last_movement_dir
var next_patrol_point
var last_known_player_team_pos
var closest_hostile
var hostiles_in_los := []
var potential_cover_in_los := []
var num_bullets_in_los := 0

var id
var cur_state
var current_weapons := []
var selectedWeaponIdx := 0
var currentWeapon


func pathfind_to_point(delta, pos: Vector2):
	var move_dist = speed * delta
	
	if pathfinding_timer > 0 and current_path:
		pathfinding_timer -= delta
	else:
		current_path = Global.world_nav.get_simple_path(self.global_position, pos)
		pathfinding_timer = 0.3
	
	while current_path.size() > 0:
		var dist_to_next_point = self.global_position.distance_to(current_path[0])
		
		if move_dist <= dist_to_next_point:
			var move_rot = get_angle_to(self.global_position.linear_interpolate(current_path[0], move_dist / dist_to_next_point))
			
			var motion = Vector2(speed, 0).rotated(move_rot)
			move_and_slide(motion)
			
			if motion.x > 0 and abs(motion.x) > abs(motion.y):
				last_movement_dir = Global.MOVEMENT_DIR.RIGHT
				anim_sprt.play("run_right")
			elif motion.x < 0 and abs(motion.x) > abs(motion.y):
				anim_sprt.play("run_left")
				last_movement_dir = Global.MOVEMENT_DIR.LEFT
			elif motion.y < 0:
				anim_sprt.play("run_up")
				last_movement_dir = Global.MOVEMENT_DIR.UP
			elif motion.y > 0:
				anim_sprt.play("run_down")
				last_movement_dir = Global.MOVEMENT_DIR.DOWN
			break
		
		current_path.remove(0)
		move_dist -= dist_to_next_point

func get_closest_of(type):
	var node_arr := []
	
	if type == "hostile":
		node_arr = hostiles_in_los
	elif type == "cover":
		node_arr = potential_cover_in_los
	else:
		return null
	
	if node_arr.size() == 0:
		return null
	
	var closest_node = node_arr[0]
	for node in node_arr:
		if node.global_position.distance_to(self.global_position) < closest_node.global_position.distance_to(self.global_position):
			closest_node = node
	
	if type == "hostile":
		last_known_player_team_pos = closest_node.global_position
	return closest_node

func set_new_patrol_point():
	var map_limits = Global.world_nav.get_child(0).get_used_rect()
	
	next_patrol_point = Global.get_random_location_in_map(map_limits)

func enter_state(new_state):
	# DEBUG: var states = ["idle", "patrolling", "taking cover", "advancing", "attacking", "fleeing"]
	# DEBUG: print(states[new_state])
	cur_state = new_state

func handle_enemies_in_line_of_sight():
	if hostiles_in_los.size() > 0:
		enter_state(STATE.ATTACKING)

func handle_idle_anim():
	if last_movement_dir == Global.MOVEMENT_DIR.UP:
		anim_sprt.play("idle_up")
	elif last_movement_dir == Global.MOVEMENT_DIR.LEFT:
		anim_sprt.play("idle_left")
	elif last_movement_dir == Global.MOVEMENT_DIR.RIGHT:
		anim_sprt.play("idle_right")
	else:
		anim_sprt.play("idle_down")

# Can go to/from patrolling
func process_idle(delta):
	randomize()
	
	if timer == -1.0:
		timer = rand_range(2.0, 6.0)
	
	handle_idle_anim()
	
	if timer <= 0.0:
		timer = -1.0
		
		set_new_patrol_point()
		
		enter_state(STATE.PATROLLING)
	else:
		timer -= delta
	
	handle_enemies_in_line_of_sight()

# Can go to/from idle, attacking
func process_patrolling(delta):
	handle_enemies_in_line_of_sight()
	
	# NOTE: The below two if statements are used because the entity can't always get perfectly close to the point
	if last_known_player_team_pos and self.global_position.distance_to(last_known_player_team_pos) > 16:
		pathfind_to_point(delta, last_known_player_team_pos)
	elif next_patrol_point and self.global_position.distance_to(next_patrol_point) > 16:
		#print(self.global_position.distance_to(next_patrol_point))
		last_known_player_team_pos = null
		pathfind_to_point(delta, next_patrol_point)
	else:
		next_patrol_point = null
		last_known_player_team_pos = null
		enter_state(STATE.IDLE)

# Can go to/from patrolling, attacking
func process_taking_cover(delta):
	var closest_cover = get_closest_of("cover")
	
	if closest_cover and (timer > 0 or num_bullets_in_los > bullets_to_take_cover):
		timer -= delta
		var closest_hostile = get_closest_of("hostile")
		if closest_hostile:
			pathfind_to_point(delta, closest_cover.global_position)
		else:
			pathfind_to_point(delta, closest_cover.global_position)
	else:
		timer = -1.0
		enter_state(STATE.ATTACKING) # If there isn't static body in LoS, just switch back to attacking

# Can go to/from taking_cover, attacking, patrolling
func process_advancing(delta):
	if hostiles_in_los.size() == 0:
		closest_hostile = null
		enter_state(STATE.PATROLLING)
		return
	
	# Advance towards closest hostile
	closest_hostile = get_closest_of("hostile")
	
	if self.global_position.distance_to(closest_hostile.global_position) < dist_to_advance:
		enter_state(STATE.ATTACKING)
	else:
		pathfind_to_point(delta, closest_hostile.global_position)

# Can go to/from advancing, taking_cover
func process_attacking(delta):
	# If no more enemies present in LoS, enter_state(patrolling)
	if hostiles_in_los.size() == 0:
		closest_hostile = null
		reset_weapon_rotation()
		enter_state(STATE.PATROLLING)
		return
	
	handle_idle_anim()
	
	# Find closest hostile and engage them
	closest_hostile = get_closest_of("hostile")
	
	# Rotate weapon towards entity we're attacking
		# TODO: predict player_team entities position w/ var accuracy (using current motion)
	$Position2D.look_at(closest_hostile.global_position)
	if global_position.x > closest_hostile.global_position.x:
		currentWeapon.scale.y = -1
	else:
		currentWeapon.scale.y = 1
	currentWeapon.shoot(closest_hostile.global_position.angle_to_point(currentWeapon.global_position), team_group)
	
	# Take cover if lots of bullets are flying around (in LoS)
	if num_bullets_in_los > bullets_to_take_cover:
		timer = 7.5
		reset_weapon_rotation()
		enter_state(STATE.TAKING_COVER)
	
	# Advance if closest hostile reaches a certain distance away (within LoS)
	if self.global_position.distance_to(closest_hostile.global_position) >= dist_to_advance:
		reset_weapon_rotation()
		enter_state(STATE.ADVANCING)

func process_fleeing(delta):
	$Position2D.visible = false # "Unequip" weapon when fleeing/cowering
	var closest_enemy = get_closest_of("hostile")
	
	if closest_enemy:
		pathfind_to_point(delta, closest_enemy.global_position * -1)
	else:
		enter_state(STATE.COWERING)

func process_cowering(delta):
	# TODO: play cowering animation
	
	if get_closest_of("hostile"):
		enter_state(STATE.FLEEING)

func take_damage(dmg_amt):
	health -= dmg_amt
	
	if health <= 0:
		die()

func die():
	queue_free()
	
	if self.is_in_group("player_team") and Global.playerBaseData.colonists.size() > id:
		Global.push_player_notification("Colonist " + str(id) + " has been KIA.")
		Global.playerBaseData.colonists.remove(id)

func handle_healthbar():
	healthbar.value = health
	
	if health < max_health:
		healthbar.visible = true
	else:
		healthbar.visible = false

func reset_weapon_rotation():
	get_node("Position2D").rotation_degrees = 45.0
	currentWeapon.scale.y = 1
