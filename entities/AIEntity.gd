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
var last_movement_dir
var next_patrol_point
var last_known_player_team_pos
var closest_hostile
var hostiles_in_los := []
var potential_cover_in_los := []
var num_bullets_in_los := 0
var nearby_col_objects := []

var id
var cur_state
var current_weapons := []
var selectedWeaponIdx := 0
var currentWeapon


func pathfind_to_point(delta, pos: Vector2):
	var move_dist = speed * delta
	var path := Global.world_nav.get_simple_path(self.global_position, pos)
	
	while path.size() > 0:
		var dist_to_next_point = self.global_position.distance_to(path[0])
		
		if move_dist <= dist_to_next_point:
			var move_rot = get_angle_to(self.global_position.linear_interpolate(path[0], move_dist / dist_to_next_point))
			
			# Mke sure we're not running into something, and if we are, run perpendicular to it in the direction closest to the original
			if nearby_col_objects.size() > 0:
				var obj_to_avoid = get_closest_of("col_obj")
				var angle_to_obj := get_angle_to(obj_to_avoid.global_position) # self.global_position.angle_to_point(obj_to_avoid.global_position)
				
				var move1 = self.global_position + Vector2(speed, 0).rotated(angle_to_obj + deg2rad(90))
				var move2 = self.global_position + Vector2(speed, 0).rotated(angle_to_obj - deg2rad(90))
				
				# Check which distance is shorter, and make sure the difference is great enough so we eliminate MOST (not all) indecisive glitching in place
				if move1.distance_to(path[0]) < move2.distance_to(path[0]) and abs(move1.distance_to(path[0]) - move2.distance_to(path[0])) > 50:
					move_rot = angle_to_obj + deg2rad(90)
				else:
					move_rot = angle_to_obj - deg2rad(90)
			
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
		
		path.remove(0)
		move_dist -= dist_to_next_point

func get_closest_of(type):
	var node_arr := []
	
	if type == "hostile":
		node_arr = hostiles_in_los
	elif type == "col_obj":
		node_arr = nearby_col_objects
	elif type == "cover":
		node_arr = potential_cover_in_los
	else:
		return null
	
	if node_arr.size() == 0:
		return null
	
	var closest_node = node_arr[0]
	for node in node_arr:
		if node.global_position.distance_to(self.global_position) < node.global_position.distance_to(self.global_position):
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
