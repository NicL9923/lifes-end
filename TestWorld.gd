extends Node2D

enum Building_Types {
	HQ
}

# TODO: move these into proper scenes (Ex: UI -> Player_UI.tscn that's attached to Player.tscn)

onready var building_panel = $Player/UI/Building_Panel
var in_building_mode = false
var building_node
var placement_highlight

func _physics_process(_delta):
	if in_building_mode:
		# TODO: attach building & highlight sprite to player cursor
		building_node.global_position = get_global_mouse_position()
		
		if Input.is_action_pressed("ui_cancel"):
			in_building_mode = false
			return
		
		check_building_placement()

func start_building(building_type):
	in_building_mode = true
	
	# TODO: set building_node and placement_highlight based on type
	if building_type == Building_Types.HQ:
		building_node = preload("res://objects/buildings/HQ_Building.tscn").instance()
		get_tree().get_root().add_child(building_node)

func check_building_placement():
	# TODO: if no collision w/ other objects/buildings
		# place_highlight = green
		if Input.is_action_pressed("shoot"):
			#place building on map (save position to save/game data -> TODO)
			in_building_mode = false
	# else:
		# red tiles

func _on_TglCmbt_Button_pressed():
	Global.player.toggle_combat()


func _on_Building_Button_pressed():
	building_panel.show()

func _on_Close_Button_pressed():
	building_panel.hide()

func _on_HQ_Button_pressed():
	building_panel.hide()
	start_building(Building_Types.HQ)


func _on_Research_Button_pressed():
	pass
