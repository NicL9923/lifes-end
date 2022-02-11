extends Building

export var energy_produced_per_day := 15
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 15

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_energy(energy_produced_per_day)
	add_pollution(pollution_produced_per_day)
