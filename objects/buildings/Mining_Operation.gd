extends Building

export var metal_produced_per_day := 4
export var pollution_produced_per_day := 0.3

func _init():
	cost_to_build = 25
	bldg_name = "Mining Operation"
	bldg_desc = "Produces " + str(metal_produced_per_day) + " Metal and " + str(pollution_produced_per_day) + " Pollution per day"
	has_to_be_unlocked = true

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_metal(metal_produced_per_day)
	add_pollution(pollution_produced_per_day)
