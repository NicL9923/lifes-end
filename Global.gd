extends Node

enum MOVEMENT_DIR { UP, DOWN, LEFT, RIGHT }
enum Cell { GROUND, OUTER_TOP, OUTER_BOTTOM, OUTER_LEFT, OUTER_RIGHT }

enum RESEARCH_EFFECTS {
	WPN_DMG = 0,
	SOLAR = 1,
	RESEARCH_SPEED = 2,
	BUILD_SPEED = 3,
	FOOD = 4,
	POLLUTION_DMG = 5,
	METAL_DEPOSIT_VALUE = 6,
	UNLOCK_MAINTENANCE_BLDG = 7,
	UNLOCK_MEDBAY = 8,
	UNLOCK_CARBON_SCRUBBER = 9,
	UNLOCK_MINING_OPERATION = 10,
	UNLOCK_FACTORY = 11,
	UNLOCK_GAS_POWER = 12,
	UNLOCK_OIL_POWER = 13,
	UNLOCK_SMELTERY = 14,
	UNLOCK_WORKSHOP = 15,
	UNLOCK_GEOTHERMAL_POWER = 16,
	UNLOCK_NUCLEAR_POWER = 17,
	DISCOVER_YOUR_FATE = 18
}

#Game classes/types
# NOTE: Was using custom classes for base data, but that doesn't let it be serialized for savegames so that's a no go
const defaultShipData = { level = 1 }
const defaultPlayerStats = { cmdr = 0, engr = 0, biol = 0, doc = 0, max_health = 100 }
const defaultPlayerResources = { metal = 0, food = 0, water = 0, energy = 0 }
const defaultPlayerBaseData = {
	planet = "",
	coords = { lat = 0, long = 0 },
	unlockedBuildings = [], # String[] of BUILDING_TYPES
	buildings = [], # BuildingData{} -> type(String), global_pos(Vector2), building_lvl(int *start is 1)
	colonists = [], # Colonist{} -> health(int), global_pos(Vector2)
	lastPlayerPos = Vector2(0, 0),
	metalDeposits = [], # Vector2[]
	pollutionLevel = 0.0 # 0.0 - 100.0
}
const defaultModifiers = {
	playerTeamWeaponDamage = 1.0,
	solarEnergyProduction = 1.0,
	researchSpeed = 1.0,
	buildSpeed = 1.0,
	foodProduction = 1.0,
	waterProduction = 1.0,
	pollutionDamage = 1.0,
	metalDepositValue = 1.0,
	medbayHealing = 1.0,
	colonistMaxHealth = 100,
	playerHealthRecovery = 1.0
}

const defaultGameTime = { ticks = 800.0, earthDays = 0 }

#Game Settings
const GAME_SETTINGS_CONFIG_PATH := "user://game_settings.cfg"
var audioVolume: int

