extends Control

enum Building_Types {
	HQ
}

onready var building_panel = $Building_Panel
var in_building_mode = false
var building_node
const highlight_opacity := 0.5


func _ready():
	pass

func _physics_process(_delta):
	if in_building_mode:
		var snapped_mouse_pos = get_global_mouse_position().snapped(Vector2.ONE * Global.cellSize)
		building_node.global_position = snapped_mouse_pos + (Vector2.ONE * (Global.cellSize / 2)) #TODO: make sure this works with buildings sized other than 3x3 tiles
		
		if Input.is_action_pressed("ui_cancel"):
			in_building_mode = false
			return
		
		check_building_placement()

func start_building(building_type):
	in_building_mode = true
	
	# Set the building_node based on type
	if building_type == Building_Types.HQ:
		building_node = preload("res://objects/buildings/HQ_Building.tscn").instance()
	
	building_node.modulate.a = 0.75
	get_tree().get_root().add_child(building_node)

func check_building_placement():
	if building_node.get_overlapping_bodies().size() == 0:
		building_node.get_child(0).color = Color(0.0, 1.0, 0.0, highlight_opacity)
		if Input.is_action_pressed("shoot"):
			# Place building on map (save position to save/game data -> TODO)
			# TODO: clear building_node ...??? EDIT: may not need to do as it'll just be reset when placing a new building - just keep an eye out for this
			building_node.modulate.a = 1.0
			building_node.get_child(0).visible = false
			in_building_mode = false
	else:
		building_node.get_child(0).color = Color(1.0, 0.0, 0.0, highlight_opacity)


func _on_Building_Button_pressed():
	building_panel.show()


func _on_Close_Button_pressed():
	building_panel.hide()


func _on_HQ_Button_pressed():
	building_panel.hide()
	start_building(Building_Types.HQ)
