extends Node2D

# TODO: show planet player colony is on as main planetary body
	# Smoke effects/etc if bad main ending
# TODO: show destroyed earth off in distance

# Figure out how to show effect of sub (humanity) ending...smoke effects etc on other planets if bad?

func _ready():
	# TEMPORARY: For final demo, just default showing good-good main/sub endings
	Global.mainEndingIsGood = true
	Global.subEndingIsGood = true
	
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
	
	$AnimationPlayer.play("credits")
	yield($AnimationPlayer, "animation_finished")
	
	_on_Skip_Button_button_pressed()

func _on_Skip_Button_button_pressed():
	get_tree().change_scene("res://MainWorld.tscn")
