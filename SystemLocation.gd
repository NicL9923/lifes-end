extends Node2D

onready var tilemap = get_node("Navigation2D/TileMap")
var are_enemies_present := false
var remaining_enemies := 0
var isARaid := false
var location_type: String
var location_index: int
var colony_destroyed := false


func _ready():
	get_tree().get_current_scene().add_child(Global.player)
	
	location_type = Global.location_to_load.type
	location_index = Global.location_to_load.index
	isARaid = Global.location_to_load.isRaiding
	
	Global.world_nav = $Navigation2D
	Global.player.global_position = Vector2(Global.cellSize * Global.world_tile_size.x / 2, Global.cellSize * Global.world_tile_size.y / 2)
	
	Global.generate_map_tiles(tilemap)
	
	if location_type == Global.location_type.npcColony:
		load_npc_colony()
	elif location_type == Global.location_type.rscSite:
		load_resource_collection_site()
	else:
		print("You screwed something up really bad if you're seeing this...")
	
	Global.set_player_camera_bounds(tilemap.get_used_rect())

func _process(_delta):
	var enemy_count := 0
	if isARaid:
		for node in get_children():
			if node.is_in_group("enemy"):
				enemy_count +=1
		
		remaining_enemies = enemy_count
		
		if remaining_enemies == 0 and not colony_destroyed:
			Global.player.rtb_btn.visible = true
			colony_destroyed = true # Only trigger this block once after all enemies have been deaded
			Global.npcColonyData[location_index].isDestroyed = true
			are_enemies_present = false
			Global.player.toggle_combat(false)
			Global.push_player_notification("You successfully overtook the colony!")
			
			# Transfer the colony's resources to the player
			Global.change_metal_by(Global.npcColonyData[location_index].resources.metal)
			Global.change_food_by(Global.npcColonyData[location_index].resources.food)
			Global.change_water_by(Global.npcColonyData[location_index].resources.water)
			
			Global.push_player_notification("Looted " + str(Global.npcColonyData[location_index].resources.metal) + " metal, " + str(Global.npcColonyData[location_index].resources.food) + " food, " + str(Global.npcColonyData[location_index].resources.water) + " water")

func load_npc_colony():
	Global.player.rtb_btn.visible = !isARaid
	var npcColony = Global.npcColonyData[Global.location_to_load.index]
	Global.player.trade_ui.npc_col_id = Global.location_to_load.index
	
	spawn_buildings(npcColony.buildings)
	spawn_colonists(npcColony.num_colonists)
	
	load_player_colonists()
	
	if isARaid:
		are_enemies_present = true
		Global.player.toggle_combat(are_enemies_present)
		
		if not npcColony.isGood:
			Global.add_player_humanity(10)
			Global.push_player_notification("Your humanity increased by 10!")
		else:
			Global.add_player_humanity(-25)
			Global.push_player_notification("Your humanity decreased by 25.")

func load_resource_collection_site():
	Global.player.rtb_btn.visible = true
	var rscSite = Global.rscCollectionSiteData[Global.location_to_load.index]
	
	spawn_metal_deposits(rscSite.numMetalDeposits)
	
	# TODO: random chance enemies spawn!
	
	Global.rscCollectionSiteData.pop_at(Global.location_to_load.index) # Remove the site after player visits it


func spawn_buildings(bldg_list: Array):
	for bldg in bldg_list:
		var building_node = load("res://objects/buildings/Building.tscn").instance()
		building_node.init(bldg.type, Global.buildings[bldg.type])
		
		building_node.global_position = bldg.global_pos
		add_child(building_node)
		
		# Set tiles taken up by building on tilemap to tile/Concrete
		var bldg_tile_size = building_node.bldg_size / Global.cellSize
		if int(bldg_tile_size.x) % 2 == 1:
			building_node.global_position.x += 16
		if int(bldg_tile_size.y) % 2 == 1:
			building_node.global_position.y += 16
		
		Global.set_building_tiles(tilemap, building_node)
		Global.set_building_tiles(tilemap, building_node)

func spawn_colonists(num_colonists: int):
	for _i in range(num_colonists):
		var new_colonist
		
		if isARaid:
			new_colonist = load("res://entities/enemies/EnemyColonist.tscn").instance()
		else:
			new_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
		
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
		loaded_colonist.ent_name = colonist.ent_name
		loaded_colonist.id = colonist.id
		loaded_colonist.health = colonist.health
		loaded_colonist.global_position = Global.get_position_in_radius_around(Global.player.global_position, 5)
		add_child(loaded_colonist)
