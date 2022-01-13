extends Node2D

func _ready():
	$AnimationPlayer.play("IntroCinematicAnim")

func _on_Skip_Button_pressed():
	get_tree().change_scene("res://PlanetSelection.tscn")
