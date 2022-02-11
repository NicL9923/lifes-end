extends Building

export var energy_produced_per_day := 30


func _init():
	cost_to_build = 75

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_energy(energy_produced_per_day)