#Player stats
var player: Player
var playerName: String
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
const buildings = {
	HQ = {
		bldg_name = "HQ",
		bldg_desc = "The foundation of every colony",
		cost_to_build = 15,
		bldg_limit = 1,
		popup = [
			{
				btn_text = "Build",
				connect_fn = "_on_Build_Button_pressed"
			},
			{
				btn_text = "Save Game",
				connect_fn = "_on_SaveGame_Button_pressed"
			}
		]
	},
	Shipyard = {
		bldg_name = "Shipyard",
		bldg_desc = "Allows the player to upgrade their ship",
		cost_to_build = 25,
		bldg_limit = 1,
		energy_cost_to_run = 5,
		popup = [
			{
				btn_text = "View Ship",
				connect_fn = "_on_ViewShip_Button_pressed"
			}
		]
	},
	Communications_Array = {
		bldg_name = "Communications Array",
		bldg_desc = "View the System Map",
		cost_to_build = 30,
		bldg_limit = 1,
		energy_cost_to_run = 5,
		popup = [
			{
				btn_text = "System Map",
				connect_fn = "_on_SystemMap_Button_pressed"
			}
		]
	},
	Science_Lab = {
		bldg_name = "Science Lab",
		bldg_desc = "Allows the player to conduct research",
		cost_to_build = 25,
		energy_cost_to_run = 10, # Handle power/no power states in Player/ResearchUI
		bldg_limit = 1,
		popup = [
			{
				btn_text = "Research",
				connect_fn = "_on_Research_Button_pressed"
			}
		]
	},
	Maintenance = {
		bldg_name = "Maintenance",
		bldg_desc = "Upgrade, move, repair, and scrap buildings",
		cost_to_build = 30,
		has_to_be_unlocked = true,
		energy_cost_to_run = 4,
		bldg_limit = 1,
		popup = [
			{
				btn_text = "Upgrade",
				connect_fn = "_on_BldgUpgrade_Button_pressed"
			},
			{
				btn_text = "Move",
				connect_fn = "_on_BldgMove_Button_pressed"
			},
			{
				btn_text = "Repair",
				connect_fn = "_on_BldgRepair_Button_pressed"
			},
			{
				btn_text = "Scrap",
				connect_fn = "_on_BldgScrap_Button_pressed"
			}
		]
	},
	Factory = {
		bldg_name = "Factory",
		bldg_desc = "Manufacture weaponry (produces pollution while active)",
		cost_to_build = 50,
		has_to_be_unlocked = true,
		energy_cost_to_run = 5,
		popup = [
			{
				btn_text = "Manufacture",
				connect_fn = "_on_Craft_Button_pressed"
			}
		]
	},
	Workshop = {
		bldg_name = "Workshop",
		bldg_desc = "Craft weaponry",
		cost_to_build = 30,
		has_to_be_unlocked = true,
		energy_cost_to_run = 5,
		popup = [
			{
				btn_text = "Craft",
				connect_fn = "_on_Craft_Button_pressed"
			}
		]
	},
	Barracks = {
		bldg_name = "Barracks",
		bldg_desc = "Recruit colonists, and view your stats",
		cost_to_build = 25,
		energy_cost_to_run = 5,
		cost_to_recruit_colonist = 30,
		popup = [
			{
				btn_text = "Recruit Colonist",
				connect_fn = "_on_RecruitColonist_Button_pressed"
			},
			{
				btn_text = "View Stats",
				connect_fn = "_on_ViewStats_Button_pressed"
			}
		]
	},
	Medbay = {
		bldg_name = "Medbay",
		bldg_desc = "TODO",
		cost_to_build = 25,
		energy_cost_to_run = 5,
		daily_colonist_healing_amt = 20,
		bldg_limit = 1,
		has_to_be_unlocked = true
	},
	Greenhouse = {
		bldg_name = "Greenhouse",
		bldg_desc = "TODO",
		cost_to_build = 10,
		energy_cost_to_run = 2,
		food_produced_per_day = 5
	},
	Water_Recycling_System = {
		bldg_name = "Water Recycling System",
		bldg_desc = "TODO",
		cost_to_build = 10,
		energy_cost_to_run = 2,
		water_produced_per_day = 10
	},
	Power_Industrial_Coal = {
		bldg_name = "Coal Power Plant",
		bldg_desc = "TODO",
		cost_to_build = 15,
		energy_produced = 15,
		pollution_produced_per_day = 0.1
	},
	Power_Industrial_Gas = {
		bldg_name = "Gas Power Plant",
		bldg_desc = "TODO",
		cost_to_build = 50,
		has_to_be_unlocked = true,
		energy_produced = 50,
		pollution_produced_per_day = 0.2
	},
	Power_Industrial_Oil = {
		bldg_name = "Oil Power Plant",
		bldg_desc = "TODO",
		cost_to_build = 100,
		has_to_be_unlocked = true,
		energy_produced = 150,
		pollution_produced_per_day = 0.4
	},
	Power_Sustainable_Solar = {
		bldg_name = "Solar Array",
		bldg_desc = "TODO",
		cost_to_build = 10,
		energy_produced = 5
	},
	Power_Sustainable_Geothermal = {
		bldg_name = "Geothermal Power Plant",
		bldg_desc = "TODO",
		cost_to_build = 75,
		energy_produced = 75,
		has_to_be_unlocked = true
	},
	Power_Sustainable_Nuclear = {
		bldg_name = "Nuclear Power Plant",
		bldg_desc = "TODO",
		cost_to_build = 200,
		energy_produced = 200,
		has_to_be_unlocked = true
	},
	Smeltery = {
		bldg_name = "Smeltery",
		bldg_desc = "TODO",
		cost_to_build = 20,
		energy_cost_to_run = 2,
		metal_produced_per_day = 2,
		has_to_be_unlocked = true
	},
	Mining_Operation = {
		bldg_name = "Mining Operation",
		bldg_desc = "TODO",
		cost_to_build = 25,
		energy_cost_to_run = 5,
		metal_produced_per_day = 4,
		has_to_be_unlocked = true,
		pollution_produced_per_day = 0.4
	},
	Carbon_Scrubber = {
		bldg_name = "Carbon Scrubber",
		bldg_desc = "TODO",
		cost_to_build = 0,
		energy_cost_to_run = 10,
		pollution_removed_per_day = 0.05,
		has_to_be_unlocked = true
	}
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
	god_mode = false,
	instant_build = false
}

############### FUNCTIONS ##################

