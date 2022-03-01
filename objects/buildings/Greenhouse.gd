extends Building

export var food_produced_per_day := 5 # TODO: update this when building is upgraded so BaseManager gets new rsc amt

func _init():
	cost_to_build = 10
	bldg_name = "Greenhouse"
	bldg_desc = "Produces " + str(food_produced_per_day) + " Food per day"
	energy_cost_to_run = 2
