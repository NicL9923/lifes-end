extends Building

# TODO: Upgrades -> faster research and more research "slots"

func _init():
	cost_to_build = 25

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_Research_Button_pressed():
	Global.player.research_panel.show()
