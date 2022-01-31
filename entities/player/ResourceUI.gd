extends Control

func _ready():
	pass

func _process(_delta):
	$MetalLabel.text = "Metal: " + str(Global.playerBaseMetal)
