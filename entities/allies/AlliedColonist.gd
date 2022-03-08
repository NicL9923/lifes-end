extends AIEntity

# TODO: conversational popups (says random thing from conversation_text[] for now)

func _ready():
	cur_state = STATE.IDLE
	self.add_to_group("player_team")
	team_group = "player_team"
	enemy_team_group = "enemy"
	speed = 125
	max_health = Global.modifiers.colonistMaxHealth
	health = max_health
	accuracy = 50
	bullets_to_take_cover = 10 # Default: 10
	percent_chance_to_flee = 1 # Default: 1
	dist_to_follow_bullet = 1000
	will_flee_on_low_health = true if rand_range(1, 100) <= percent_chance_to_flee else false
	dist_to_advance = float(line_of_sight.get_node("CollisionShape2D").shape.radius) * 0.75
	current_weapons = [$Position2D/Rifle]
	currentWeapon = current_weapons[selectedWeaponIdx]

func _process(delta):
	handle_healthbar()
	process_states(delta)
	
	max_health = Global.modifiers.colonistMaxHealth
	
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

func _on_LineOfSight_body_entered(body):
	if body.is_in_group(enemy_team_group):
		hostiles_in_los.append(body)
	elif body.is_in_group("building"):
		potential_cover_in_los.append(body)

func _on_LineOfSight_body_exited(body):
	if body.is_in_group(enemy_team_group):
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
