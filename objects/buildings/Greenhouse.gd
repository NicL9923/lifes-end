extends Area2D

export var cost_to_build := 10
export var food_produced_per_day := 5 # TODO: consider using this value in BuildingUI (so we just have to change it here)


func _ready():
	get_tree().get_root().get_child(1).get_node("DayNightCycle").connect("day_has_passed", self, "_handle_new_day")

func _handle_new_day():
	Global.playerResources.food += food_produced_per_day