func save_game():
	var save_game = File.new()
	
	var save_name = "user://" + playerName + ".save"
	
	if save_game.file_exists(save_name):
		pass # TODO: notify player they're about to overwrite old save
		
	save_game.open(save_name, File.WRITE)
	
	# This is what contains all properties we want to save/persist
	var save_dictionary = {
		"playerName": playerName,
		"playerWeaponId": playerWeaponId,
		"playerStats": playerStats,
		"playerResearchedItemIds": playerResearchedItemIds,
		"playerResources": playerResources,
		"modifiers": modifiers,
		"gameTime": game_time,
		"playerShipData": playerShipData,
		"playerBaseData": playerBaseData,
		"npcColonyData": npcColonyData,
		"rscCollectionSiteData": rscCollectionSiteData,
		"saveTimestamp": OS.get_datetime()
	}
	
	save_game.store_var(save_dictionary, true)
	
	push_player_notification("Successfully saved! (" + playerName + ".save)")
	
	save_game.close()

func load_game(save_name):
	var save_game = File.new()
	
	save_game.open("user://" + save_name + ".save", File.READ)
	
	# Get save data and put it back into the respective Global vars
	var save_data = save_game.get_var(true)
	
	playerName = save_data.playerName
	playerWeaponId = save_data.playerWeaponId
	playerStats = save_data.playerStats
	playerResearchedItemIds = save_data.playerResearchedItemIds
	playerResources = save_data.playerResources
	modifiers = save_data.modifiers
	game_time = save_data.gameTime
	playerShipData = save_data.playerShipData
	playerBaseData = save_data.playerBaseData
	isPlayerBaseFirstLoad = false
	npcColonyData = save_data.npcColonyData
	rscCollectionSiteData = save_data.rscCollectionSiteData

	save_game.close()
	
	# Load the MainWorld scene now that we've parsed in the save data
	get_tree().change_scene("res://MainWorld.tscn")

func reset_global_data():
	player = null
	world_nav = null
	playerName = ""
	playerWeaponId = -1
	playerStats = Global.defaultPlayerStats
	playerResources = Global.defaultPlayerResources
	playerResearchedItemIds = []
	modifiers = Global.defaultModifiers
	game_time = Global.defaultGameTime
	playerShipData = Global.defaultShipData
	playerBaseData = Global.defaultPlayerBaseData
	npcColonyData = []
	rscCollectionSiteData = []
	isPlayerBaseFirstLoad = true


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

func generate_map_tiles(tilemap):
	# Find first and last tiles in indexing for corner pieces
	# Determine left, right, top and bottom sides
	var wts = world_tile_size
	
	# Corner tiles
	tilemap.set_cell(0, 0, planet_tile_value(0))
	tilemap.set_cell(0, 49, planet_tile_value(8))
	tilemap.set_cell(49, 0, planet_tile_value(3))
	tilemap.set_cell(49, 49, planet_tile_value(11))
	
	# Vertical column tiles
	for x in [0, wts.x - 1]:
		for y in range(0, wts.y - 1):
			#wall tiles
			if y > 0 and y < wts.y and x == 0:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_LEFT)))
			if y > 0 and y < wts.y and x == wts.x - 1:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_RIGHT)))
			
	# Horizontal row tiles
	for x in range(1, wts.x - 1):
		for y in [0, wts.y - 1]:
			#top edge
			if y == 0:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_TOP)))
			#bottom edge
			if y == wts.y - 1:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_BOTTOM)))
	
	# Inner tiles
	for x in range(1, wts.x - 1):
			for y in range(1, wts.y - 1):
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.GROUND)))

func generate_random_tile(cell_type):
	var range_vector := Vector2()
	
	if cell_type == Cell.OUTER_TOP:
		range_vector = Vector2(1, 2)
	elif cell_type == Cell.OUTER_BOTTOM:
		range_vector = Vector2(9,10)
	elif cell_type == Cell.OUTER_LEFT:
		range_vector = Vector2(4, 5)
	elif cell_type == Cell.OUTER_RIGHT:
		range_vector = Vector2(6, 7)
	elif cell_type == Cell.GROUND:
		range_vector = Vector2(12,15)
	
	return int(rand_range(range_vector.x, range_vector.y))
	
func planet_tile_value(ind):
	var planet = Global.playerBaseData.planet
	
	match planet:
		"Mars": return ind
		"Venus": return ind + 16
		"Mercury": return ind + 32
		"Earth's Moon": return ind + 48
		"Pluto": return ind + 64

func player_stat_modifier_formula(value: float) -> float:
	return (1.0 + (value * 0.1))

func push_player_notification(new_notification: String) -> void:
	player.notifications.notification_queue.append(new_notification)
