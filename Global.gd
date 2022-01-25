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

class BuildingData:
	var type: int #BUILDING_TYPES
	var global_pos: Vector2
	#TODO: building_lvl

class BaseData:
	var planet: String
	var buildings: Array #BuildingData[]
	var colonists: Array


#Game Settings
var audioVolume: int

#Player stats
var player: Player
var playerHealth: int
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


var playerBaseData := BaseData.new()

var npcColonyData: Array #BaseData[]

#Game flags/vars
var cellSize := 32
var planets := ["Mercury", "Venus", "Earth's Moon", "Mars", "Pluto"]
var building_activiation_distance := 35

#TODO: to know when to spawn random mineral deposits in ready() for MainWorld
#Also, for now set to true for testing but needs to be loaded from save data in future
var isPlayerBaseFirstLoad := true

var mainEndingIsGood := false
var subEndingIsGood := false
