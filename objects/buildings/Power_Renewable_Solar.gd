extends Building

export var energy_produced_per_day := 5


func _ready():
	cost_to_build = 15
	connect_to_daynight_cycle()

func handle_new_day():
	Global.playerResources.energy += energy_produced_per_day
