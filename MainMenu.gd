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
		var filepath = "user://save" + String(i) + ".save"
		if save_game.file_exists(filepath):
			save_game_count += 1
			
			var savegame_panel = Button.new()
			savegame_panel.rect_min_size.y = 50
			
			var new_vbox = VBoxContainer.new()
			new_vbox.alignment = BoxContainer.ALIGN_CENTER
			new_vbox.rect_position.x += 20
			new_vbox.rect_position.y += 5
			savegame_panel.add_child(new_vbox)
			
			var save_name_label = Label.new()
			save_name_label.text = "save" + String(i)
			new_vbox.add_child(save_name_label)
			
			var timestamp_label = Label.new()
			save_game.open(filepath, File.READ)
			var time = save_game.get_var(true).saveTimestamp
			timestamp_label.text = "%02d/%02d/%d @ %02d:%02d" % [time.month, time.day, time.year, time.hour, time.minute]
			new_vbox.add_child(timestamp_label)
			
			savegame_panel.connect("pressed", self, "load_game", [save_name_label.text])
			$LoadGameContainer/SaveGamesVBox.add_child(savegame_panel)
	
	save_game.close()
	
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
	Global.playerStats = save_data.playerStats
	Global.playerResearchedItemIds = save_data.playerResearchedItemIds
	Global.playerResources = save_data.playerResources
	Global.modifiers = save_data.modifiers
	Global.game_time = save_data.gameTime
	Global.playerShipData = save_data.playerShipData
	Global.playerBaseData = save_data.playerBaseData
	Global.isPlayerBaseFirstLoad = false
	Global.npcColonyData = save_data.npcColonyData
	Global.rscCollectionSiteData = save_data.rscCollectionSiteData

	save_game.close()
	
	# Load the MainWorld scene now that we've parsed in the save data
	get_tree().change_scene("res://MainWorld.tscn")
