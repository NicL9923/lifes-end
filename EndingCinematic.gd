extends Node2D

func _ready():
	#TODO: determine cutscene to play (i.e. good/bad main and sub-endings
	
	$AnimationPlayer.play("EndingCinematicAnim")

func _on_Skip_Button_pressed():
	#TODO: go back to player base (verify no save data is lost - either save before cutscene, or something...)
	pass
