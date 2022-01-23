extends Control

var isMenuUp := false
export var max_cmds := 100
var entered_cmds: Array
var current_history_index := 0


func _ready():
	self.visible = false

func _physics_process(delta):
	if Input.is_action_just_pressed("dev_menu"):
		if isMenuUp:
			self.visible = false
			isMenuUp = false
			$ColorRect/LineEdit.release_focus()
			get_tree().paused = false
		else:
			isMenuUp = true
			self.visible = true
			get_tree().paused = true
			$ColorRect/LineEdit.grab_focus()
	
	if isMenuUp and Input.is_action_just_pressed("ui_enter"):
		execute_dev_commands()
	
	if isMenuUp and Input.is_action_just_pressed("arrow_up"):
		$ColorRect/LineEdit.text = entered_cmds[current_history_index]
		
		if current_history_index != 0:
			current_history_index -= 1
	elif isMenuUp and Input.is_action_just_pressed("arrow_down"):
		if current_history_index != entered_cmds.size() - 1:
			current_history_index += 1
		
		$ColorRect/LineEdit.text = entered_cmds[current_history_index]

func execute_dev_commands():
	var cmdTxt = Array($ColorRect/LineEdit.text.split(' '))
		
	#TODO: god mode (no dmg + unlimited ammo), ammo, other resources
	if cmdTxt[0] == "metal" and cmdTxt[1] != null: #metal 5
		Global.playerBaseMetal += int(cmdTxt[1])
	elif cmdTxt[0] == "health" and cmdTxt[1] != null: #health 100
		Global.playerHealth = int(cmdTxt[1])
	elif cmdTxt[0] == "load_scene" and cmdTxt[1] != null: #load_scene MainWorld
		get_tree().change_scene("res://" + cmdTxt[1] + ".tscn")
		get_tree().paused = false
	elif cmdTxt[0] == "teleport" and cmdTxt[1] != null and cmdTxt[2] != null: #teleport 20 30
		Global.player.global_position = Vector2(int(cmdTxt[1]), int(cmdTxt[2]))
	else:
		$ColorRect/LineEdit.placeholder_text = "Error: Invalid command"
	
	if entered_cmds.size() >= max_cmds:
		entered_cmds.pop_front()
		
	entered_cmds.append($ColorRect/LineEdit.text)
	$ColorRect/LineEdit.text = ""
	current_history_index = entered_cmds.size() - 1
	
	#TODO: make this work
	for i in range(entered_cmds.size() - 1, 0):
		$ColorRect/CmdHistory.set_line(i, entered_cmds[i])
