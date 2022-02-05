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


#Game Settings
const GAME_SETTINGS_CONFIG_PATH := "user://game_settings.cfg"
var audioVolume: int

#Player stats
# TODO: Combine player stats and base resources into a single class/object/dictionary?
var player: Player
var playerWeaponId: int
var playerCmdrStat: int
var playerEngrStat: int
var playerBiolStat: int
var playerDocStat: int
var playerResearchedItemIds: Array

var playerBaseMetal: int
var playerBaseFood: int
var playerBaseWater: int
var playerBaseEnergy: int


var playerBaseData = {
	planet = "",
	coords = { lat = 0, long = 0 },
	buildings = [], #BuildingData[] -> type(int), global_pos(Vector2), building_lvl(int *start is 1)
	colonists = [],
	lastPlayerPos = Vector2(0, 0),
	metalDeposits = [] # Vector2[]
}

var npcColonyData: Array # (playerBaseData, but w/o colonists[]/playerPos/metalDeposits[] and w/ isDestroyed bool)
var rscCollectionSiteData: Array # { planet: String, coords, numMetalDeposits: int }

#Game flags/vars
const world_tile_size := Vector2(50, 50)
const cellSize := 32
const bldg_names = ["HQ", "Shipyard", "Medbay", "Barracks", "Greenhouse", "Power_Industrial_Coal", "Power_Renewable_Solar", "Water_Recycling_System", "Communications_Array", "Science_Lab"]
const planets := ["Mercury", "Venus", "Earth's Moon", "Mars", "Pluto"]
const location_type := { playerColony = "playerColony", npcColony = "npcColony", rscSite = "rscSite" }
const colony_biases := [10, 25, 65, 95, 100] # Used to determine concentration of npc colonies on the above planets (actual prob is 10/15/40/30/5%)
const rsc_site_biases := [20, 45, 55, 70, 100] # Same idea as planet_biases (actual prob is 20/25/10/15/30)
const latitude_range := [-90, 90]
const longitude_range := [-180, 180]
const max_deposits_at_rsc_site := 100
const max_colonists_at_npc_colony := 20
const building_activiation_distance := 75
const MAX_SAVES := 5

var isPlayerBaseFirstLoad := true
var world_nav: Navigation2D
var location_to_load := {
	type = "",
	index = 0
}

var mainEndingIsGood := false
var subEndingIsGood := false
