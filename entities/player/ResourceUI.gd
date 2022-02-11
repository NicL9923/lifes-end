extends Control

func _ready():
	pass

func _process(_delta):
	$VBoxContainer/MetalLabel.text = "Metal: " + str(Global.playerResources.metal)
	$VBoxContainer/EnergyLabel.text = "Energy: " + str(Global.playerResources.energy)
	$VBoxContainer/WaterLabel.text = "Water: " + str(Global.playerResources.water)
	$VBoxContainer/FoodLabel.text = "Food: " + str(Global.playerResources.food)
