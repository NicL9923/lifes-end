extends Building

# TODO: clicking one toggles a mode that shows icons on each building it applies to (i.e. metal + cost-number/4-directions-arrows/hammer)
	# Player clicks building to do the above operation and has to confirm (popup dialog)
	# Probably need to start giving buildings unique IDs (or something to track it in both playerBaseData and game tree)


func _init():
	cost_to_build = 30

func _on_Upgrade_Button_pressed():
	pass

func _on_Move_Button_pressed():
	pass

func _on_Scrap_Button_pressed():
	pass
