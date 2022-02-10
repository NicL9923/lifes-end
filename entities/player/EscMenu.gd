extends Control


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		get_tree().paused = self.visible
