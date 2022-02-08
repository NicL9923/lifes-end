extends CanvasModulate

signal day_has_passed

# NOTE: A game-day is 20mins long (1200 seconds) (0000 - 2400)

export var min_darkness := 0.4
var dark_value := 1.0

# Handles tracking game/time ticks and day/night darkness levels based on current planet
func _process(delta):
	if Global.game_time.ticks >= 2400.0:
		Global.game_time.ticks = 0.0
		Global.game_time.earthDays += 1
		emit_signal("day_has_passed")
	else:
		Global.game_time.ticks += delta * 2
	
	handle_daylight_based_on_planet(delta)

func handle_daylight_based_on_planet(delta):
	if Global.playerBaseData.planet == Global.planets[0]: # Mercury - 1/176 Earth time
		handle_planet_day_night_cycle(176)
	elif Global.playerBaseData.planet == Global.planets[1]: # Venus - 1/243 Earth time
		handle_planet_day_night_cycle(243)
	elif Global.playerBaseData.planet == Global.planets[2]: # Earth's Moon - 1/30 Earth time
		handle_planet_day_night_cycle(30)
	elif Global.playerBaseData.planet == Global.planets[3]: # Mars - essentially same as Earth
		if Global.game_time.ticks >= 1800:
			transition_to_night()
		elif Global.game_time.ticks >= 500:
			transition_to_day()
	elif Global.playerBaseData.planet == Global.planets[4]: # Pluto - 1/6 Earth time
		handle_planet_day_night_cycle(6)

func handle_planet_day_night_cycle(num_days_equal_to_one_earth_day):
	if (Global.game_time.earthDays / num_days_equal_to_one_earth_day) % 2 == 0:
		transition_to_day()
	else:
		transition_to_night()

func transition_to_day():
	dark_value = lerp(dark_value, 1.0, 0.005)
	self.color = Color(dark_value, dark_value, dark_value, 1)

func transition_to_night():
	dark_value = lerp(dark_value, min_darkness, 0.005)
	self.color = Color(dark_value, dark_value, dark_value, 1)
