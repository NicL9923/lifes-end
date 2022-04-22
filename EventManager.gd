extends Control

export var daily_event_chance := 0.15
onready var rain_particles := $ParticleFX/Rain_Particles
onready var pol_particles := $ParticleFX/Pollution_Particles

const events = {
	#npc_raid = { event_name = "NPC raid", chance = 0.3 },
	solar_flare = { event_name = "Solar flare", chance = 0.2 },
	heat_wave = { event_name = "Heat wave", chance = 0.1 },
	acidic_rain = { event_name = "Acidic rain", chance = 0.15 },
	intense_freeze = { event_name = "Intense freeze", chance = 0.15 }
}


func _ready():
	connect_to_daynight_cycle()
	
	# Set particle emitter sizes
	pol_particles.emission_rect_extents.x = Global.world_tile_size.x * Global.cellSize
	pol_particles.emission_rect_extents.y = Global.world_tile_size.y * Global.cellSize
	
	rain_particles.emission_rect_extents.x = Global.world_tile_size.x * Global.cellSize
	rain_particles.emission_rect_extents.y = Global.world_tile_size.y * Global.cellSize

func connect_to_daynight_cycle():
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

# Check if day will have event, and then check which event will happen
func handle_new_day():
	randomize()
	
	# Set pollution
	var cur_pol = Global.playerBaseData.pollutionLevel
	if cur_pol < 5.0:
		pol_particles.emitting = false
	else:
		pol_particles.emitting = true
		pol_particles.amount = int(Global.playerBaseData.pollutionLevel)
	
	# Handle events
	clean_up_prev_event()
	
	if rand_range(0, 1.0) < daily_event_chance:
		if Global.playerBaseData.planet == "Mercury" and rand_range(0, 1.0) < events.heat_wave.chance:
			event_heat_wave()
			return
		elif Global.playerBaseData.planet == "Venus" and rand_range(0, 1.0) < events.acidic_rain.chance * 2: # x2 represents higher chance of natural events on Venus
			event_acidic_rain()
			return
		elif Global.playerBaseData.planet == "Pluto" and rand_range(0, 1.0) < events.intense_freeze.chance:
			event_intense_freeze()
			return
		
		if rand_range(0, 1.0) < events.solar_flare.chance:
			event_solar_flare()
			return
		#else:
			#event_npc_raid()

func clean_up_prev_event():
	rain_particles.emitting = false

# Solar flare -> energy == 0
# Heat wave -> daily water cost 2.0x
# Intense freeze -> movement speed 0.5x; build_speed 0.5x; daily food cost 1.5x
# Acidic rain -> water production 0.75x; food 0.25x

func event_npc_raid():
	Global.push_player_notification("Your colony is under attack!")

func event_solar_flare():
	Global.push_player_notification("A solar flare is affecting your colony!")

# Mercury only
func event_heat_wave():
	Global.push_player_notification("Your colony is experiencing a heat wave!")

# Venus only
func event_acidic_rain():
	Global.push_player_notification("An acidic rain system is approaching your colony!")
	
	rain_particles.amount = 2500
	rain_particles.emitting = true

# Pluto only
func event_intense_freeze():
	Global.push_player_notification("Your region of Pluto is experiencing an intense freeze!")
