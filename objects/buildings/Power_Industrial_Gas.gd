extends Building

export var energy_produced := 75
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 50
	bldg_name = "Gas Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy, and " + str(pollution_produced_per_day) + " Pollution per day"
	has_to_be_unlocked = true

func _ready():
	connect_to_daynight_cycle()
	Global.playerResources.energy += energy_produced

func _exit_tree():
	Global.playerResources.energy -= energy_produced

func handle_new_day():
	add_pollution(pollution_produced_per_day)
