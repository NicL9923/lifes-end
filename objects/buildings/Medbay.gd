extends Building

const BUILDING_LIMIT := 1
const daily_colonist_healing_amt := 20


func _init():
	cost_to_build = 25
	bldg_name = "Medbay"
	bldg_desc = "Heals colonists by " + str(daily_colonist_healing_amt) + " per day"
	has_to_be_unlocked = true

func _process(delta):
	._process(delta)
	handle_energy_display(delta)
