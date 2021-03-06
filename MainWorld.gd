extends Node2D

export var minerals_to_spawn := 30
export var npc_colonies_to_generate := 50
export var rsc_collection_sites_to_generate := 20
export var location_radius := 10
onready var tilemap := $Navigation2D/TileMap
onready var base_mgr := $BaseManager
onready var event_mgr := $EventManager
var build_hq_btn
var areThereRemainingMetalDeposits := true


func _ready():
	# Create a node to be the Global(ly instantiated) player if there isn't already one
	if not Global.player:
		Global.player = load("res://entities/player/Player.tscn").instance()
	get_tree().get_current_scene().add_child_below_node($Navigation2D, Global.player)
	
	Global.world_nav = $Navigation2D
	build_hq_btn = Global.player.build_hq_btn
	
	Global.generate_map_tiles(tilemap)
	
	Global.set_player_camera_bounds(tilemap.get_used_rect())
	
	if Global.isPlayerBaseFirstLoad:
		build_hq_btn.disabled = true
		build_hq_btn.visible = true
		
		spawn_metal_deposits()
		
		generate_npc_colonies()
		generate_resource_collection_sites()
		
		Global.player.global_position = Vector2(Global.cellSize * Global.world_tile_size.x / 2, Global.cellSize * Global.world_tile_size.y / 2)
		
		init_modifiers()
		
		Global.isPlayerBaseFirstLoad = false
	else:
		Global.player.global_position = Global.playerBaseData.lastPlayerPos
		
		load_buildings()
		load_colonists()
		
		if Global.playerBaseData.metalDeposits.size() == 0:
			areThereRemainingMetalDeposits = false
		else:
			re_spawn_metal_deposits()

func _process(_delta):
	if build_hq_btn.visible and Global.playerResources.metal >= Global.buildings.HQ.cost_to_build:
		build_hq_btn.disabled = false
	
	Global.playerBaseData.lastPlayerPos = Global.player.global_position
	
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
	
	Global.playerStats.max_health *= Global.player_stat_modifier_formula(Global.playerStats.doc)
	Global.player.health = Global.playerStats.max_health
	Global.modifiers.medbayHealing *= Global.player_stat_modifier_formula(Global.playerStats.doc)
	Global.modifiers.colonistMaxHealth *= Global.player_stat_modifier_formula(Global.playerStats.doc)
	Global.modifiers.playerHealthRecovery *= Global.player_stat_modifier_formula(Global.playerStats.doc)
	
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
		add_child_below_node($Navigation2D, metal_deposit)

func re_spawn_metal_deposits():
	for deposit_pos in Global.playerBaseData.metalDeposits:
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = deposit_pos
		add_child_below_node($Navigation2D, metal_deposit)

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
			num_colonists = rand_range(1, Global.max_colonists_at_npc_colony),
			resources = {
				metal = rand_range(25, 200),
				food = rand_range(10, 75),
				water = rand_range(15, 60)
			},
			col_name = "",
			isGood = true,
			isDestroyed = false
		}
		
		newNpcColony.planet = Global.planets[randomly_select_planet("colony")]
		
		newNpcColony.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
		newNpcColony.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		while not is_clear_of_other_locations(newNpcColony.coords.lat, newNpcColony.coords.long, newNpcColony.planet):
			newNpcColony.coords.lat = rand_range(Global.latitude_range[0], Global.latitude_range[1])
			newNpcColony.coords.long = rand_range(Global.longitude_range[0], Global.longitude_range[1])
		
		# Add buildings to NPC colony
			# NOTE: This should technically be using the SystemLocation tilemap, but they (MainWorld & that) are (as of writing this) the same, so it's fine FOR NOW
		newNpcColony.buildings.append({ type = "HQ", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
		newNpcColony.buildings.append({ type = "Barracks", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
		
		if rand_range(0, 100) < 30:
			newNpcColony.buildings.append({ type = "Science_Lab", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
			newNpcColony.buildings.append({ type = "Medbay", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
		if rand_range(0, 100) < 50:
			newNpcColony.buildings.append({ type = "Communications_Array", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
			newNpcColony.buildings.append({ type = "Shipyard", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
			
		
		if rand_range(0, 100) < 50:
			# Colony will have sustainable buildings
			for _x in range(1, 3):
				newNpcColony.buildings.append({ type = "Power_Sustainable_Solar", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
				
			newNpcColony.buildings.append({ type = "Power_Sustainable_Geothermal", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
		else:
			# Colony will have industrial buildings
			for _x in range(1, 3):
				newNpcColony.buildings.append({ type = "Power_Industrial_Coal", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
				
			newNpcColony.buildings.append({ type = "Power_Industrial_Gas", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
			
			if rand_range(0, 100) < 10:
				newNpcColony.buildings.append({ type = "Carbon_Scrubber", global_pos = Global.get_random_location_in_map(tilemap.get_used_rect()).snapped(Vector2.ONE * Global.cellSize) })
		
		newNpcColony.col_name = Global.colony_names.noun[int(rand_range(0, Global.colony_names.noun.size() - 1))]
		
		# Set 50% of NPC colonies to be bad/evil
		if rand_range(0, 100) < 50:
			newNpcColony.isGood = false
			newNpcColony.col_name = Global.colony_names.bad_adj[int(rand_range(0, Global.colony_names.bad_adj.size() - 1))] + " " + newNpcColony.col_name
		else:
			newNpcColony.col_name = Global.colony_names.good_adj[int(rand_range(0, Global.colony_names.good_adj.size() - 1))] + " " + newNpcColony.col_name
		
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
		var building_node = load("res://objects/buildings/Building.tscn").instance()
		building_node.init(bldg.type, Global.buildings[bldg.type], true)
		
		building_node.global_position = bldg.global_pos
		building_node.get_node("CollisionHighlight").visible = false
		base_mgr.add_building(building_node)
		add_child_below_node($Navigation2D, building_node)
		
		# Set tiles taken up by building on tilemap to tile/Concrete
		Global.set_building_tiles(tilemap, building_node)

func load_colonists():
	for colonist in Global.playerBaseData.colonists:
		var loaded_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
		loaded_colonist.ent_name = colonist.ent_name
		loaded_colonist.id = colonist.id
		loaded_colonist.health = colonist.health
		loaded_colonist.global_position = Global.get_position_in_radius_around(Global.player.global_position, 5)
		base_mgr.add_colonist(loaded_colonist)
		add_child_below_node($Navigation2D, loaded_colonist)
