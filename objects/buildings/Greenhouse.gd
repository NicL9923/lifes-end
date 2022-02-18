extends Building

export var food_produced_per_day := 5 # TODO: consider using this value in BuildingUI (so we just have to change it here)

func _init():
	cost_to_build = 10
	bldg_name = "Greenhouse"
	bldg_desc = "Produces " + str(food_produced_per_day * Global.modifiers.foodProduction) + " Food per day"

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_food(food_produced_per_day * Global.modifiers.foodProduction)
