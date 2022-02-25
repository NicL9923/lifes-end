extends Building

export var energy_produced := 250


func _init():
	cost_to_build = 200
	bldg_name = "Nuclear Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy"
	has_to_be_unlocked = true

func _ready():
	Global.playerResources.energy += energy_produced

func _exit_tree():
	Global.playerResources.energy -= energy_produced
