extends Control

export var daily_food_water_usage := 2
export var min_health_from_base_stuff := 25
export var daily_dmg_from_no_food_water := 15
export var daily_dmg_from_pollution := 10
var buildings := []
var colonists := []


func _ready():
	connect_to_daynight_cycle()

func _process(_delta):
	handle_energy_production()
	
	handle_energy_distribution()

func connect_to_daynight_cycle():
# warning-ignore:return_value_discarded
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

func handle_new_day():
	handle_rsc_production()
	handle_medbay()
	handle_pollution_damage()
	handle_food_and_water_usage()

# Iterate through buildings, and add resource of each type if it's in that building
	# NOTE: building nodes are responsible for maintaining how much they should be producing per day (i.e. based on bldg_level, etc)
func handle_rsc_production():
	for bldg in buildings:
		if is_instance_valid(bldg) and bldg.has_energy and not bldg.isBeingPlaced and not bldg.isBeingBuilt:
			if bldg.metal_produced_per_day != null:
				add_metal(bldg.metal_produced_per_day)
			
			if bldg.food_produced_per_day != null:
				add_food(bldg.food_produced_per_day)
			
			if bldg.water_produced_per_day != null:
				add_water(bldg.water_produced_per_day)
			
			if bldg.pollution_produced_per_day != null:
				add_pollution(bldg.pollution_produced_per_day)
			
			if bldg.pollution_removed_per_day != null:
				remove_pollution(bldg.pollution_removed_per_day)

func handle_energy_production():
	var total_energy_produced := 0
	
	for bldg in buildings:
		if is_instance_valid(bldg) and bldg.energy_produced != null and not bldg.isBeingPlaced and not bldg.isBeingBuilt:
			total_energy_produced += bldg.energy_produced
	
	Global.playerResources.energy = total_energy_produced

# Currently just distributes power in order - in future, TODO: will give player some influence over power distribution preference
func handle_energy_distribution():
	for bldg in buildings:
		if not is_instance_valid(bldg):
			continue
		
		if bldg.energy_produced != null:
			continue # Skip energy-producing buildings
		
		# Handle not having enough remaining energy for this bldg (other than rsc production (i.e. btns), offload handling of no energy to specific bldgs)
		if Global.playerResources.energy - bldg.energy_cost_to_run < 0:
			bldg.has_energy = false
		else:
			bldg.has_energy = true
			Global.playerResources.energy -= bldg.energy_cost_to_run

# Called in MainWorld + BuildingUI when building is initially placed or loaded
func add_building(bldg_node):
	buildings.append(bldg_node)

func add_colonist(colonist_node):
	colonists.append(colonist_node)

# Called when PLAYER removes building (not when they're unloaded from a scene tree)
func remove_building(bldg_node):
	buildings.erase(bldg_node)

func add_metal(amt: int):
	Global.change_metal_by(amt)

func add_energy(amt: int):
	Global.playerResources.energy += amt

func add_food(amt: int):
	Global.change_food_by(amt * Global.modifiers.foodProduction)

func add_water(amt: int):
	Global.change_water_by(amt * Global.modifiers.waterProduction)

func add_pollution(amt: float):
	var cur_pol = Global.playerBaseData.pollutionLevel
	cur_pol = clamp(cur_pol + amt, 0, 100)
	Global.playerBaseData.pollutionLevel = cur_pol

func remove_pollution(amt: float):
	var cur_pol = Global.playerBaseData.pollutionLevel
	cur_pol = clamp(cur_pol - amt, 0, 100)
	Global.playerBaseData.pollutionLevel = cur_pol

func change_colonists_health(amt: int):
	Global.player.health = clamp(Global.player.health + amt, min_health_from_base_stuff, Global.playerStats.max_health)
	
	for colonist in colonists:
		colonist.health = clamp(colonist.health + amt, min_health_from_base_stuff, colonist.max_health)
		Global.playerBaseData.colonists[colonist.id].health = colonist.health

func handle_food_and_water_usage():
	var take_dmg_for_no_rscs := false
	
	var total_colonist_usage = (1 + Global.playerBaseData.colonists.size()) * daily_food_water_usage
	if Global.playerResources.food - total_colonist_usage < 0:
		Global.playerResources.food = 0
		Global.push_player_notification("You've run out of food!")
		
		take_dmg_for_no_rscs = true
	else:
		Global.change_food_by(-total_colonist_usage)
	
	
	if Global.playerResources.water - total_colonist_usage < 0:
		Global.playerResources.water = 0
		Global.push_player_notification("You've run out of water!")
		
		take_dmg_for_no_rscs = true
	else:
		Global.change_water_by(-total_colonist_usage)
	
	# TODO: add a water cost to greenhouse food production?
	
	# Don't stack damage if we're out of both food AND water, just do it once
	if take_dmg_for_no_rscs:
		change_colonists_health(-1 * daily_dmg_from_no_food_water)

func handle_pollution_damage():
	# Multiply daily pollution damage by percent player base is polluted
	change_colonists_health(-1 * daily_dmg_from_pollution * Global.playerBaseData.pollutionLevel * Global.modifiers.pollutionDamage)

# Medbay just going to heal colonists - player heals over time
func handle_medbay():
	for bldg in buildings:
		if is_instance_valid(bldg) and bldg.daily_colonist_healing_amt != null and not bldg.isBeingPlaced and not bldg.isBeingBuilt:
			# If we find a/the medbay (which will have the above property), go ahead and heal colonists (daily)
			change_colonists_health(bldg.daily_colonist_healing_amt * Global.modifiers.medbayHealing)
			return
