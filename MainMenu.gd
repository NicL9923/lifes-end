extends Control

func _ready():
	$VBoxContainer/NewGameButton.grab_focus()

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGameButton_pressed():
	pass

func _on_SettingsButton_pressed():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
