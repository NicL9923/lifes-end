extends Building

export var energy_produced := 20
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 15
	bldg_name = "Coal Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy, and " + str(pollution_produced_per_day) + " Pollution per day"
	energy_cost_to_run = 3
