extends Control

onready var building_panel = $Building_Panel
onready var building_button_box = $Building_Panel/ScrollContainer/VBoxContainer
var in_building_mode = false
var building_node
var building_type
const highlight_opacity := 0.5
const base_bldg_path := "res://objects/buildings/"


func _ready():
	generate_building_buttons()

func _physics_process(_delta):
	if in_building_mode:
		handle_building_placement()
	
	check_building_requirements()

func handle_building_placement():
	#NOTE: get_global_mouse_position() should work, but the CanvasLayer 'UI' in Player.tscn affects it in some way...meaning we have to use this monstrosity seen below
	var snapped_mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position()).snapped(Vector2.ONE * Global.cellSize)
	building_node.global_position = snapped_mouse_pos + (Vector2.ONE * (Global.cellSize / 2))
	
	if Input.is_action_pressed("ui_cancel"):
		in_building_mode = false
		building_node.queue_free()
		building_node = null
		return
	
	check_building_placement()

func check_building_requirements():
	var cur_bldg_idx := 1
	for node in building_button_box.get_children():
		var btn_is_disabled := false
		
		# Check if player has enough resources for each building
		var bldg_cost = int(node.get_child(3).text.split(" ")[1])
		if Global.playerResources.metal < bldg_cost:
			btn_is_disabled = true
		
		# Check how many of each limited building player has, and disable the button if they're at the limit
		if node.get_children().size() == 5:
			var num_placed := get_num_bldgs_placed(Global.buildings.keys()[cur_bldg_idx])
			var limit_lbl = node.get_child(4)
			var max_placeable := int(limit_lbl.text.split(" / ")[1])
			
			if num_placed == max_placeable:
				btn_is_disabled = true
			
			limit_lbl.text = str(num_placed) + " / " + str(max_placeable)
		
		node.disabled = btn_is_disabled
		cur_bldg_idx += 1

func is_building_unlocked(bldg_key):
	for unlocked_bldg in Global.playerBaseData.unlockedBuildings:
		if bldg_key == unlocked_bldg:
			return true
	
	return false

# Since we generate them based on the order of Global.BUILDING_TYPES, we can safely assume that order stays the same when referencing it elsewhere
func generate_building_buttons():
	for bldg_btn in building_button_box.get_children():
		bldg_btn.queue_free()
	
	for bldg_key in Global.buildings.keys():
		if bldg_key == "HQ": # Skip HQ
			continue
		
		var bldg_info = load(base_bldg_path + "Building.tscn").instance()
		bldg_info.init(bldg_key, Global.buildings[bldg_key], 1)
		
		# Skip if building needs to be unlocked and hasn't
		if bldg_info.has_to_be_unlocked and not is_building_unlocked(bldg_key):
			continue
		
		var new_bldg_btn = Button.new()
		new_bldg_btn.rect_min_size = Vector2(590, 100)
		
		var bldg_sprite = Sprite.new()
		bldg_sprite.texture = load(base_bldg_path + bldg_key.to_lower() + ".png")
		bldg_sprite.scale = Vector2(72 / bldg_sprite.texture.get_size().x, 72 / bldg_sprite.texture.get_size().y)
		new_bldg_btn.add_child(bldg_sprite)
		bldg_sprite.position = Vector2(50, new_bldg_btn.rect_min_size.y / 2)
		
		var title_lbl = Label.new()
		title_lbl.text = bldg_info.bldg_name
		new_bldg_btn.add_child(title_lbl)
		title_lbl.rect_position = Vector2(125, 10)
		
		var desc_lbl = Label.new()
		desc_lbl.text = bldg_info.bldg_desc
		desc_lbl.autowrap = true
		desc_lbl.rect_size.x = 350
		new_bldg_btn.add_child(desc_lbl)
		desc_lbl.rect_position = Vector2(125, 35)
		
		var cost_lbl = Label.new()
		cost_lbl.text = "Cost: " + str(bldg_info.cost_to_build) + " metal"
		new_bldg_btn.add_child(cost_lbl)
		cost_lbl.rect_position = Vector2(125, 75)
		
		if bldg_info.bldg_limit != null:
			var limit_lbl = Label.new()
			limit_lbl.text = str(get_num_bldgs_placed(bldg_key)) + " / " + str(bldg_info.bldg_limit)
			new_bldg_btn.add_child(limit_lbl)
			limit_lbl.rect_position = Vector2(550, (new_bldg_btn.rect_min_size.y / 2) - 5)
		
		new_bldg_btn.connect("pressed", self, "start_building", [bldg_key])
		building_button_box.add_child(new_bldg_btn)

func get_num_bldgs_placed(bldg_key: String) -> int:
	var bldgs_found := 0
	
	for bldg in Global.playerBaseData.buildings:
		if bldg.type == bldg_key:
			bldgs_found += 1
	
	return bldgs_found

func start_building(bldg_key: String):
	building_panel.hide()
	in_building_mode = true
	building_type = bldg_key
	
	# Set the building_node based on type
	building_node = load(base_bldg_path + "Building.tscn").instance()
	building_node.init(bldg_key, Global.buildings[bldg_key], 1)
	
	building_node.get_node("StaticBody2D/CollisionShape2D").disabled = true
	building_node.modulate.a = 0.75
	building_node.isBeingPlaced = true
	building_node.get_node("CollisionHighlight").visible = true
	get_tree().get_current_scene().add_child(building_node) # Note: Second child of root is scene's top level node (first is utils)

func check_building_placement():
	if building_node.get_overlapping_bodies().size() == 0:
		building_node.get_child(0).color = Color(0.0, 1.0, 0.0, highlight_opacity)
		
		if Input.is_action_pressed("shoot"):
			place_building()
	else:
		building_node.get_child(0).color = Color(1.0, 0.0, 0.0, highlight_opacity)

func place_building():
	# Place building on map
	building_node.modulate.a = 1.0
	building_node.isBeingPlaced = false
	if not Global.debug.instant_build:
		building_node.isBeingBuilt = true
	building_node.isPlayerBldg = true
	building_node.bldgLvl = 1
	Global.playerResources.metal -= building_node.cost_to_build
	
	building_node.get_child(0).visible = false # Hide collision colorRect
	building_node.get_node("StaticBody2D/CollisionShape2D").disabled = false # Enable StaticBody2D so player can collide with placed buildings
	
	# Add building data to global player base data
	var bldg_data = {
		type = building_type,
		building_lvl = building_node.bldgLvl,
		global_pos = building_node.global_position
	}
	Global.playerBaseData.buildings.append(bldg_data)
	
	get_tree().get_current_scene().base_mgr.add_building(building_node)
	
	building_node = null
	in_building_mode = false

func _on_Build_HQ_Button_pressed():
	$Build_HQ_Button.visible = false
	start_building("HQ")

func _on_Close_Button_pressed():
	building_panel.hide()
