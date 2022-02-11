extends Building

func _init():
	cost_to_build = Global.cost_to_build_HQ

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_Building_Button_pressed():
	Global.player.building_panel.show()

func _on_SaveGame_Button_pressed():
	get_tree().get_root().get_node("MainWorld").save_game()
