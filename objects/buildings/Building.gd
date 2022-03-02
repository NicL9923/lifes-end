extends Area2D
class_name Building

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed
var isBeingBuilt := false
var isPlayerBldg := false
var bldgLvl: int
var has_to_be_unlocked := false
var sec_to_build := float(60 / Global.modifiers.buildSpeed)
var cur_seconds_to_build := sec_to_build
var energy_cost_to_run := 0
var has_energy := true
var energy_blink_timer := 0.5

var bldg_name: String
var bldg_desc: String

onready var static_body := get_node("StaticBody2D")
onready var bldg_progr := get_node("BuildingProgress")
onready var bldg_sprite := get_node("BuildingSprite")


func _ready():
	static_body.add_to_group("building")
	bldg_progr.visible = false

func is_player_in_popup_distance():
	return (Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced)

func _process(delta):
	if isBeingBuilt:
		handle_building_building(delta)

func handle_building_building(delta):
	var bldg_radial_progress := get_node("BuildingProgress")
	
	if cur_seconds_to_build <= 0:
		bldg_radial_progress.value = 100
		isBeingBuilt = false
		bldg_sprite.self_modulate = Color(1, 1, 1)
		bldg_radial_progress.visible = false
	else:
		bldg_radial_progress.visible = true
		cur_seconds_to_build -= delta
		bldg_sprite.self_modulate = Color(0.25, 0.25, 0.25) # Darken the building
		bldg_radial_progress.value = ((sec_to_build - cur_seconds_to_build) / sec_to_build) * 100
		

func handle_energy_display(delta):
	var energy_icon = get_node("EnergyIcon")
	
	if self.has_energy:
		energy_icon.visible = false
		bldg_sprite.self_modulate = Color(1, 1, 1)
	else:
		bldg_sprite.self_modulate = Color(0.25, 0.25, 0.25) # Darken the building
		if energy_blink_timer > 0:
			energy_blink_timer -= delta
		else:
			energy_icon.visible = !energy_icon.visible
			energy_blink_timer = 0.5
