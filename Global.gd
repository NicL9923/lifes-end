extends Node

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
var playerBaseData: bool #TODO: keep track of base planet/coordinates, base buildings (types, positions, levels, etc), # of colonists, etc.
var playerResearchedItemIds: Array

var playerBaseMetal: int
var playerBaseFood: int
var playerBaseWater: int
var playerBaseEnergy: int

var npcColonyData: Array #TODO: keep track of NPC colony planets/coordinates, buildings (types, positions, levels, etc), # of colonists, etc.

#Game flags/vars
var cellSize := 32

var isPlayerBaseFirstLoad: bool #TODO: to know when to spawn random mineral deposits in ready() for MainWorld

var mainEndingIsGood := false
var subEndingIsGood := false
