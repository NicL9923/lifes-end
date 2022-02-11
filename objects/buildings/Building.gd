extends Area2D
class_name Building

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed


func _ready():
	pass

func is_player_in_popup_distance():
	return (Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced)

func connect_to_daynight_cycle():
	get_tree().get_root().get_child(1).get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")
