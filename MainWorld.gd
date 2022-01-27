extends Node2D

var worldTileSize := Global.world_tile_size
export var minerals_to_spawn := 30
export var HQ_mineral_cost := 15 # TODO: move building mineral costs into their respective scripts


func _ready():
	Global.world_nav = $Navigation2D
	
	var planet = Global.playerBaseData.planet
	#TODO: may be worth just merging all planet tiles into single tilemap if they all have 1 or 2 tiles at most...
	$TileMap.tile_set = load("res://objects/planets/tilesets/" + planet + "_Tileset.tres")
	
	generate_map_border_tiles()
	generate_map_inner_tiles()
	
	set_player_camera_bounds()
	
	if Global.isPlayerBaseFirstLoad:
		$Player/UI/BuildingUI/Build_HQ_Button.disabled = true
		$Player/UI/BuildingUI/Build_HQ_Button.visible = true
		
		spawn_metal_deposits()
	else:
		load_buildings()
		# TODO: load_colonists()
	
	$Player.global_position = Vector2(Global.cellSize * worldTileSize.x / 2, Global.cellSize * worldTileSize.y / 2)

func _process(delta):
	if Global.isPlayerBaseFirstLoad and Global.playerBaseMetal >= 15:
		$Player/UI/BuildingUI/Build_HQ_Button.disabled = false

func generate_map_border_tiles():
	for x in [0, worldTileSize.x - 1]:
		for y in range(0, worldTileSize.y):
			$TileMap.set_cell(x, y, 0)
	
	for x in range(1, worldTileSize.x - 1):
		for y in [0, worldTileSize.y - 1]:
			$TileMap.set_cell(x, y, 0)

func generate_map_inner_tiles():
		for x in range(1, worldTileSize.x - 1):
			for y in range(1, worldTileSize.y - 1):
				$TileMap.set_cell(x, y, 1)

func set_player_camera_bounds():
	var map_limits = $TileMap.get_used_rect()
	$Player/Camera2D.limit_left = map_limits.position.x * Global.cellSize
	$Player/Camera2D.limit_right = map_limits.end.x * Global.cellSize
	$Player/Camera2D.limit_top = map_limits.position.y * Global.cellSize
	$Player/Camera2D.limit_bottom = map_limits.end.y * Global.cellSize

func spawn_metal_deposits():
	randomize()
	var map_limits = $TileMap.get_used_rect()
	
	for i in range(0, minerals_to_spawn):
		var metal_deposit := preload("res://objects/MetalDeposit.tscn").instance()
		metal_deposit.global_position = Vector2(rand_range(map_limits.position.x * (Global.cellSize + 1), map_limits.end.x * (Global.cellSize - 1)), rand_range(map_limits.end.y * (Global.cellSize + 1), map_limits.position.y * (Global.cellSize - 1)))
		get_tree().get_root().get_node("MainWorld").add_child(metal_deposit)

func load_buildings():
	var bldg_names = ["HQ", "Shipyard", "Medbay", "Barracks", "Greenhouse", "Power_Industrial_Coal", "Power_Renewable_Solar", "Water_Recycling_System", "Communications_Array", "Science_Lab"]
	
	for bldg in Global.playerBaseData.buildings:
		var building_node = load("res://objects/buildings/" + bldg_names[bldg.type] + ".tscn").instance()
		building_node.global_position = bldg.global_pos
		# TODO: set building level
		# TODO: set any other random vars we need to here that differ from the actual building placement process
		get_tree().get_root().get_child(1).add_child(building_node)

func save_game():
	var save_game = File.new()
	
	# TODO: show label 'Saving...'
	
	for i in range(1, Global.MAX_SAVES):
		var save_name = "user://save" + String(i) + ".save"
		
		if not save_game.file_exists(save_name):
			save_game.open(save_name, File.WRITE)
			
			# This is what contains all properties we want to save/persist
			var save_dictionary = {
				"playerWeaponId": Global.playerWeaponId,
				"playerCmdrStat": Global.playerCmdrStat,
				"playerEngrStat": Global.playerEngrStat,
				"playerBiolStat": Global.playerBiolStat,
				"playerDocStat": Global.playerDocStat,
				"playerResearchedItemIds": Global.playerResearchedItemIds,
				"playerBaseMetal": Global.playerBaseMetal,
				"playerBaseFood": Global.playerBaseFood,
				"playerBaseWater": Global.playerBaseWater,
				"playerBaseEnergy": Global.playerBaseEnergy,
				"playerBaseData": Global.playerBaseData,
				"npcColonyData": Global.npcColonyData,
				"saveTimestamp": OS.get_datetime()
			}
			
			save_game.store_var(save_dictionary, true)
			
			save_game.close()
			
			# TODO: show label 'Successfully saved!'
			
			return
	
	# TODO: prompt user to overwrite a save of their choice (between 1 and Global.MAX_SAVES)
	save_game.close()
