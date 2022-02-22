extends Building

export var energy_produced_per_day := 15
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 15
	bldg_name = "Oil Power Plant"
	bldg_desc = "Produces " + str(energy_produced_per_day) + " Energy and " + str(pollution_produced_per_day) + " Pollution per day"
	has_to_be_unlocked = true

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_energy(energy_produced_per_day)
	add_pollution(pollution_produced_per_day)
