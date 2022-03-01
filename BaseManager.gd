extends Control

var buildings := []
# TODO: may need to manage colonists here as well (for altering health, when we add more detailed backgrounds/names, pollution damage, etc)
	# Also to handle food/water consumption by player + colonists each day

# TODO: handle pollution visuals, and damage to player/colonists (daily check?)


func _ready():
	connect_to_daynight_cycle()

func _physics_process(_delta):
	print(buildings)
	handle_energy_production()
	
	handle_energy_distribution()

func connect_to_daynight_cycle():
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

func handle_new_day():
	handle_rsc_production()

# Iterate through buildings, and add resource of each type if it's in that building
	# NOTE: building nodes are responsible for maintaining how much they should be producing per day (i.e. based on bldg_level, etc)
func handle_rsc_production():
	for bldg in buildings:
		if bldg.has_energy:
			if "metal_produced_per_day" in bldg:
				add_metal(bldg.metal_produced_per_day)
			
			if "food_produced_per_day" in bldg:
				add_food(bldg.food_produced_per_day)
			
			if "water_produced_per_day" in bldg:
				add_water(bldg.water_produced_per_day)
			
			if "pollution_produced_per_day" in bldg:
				add_pollution(bldg.pollution_produced_per_day)
			
			if "pollution_removed_per_day" in bldg:
				remove_pollution(bldg.pollution_removed_per_day)

func handle_energy_production():
	var total_energy_produced := 0
	
	for bldg in buildings:
		if "energy_produced" in bldg:
			total_energy_produced += bldg.energy_produced
	
	Global.playerResources.energy = total_energy_produced

# Currently just distributes power in order - in future, TODO: will give player some influence over power distribution preference
func handle_energy_distribution():
	for bldg in buildings:
		# Handle not having enough remaining energy for this bldg (other than rsc production (i.e. btns), offload handling of no energy to specific bldgs)
		if Global.playerResources.energy - bldg.energy_cost_to_run < 0:
			bldg.has_energy = false
		else:
			bldg.has_energy = true
			Global.playerResources.energy -= bldg.energy_cost_to_run

# Called in MainWorld + BuildingUI when building is initially placed or loaded
func add_building(bldg_node):
	buildings.append(bldg_node)

# Called when PLAYER removes building (not when they're unloaded from a scene tree)
func remove_building(bldg_node):
	buildings.erase(bldg_node)

func add_metal(amt: int):
	Global.playerResources.metal += amt

func add_energy(amt: int):
	Global.playerResources.energy += amt

func add_food(amt: int):
	Global.playerResources.food += (amt * Global.modifiers.foodProduction)

func add_water(amt: int):
	Global.playerResources.water += (amt * Global.modifiers.waterProduction)

func add_pollution(amt: float):
	var cur_pol = Global.playerBaseData.pollutionLevel
	cur_pol = clamp(cur_pol + amt, 0, 100)

func remove_pollution(amt: float):
	var cur_pol = Global.playerBaseData.pollutionLevel
	cur_pol = clamp(cur_pol - amt, 0, 100)
