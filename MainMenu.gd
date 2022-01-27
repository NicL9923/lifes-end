extends Control

func _ready():
	$SettingsContainer.visible = false
	$LoadGameContainer.visible = false
	$MainMenuContainer/MainMenuVBox/NewGameButton.grab_focus()
	
	var config = ConfigFile.new()
	config.load("res://game_settings.cfg")
	Global.audioVolume = config.get_value("audio", "volume")
	$SettingsContainer/SettingsVBox/HSlider.value = Global.audioVolume

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGameButton_pressed():
	$MainMenuContainer.visible = false
	
	# Get save games to parse in SaveGamesVBox
	var save_game_count := 0
	var save_game = File.new()
	
	for i in range(1, Global.MAX_SAVES):
		if save_game.file_exists("user://save" + String(i) + ".save"):
			save_game_count += 1
			# TODO: show a button in $SaveGamesVBox for each one that, when clicked, runs load_game with that save's name (make sure value is exact save name i.e. save1)
	
	if save_game_count == 0:
		pass # TODO: show label saying '[ No savegames found ]'
	
	save_game.close()
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
	Global.audioVolume = int(value)
	
	var config = ConfigFile.new()
	config.load("res://game_settings.cfg")
	
	config.set_value("audio", "volume", int(value))
	
	config.save("res://game_settings.cfg")


func load_game(save_name):
	var save_game = File.new()
	
	save_game.open("user://" + save_name + ".save", File.READ)
	
	# Parse JSON save data and put it back into the respective Global vars
	var save_data = parse_json(save_game.get_as_text())

	save_game.close()
	
	# Load the MainWorld scene now that we've parsed in the save data
	get_tree().change_scene("res://MainWorld.tscn")
