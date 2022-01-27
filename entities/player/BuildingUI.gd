extends Control

onready var building_panel = $Building_Panel
var in_building_mode = false
var building_node
const highlight_opacity := 0.5


func _ready():
	pass

func _physics_process(_delta):
	if in_building_mode:
		#NOTE: get_global_mouse_position() should work, but the CanvasLayer 'UI' in Player.tscn affects it in some way...meaning we have to use this monstrosity seen below
		var snapped_mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position()).snapped(Vector2.ONE * Global.cellSize)
		building_node.global_position = snapped_mouse_pos + (Vector2.ONE * (Global.cellSize / 2)) #TODO: make sure this works with buildings sized other than 3x3 tiles
		
		if Input.is_action_pressed("ui_cancel"):
			in_building_mode = false
			return
		
		check_building_placement()

func start_building(building_type):
	in_building_mode = true
	
	# Set the building_node based on type
	if building_type == Global.BUILDING_TYPES.HQ:
		building_node = preload("res://objects/buildings/HQ.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Shipyard:
		building_node = preload("res://objects/buildings/Shipyard.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Medbay:
		building_node = preload("res://objects/buildings/Medbay.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Barracks:
		building_node = preload("res://objects/buildings/Barracks.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Greenhouse:
		building_node = preload("res://objects/buildings/Greenhouse.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Power_Industrial_Coal:
		building_node = preload("res://objects/buildings/Power_Industrial_Coal.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Power_Renewable_Solar:
		building_node = preload("res://objects/buildings/Power_Renewable_Solar.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Water_Recycling_System:
		building_node = preload("res://objects/buildings/Water_Recycling_System.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Communications_Array:
		building_node = preload("res://objects/buildings/Communications_Array.tscn").instance()
	elif building_type == Global.BUILDING_TYPES.Science_Lab:
		building_node = preload("res://objects/buildings/Science_Lab.tscn").instance()
	
	building_node.modulate.a = 0.75
	if "isBeingPlaced" in building_node:
		building_node.isBeingPlaced = true
	building_node.get_child(0).visible = true
	get_tree().get_root().get_child(1).add_child(building_node) # Note: Second child of root is scene's top level node (first is utils)

func check_building_placement():
	if building_node.get_overlapping_bodies().size() == 0:
		building_node.get_child(0).color = Color(0.0, 1.0, 0.0, highlight_opacity)
		if Input.is_action_pressed("shoot"):
			# Place building on map (save position to save/game data -> TODO)
			# TODO: clear building_node ...??? EDIT: may not need to do as it'll just be reset when placing a new building - just keep an eye out for this
			building_node.modulate.a = 1.0
			if "isBeingPlaced" in building_node:
				building_node.isBeingPlaced = false
			building_node.get_child(0).visible = false
			in_building_mode = false
	else:
		building_node.get_child(0).color = Color(1.0, 0.0, 0.0, highlight_opacity)

func _on_Build_HQ_Button_pressed():
	$Build_HQ_Button.visible = false
	start_building(Global.BUILDING_TYPES.HQ)

func _on_Close_Button_pressed():
	building_panel.hide()


func _on_Shipyard_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Shipyard)

func _on_Medbay_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Medbay)

func _on_Barracks_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Barracks)

func _on_Greenhouse_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Greenhouse)

func _on_CoalPower_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Power_Industrial_Coal)

func _on_SolarPower_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Power_Renewable_Solar)

func _on_WaterRecyclingSystem_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Water_Recycling_System)

func _on_CommunicationsArray_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Communications_Array)

func _on_ScienceLab_Button_pressed():
	building_panel.hide()
	start_building(Global.BUILDING_TYPES.Science_Lab)
