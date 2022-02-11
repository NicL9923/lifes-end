extends Area2D
class_name Building

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed
var isPlayerBldg := false
var bldgLvl: int


func _ready():
	get_node("CollisionHighlight").visible = false

func is_player_in_popup_distance():
	return (Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced)

func connect_to_daynight_cycle():
	get_tree().get_root().get_child(1).get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

func add_metal(amt: int):
	Global.playerResources.metal += amt

func add_energy(amt: int):
	Global.playerResources.energy += amt

func add_food(amt: int):
	Global.playerResources.food += amt

func add_water(amt: int):
	Global.playerResources.water += amt

func add_pollution(amt: float):
	var cur_pol = Global.playerBaseData.pollutionLevel
	cur_pol = clamp(cur_pol + amt, 0, 100)
