extends Control

func _ready():
	$SettingsContainer.visible = false
	$LoadGameContainer.visible = false
	$MainMenuContainer/MainMenuVBox/NewGameButton.grab_focus()

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGameButton_pressed():
	$MainMenuContainer.visible = false
	$LoadGameContainer.visible = true

func _on_SettingsButton_pressed():
	$MainMenuContainer.visible = false
	$SettingsContainer.visible = true

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_S_GoBackBN_pressed():
	$SettingsContainer.visible = false
	$MainMenuContainer.visible = true


func _on_LG_GoBackBN_pressed():
	$LoadGameContainer.visible = false
	$MainMenuContainer.visible = true


func _on_HSlider_value_changed(value):
	Global.audioVolume = value as int
