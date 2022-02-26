extends Control

onready var metal_lbl := $MetalLabel
onready var energy_lbl := $EnergyLabel
onready var water_lbl := $WaterLabel
onready var food_lbl := $FoodLabel


func _ready():
	pass

func _process(_delta):
	metal_lbl.text = str(Global.playerResources.metal)
	energy_lbl.text = str(Global.playerResources.energy)
	water_lbl.text = str(Global.playerResources.water)
	food_lbl.text = str(Global.playerResources.food)
