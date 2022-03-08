extends Building

export var metal_produced_per_day := 4
export var pollution_produced_per_day := 0.3

func _init():
	cost_to_build = 25
	bldg_name = "Mining Operation"
	bldg_desc = "Produces " + str(metal_produced_per_day) + " Metal and " + str(pollution_produced_per_day) + " Pollution per day"
	has_to_be_unlocked = true
	energy_cost_to_run = 2

func _process(delta):
	._process(delta)
	handle_energy_display(delta)
