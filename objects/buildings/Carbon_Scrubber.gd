extends Building

export var pollution_removed_per_day := 0.05

func _init():
	cost_to_build = 10
	bldg_name = "Carbon Scrubber"
	bldg_desc = "Removes " + str(pollution_removed_per_day) + " pollution per day"
	has_to_be_unlocked = true
	energy_cost_to_run = 4
