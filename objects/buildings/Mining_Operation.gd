extends Building

export var metal_produced_per_day := 4


func _init():
	cost_to_build = 25

func _ready():
	connect_to_daynight_cycle()

func handle_new_day():
	add_metal(metal_produced_per_day)
