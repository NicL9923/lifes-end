extends Control

var isFactory := false # TODO: use this when calculating if pollution is produced while crafting (factory) and how long for it to take (factory shorter vs workshop longer)
	# var seconds_to_craft = 30 / Global.modifiers.buildSpeed ****60 if workshop


func _ready():
	pass

func show_crafting_ui(is_factory: bool):
	self.isFactory = is_factory
	self.visible = true

func _on_Close_Button_button_pressed():
	self.visible = false
