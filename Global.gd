extends Node

enum MOVEMENT_DIR { UP, DOWN, LEFT, RIGHT }
enum Cell { GROUND, OUTER_TOP, OUTER_BOTTOM, OUTER_LEFT, OUTER_RIGHT }

# Collision mask/layer notes:
	# -Bullets: on: 3, collide_with: 1/2
	# -Buildings: on: 1, collide_with: 1/2/3
	# -Metal deposits -> on: 1, collide_with: 1/2/3
	# -Entities + player -> on: 2, collide_with: 1

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
	UNLOCK_GAS_POWER = 12,
	UNLOCK_OIL_POWER = 13,
	UNLOCK_SMELTERY = 14,
	UNLOCK_GEOTHERMAL_POWER = 16,
	UNLOCK_NUCLEAR_POWER = 17,
	DISCOVER_YOUR_FATE = 18
}

#Game classes/types
# NOTE: Was using custom classes for base data, but that doesn't let it be serialized for savegames so that's a no go
const defaultShipData = { level = 1 }
const defaultPlayerStats = { cmdr = 0, engr = 0, biol = 0, doc = 0, max_health = 100.0, humanity = 0.0 } # Humanity can be float(-100 to 100)
const defaultPlayerResources = { metal = 0, food = 0, water = 0, energy = 0 }
const defaultPlayerBaseData = {
	planet = "",
	coords = { lat = 0, long = 0 },
	unlockedBuildings = [], # String[] of BUILDING_TYPES
	buildings = [], # BuildingData{} -> type(String), global_pos(Vector2)
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

var npcColonyData: Array # (playerBaseData, but w/o colonists[]/playerPos/metalDeposits[] and w/ isGood and isDestroyed bools)
var rscCollectionSiteData: Array # { planet: String, coords, numMetalDeposits: int }

var modifiers := defaultModifiers

#Game flags/vars
var is_in_mode_to_use_esc := false # Prioritizes only exiting a mode (i.e. building placement/moving), and if not in one of those, then open the esc menu
const world_tile_size := Vector2(50, 50)
const cellSize := 32
const entity_names := {
	first = ["Rayce", "Nicolas", "Cameron", "Garrett", "Lei", "Evan", "Ben", "Reeech", "Devon", "Hanto", "Bryan", "David", "Michael"],
	last = ["Peel", "Huang", "Powell", "Layne", "Johnson", "Garcia", "Smith", "Hernandez", "Miller", "Brown", "Williams", "Anderson"]
}
const colony_names := {
	good_adj = ["Typical", "Militant", "Consular", "Tribal", "Religious", "Civilized", "Independent", "Chauvinistic", "Patriotic", "United", "Ecological", "Industrial", "Sustainable"],
	bad_adj = ["Ruthless", "Terrorist", "Barbaric", "Savage", "Warlike", "Nationalist", "Separatist"],
	noun = ["Colony", "Consulate", "Project", "Tribe", "Task Force", "Hegemony", "Empire", "Corporation", "Initiative", "Band", "Gang", "Cavalcade", "College"]
}
const buildings = {
	HQ = {
		bldg_name = "HQ",
		bldg_desc = "The foundation of every colony",
		cost_to_build = 30,
		metal_produced_per_day = 5,
		bldg_limit = 1,
		popup_activation_distance = 164,
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
		cost_to_build = 50,
		bldg_limit = 1,
		energy_cost_to_run = 3,
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
		cost_to_build = 25,
		bldg_limit = 1,
		energy_cost_to_run = 5,
		popup_activation_distance = 164,
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
		cost_to_build = 100,
		energy_cost_to_run = 20,
		bldg_limit = 1,
		popup_activation_distance = 128,
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
		cost_to_build = 20,
		has_to_be_unlocked = true,
		energy_cost_to_run = 2,
		bldg_limit = 1,
		popup = [
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
	Barracks = {
		bldg_name = "Barracks",
		bldg_desc = "Recruit colonists, and view your stats",
		cost_to_build = 50,
		energy_cost_to_run = 4,
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
		bldg_desc = "N/A",
		cost_to_build = 30,
		energy_cost_to_run = 8,
		daily_colonist_healing_amt = 20,
		bldg_limit = 1,
		has_to_be_unlocked = true
	},
	Greenhouse = {
		bldg_name = "Greenhouse",
		bldg_desc = "N/A",
		cost_to_build = 10,
		energy_cost_to_run = 10,
		food_produced_per_day = 4
	},
	Water_Recycling_System = {
		bldg_name = "Water Recycling System",
		bldg_desc = "N/A",
		cost_to_build = 15,
		energy_cost_to_run = 5,
		water_produced_per_day = 8
	},
	Power_Industrial_Coal = {
		bldg_name = "Coal Power Plant",
		bldg_desc = "N/A",
		cost_to_build = 5,
		energy_produced = 10,
		pollution_produced_per_day = 1
	},
	Power_Industrial_Gas = {
		bldg_name = "Gas Power Plant",
		bldg_desc = "N/A",
		cost_to_build = 50,
		has_to_be_unlocked = true,
		energy_produced = 75,
		pollution_produced_per_day = 2
	},
	Power_Industrial_Oil = {
		bldg_name = "Oil Power Plant",
		bldg_desc = "N/A",
		cost_to_build = 100,
		has_to_be_unlocked = true,
		energy_produced = 150,
		pollution_produced_per_day = 4
	},
	Power_Sustainable_Solar = {
		bldg_name = "Solar Array",
		bldg_desc = "N/A",
		cost_to_build = 10,
		energy_produced = 5
	},
	Power_Sustainable_Geothermal = {
		bldg_name = "Geothermal Power Plant",
		bldg_desc = "N/A",
		cost_to_build = 75,
		energy_produced = 30,
		has_to_be_unlocked = true
	},
	Power_Sustainable_Nuclear = {
		bldg_name = "Nuclear Power Plant",
		bldg_desc = "N/A",
		cost_to_build = 200,
		energy_produced = 100,
		has_to_be_unlocked = true
	},
	Smeltery = {
		bldg_name = "Smeltery",
		bldg_desc = "N/A",
		cost_to_build = 50,
		energy_cost_to_run = 2,
		metal_produced_per_day = 5,
		has_to_be_unlocked = true
	},
	Mining_Operation = {
		bldg_name = "Mining Operation",
		bldg_desc = "N/A",
		cost_to_build = 30,
		energy_cost_to_run = 5,
		metal_produced_per_day = 15,
		has_to_be_unlocked = true,
		pollution_produced_per_day = 2
	},
	Carbon_Scrubber = {
		bldg_name = "Carbon Scrubber",
		bldg_desc = "N/A",
		cost_to_build = 30,
		energy_cost_to_run = 15,
		pollution_removed_per_day = 1,
		has_to_be_unlocked = true
	}
}
const planets := ["Mercury", "Venus", "Earth's Moon", "Mars", "Pluto"]
const planet_distances := [31, 36, 33, 3000] # in millions of miles
const location_type := { playerColony = "playerColony", npcColony = "npcColony", rscSite = "rscSite" }
const colony_biases := [10, 25, 65, 95, 100] # Used to determine concentration of npc colonies on the above planets (actual prob is 10/15/40/30/5%)
const rsc_site_biases := [20, 45, 55, 70, 100] # Same idea as planet_biases (actual prob is 20/25/10/15/30)
const latitude_range := [-90, 90]
const longitude_range := [-180, 180]
const ship_upgrade_costs := [50, 100, 200]
const max_deposits_at_rsc_site := 30
const max_colonists_at_npc_colony := 20 # Default: 20
var time_speed := 40 # Default is 40, which makes 1 day last 1 real-world min (2 = 20min; 160 = 15 seconds)

var isPlayerBaseFirstLoad := true
var game_time := defaultGameTime # Game loads at 0800/8AM (goes from 0000 to 2400)
var world_nav: Navigation2D
var location_to_load := {
	type = "",
	index = 0,
	is_raiding = true
}

var mainEndingIsGood := false
var subEndingIsGood := false # Also actively represents if player is "Good" or "Evil" as they're playing (see playerStats.humanity)

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
	# warning-ignore:return_value_discarded
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


func set_player_camera_bounds(map_limits): # map_limits == tilemap.get_used_rect()
	var p_cam = player.get_node("Camera2D")
	p_cam.limit_left = map_limits.position.x * Global.cellSize
	p_cam.limit_right = map_limits.end.x * Global.cellSize
	p_cam.limit_top = map_limits.position.y * Global.cellSize
	p_cam.limit_bottom = map_limits.end.y * Global.cellSize

func get_random_location_in_map(map_limits):
	randomize()
	
	var x := rand_range((map_limits.position.x + 2) * Global.cellSize , (map_limits.end.x - 2) * Global.cellSize)
	var y := rand_range((map_limits.end.y - 2) * Global.cellSize, (map_limits.position.y + 2) * Global.cellSize)
	
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
			# Wall tiles
			if y > 0 and y < wts.y and x == 0:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_LEFT)))
			if y > 0 and y < wts.y and x == wts.x - 1:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_RIGHT)))
			
	# Horizontal row tiles
	for x in range(1, wts.x - 1):
		for y in [0, wts.y - 1]:
			# Top edge
			if y == 0:
				tilemap.set_cell(x, y, planet_tile_value(generate_random_tile(Cell.OUTER_TOP)))
			# Bottom edge
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
	var planet = playerBaseData.planet
	
	match planet:
		"Mars": return ind
		"Venus": return ind + 16
		"Mercury": return ind + 32
		"Earth's Moon": return ind + 48
		"Pluto": return ind + 64

