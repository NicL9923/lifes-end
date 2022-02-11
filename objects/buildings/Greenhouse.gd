extends Building

export var food_produced_per_day := 5 # TODO: consider using this value in BuildingUI (so we just have to change it here)

func _ready():
	cost_to_build = 10
	connect_to_daynight_cycle()

func handle_new_day():
	add_food(food_produced_per_day * Global.modifiers.foodProduction)
