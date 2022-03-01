extends Area2D
class_name Building

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed
var isPlayerBldg := false
var bldgLvl: int
var has_to_be_unlocked := false
var seconds_to_build = 60 / Global.modifiers.buildSpeed
var energy_cost_to_run := 0
var has_energy := true

var bldg_name: String
var bldg_desc: String


func _ready():
	get_node("StaticBody2D").add_to_group("building")

func is_player_in_popup_distance():
	return (Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced)
