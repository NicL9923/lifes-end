extends Building

func _ready():
	cost_to_build = Global.cost_to_build_HQ

func _process(_delta):
	#Check if player within collection distance
	if Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced:
		$PopupUI.visible = true
	else:
		$PopupUI.visible = false


func _on_Building_Button_pressed():
	Global.player.building_panel.show()

func _on_SaveGame_Button_pressed():
	get_tree().get_root().get_node("MainWorld").save_game()
