extends Building

export var energy_produced_per_day := 15
export var pollution_produced_per_day := 5 # TODO: implement pollution-tracking (in save-data as well)


func _ready():
	cost_to_build = 15
	get_tree().get_root().get_child(1).get_node("DayNightCycle").connect("day_has_passed", self, "_handle_new_day")

func _handle_new_day():
	Global.playerResources.energy += energy_produced_per_day
