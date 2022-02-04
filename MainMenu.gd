extends Control

func _ready():
	$SettingsContainer.visible = false
	$LoadGameContainer.visible = false
	$MainMenuContainer/MainMenuVBox/NewGameButton.grab_focus()
	
	var config = ConfigFile.new()
	
	if config.load(Global.GAME_SETTINGS_CONFIG_PATH) != OK:
		Global.audioVolume = 100
	else:
		Global.audioVolume = config.get_value("audio", "volume")
	
	$SettingsContainer/SettingsVBox/HSlider.value = Global.audioVolume

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGameButton_pressed():
	$MainMenuContainer.visible = false
	
	# Get save games to parse in SaveGamesVBox
	var save_game_count := 0
	var save_game = File.new()
	
	# Show a button for each save found
	for i in range(1, Global.MAX_SAVES):
		if save_game.file_exists("user://save" + String(i) + ".save"):
			save_game_count += 1
			
			var new_button = Button.new()
			new_button.text = "save" + String(i)
			# TODO: show saveTimestamp
			new_button.connect("pressed", self, "load_game", [new_button.text])
			$LoadGameContainer/SaveGamesVBox.add_child(new_button)
	
	if save_game_count == 0:
		$LoadGameContainer/NoSavesFound_Label.visible = true
	else:
		$LoadGameContainer/NoSavesFound_Label.visible = false
	
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
	config.load(Global.GAME_SETTINGS_CONFIG_PATH)
	
	config.set_value("audio", "volume", int(value))
	
	config.save(Global.GAME_SETTINGS_CONFIG_PATH)


func load_game(save_name):
	var save_game = File.new()
	
	save_game.open("user://" + save_name + ".save", File.READ)
	
	# Get save data and put it back into the respective Global vars
	var save_data = save_game.get_var(true)
	
	Global.playerWeaponId = save_data.playerWeaponId
	Global.playerCmdrStat = save_data.playerCmdrStat
	Global.playerEngrStat = save_data.playerEngrStat
	Global.playerBiolStat = save_data.playerBiolStat
	Global.playerDocStat = save_data.playerDocStat
	Global.playerResearchedItemIds = save_data.playerResearchedItemIds
	Global.playerBaseMetal = save_data.playerBaseMetal
	Global.playerBaseFood = save_data.playerBaseFood
	Global.playerBaseWater = save_data.playerBaseWater
	Global.playerBaseEnergy = save_data.playerBaseEnergy
	Global.playerBaseData = save_data.playerBaseData
	Global.isPlayerBaseFirstLoad = false
	Global.npcColonyData = save_data.npcColonyData
	Global.rscCollectionSiteData = save_data.rscCollectionSiteData

	save_game.close()
	
	# Load the MainWorld scene now that we've parsed in the save data
	get_tree().change_scene("res://MainWorld.tscn")
