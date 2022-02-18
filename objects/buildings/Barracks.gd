extends Building

func _init():
	cost_to_build = 25
	bldg_name = "Barracks"
	bldg_desc = "Recruit colonists, and view your stats"

func _process(_delta):
	$PopupUI.visible = is_player_in_popup_distance()

func _on_RecruitColonist_Button_pressed():
	randomize()
	# TODO: some cost for recruiting colonists
	
	var new_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
	new_colonist.id = Global.playerBaseData.colonists.size() # This keeps IDs simple and incremental
	new_colonist.global_position = Vector2(self.global_position.x + rand_range(-15, 15), self.global_position.y + rand_range(-15, 15))
	
	Global.playerBaseData.colonists.append({
		id = new_colonist.id,
		health = new_colonist.health
	})
	
	get_tree().get_root().get_child(1).add_child(new_colonist)

func _on_ViewStats_Button_pressed():
	pass # TODO
