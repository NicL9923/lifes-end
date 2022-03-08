extends Building

export var water_produced_per_day := 10


func _init():
	cost_to_build = 10
	bldg_name = "Water Recycling System"
	bldg_desc = "Produces " + str(water_produced_per_day) + " Water per day"
	energy_cost_to_run = 2

func _process(delta):
	._process(delta)
	handle_energy_display(delta)
