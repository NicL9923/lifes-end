extends Building

export var energy_produced := 5


func _init():
	cost_to_build = 15
	bldg_name = "Solar Array"
	bldg_desc = "Produces " + str(energy_produced) + " Energy"

func _ready():
	Global.playerResources.energy += (energy_produced * Global.modifiers.solarEnergyProduction)

func _exit_tree():
	Global.playerResources.energy -= (energy_produced * Global.modifiers.solarEnergyProduction)
