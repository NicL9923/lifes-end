extends Control

var isMenuUp := false
export var max_cmds := 100
onready var line_edit = $ColorRect/LineEdit
onready var history_scroll_cont = $ColorRect/ScrollContainer
onready var history_vbox = $ColorRect/ScrollContainer/CmdHistory_VBox


func _ready():
	self.visible = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("dev_menu"):
		if isMenuUp:
			self.visible = false
			isMenuUp = false
			line_edit.release_focus()
			get_tree().paused = false
		else:
			isMenuUp = true
			self.visible = true
			get_tree().paused = true
			line_edit.text = ""
			line_edit.grab_focus()
	
	if isMenuUp and Input.is_action_just_pressed("ui_enter"):
		execute_dev_commands()
	
	if isMenuUp and Global.debug.dev_console.entered_cmds.size() > 0:
		if isMenuUp and Input.is_action_just_pressed("arrow_up"):
			line_edit.text = Global.debug.dev_console.entered_cmds[Global.debug.dev_console.current_history_index]
			line_edit.caret_position = line_edit.text.length()
			
			if Global.debug.dev_console.current_history_index != 0:
				Global.debug.dev_console.current_history_index -= 1
		elif isMenuUp and Input.is_action_just_pressed("arrow_down"):
			if Global.debug.dev_console.current_history_index != Global.debug.dev_console.entered_cmds.size() - 1:
				Global.debug.dev_console.current_history_index += 1
			
			line_edit.text = Global.debug.dev_console.entered_cmds[Global.debug.dev_console.current_history_index]
			line_edit.caret_position = line_edit.text.length()

func execute_dev_commands():
	line_edit.placeholder_text = "Input commands here"
	var cmdTxt = Array(line_edit.text.split(' '))
	var output_to_add = []
	
	# TODO: add ammo, place building
	# TODO: handle commands w/ invalid parameters
	if cmdTxt[0] == "help":
		output_to_add.append("god - player is invincible and has unlimited ammo")
		output_to_add.append("metal/energy/food/water x - gives player x of specified rsc")
		output_to_add.append("health x - sets player health to x")
		output_to_add.append("teleport x y - teleports player to coords (x, y)")
		output_to_add.append("set_time 0-2400 - sets time of day to given num")
		output_to_add.append("set_day x - sets game Earth days passed to x")
		output_to_add.append("set_time_speed x - sets time speed (8=5min day; 40=1min; 160=15s)")
		output_to_add.append("push_player_notification x - pushes a player notification that says x")
		output_to_add.append("load_scene scene_name_or_path - loads scene with given name/path")
		output_to_add.append("clear_saves - removes all save files in default directory")
	elif cmdTxt[0] == "god":
		Global.debug.god_mode = !Global.debug.god_mode
		output_to_add.append("God mode set to " + ("on" if Global.debug.god_mode else "off"))
	elif cmdTxt[0] == "metal" or cmdTxt[0] == "energy" or cmdTxt[0] == "food" or cmdTxt[0] == "water" and cmdTxt[1] != null:
		Global.playerResources[cmdTxt[0]] += int(cmdTxt[1])
		output_to_add.append("Successfully added " + cmdTxt[1] + " " + cmdTxt[0] + "!")
	elif cmdTxt[0] == "health" and cmdTxt[1] != null: #health 100
		Global.player.health = int(cmdTxt[1])
		output_to_add.append("Set player health to " + cmdTxt[1])
	elif cmdTxt[0] == "teleport" and cmdTxt[1] != null and cmdTxt[2] != null: #teleport 20 30
		Global.player.global_position = Vector2(int(cmdTxt[1]), int(cmdTxt[2]))
		output_to_add.append("Teleported to x: " + cmdTxt[1] + " y: " + cmdTxt[2])
	elif cmdTxt[0] == "set_time" and cmdTxt[1] != null: # set_time 800 *range: 0-2400
		Global.game_time.ticks = float(cmdTxt[1])
		output_to_add.append("Set time to " + cmdTxt[1])
	elif cmdTxt[0] == "set_day" and cmdTxt[1] != null: # set_day 13
		Global.game_time.earthDays = int(cmdTxt[1])
		output_to_add.append("Set day (in Earth days) to " + cmdTxt[1])
	elif cmdTxt[0] == "set_time_speed" and cmdTxt[1] != null:
		Global.time_speed = int(cmdTxt[1])
		output_to_add.append("Set time speed to " + cmdTxt[1])
	elif cmdTxt[0] == "push_player_notification" and cmdTxt[1] != null:
		Global.push_player_notification(cmdTxt[1])
	elif cmdTxt[0] == "load_scene" and cmdTxt[1] != null: #load_scene MainWorld
		var path = "res://" + cmdTxt[1] + ".tscn"
		get_tree().change_scene(path)
		output_to_add.append("Loaded scene " + path)
		get_tree().paused = false
	elif cmdTxt[0] == "clear_saves":
		var file_deleter = Directory.new()
		file_deleter.open("user://")
		file_deleter.list_dir_begin(true, true)
		var file_name = file_deleter.get_next()
		while file_name != "":
			if ".save" in file_name:
				file_deleter.remove("user://" + file_name)
			file_name = file_deleter.get_next()
		file_deleter.list_dir_end()
			
		output_to_add.append("Cleared saves!")
	else:
		line_edit.placeholder_text = "Error: Invalid command"
	
	if Global.debug.dev_console.entered_cmds.size() >= max_cmds:
		Global.debug.dev_console.entered_cmds.pop_front()
		Global.debug.dev_console.output_stream.pop_front() # This is a weird case, but entered_cmds being limited should limit output_stream well enough
		
	Global.debug.dev_console.entered_cmds.append(line_edit.text)
	line_edit.text = ""
	Global.debug.dev_console.current_history_index = Global.debug.dev_console.entered_cmds.size() - 1
	
	Global.debug.dev_console.output_stream.append(Global.debug.dev_console.entered_cmds[Global.debug.dev_console.current_history_index])
	for output in output_to_add:
		Global.debug.dev_console.output_stream.append(output)
	
	# Clear cmd history labels first to stay up-to-date
	for node in history_vbox.get_children():
		node.queue_free()
	
	# Push command/console output history to actual display
	for line in Global.debug.dev_console.output_stream:
		var history_label = Label.new()
		history_label.text = line
		history_vbox.add_child(history_label)
	
	yield(VisualServer, "frame_post_draw") # Note: This is here because if it isn't, scrollbar max_value doesn't update quick enough
	history_scroll_cont.scroll_vertical = history_scroll_cont.get_v_scrollbar().max_value + 5
