extends Building

# TODO: Upgrades -> faster research and more research "slots"
const BUILDING_LIMIT := 1


func _init():
	cost_to_build = 25
	bldg_name = "Science Lab"
	bldg_desc = "Allows the player to conduct research"

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_Research_Button_pressed():
	Global.player.research_ui.show()
