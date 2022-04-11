extends KinematicBody2D
class_name Player

var health = Global.playerStats.max_health
export var ACCELERATION := 50
export var MAX_SPEED := 150
export var MAX_ZOOM := 0.25 # 4X zoom in
export var health_recovered_per_second := 1
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

onready var camera := $Camera2D
onready var healthbar := $UI/Healthbar
onready var earth_days_lbl := $UI/Days_Label
onready var notifications := $UI/Notifications
onready var building_panel := $UI/BuildingUI/Building_Panel
onready var research_ui := $UI/ResearchUI
onready var ship_ui := $UI/ShipUI
onready var player_stats_ui := $UI/PlayerStatsUI
onready var dev_console := $UI/DevConsole
onready var esc_menu := $UI/EscMenu
onready var rtb_btn := $UI/RTB_Button
onready var build_hq_btn := $UI/BuildingUI/Build_HQ_Button


func _ready():
	self.add_to_group("player_team")
	
	# Hide these in case we leave it visible in the editor by accident
	dev_console.visible = false
	esc_menu.visible = false
	research_ui.visible = false
	ship_ui.visible = false
	player_stats_ui.visible = false
	

func _process(delta):
	player_movement()
	handle_camera_zoom()
	check_if_ui_open()
	
	health += (delta * Global.modifiers.playerHealthRecovery * health_recovered_per_second)
	
	healthbar.value = health
	healthbar.max_value = Global.playerStats.max_health
	
	earth_days_lbl.text = "Earth Days: " + str(Global.game_time.earthDays)
	
	Global.subEndingIsGood = true if Global.playerStats.humanity > 0 else false
	
	if isInCombat:
		weapon_handling(delta)
	else:
		gun_rotation_point.visible = false

func player_movement():
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity += input_vector * ACCELERATION
		velocity = velocity.clamped(MAX_SPEED)
	else:
		velocity = Vector2.ZERO
	
	player_animation(input_vector)
# warning-ignore:return_value_discarded
	move_and_slide(velocity)

func player_animation(input_vector):
	# Right animations
	if input_vector.x > 0:
		animatedSprite.play("rightRun")
	elif Input.is_action_just_released("ui_right"):
		animatedSprite.play("rightIdle")
		
	# Left animations
	if input_vector.x < 0:
		animatedSprite.play("leftRun")
	elif Input.is_action_just_released("ui_left"):
		animatedSprite.play("leftIdle")
	
	# Down animations
	if input_vector.y > 0 and input_vector.x == 0:
		animatedSprite.play("downRun")
	elif Input.is_action_just_released("ui_down"):
		animatedSprite.play("downIdle")
	
	# Up animations
	if input_vector.y < 0 and input_vector.x == 0:
		animatedSprite.play("upRun")
	elif Input.is_action_just_released("ui_up"):
		animatedSprite.play("upIdle")

func handle_camera_zoom():
	if ui_is_open:
		return
	
	if Input.is_action_just_released("scroll_up"):
		currentZoom = clamp(lerp(currentZoom, currentZoom - 0.25, 0.2), MAX_ZOOM, MIN_ZOOM)
		camera.zoom = Vector2(currentZoom, currentZoom)
	elif Input.is_action_just_released("scroll_down"):
		currentZoom = clamp(lerp(currentZoom, currentZoom + 0.25, 0.2), MAX_ZOOM, MIN_ZOOM)
		camera.zoom = Vector2(currentZoom, currentZoom)

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
		currentWeapon.shoot(gun_angle, "player_team")

func toggle_combat(on: bool):
	if !on:
		isInCombat = false
		gun_rotation_point.hide()
	else:
		isInCombat = true
		gun_rotation_point.show()

func take_damage(dmg_amt):
	if Global.debug.god_mode:
		return
	
	health = clamp(health - dmg_amt, 0, Global.playerStats.max_health)
	
	if health == 0:
		die()

func die():
	Global.push_player_notification("You've met Life's End.")
	
	# TODO - slow fade to black
	
	# Respawn back at colony and lose 1/4 of all resources
	Global.change_metal_by(-(Global.playerResources.metal / 4))
	Global.change_food_by(-(Global.playerResources.food / 4))
	Global.change_water_by(-(Global.playerResources.water / 4))
	get_tree().change_scene("res://MainWorld.tscn")

func check_if_ui_open():
	if building_panel.visible or ship_ui.visible or research_ui.visible or player_stats_ui.visible:
		ui_is_open = true
	else:
		ui_is_open = false

func _on_RTB_Button_button_pressed():
	Global.player.rtb_btn.visible = false
	Global.player.get_parent().remove_child(Global.player) # Necessary to make sure the player node doesn't get automatically freed (aka destroyed)
	# warning-ignore:return_value_discarded
	Global.get_tree().change_scene("res://MainWorld.tscn")
