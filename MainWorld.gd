extends Node2D

var worldTileSize := Global.world_tile_size
export var minerals_to_spawn := 30
export var npc_colonies_to_generate := 50
export var rsc_collection_sites_to_generate := 20
onready var tilemap = get_node("Navigation2D/TileMap")
var areThereRemainingMetalDeposits := true


func _ready():
	Global.world_nav = $Navigation2D
	
	var planet = Global.playerBaseData.planet
	#TODO: may be worth just merging all planet tiles into single tileset if they all have 1 to 4 tiles at most...
	tilemap.tile_set = load("res://objects/planets/tilesets/" + planet + "_Tileset.tres")
	
	generate_map_border_tiles()
	generate_map_inner_tiles()
	
	set_player_camera_bounds()
	
	if Global.isPlayerBaseFirstLoad:
		$Player/UI/BuildingUI/Build_HQ_Button.disabled = true
		$Player/UI/BuildingUI/Build_HQ_Button.visible = true
		
		spawn_metal_deposits()
		
		generate_npc_colonies()
		generate_resource_collection_sites()
		
		$Player.global_position = Vector2(Global.cellSize * worldTileSize.x / 2, Global.cellSize * worldTileSize.y / 2)
		
		# TODO: set Global.modifiers based on player stats
		
		Global.isPlayerBaseFirstLoad = false
	else:
		load_buildings()
		# TODO: load_colonists()
		
		if Global.playerBaseData.metalDeposits.size() == 0:
			areThereRemainingMetalDeposits = false
		else:
			re_spawn_metal_deposits()
		
		$Player.global_position = Global.playerBaseData.lastPlayerPos

func _physics_process(_delta):
	if $Player/UI/BuildingUI/Build_HQ_Button.visible and Global.playerResources.metal >= Global.cost_to_build_HQ:
		$Player/UI/BuildingUI/Build_HQ_Button.disabled = false
	
	Global.playerBaseData.lastPlayerPos = $Player.global_position
	
	if areThereRemainingMetalDeposits:
		var updatedMetalDepositArr := []
		for node in get_children():
			if node.is_in_group("metal_deposit"):
				updatedMetalDepositArr.append(node.global_position)
		Global.playerBaseData.metalDeposits = updatedMetalDepositArr

func generate_map_border_tiles():
	for x in [0, worldTileSize.x - 1]:
		for y in range(0, worldTileSize.y):
			tilemap.set_cell(x, y, 0)
	
	for x in range(1, worldTileSize.x - 1):
		for y in [0, worldTileSize.y - 1]:
			tilemap.set_cell(x, y, 0)

func generate_map_inner_tiles():
		for x in range(1, worldTileSize.x - 1):
			for y in range(1, worldTileSize.y - 1):
				tilemap.set_cell(x, y, 1)

func set_player_camera_bounds():
	var map_limits = tilemap.get_used_rect()
	$Player/Camera2D.limit_left = map_limits.position.x * Global.cellSize
	$Player/Camera2D.limit_right = map_limits.end.x * Global.cellSize
	$Player/Camera2D.limit_top = map_limits.position.y * Global.cellSize
	$Player/Camera2D.limit_bottom = map_limits.end.y * Global.cellSize

func spawn_metal_deposits():
	randomize()
	var map_limits = tilemap.get_used_rect()
	
	for _i in range(0, minerals_to_spawn):
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = Vector2(rand_range(map_limits.position.x * (Global.cellSize + 1), map_limits.end.x * (Global.cellSize - 1)), rand_range(map_limits.end.y * (Global.cellSize + 1), map_limits.position.y * (Global.cellSize - 1)))
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
		
		# TODO: check to make sure not adding colonies within a certain radius of one another
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
		
		# TODO: check to make sure not adding sites within a certain radius of one another, or of npc colonies
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
		get_tree().get_root().get_child(1).add_child(building_node)

func save_game():
	var save_game = File.new()
	
	for i in range(1, Global.MAX_SAVES):
		var save_name = "user://save" + String(i) + ".save"
		
		if not save_game.file_exists(save_name):
			save_game.open(save_name, File.WRITE)
			
			# This is what contains all properties we want to save/persist
			var save_dictionary = {
				"playerWeaponId": Global.playerWeaponId,
				"playerStats": Global.playerStats,
				"playerResearchedItemIds": Global.playerResearchedItemIds,
				"playerResources": Global.playerResources,
				"modifiers": Global.modifiers,
				"gameTime": Global.game_time,
				"playerShipData": Global.playerShipData,
				"playerBaseData": Global.playerBaseData,
				"npcColonyData": Global.npcColonyData,
				"rscCollectionSiteData": Global.rscCollectionSiteData,
				"saveTimestamp": OS.get_datetime()
			}
			
			save_game.store_var(save_dictionary, true)
			
			save_game.close()
			
			var popup = AcceptDialog.new()
			popup.dialog_text = "Successfully saved! (save" + String(i) + ")"
			Global.player.get_node("UI").add_child(popup)
			popup.popup_centered()
			
			return
	
	# TODO: prompt user to overwrite a save of their choice (between 1 and Global.MAX_SAVES)
	save_game.close()
