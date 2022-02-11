extends Building

export var energy_produced_per_day := 15
export var pollution_produced_per_day := 5 # TODO: implement pollution-tracking (in save-data as well)


func _ready():
	cost_to_build = 15
	connect_to_daynight_cycle()

func handle_new_day():
	Global.playerResources.energy += energy_produced_per_day
