extends Node2D

func _ready():
	get_tree().get_current_scene().add_child(Global.player)
	
	Global.world_nav = $Navigation2D

func _on_TglCmbt_Button_pressed():
	Global.player.toggle_combat(!Global.player.isInCombat)
