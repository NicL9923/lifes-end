extends Control

func _ready():
	pass

func _process(_delta):
	$VBoxContainer/MetalLabel.text = "Metal: " + str(Global.playerBaseMetal)
	$VBoxContainer/EnergyLabel.text = "Energy: " + str(Global.playerBaseEnergy)
	$VBoxContainer/WaterLabel.text = "Water: " + str(Global.playerBaseWater)
	$VBoxContainer/FoodLabel.text = "Food: " + str(Global.playerBaseFood)
