extends Node2D

onready var tilemap = get_node("Navigation2D/TileMap")
var are_enemies_present := false
var remaining_enemies := 0
var isARaid := false
var location_type: String
var location_index: int


func _ready():
	location_type = Global.location_to_load.type
	location_index = Global.location_to_load.index
	
	Global.world_nav = $Navigation2D
	$Player.global_position = Vector2(Global.cellSize * Global.world_tile_size.x / 2, Global.cellSize * Global.world_tile_size.y / 2)
	Global.player = $Player
	
	if location_type == Global.location_type.npcColony:
		load_npc_colony()
	elif location_type == Global.location_type.rscSite:
		load_resource_collection_site()
	else:
		print("You screwed something up really bad if you're seeing this...")
	
	Global.set_player_camera_bounds(tilemap.get_used_rect())

func _physics_process(_delta):
	$Player.get_node("UI/RTB_Button").visible = !are_enemies_present
	
	var enemy_count := 0
	if isARaid:
		for node in get_children():
			if node.is_in_group("enemy"):
				enemy_count +=1
		
		remaining_enemies = enemy_count
		
		if remaining_enemies == 0:
			Global.npcColonyData[location_index].isDestroyed = true
			are_enemies_present = false
			Global.player.toggle_combat(false)


func load_planet(planet):
	tilemap.tile_set = load("res://objects/planets/tilesets/" + planet + "_Tileset.tres")
	
	generate_map_border_tiles()
	generate_map_inner_tiles()

func load_npc_colony():
	var npcColony = Global.npcColonyData[Global.location_to_load.index]
	
	load_planet(npcColony.planet)
	
	spawn_buildings(npcColony.buildings)
	spawn_colonists()
	
	load_player_colonists()
	
	isARaid = true
	are_enemies_present = true
	Global.player.toggle_combat(are_enemies_present)

func load_resource_collection_site():
	var rscSite = Global.rscCollectionSiteData[Global.location_to_load.index]
	
	load_planet(rscSite.planet)
	
	spawn_metal_deposits(rscSite.numMetalDeposits)
	
	# TODO: random chance enemies spawn!
	
	Global.rscCollectionSiteData.pop_at(Global.location_to_load.index) # Remove the site after player visits it


func spawn_buildings(bldg_list: Array):
	for bldg in bldg_list:
		var building_node = load("res://objects/buildings/" + Global.BUILDING_TYPES[bldg.type] + ".tscn").instance()
		building_node.global_position = Global.get_random_location_in_map(tilemap.get_used_rect())
		building_node.bldgLvl = 1
		add_child(building_node)

# NOTE: Until this changes, this is just randomly decided (i.e. not saved/persisted) on loading the colony
func spawn_colonists():
	var num_colonists = rand_range(1, Global.max_colonists_at_npc_colony)
	for _i in range(num_colonists):
		var new_colonist = load("res://entities/enemies/EnemyColonist.tscn").instance()
		new_colonist.global_position = Global.get_random_location_in_map(tilemap.get_used_rect())
		add_child(new_colonist)
		
		remaining_enemies += 1

func spawn_metal_deposits(numMetalDeposits: int):
	for _i in range(numMetalDeposits):
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = Global.get_random_location_in_map(tilemap.get_used_rect())
		add_child(metal_deposit)

func load_player_colonists():
	for colonist in Global.playerBaseData.colonists:
		var loaded_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
		loaded_colonist.id = colonist.id
		loaded_colonist.health = colonist.health
		loaded_colonist.global_position = Global.get_position_in_radius_around(Global.player.global_position, 5)
		add_child(loaded_colonist)

func generate_map_border_tiles():
	for x in [0, Global.world_tile_size.x - 1]:
		for y in range(0, Global.world_tile_size.y):
			tilemap.set_cell(x, y, 0)
	
	for x in range(1, Global.world_tile_size.x - 1):
		for y in [0, Global.world_tile_size.y - 1]:
			tilemap.set_cell(x, y, 0)

func generate_map_inner_tiles():
		for x in range(1, Global.world_tile_size.x - 1):
			for y in range(1, Global.world_tile_size.y - 1):
				tilemap.set_cell(x, y, 1)
