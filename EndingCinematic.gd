extends Node2D

func _ready():
	if Global.mainEndingIsGood:
		$AnimationPlayer.play("goodMainEnding")
		
		if Global.subEndingIsGood:
			$AnimationPlayer.play("goodGoodSubEnding")
		else:
			$AnimationPlayer.play("goodBadSubEnding")
	else:
		$AnimationPlayer.play("badMainEnding")
		
		if Global.subEndingIsGood:
			$AnimationPlayer.play("badGoodSubEnding")
		else:
			$AnimationPlayer.play("badBadSubEnding")

func _on_Skip_Button_pressed():
	#TODO: go back to player base (verify no save data is lost - either save before cutscene, or something...)
	pass
