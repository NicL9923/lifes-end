extends AIEntity

enum STATE {
	IDLE,
	PATROLLING,
	TAKING_COVER,
	ADVANCING,
	ATTACKING,
	FLEEING,
	COWERING
}

# TODO: conversational popups (says random thing from conversation_text[] for now)


func _ready():
	cur_state = STATE.IDLE
	self.add_to_group("player_team")
	speed = 125
	health = 100
	max_health = 100
	accuracy = 50
	bullets_to_take_cover = 10 # Default: 10
	percent_chance_to_flee = 1 # Default: 1
	dist_to_follow_bullet = 1000
	will_flee_on_low_health = true if rand_range(1, 100) <= percent_chance_to_flee else false
	dist_to_advance = float(line_of_sight.get_node("CollisionShape2D").shape.radius) * 0.75
	current_weapons = [$Position2D/Rifle]
	currentWeapon = current_weapons[selectedWeaponIdx]

func _physics_process(delta):
	handle_healthbar()
	process_states(delta)
	
	if health < 50 and will_flee_on_low_health:
		enter_state(STATE.FLEEING)


func process_states(delta):
	match(cur_state):
		STATE.IDLE: process_idle(delta)
		STATE.PATROLLING: process_patrolling(delta)
		STATE.TAKING_COVER: process_taking_cover(delta)
		STATE.ADVANCING: process_advancing(delta)
		STATE.ATTACKING: process_attacking(delta)
		STATE.FLEEING: process_fleeing(delta)
		STATE.COWERING: process_cowering(delta)

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

func set_new_patrol_point():
	var map_limits = Global.world_nav.get_child(0).get_used_rect()
	randomize()
	
	var next_x := clamp(self.global_position.x + rand_range(-100, 100), map_limits.position.x, map_limits.end.x)
	var next_y := clamp(self.global_position.y + rand_range(-100, 100), map_limits.position.y, map_limits.end.y)
	
	next_patrol_point = Vector2(next_x, next_y)

# Can go to/from patrolling
func process_idle(delta):
	if timer == -1.0:
		timer = 3.0
	
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
	
	# NOTE: The below two if statements use 5 as the value because the entity can't always get perfectly close to the point
	if last_known_player_team_pos and self.global_position.distance_to(last_known_player_team_pos) > 5:
		pathfind_to_point(delta, last_known_player_team_pos)
	elif next_patrol_point and self.global_position.distance_to(next_patrol_point) > 5:
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
		enter_state(STATE.PATROLLING)
		return
	
	# Advance towards closest hostile
	var closest_hostile = get_closest_of("hostile")
	
	if self.global_position.distance_to(closest_hostile.global_position) < dist_to_advance:
		enter_state(STATE.ATTACKING)
	else:
		pathfind_to_point(delta, closest_hostile.global_position)

# Can go to/from advancing, taking_cover
func process_attacking(delta):
	# If no more enemies present in LoS, enter_state(patrolling)
	if hostiles_in_los.size() == 0:
		reset_weapon_rotation()
		enter_state(STATE.PATROLLING)
		return
	
	handle_idle_anim()
	
	# Find closest hostile and engage them
	var closest_hostile = get_closest_of("hostile")
	
	# Rotate weapon towards entity we're attacking
		# TODO: predict player_team entities position w/ var accuracy (using current motion)
	$Position2D.look_at(closest_hostile.global_position)
	if global_position.x > closest_hostile.global_position.x:
		currentWeapon.scale.y = -1
	else:
		currentWeapon.scale.y = 1
	currentWeapon.shoot(closest_hostile.global_position.angle_to_point(currentWeapon.global_position), "player_team")
	
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


func _on_LineOfSight_body_entered(body):
	if body.is_in_group("enemy"):
		hostiles_in_los.append(body)
	elif body.is_in_group("building"):
		potential_cover_in_los.append(body)

func _on_LineOfSight_body_exited(body):
	if body.is_in_group("enemy"):
		last_known_player_team_pos = body.global_position
		hostiles_in_los.erase(body)
	elif body.is_in_group("building"):
		potential_cover_in_los.erase(body)

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
