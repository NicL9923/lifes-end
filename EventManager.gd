extends Control

export var daily_event_chance := 0.15
onready var rain_particles := $ParticleFX/Rain_Particles

const events = {
	npc_raid = { event_name = "NPC raid", chance = 0.4 },
	solar_flare = { event_name = "Solar flare", chance = 0.33 },
	acidic_rain = { event_name = "Acidic rain", chance = 0.2 },
	intense_freeze = { event_name = "Intense freeze", chance = 0.2 }
}


func _ready():
	connect_to_daynight_cycle()

func connect_to_daynight_cycle():
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

# Check if day will have event, and then check which event will happen
func handle_new_day():
	randomize()
	
	clean_up_prev_event()
	
	if rand_range(0, 1.0) < daily_event_chance:
		if Global.playerBaseData.planet == "Venus" and rand_range(0, 1.0) < events.acidic_rain.chance:
			event_acidic_rain()
			return
		elif Global.playerBaseData.planet == "Pluto" and rand_range(0, 1.0) < events.intense_freeze.chance:
			event_intense_freeze()
			return
		
		if rand_range(0, 1.0) < events.solar_flare.chance:
			event_solar_flare()
			return
		else:
			event_npc_raid()

func clean_up_prev_event():
	rain_particles.emitting = false

func event_npc_raid():
	Global.push_player_notification("Your colony is under attack!")

func event_solar_flare():
	Global.push_player_notification("A solar flare is affecting your colony!")

# Venus only
func event_acidic_rain():
	Global.push_player_notification("An acidic rain system is approaching your colony!")
	
	rain_particles.process_material.emission_box_extents.x = Global.world_tile_size.x * Global.cellSize
	rain_particles.process_material.emission_box_extents.y = Global.world_tile_size.y * Global.cellSize
	rain_particles.global_position = Global.world_tile_size * Global.cellSize / 2
	
	rain_particles.amount = 2000
	rain_particles.emitting = true

# Pluto only
func event_intense_freeze():
	Global.push_player_notification("Your region of Pluto is experiencing an intense freeze!")
