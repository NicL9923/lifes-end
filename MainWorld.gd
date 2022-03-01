extends Node2D

export var minerals_to_spawn := 30
export var npc_colonies_to_generate := 50
export var rsc_collection_sites_to_generate := 20
export var location_radius := 10
onready var tilemap = get_node("Navigation2D/TileMap")
onready var build_hq_btn := Global.player.get_node("UI/BuildingUI/Build_HQ_Button")
var areThereRemainingMetalDeposits := true

# TODO: handle pollution visuals, and damage to player/colonists (daily check?)


func _ready():
	Global.player = $Player
	Global.world_nav = $Navigation2D
	
	var planet = Global.playerBaseData.planet
	
	Global.generate_map_tiles(tilemap)
	
	Global.set_player_camera_bounds(tilemap.get_used_rect())
	
	if Global.isPlayerBaseFirstLoad:
		build_hq_btn.disabled = true
		build_hq_btn.visible = true
		
		spawn_metal_deposits()
		
		generate_npc_colonies()
		generate_resource_collection_sites()
		
		$Player.global_position = Vector2(Global.cellSize * Global.world_tile_size.x / 2, Global.cellSize * Global.world_tile_size.y / 2)
		
		init_modifiers()
		
		Global.isPlayerBaseFirstLoad = false
	else:
		$Player.global_position = Global.playerBaseData.lastPlayerPos
		
		load_buildings()
		load_colonists()
		
		if Global.playerBaseData.metalDeposits.size() == 0:
			areThereRemainingMetalDeposits = false
		else:
			re_spawn_metal_deposits()

func _physics_process(_delta):
	if build_hq_btn.visible and Global.playerResources.metal >= Global.cost_to_build_HQ:
		build_hq_btn.disabled = false
	
	Global.playerBaseData.lastPlayerPos = $Player.global_position
	
	if areThereRemainingMetalDeposits:
		var updatedMetalDepositArr := []
		for node in get_children():
			if node.is_in_group("metal_deposit"):
				updatedMetalDepositArr.append(node.global_position)
		Global.playerBaseData.metalDeposits = updatedMetalDepositArr

func init_modifiers():
	# Set modifiers based on player stats/attributes
	Global.modifiers.playerTeamWeaponDamage *= Global.player_stat_modifier_formula(Global.playerStats.cmdr) # TODO (cmdr): allied colonists shoot faster
	
	Global.modifiers.buildSpeed *= Global.player_stat_modifier_formula(Global.playerStats.engr) # TODO (engr): faster industrial research
	
	Global.modifiers.foodProduction *= Global.player_stat_modifier_formula(Global.playerStats.biol) # TODO (biol): faster SUSTAINABLE research modifier
	Global.modifiers.waterProduction *= Global.player_stat_modifier_formula(Global.playerStats.biol)
	
	Global.playerStats.max_health *= Global.player_stat_modifier_formula(Global.playerStats.doc) # TODO (doc): increased max health for allied colonists too + faster health recovery for player only + more effective medbay
	
	# Set Global.modifiers based on planet traits
	match Global.playerBaseData.planet:
		"Mercury":
			Global.modifiers.solarEnergyProduction *= 2.5
		"Venus":
			pass # TODO: more natural events - less raids
		"Earth's Moon":
			Global.modifiers.solarEnergyProduction *= 0.75
		"Mars":
			Global.modifiers.waterProduction *= 2.0
		"Pluto":
			pass

func spawn_metal_deposits():
	for _i in range(0, minerals_to_spawn):
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = Global.get_random_location_in_map(tilemap.get_used_rect())
		metal_deposit.add_to_group("metal_deposit")
		add_child(metal_deposit)

func re_spawn_metal_deposits():
	for deposit_pos in Global.playerBaseData.metalDeposits:
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = deposit_pos
		add_child(metal_deposit)

func randomly_select_planet(bias: String):
	randomize()
	var prob_biases: Array
	
	if bias == "colony":
		prob_biases = Global.colony_biases
	elif bias == "rsc_site":
		prob_biases = Global.rsc_site_biases
	else:
		return 0
	
	var planet_rand = rand_range(1, 100)
	if planet_rand < prob_biases[0]:
		return 0
	elif planet_rand < prob_biases[1]:
		return 1
	elif planet_rand < prob_biases[2]:
		return 2
	elif planet_rand < prob_biases[3]:
		return 3
	elif planet_rand < prob_biases[4]:
		return 4

func is_clear_of_other_locations(new_lat, new_long, new_planet):
	var is_clear := true
	
	for colony in Global.npcColonyData:
		if colony.planet == new_planet:
			if abs(new_lat - colony.coords.lat) < location_radius and abs(new_long - colony.coords.long) < location_radius:
				is_clear = false
				
	for site in Global.rscCollectionSiteData:
		if site.planet == new_planet:
			if abs(new_lat - site.coords.lat) < location_radius and abs(new_long - site.coords.long) < location_radius:
				is_clear = false
	
	return is_clear

func generate_npc_colonies():
	randomize()
	
	for _i in range(1, npc_colonies_to_generate):
		var newNpcColony = {
			planet = "",
			coords = { lat = 0, long = 0 },
			buildings = [],
			isDestroyed = false
		}
		
		newNpcColony.planet = Global.planets[randomly_select_planet("colony")]
		
		newNpcColony.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
		newNpcColony.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		while not is_clear_of_other_locations(newNpcColony.coords.lat, newNpcColony.coords.long, newNpcColony.planet):
			newNpcColony.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
			newNpcColony.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		# TODO: Randomly generate other buildings within npc colony
			# NOTE: currently randomly setting building locations in SystemLocation.gd
		newNpcColony.buildings.append({ type = Global.BUILDING_TYPES.HQ, global_pos = Vector2(0, 0), building_lvl = 1 })
		newNpcColony.buildings.append({ type = Global.BUILDING_TYPES.Barracks, global_pos = Vector2(0, 0), building_lvl = 1 })
		
		Global.npcColonyData.append(newNpcColony)

func generate_resource_collection_sites():
	randomize()
	
	for _i in range(1, rsc_collection_sites_to_generate):
		var newRscSite = {
			planet = "",
			coords = { lat = 0, long = 0 },
			numMetalDeposits = 0
		}
		
		newRscSite.planet = Global.planets[randomly_select_planet("rsc_site")]
		
		newRscSite.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
		newRscSite.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		while not is_clear_of_other_locations(newRscSite.coords.lat, newRscSite.coords.long, newRscSite.planet):
			newRscSite.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
			newRscSite.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		newRscSite.numMetalDeposits = rand_range(1, Global.max_deposits_at_rsc_site)
		
		Global.rscCollectionSiteData.append(newRscSite)

func load_buildings():
	for bldg in Global.playerBaseData.buildings:
		var building_node = load("res://objects/buildings/" + Global.BUILDING_TYPES[bldg.type] + ".tscn").instance()
		building_node.global_position = bldg.global_pos
		building_node.isPlayerBldg = true
		building_node.bldgLvl = bldg.building_lvl
		building_node.get_node("CollisionHighlight").visible = false
		Global.player.base_manager.add_building(building_node)
		add_child(building_node)

func load_colonists():
	for colonist in Global.playerBaseData.colonists:
		var loaded_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
		loaded_colonist.id = colonist.id
		loaded_colonist.health = colonist.health
		loaded_colonist.global_position = Global.get_position_in_radius_around(Global.player.global_position, 5)
		add_child(loaded_colonist)
