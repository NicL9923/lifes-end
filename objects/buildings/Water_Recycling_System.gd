extends Building

export var water_produced_per_day := 10


func _init():
	cost_to_build = 10
	bldg_name = "Water Recycling System"
	bldg_desc = "Produces " + str(water_produced_per_day) + " Water per day"

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_water(water_produced_per_day * Global.modifiers.waterProduction)
