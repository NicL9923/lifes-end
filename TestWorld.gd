extends Node2D

func _ready():
	Global.world_nav = $Navigation2D

func _on_TglCmbt_Button_pressed():
	Global.player.toggle_combat()
