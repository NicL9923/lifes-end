extends Control

onready var research_panel := $Research_Panel


func _ready():
	pass 

func _on_Research_Button_pressed():
	pass

func _on_Close_Button_pressed():
	research_panel.visible = false
