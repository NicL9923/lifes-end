extends Control

onready var metal_lbl := $VBoxContainer/MetalLabel
onready var energy_lbl := $VBoxContainer/EnergyLabel
onready var water_lbl := $VBoxContainer/WaterLabel
onready var food_lbl := $VBoxContainer/FoodLabel


func _ready():
	pass

func _process(_delta):
	metal_lbl.text = "Metal: " + str(Global.playerResources.metal)
	energy_lbl.text = "Energy: " + str(Global.playerResources.energy)
	water_lbl.text = "Water: " + str(Global.playerResources.water)
	food_lbl.text = "Food: " + str(Global.playerResources.food)
