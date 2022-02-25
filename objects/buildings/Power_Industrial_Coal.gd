extends Building

export var energy_produced := 20
export var pollution_produced_per_day := 0.1


func _init():
	cost_to_build = 15
	bldg_name = "Coal Power Plant"
	bldg_desc = "Produces " + str(energy_produced) + " Energy, and " + str(pollution_produced_per_day) + " Pollution per day"

func _ready():
	connect_to_daynight_cycle()
	Global.playerResources.energy += energy_produced

func _exit_tree():
	Global.playerResources.energy -= energy_produced

func handle_new_day():
	add_pollution(pollution_produced_per_day)
