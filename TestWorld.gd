extends Node2D

# TODO: move these into proper scenes (Ex: UI -> Player_UI.tscn that's attached to Player.tscn)

onready var building_panel = $Player/UI/Building_Panel

func _on_TglCmbt_Button_pressed():
	Global.player.toggle_combat()


func _on_Building_Button_pressed():
	building_panel.show()

func _on_Close_Button_pressed():
	building_panel.hide()

func _on_HQ_Button_pressed():
	pass


func _on_Research_Button_pressed():
	pass
