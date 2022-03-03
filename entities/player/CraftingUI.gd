extends Control

var isFactory := false # TODO: use this when calculating if pollution is produced while crafting (factory) and how long for it to take (factory shorter vs workshop longer)
	# var seconds_to_craft = 30 / Global.modifiers.buildSpeed ****60 if workshop


func _ready():
	pass

func show_crafting_ui(isFactory: bool):
	self.isFactory = isFactory
	self.visible = true

func _on_Close_Button_pressed():
	self.visible = false
