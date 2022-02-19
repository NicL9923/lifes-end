extends Building

export var energy_produced_per_day := 5


func _init():
	cost_to_build = 15
	bldg_name = "Nuclear Power Plant"
	bldg_desc = "Produces " + str(energy_produced_per_day) + " Energy per day"
	has_to_be_unlocked = true

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_energy(energy_produced_per_day)
