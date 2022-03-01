extends Building

# TODO: makes weapons, and other things but what??? -> see factory
# TODO: crafts slower than factory
var seconds_to_craft = 60 / Global.modifiers.buildSpeed


func _init():
	cost_to_build = 30
	bldg_name = "Workshop"
	bldg_desc = "Allows you to craft weapons"
	has_to_be_unlocked = true

func _process(delta):
	handle_energy_display(delta)

func _on_Craft_Button_pressed():
	Global.player.crafting_ui.visible.show()
