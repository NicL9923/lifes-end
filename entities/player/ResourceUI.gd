extends Control

func _ready():
	pass

func _process(delta):
	$MetalLabel.text = "Metal: " + str(Global.playerBaseMetal)
