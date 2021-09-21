extends KinematicBody2D
class_name Player

export var health := 100
export var MAX_SPEED := 150

export var time_between_shots := 10
var time_since_last_shot: int

var commander_attr: int
var biologist_attr: int
var engineer_attr: int
var doctor_attr: int

var velocity := Vector2.ZERO
onready var gun := $Position2D/Rifle
onready var gun_muzzle := $Position2D/Rifle/Muzzle
onready var gun_rotation_point := $Position2D
var gun_angle: float

func _ready():
	Global.player = self
	
	# TODO: read player attributes from save data or somewhere

func _physics_process(delta):
	player_movement()
	gun_handling(delta)

func player_movement():
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * MAX_SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide(velocity)

func gun_handling(delta):
	var mouse_pos := get_global_mouse_position()
	time_since_last_shot -= delta
	
	# Gun rotation to follow cursor
	gun_angle = mouse_pos.angle_to_point(gun.global_position)
	gun_rotation_point.look_at(mouse_pos)
	
	if global_position.x > mouse_pos.x:
		gun.scale.y = -1
	else:
		gun.scale.y = 1
	
	# Gun shooting
	if Input.is_action_pressed("shoot"):
		if time_since_last_shot <= 0:
			var bullet := preload("res://objects/weapons/Bullet.tscn").instance()
			bullet.rotation = gun_angle
			bullet.global_position = gun_muzzle.global_position
			get_tree().get_root().add_child(bullet)
			time_since_last_shot = time_between_shots
