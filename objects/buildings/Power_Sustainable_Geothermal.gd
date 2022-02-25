extends Building

export var energy_produced := 75


func _init():
	cost_to_build = 75
	bldg_name = "Geothermal Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy"
	has_to_be_unlocked = true

func _ready():
	Global.playerResources.energy += energy_produced

func _exit_tree():
	Global.playerResources.energy -= energy_produced
