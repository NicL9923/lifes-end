extends Node

#Game classes/types
enum BUILDING_TYPES {
	HQ = 0
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

var isPlayerBaseFirstLoad: bool #TODO: to know when to spawn random mineral deposits in ready() for MainWorld

var mainEndingIsGood := false
var subEndingIsGood := false
