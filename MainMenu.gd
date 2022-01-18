extends Control

func _ready():
	$SettingsContainer.visible = false
	$LoadGameContainer.visible = false
	$MainMenuContainer/MainMenuVBox/NewGameButton.grab_focus()

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://CharacterCreation.tscn")

func _on_LoadGameButton_pressed():
	$MainMenuContainer.visible = false
	
	#TODO: get save games to parse in SaveGamesVBox
	#if none, show label saying '[ No savegames found ]'
	#else show a button in $SaveGamesVBox for each one that, when clicked, runs load_game with that save's name
	
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


#TODO: first take care of save_game function in MainWorld scene, then
#adapt this func to our specific needs/conventions
func load_game(save_name):
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])

	save_game.close()
