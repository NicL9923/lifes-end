extends Building

# NOTE: This building has no upgrades
const BUILDING_LIMIT := 1


func _init():
	cost_to_build = 30
	bldg_name = "Communications Array"
	bldg_desc = "View the System Map"

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_WorldMap_Button_pressed():
	get_tree().change_scene("res://SystemMap.tscn")
