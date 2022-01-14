extends Node2D

func _ready():
	if Global.mainEndingIsGood:
		$AnimationPlayer.play("goodMainEnding")
		yield($AnimationPlayer, "animation_finished")
		
		if Global.subEndingIsGood:
			$AnimationPlayer.play("goodGoodSubEnding")
		else:
			$AnimationPlayer.play("goodBadSubEnding")
	else:
		$AnimationPlayer.play("badMainEnding")
		yield($AnimationPlayer, "animation_finished")
		
		if Global.subEndingIsGood:
			$AnimationPlayer.play("badGoodSubEnding")
		else:
			$AnimationPlayer.play("badBadSubEnding")
	
	yield($AnimationPlayer, "animation_finished")
	_on_Skip_Button_pressed()

func _on_Skip_Button_pressed():
	#TODO: go back to player base (verify no save data is lost - either save before cutscene, or something...)
	pass
