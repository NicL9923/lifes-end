extends Node

enum MOVEMENT_DIR { UP, DOWN, LEFT, RIGHT }

#Game classes/types
# NOTE: Was using custom classes for base data, but that doesn't let it be serialized for savegames so that's a no go
const defaultShipData = { level = 1 }
const defaultPlayerStats = { cmdr = 0, engr = 0, biol = 0, doc = 0, max_health = 100 }
const defaultPlayerResources = { metal = 0, food = 0, water = 0, energy = 0 }
const defaultPlayerBaseData = {
	planet = "",
	coords = { lat = 0, long = 0 },
	buildings = [], # BuildingData{} -> type(String), global_pos(Vector2), building_lvl(int *start is 1)
	colonists = [], # Colonist{} -> health(int), global_pos(Vector2)
	lastPlayerPos = Vector2(0, 0),
	metalDeposits = [], # Vector2[]
	pollutionLevel = 0.0 # 0.0 - 100.0
}
const defaultModifiers = {
	playerWeaponDamage = 1,
	solarEnergyProduction = 1,
	researchSpeed = 1,
	buildSpeed = 1,
	foodProduction = 1,
	waterProduction = 1
}
const defaultGameTime = { ticks = 800.0, earthDays = 0 }

#Game Settings
const GAME_SETTINGS_CONFIG_PATH := "user://game_settings.cfg"
var audioVolume: int

#Player stats
var player: Player
var playerWeaponId: int
var playerStats := defaultPlayerStats
var playerResources := defaultPlayerResources

var playerResearchedItemIds: Array
var playerShipData := defaultShipData
var playerBaseData := defaultPlayerBaseData

var npcColonyData: Array # (playerBaseData, but w/o colonists[]/playerPos/metalDeposits[] and w/ isDestroyed bool)
var rscCollectionSiteData: Array # { planet: String, coords, numMetalDeposits: int }

var modifiers := defaultModifiers

#Game flags/vars
const world_tile_size := Vector2(50, 50)
const cellSize := 32
const BUILDING_TYPES = {
	HQ = "HQ",
	Shipyard = "Shipyard",
	Communications_Array = "Communications_Array",
	Science_Lab = "Science_Lab",
	Maintenance = "Maintenance",
	Factory = "Factory",
	Workshop = "Workshop",
	Barracks = "Barracks",
	Medbay = "Medbay",
	Greenhouse = "Greenhouse",
	Water_Recycling_System = "Water_Recycling_System",
	Power_Industrial_Coal = "Power_Industrial_Coal",
	Power_Industrial_Oil = "Power_Industrial_Oil",
	Power_Industrial_Gas = "Power_Industrial_Gas",
	Power_Sustainable_Solar = "Power_Sustainable_Solar",
	Power_Sustainable_Geothermal = "Power_Sustainable_Geothermal",
	Power_Sustainable_Nuclear = "Power_Sustainable_Nuclear",
	Smeltery = "Smeltery",
	Mining_Operation = "Mining_Operation"
}
const cost_to_build_HQ := 15
const planets := ["Mercury", "Venus", "Earth's Moon", "Mars", "Pluto"]
const planet_distances := [31, 36, 33, 3000] # in millions of miles
const location_type := { playerColony = "playerColony", npcColony = "npcColony", rscSite = "rscSite" }
const colony_biases := [10, 25, 65, 95, 100] # Used to determine concentration of npc colonies on the above planets (actual prob is 10/15/40/30/5%)
const rsc_site_biases := [20, 45, 55, 70, 100] # Same idea as planet_biases (actual prob is 20/25/10/15/30)
const latitude_range := [-90, 90]
const longitude_range := [-180, 180]
const ship_upgrade_costs := [15, 30, 50, 100]
const max_deposits_at_rsc_site := 100
const max_colonists_at_npc_colony := 20 # Default: 20
const building_activiation_distance := 75
const MAX_SAVES := 5
var time_speed := 8 # Default is 8, which makes 1 day last 5 real-world mins (2 = 20min; 40 = 1 min; 160 = 15 seconds)

var isPlayerBaseFirstLoad := true
var game_time := defaultGameTime # Game loads at 0800/8AM (goes from 0000 to 2400)
var world_nav: Navigation2D
var location_to_load := {
	type = "",
	index = 0
}

var mainEndingIsGood := false
var subEndingIsGood := false

var debug = {
	dev_console = {
		entered_cmds = [],
		output_stream = [],
		current_history_index = 0
	},
	god_mode = false
}

############### FUNCTIONS ##################

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

func load_game(save_name):
	var save_game = File.new()
	
	save_game.open("user://" + save_name + ".save", File.READ)
	
	# Get save data and put it back into the respective Global vars
	var save_data = save_game.get_var(true)
	
	Global.playerWeaponId = save_data.playerWeaponId
	Global.playerStats = save_data.playerStats
	Global.playerResearchedItemIds = save_data.playerResearchedItemIds
	Global.playerResources = save_data.playerResources
	Global.modifiers = save_data.modifiers
	Global.game_time = save_data.gameTime
	Global.playerShipData = save_data.playerShipData
	Global.playerBaseData = save_data.playerBaseData
	Global.isPlayerBaseFirstLoad = false
	Global.npcColonyData = save_data.npcColonyData
	Global.rscCollectionSiteData = save_data.rscCollectionSiteData

	save_game.close()
	
	# Load the MainWorld scene now that we've parsed in the save data
	get_tree().change_scene("res://MainWorld.tscn")

func reset_global_data():
	Global.playerWeaponId = -1
	Global.playerStats = Global.defaultPlayerStats
	Global.playerResources = Global.defaultPlayerResources
	Global.playerResearchedItemIds = []
	Global.modifiers = Global.defaultModifiers
	Global.game_time = Global.defaultGameTime
	Global.playerShipData = Global.defaultShipData
	Global.playerBaseData = Global.defaultPlayerBaseData
	Global.npcColonyData = []
	Global.rscCollectionSiteData = []
	Global.isPlayerBaseFirstLoad = true


func set_player_camera_bounds(map_limits): # tilemap.get_used_rect()
	player.get_node("Camera2D").limit_left = map_limits.position.x * Global.cellSize
	player.get_node("Camera2D").limit_right = map_limits.end.x * Global.cellSize
	player.get_node("Camera2D").limit_top = map_limits.position.y * Global.cellSize
	player.get_node("Camera2D").limit_bottom = map_limits.end.y * Global.cellSize

func get_random_location_in_map(map_limits):
	randomize()
	var x := rand_range(map_limits.position.x * (Global.cellSize + 1), map_limits.end.x * (Global.cellSize - 1))
	var y := rand_range(map_limits.end.y * (Global.cellSize + 1), map_limits.position.y * (Global.cellSize - 1))
	return Vector2(x, y)

func get_position_in_radius_around(position: Vector2, radius: int) -> Vector2:
	randomize()
	
	return Vector2(position.x + rand_range(-radius, radius) * cellSize, position.y + rand_range(-radius, radius) * cellSize)
