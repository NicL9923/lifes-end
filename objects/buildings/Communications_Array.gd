extends Building

# NOTE: This building has no upgrades

func _init():
	self.cost_to_build = 30

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_WorldMap_Button_pressed():
	get_tree().change_scene("res://SystemMap.tscn")
