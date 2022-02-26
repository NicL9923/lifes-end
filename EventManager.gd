extends Control

export var daily_event_chance := 0.15
const events = {
	npc_raid = { event_name = "NPC raid", chance = 0.4 },
	solar_flare = { event_name = "Solar flare", chance = 0.33 },
	acidic_dust_storm = { event_name = "Acidic dust storm", chance = 0.2 },
	intense_freeze = { event_name = "Intense freeze", chance = 0.2 }
}


func _ready():
	connect_to_daynight_cycle()

func connect_to_daynight_cycle():
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

# Check if day will have event, and then check which event will happen
func handle_new_day():
	randomize()
	
	if rand_range(0, 1.0) < daily_event_chance:
		if Global.playerBaseData.planet == "Venus" and rand_range(0, 1.0) < events.acidic_dust_storm.chance:
			event_acidic_dust_storm()
			return
		elif Global.playerBaseData.planet == "Pluto" and rand_range(0, 1.0) < events.intense_freeze.chance:
			event_intense_freeze()
			return
		
		if rand_range(0, 1.0) < events.solar_flare.chance:
			event_solar_flare()
			return
		else:
			event_npc_raid()

func event_npc_raid():
	Global.push_player_notification("Your colony is under attack!")

func event_solar_flare():
	Global.push_player_notification("A solar flare is affecting your colony!")

# Venus only
func event_acidic_dust_storm():
	Global.push_player_notification("An acidic dust storm is approaching your colony!")

# Pluto only
func event_intense_freeze():
	Global.push_player_notification("Your region of Pluto is experiencing an intense freeze!")
