extends Node2D

export var worldSize := Vector2(25, 25)


func _ready():
	#TODO: choose tilemap tileset based on Global.playerBaseData (that has yet to be fleshed out, but should include a property such as 'planet'
	#$TileMap.tile_Set = ???
	
	generate_map_border_tiles()
	generate_map_inner_tiles()
	
	set_player_camera_bounds()
	
	if Global.isPlayerBaseFirstLoad:
		spawn_mineral_deposits()
	
	$Player.global_position = Vector2(Global.cellSize * worldSize.x / 2, Global.cellSize * worldSize.y / 2)

func generate_map_border_tiles():
	for x in [0, worldSize.x - 1]:
		for y in range(0, worldSize.y):
			$TileMap.set_cell(x, y, 0)
	
	for x in range(1, worldSize.x - 1):
		for y in [0, worldSize.y - 1]:
			$TileMap.set_cell(x, y, 0)

func generate_map_inner_tiles():
		for x in range(1, worldSize.x - 1):
			for y in range(1, worldSize.y - 1):
				$TileMap.set_cell(x, y, 1)

func set_player_camera_bounds():
	var map_limits = $TileMap.get_used_rect()
	$Player/Camera2D.limit_left = map_limits.position.x * Global.cellSize
	$Player/Camera2D.limit_right = map_limits.end.x * Global.cellSize
	$Player/Camera2D.limit_top = map_limits.position.y * Global.cellSize
	$Player/Camera2D.limit_bottom = map_limits.end.y * Global.cellSize

func spawn_mineral_deposits():
	pass

func save_game(): 
	var save_game = File.new()
	#TODO: check if existing saves so that: names of files will just be 'SaveX' where X is the next available num starting from 1
	save_game.open("user://savegame.save", File.WRITE)
	
	#TODO: to_json() the variables in Global that need saving
	
	save_game.close()
