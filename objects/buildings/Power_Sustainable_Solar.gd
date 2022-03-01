extends Building

export var energy_produced := 5


func _init():
	cost_to_build = 15
	bldg_name = "Solar Array"
	bldg_desc = "Produces " + str(energy_produced) + " Energy"
	energy_cost_to_run = 2

func _process(delta):
	handle_energy_display(delta)