func set_building_tiles(tilemap, bldg_node, toConcrete = true):
	var bldg_tile_size = bldg_node.bldg_size / Global.cellSize
	var tl_corner_tile = tilemap.world_to_map(bldg_node.global_position) - (bldg_tile_size / 2)
	
	# Handle odd-tile-sized buildings
	if int(bldg_tile_size.x) % 2 == 1:
		tl_corner_tile.x += 1
	if int(bldg_tile_size.y) % 2 == 1:
		tl_corner_tile.y += 1
	
	var cur_tile = tl_corner_tile
	for _y in range(0, bldg_tile_size.y):
		for _x in range(0, bldg_tile_size.x):
			
			if toConcrete:
				tilemap.set_cellv(cur_tile, 80) # Concrete
			else:
				# TODO: Doesn't handle edge tiles that were replaced atm
				tilemap.set_cellv(cur_tile, planet_tile_value(generate_random_tile(Cell.GROUND)))
			cur_tile.x += 1
		
		cur_tile.x = tl_corner_tile.x
		cur_tile.y += 1

func player_stat_modifier_formula(value: float) -> float:
	return (1.0 + (value * 0.1))

func push_player_notification(new_notification: String) -> void:
	player.notifications.notification_queue.append(new_notification)

func add_player_humanity(by_amt: float):
	playerStats.humanity = clamp(playerStats.humanity + by_amt, -100.0, 100.0)

func change_metal_by(amt):
	playerResources.metal += amt
	var rsc_n = RscNotification.new()
	rsc_n.rsc_type = RscNotification.RSC_TYPE.METAL
	rsc_n.amt = amt
	player.add_child(rsc_n)

func change_food_by(amt):
	playerResources.food += amt
	var rsc_n = RscNotification.new()
	rsc_n.rsc_type = RscNotification.RSC_TYPE.FOOD
	rsc_n.amt = amt
	player.add_child(rsc_n)

func change_water_by(amt):
	playerResources.water += amt
	var rsc_n = RscNotification.new()
	rsc_n.rsc_type = RscNotification.RSC_TYPE.WATER
	rsc_n.amt = amt
	player.add_child(rsc_n)
