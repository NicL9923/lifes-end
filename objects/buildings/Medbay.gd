extends Building

const BUILDING_LIMIT := 1


func _init():
	cost_to_build = 25
	bldg_name = "Medbay"
	bldg_desc = "Heals the player and their colonists"
	has_to_be_unlocked = true
