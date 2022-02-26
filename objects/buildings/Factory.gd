extends Building

# TODO: makes weapons, and other things but what???
# TODO: make pollution, but daily or probably only when actively crafting
# TODO: handle power/no power states
var seconds_to_craft = 30 / Global.modifiers.buildSpeed


func _init():
	cost_to_build = 50
	bldg_name = "Factory"
	bldg_desc = "Allows you to craft weapons"
	has_to_be_unlocked = true

func _on_Craft_Button_pressed():
	Global.player.crafting_ui.visible.show()
