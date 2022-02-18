extends Node2D

func _ready():
	Global.world_nav = $Navigation2D
	Global.player = $Player

func _on_TglCmbt_Button_pressed():
	Global.player.toggle_combat(!Global.player.isInCombat)
