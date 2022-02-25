extends Node2D

func _ready():
	$AnimationPlayer.play("IntroCinematicAnim")
	yield($AnimationPlayer, "animation_finished")
	
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	
	get_tree().change_scene("res://PlanetSelection.tscn")

func _on_Skip_Button_pressed():
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	
	get_tree().change_scene("res://PlanetSelection.tscn")
