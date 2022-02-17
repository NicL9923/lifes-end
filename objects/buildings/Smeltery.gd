extends Building

export var metal_produced_per_day := 2


func _init():
	cost_to_build = 20
	bldg_name = "Smeltery"
	bldg_desc = "Produces " + str(metal_produced_per_day) + " Metal per day"

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_metal(metal_produced_per_day)