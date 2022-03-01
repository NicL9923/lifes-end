extends Building

export var metal_produced_per_day := 2


func _init():
	cost_to_build = 20
	bldg_name = "Smeltery"
	bldg_desc = "Produces " + str(metal_produced_per_day) + " Metal per day"
	has_to_be_unlocked = true
	energy_cost_to_run = 2
