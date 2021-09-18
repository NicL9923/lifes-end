extends Control

# TODO: Handle attribute points and assigning them to the various character attributes

func _ready():
	pass

func _on_Launch_Button_pressed():
	get_tree().change_scene("res://IntroCinematic.tscn")
