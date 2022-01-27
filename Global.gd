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
	buildings = [], #BuildingData[] -> type(int), global_pos(Vector2), building_lvl(int *start is 1)
	colonists = []
}

var npcColonyData: Array #BaseData[]

#Game flags/vars
var world_tile_size := Vector2(50, 50)
var cellSize := 32
var planets := ["Mercury", "Venus", "Earth's Moon", "Mars", "Pluto"]
var building_activiation_distance := 75
var MAX_SAVES := 5

var isPlayerBaseFirstLoad := true

var world_nav: Navigation2D

var mainEndingIsGood := false
var subEndingIsGood := false
