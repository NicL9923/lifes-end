extends Control

var isMenuUp := false
var entered_cmds: Array #TODO: hold up to 100 of the last entered commands
	#Bonus points: up and down arrow keys to traverse through them for reuse



func _ready():
	self.visible = false

func _process(delta):
	if Input.is_action_pressed("dev_menu"):
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
	
	if isMenuUp and Input.is_key_pressed(KEY_ENTER):
		execute_dev_commands()

func execute_dev_commands():
	var cmdTxt = Array($ColorRect/LineEdit.text.split(' '))
		
	#TODO: god mode (no dmg + unlimited ammo), ammo, other resources
	if cmdTxt[0] == "metal" and cmdTxt[1] != null: #metal 5
		Global.playerBaseMetal += int(cmdTxt[1])
	elif cmdTxt[0] == "health" and cmdTxt[1] != null: #health 100
		Global.playerHealth = int(cmdTxt[1])
	elif cmdTxt[0] == "load_scene" and cmdTxt[1] != null: #load_scene MainWorld
		get_tree().change_scene("res://" + cmdTxt[1] + ".tscn")
	elif cmdTxt[0] == "teleport" and cmdTxt[1] != null and cmdTxt[2] != null: #teleport 20 30
		Global.player.global_position = Vector2(int(cmdTxt[1]), int(cmdTxt[2]))
	else:
		$ColorRect/LineEdit.placeholder_text = "Error: Invalid command"