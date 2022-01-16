extends Node2D

enum Building_Types {
	HQ
}

# TODO: move these into proper scenes (Ex: UI -> Player_UI.tscn that's attached to Player.tscn)

onready var building_panel = $Player/UI/Building_Panel
var in_building_mode = false
var building_node
var placement_highlight: ColorRect
const highlight_opacity := 0.5

func _physics_process(_delta):
	$Player/UI/MetalLabel.text = "Metal: " + str(Global.playerBaseMetal)
	
	if in_building_mode:
		var snapped_mouse_pos = get_global_mouse_position().snapped(Vector2(32, 32))
		building_node.global_position = snapped_mouse_pos
		
		if Input.is_action_pressed("ui_cancel"):
			in_building_mode = false
			return
		
		check_building_placement()

func start_building(building_type):
	in_building_mode = true
	
	# Set the building_node and placement_highlight based on type
	if building_type == Building_Types.HQ:
		building_node = preload("res://objects/buildings/HQ_Building.tscn").instance()
		
		get_tree().get_root().add_child(building_node)

func check_building_placement():
	if building_node.get_overlapping_bodies().size() == 0:
		building_node.get_child(0).color = Color(0.0, 1.0, 0.0, highlight_opacity)
		if Input.is_action_pressed("shoot"):
			# Place building on map (save position to save/game data -> TODO)
			# TODO: clear building_node ...??? EDIT: may not need to do as it'll just be reset when placing a new building - just keep an eye out for this
			building_node.get_child(0).visible = false
			in_building_mode = false
	else:
		building_node.get_child(0).color = Color(1.0, 0.0, 0.0, highlight_opacity)

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
