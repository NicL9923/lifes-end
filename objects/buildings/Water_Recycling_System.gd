extends Building

export var water_produced_per_day := 10


func _ready():
	cost_to_build = 10
	connect_to_daynight_cycle()

func handle_new_day():
	Global.playerResources.water += water_produced_per_day
