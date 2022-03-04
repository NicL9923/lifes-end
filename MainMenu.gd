extends Control

func _ready():
	$SettingsContainer.visible = false
	$LoadGameContainer.visible = false
	
	var config = ConfigFile.new()
	
	if config.load(Global.GAME_SETTINGS_CONFIG_PATH) != OK:
		Global.audioVolume = 100
	else:
		Global.audioVolume = config.get_value("audio", "volume")
	
	$SettingsContainer/SettingsVBox/HSlider.value = Global.audioVolume

func _on_HSlider_value_changed(value):
	Global.audioVolume = int(value)
	
	var config = ConfigFile.new()
	config.load(Global.GAME_SETTINGS_CONFIG_PATH)
	
	config.set_value("audio", "volume", int(value))
	
	config.save(Global.GAME_SETTINGS_CONFIG_PATH)

func _on_NewGame_Btn_button_pressed():
	$AnimationPlayer.play("transition_to_char_creation")
	yield($AnimationPlayer, "animation_finished")
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGame_Btn_button_pressed():
	$MainMenuContainer.visible = false
	var save_files = []
	
	# Find and build list of .save files
	var dir = Directory.new()
	dir.open("user://")
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		if ".save" in file_name:
			save_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if save_files.size() == 0:
		$LoadGameContainer/NoSavesFound_Label.visible = true
		return
	else:
		$LoadGameContainer/NoSavesFound_Label.visible = false
	
	# Parse savegames in SaveGamesVBox
	var save_game = File.new()
	
	# Show a button for each save found
	for save in save_files:
		var filepath = "user://" + save
		if save_game.file_exists(filepath):
			var savegame_panel = Button.new()
			savegame_panel.rect_min_size.y = 50
			
			var new_vbox = VBoxContainer.new()
			new_vbox.alignment = BoxContainer.ALIGN_CENTER
			new_vbox.rect_position.x += 20
			new_vbox.rect_position.y += 5
			savegame_panel.add_child(new_vbox)
			
			var save_name_label = Label.new()
			save_name_label.text = save.replace(".save", "")
			new_vbox.add_child(save_name_label)
			
			var timestamp_label = Label.new()
			save_game.open(filepath, File.READ)
			var time = save_game.get_var(true).saveTimestamp
			timestamp_label.text = "%02d/%02d/%d @ %02d:%02d" % [time.month, time.day, time.year, time.hour, time.minute]
			new_vbox.add_child(timestamp_label)
			
			savegame_panel.connect("pressed", Global, "load_game", [save_name_label.text])
			$LoadGameContainer/SaveGamesVBox.add_child(savegame_panel)
	
	save_game.close()
	$LoadGameContainer.visible = true

func _on_Settings_Btn_button_pressed():
	$MainMenuContainer.visible = false
	$SettingsContainer.visible = true

func _on_Quit_Btn_button_pressed():
	get_tree().quit()

func _on_Stgs_GoBack_Btn_button_pressed():
	$SettingsContainer.visible = false
	$MainMenuContainer.visible = true

func _on_Load_GoBack_Btn_button_pressed():
	$LoadGameContainer.visible = false
	$MainMenuContainer.visible = true
