extends Building

# NOTE: This building has no upgrades

func _init():
	cost_to_build = 25

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_ShipUpgrade_Button_pressed():
	Global.player.ship_panel.show()
