extends KinematicBody2D
class_name Player

export var health := 100
export var MAX_SPEED := 150
export var MAX_ZOOM := 0.25 # 4X zoom in
var MIN_ZOOM = Global.world_tile_size.x / 20 # zoom out

onready var animatedSprite = $AnimatedSprite

var currentZoom := 1.0
var isInCombat := false
var ui_is_open := false

onready var currentWeapons := [$Position2D/Rifle]
var selectedWeapon := 0

var velocity := Vector2.ZERO
onready var gun_rotation_point := $Position2D
var gun_angle: float

onready var building_panel := $UI/BuildingUI/Building_Panel
onready var ship_panel := $UI/ShipUI/Ship_Panel
onready var research_panel := $UI/ResearchUI/Research_Panel
onready var esc_menu := $UI/EscMenu

func _ready():
	Global.player = self

func _physics_process(delta):
	player_movement()
	handle_camera_zoom()
	check_if_ui_open()
	
	$UI/Healthbar.value = health
	$UI/Healthbar.max_value = Global.playerStats.max_health
	
	$UI/Days_Label.text = "Earth Days: " + str(Global.game_time.earthDays)
	
	if isInCombat:
		weapon_handling(delta)

func player_movement():
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	player_animation(input_vector)
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * MAX_SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide(velocity)

func player_animation(input_vector):
	#right animations
	if input_vector.x > 0:
		animatedSprite.play("rightRun")
	elif Input.is_action_just_released("ui_right"):
		animatedSprite.play("rightIdle")	
		
	#left animations
	if input_vector.x < 0:
		animatedSprite.play("leftRun")
	elif Input.is_action_just_released("ui_left"):
		animatedSprite.play("leftIdle")	
	
	#down animations
	if input_vector.y > 0 and input_vector.x == 0:
		animatedSprite.play("downRun")
	elif Input.is_action_just_released("ui_down"):
		animatedSprite.play("downIdle")	
	
	#up animations
	if input_vector.y < 0 and input_vector.x == 0:
		animatedSprite.play("upRun")
	elif Input.is_action_just_released("ui_up"):
		animatedSprite.play("upIdle")	

func handle_camera_zoom():
	if ui_is_open:
		return
	
	if Input.is_action_just_released("scroll_up"):
		currentZoom = clamp(lerp(currentZoom, currentZoom - 0.25, 0.2), MAX_ZOOM, MIN_ZOOM)
		$Camera2D.zoom = Vector2(currentZoom, currentZoom)
	elif Input.is_action_just_released("scroll_down"):
		currentZoom = clamp(lerp(currentZoom, currentZoom + 0.25, 0.2), MAX_ZOOM, MIN_ZOOM)
		$Camera2D.zoom = Vector2(currentZoom, currentZoom)

func weapon_handling(_delta):
	var mouse_pos := get_global_mouse_position()
	var currentWeapon = currentWeapons[selectedWeapon]
	
	# Gun rotation to follow cursor
	gun_angle = mouse_pos.angle_to_point(currentWeapon.global_position)
	gun_rotation_point.look_at(mouse_pos)
	
	if global_position.x > mouse_pos.x:
		currentWeapon.scale.y = -1
	else:
		currentWeapon.scale.y = 1
	
	# Gun shooting
	if Input.is_action_pressed("shoot"):
		currentWeapon.shoot(gun_angle)

func toggle_combat(on: bool):
	if !on:
		isInCombat = false
		gun_rotation_point.hide()
	else:
		isInCombat = true
		gun_rotation_point.show()

func check_if_ui_open():
	if building_panel.visible or ship_panel.visible or research_panel.visible:
		ui_is_open = true
	else:
		ui_is_open = false

func _on_RTB_Button_pressed():
	get_tree().change_scene("res://MainWorld.tscn")
