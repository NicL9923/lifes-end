extends Node2D

onready var tilemap = get_node("Navigation2D/TileMap")
var are_enemies_present := false


func _ready():
	if Global.location_to_load.type == Global.location_type.npcColony:
		load_npc_colony()
	elif Global.location_to_load.type == Global.location_type.rscSite:
		load_resource_collection_site()
	else:
		print("You screwed something up really bad if you're seeing this...")
	
	set_player_camera_bounds()
	
	Global.world_nav = $Navigation2D
	$Player.global_position = Vector2(Global.cellSize * Global.world_tile_size.x / 2, Global.cellSize * Global.world_tile_size.y / 2)

func _process(delta):
	pass # TODO: check if npc colony gets destroyed -> if so, set "isDestroyed" flag to true


func load_planet(planet):
	tilemap.tile_set = load("res://objects/planets/tilesets/" + planet + "_Tileset.tres")
	
	generate_map_border_tiles()
	generate_map_inner_tiles()

func load_npc_colony():
	var npcColony = Global.npcColonyData[Global.location_to_load.index]
	
	load_planet(npcColony.planet)
	
	spawn_buildings(npcColony.buildings)
	spawn_colonists()
	
	are_enemies_present = true
	Global.player.toggle_combat(are_enemies_present)

func load_resource_collection_site():
	var rscSite = Global.rscCollectionSiteData[Global.location_to_load.index]
	
	load_planet(rscSite.planet)
	
	spawn_metal_deposits(rscSite.numMetalDeposits)
	
	Global.rscCollectionSiteData.pop_at(Global.location_to_load.index) # Remove the site after player visits it


func spawn_buildings(bldg_list: Array):
	for bldg in bldg_list:
		var building_node = load("res://objects/buildings/" + Global.bldg_names[bldg.type] + ".tscn").instance()
		building_node.global_position = get_random_location_in_map()
		# TODO: set building level
		get_tree().get_root().get_child(1).add_child(building_node)

# NOTE: Until this changes, this is just randomly decided (i.e. not saved/persisted) on loading the colony
func spawn_colonists():
	for _i in range(Global.max_colonists_at_npc_colony):
		var new_colonist = load("res://entities/enemies/Dummy/DummyEnemy.tscn").instance()
		new_colonist.global_position = get_random_location_in_map()
		get_tree().get_root().get_child(1).add_child(new_colonist)

func spawn_metal_deposits(numMetalDeposits: int):
	for _i in range(numMetalDeposits):
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = get_random_location_in_map()
		get_tree().get_root().get_child(1).add_child(metal_deposit)

func get_random_location_in_map():
	randomize()
	var map_limits = tilemap.get_used_rect()
	
	return Vector2(rand_range(map_limits.position.x * (Global.cellSize + 1), map_limits.end.x * (Global.cellSize - 1)), rand_range(map_limits.end.y * (Global.cellSize + 1), map_limits.position.y * (Global.cellSize - 1)))

func set_player_camera_bounds():
	var map_limits = tilemap.get_used_rect()
	$Player/Camera2D.limit_left = map_limits.position.x * Global.cellSize
	$Player/Camera2D.limit_right = map_limits.end.x * Global.cellSize
	$Player/Camera2D.limit_top = map_limits.position.y * Global.cellSize
	$Player/Camera2D.limit_bottom = map_limits.end.y * Global.cellSize

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
