extends KinematicBody2D
class_name AIEntity

onready var anim_sprt = get_node("AnimatedSprite")
onready var line_of_sight = get_node("LineOfSight")
onready var col_det = get_node("CollisionDetector")
onready var healthbar = get_node("Healthbar")

var speed := 125
var health := 100.0
var max_health := 100
var accuracy := 50

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
	randomize()
	
	var next_x := clamp(self.global_position.x + rand_range(-100, 100), map_limits.position.x * Global.cellSize, map_limits.end.x * Global.cellSize)
	var next_y := clamp(self.global_position.y + rand_range(-100, 100), map_limits.position.y * Global.cellSize, map_limits.end.y * Global.cellSize)
	
	next_patrol_point = Vector2(next_x, next_y)

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
