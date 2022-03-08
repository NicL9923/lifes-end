extends Building

export var energy_produced := 150
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 100
	bldg_name = "Oil Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy, and " + str(pollution_produced_per_day) + " Pollution per day"
	has_to_be_unlocked = true

func _process(delta):
	._process(delta)