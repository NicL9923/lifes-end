extends Control


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		get_tree().paused = self.visible

func _load_main_menu():
	get_tree().change_scene("res://MainMenu.tscn")
	Global.reset_global_data()
	get_tree().paused = false

func _on_Quit_Button_pressed():
	var popup = ConfirmationDialog.new()
	popup.window_title = "Are you sure?"
	popup.dialog_text = "Unsaved data will be lost"
	popup.connect("confirmed", self, "_load_main_menu")
	popup.pause_mode = Node.PAUSE_MODE_PROCESS
	Global.player.get_node("UI").add_child(popup)
	popup.popup_centered()
