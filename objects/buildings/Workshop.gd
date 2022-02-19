extends Building

# TODO: makes weapons, and other things but what??? -> see factory
# TODO: crafts slower than factory

func _init():
	cost_to_build = 30
	bldg_name = "Workshop"
	bldg_desc = "Allows you to craft weapons"

func _on_Craft_Button_pressed():
	Global.player.crafting_ui.visible.show()
