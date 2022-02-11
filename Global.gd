extends Node

#Game classes/types
enum BUILDING_TYPES {
	HQ = 0,
	Shipyard = 1,
	Medbay = 2,
	Barracks = 3,
	Greenhouse = 4,
	Power_Industrial_Coal = 5,
	Power_Renewable_Solar = 6,
	Water_Recycling_System = 7,
	Communications_Array = 8,
	Science_Lab = 9
}

# NOTE: Was using custom classes for base data, but that doesn't let it be serialized for savegames so that's a no go
const defaultShipData = { level = 1 }
const defaultPlayerStats = { cmdr = 0, engr = 0, biol = 0, doc = 0, max_health = 100 }
const defaultPlayerResources = { metal = 0, food = 0, water = 0, energy = 0 }
const defaultPlayerBaseData = {
	planet = "",
	coords = { lat = 0, long = 0 },
	buildings = [], #BuildingData[] -> type(int), global_pos(Vector2), building_lvl(int *start is 1)
	colonists = [],
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
const bldg_names = ["HQ", "Shipyard", "Medbay", "Barracks", "Greenhouse", "Power_Industrial_Coal", "Power_Sustainable_Solar", "Water_Recycling_System", "Communications_Array", "Science_Lab"]
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
const max_colonists_at_npc_colony := 20
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
