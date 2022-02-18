extends Spatial

var player_planet_index := _get_player_planet_index()
var currently_selected_planet := player_planet_index
export var player_rotate_sensitivity := { x = 10 * 0.001, y = 10 * 0.001 }
var mouse_pressed := false
export var icon_scale := 0.25
const col_shape_scale := 0.05
const icon_base_path := "res://ui/icons/"


func _ready():
	display_planet(currently_selected_planet)
	map_icons_to_planet()

func _process(_delta):
	pass

func _input(event):
	# Handle player dragging/rotating planet
	if event is InputEventMouseButton:
		mouse_pressed = event.pressed
	if event is InputEventMouseMotion and mouse_pressed:
		$Planet.rotate_y(event.relative.x * player_rotate_sensitivity.x)
		$Planet.rotate_x(event.relative.y * player_rotate_sensitivity.y)
		
		$Planet.rotation_degrees.x = clamp($Planet.rotation_degrees.x, -15, 15)
		$Planet.rotation_degrees.z = clamp($Planet.rotation_degrees.z, -15, 15)

func _setup_system_location(placeType: String, placeIndex: int):
	Global.location_to_load.type = placeType
	Global.location_to_load.index = placeIndex
	get_tree().change_scene("res://SystemLocation.tscn")

func _get_player_planet_index() -> int:
	for i in range(0, Global.planets.size()):
		if Global.playerBaseData.planet == Global.planets[i]:
			return i
	
	return 0

func _calculate_distance_to_planet(start_plt_idx, dest_plt_idx):
	var total_dist := 0
	
	if start_plt_idx > dest_plt_idx:
		for cur_plt_idx in range(dest_plt_idx, start_plt_idx):
			total_dist += Global.planet_distances[cur_plt_idx]
	else:
		for cur_plt_idx in range(start_plt_idx, dest_plt_idx):
			total_dist += Global.planet_distances[cur_plt_idx]
	
	print(total_dist)
	return total_dist

func _check_if_travel_possible():
	if Global.playerShipData.level == 1: # Unable to travel w/o upgrading ship
		return false;
	elif Global.playerShipData.level == 2: # Can travel on current planet
		if currently_selected_planet == player_planet_index:
			return true
		else:
			return false
	elif Global.playerShipData.level == 3: # Can travel 40 distance (million miles) = ~1 planet
		if _calculate_distance_to_planet(player_planet_index, currently_selected_planet) > 40:
			return false
		else:
			return true
	elif Global.playerShipData.level == 4: # Can travel 80 distance (million miles) = ~2 planets
		if _calculate_distance_to_planet(player_planet_index, currently_selected_planet) > 80:
			return false
		else:
			return true
	elif Global.playerShipData.level == 5: # Can travel to any planet, and to/from Pluto
		return true

func _icon_area_clicked(_camera, event, _pos, _normal, _shape_idx, placeType, placeIndex):
	if event is InputEventMouseButton and event.pressed:
		if not _check_if_travel_possible():
			var popup = AcceptDialog.new()
			popup.window_title = "Navigation System"
			popup.dialog_text = "You are unable to travel this far with your current ship. Upgrade your ship at the shipyard to increase travel distance!"
			
			popup.dialog_autowrap = true
			popup.rect_size = Vector2(300, 100)
			
			popup.pause_mode = Node.PAUSE_MODE_PROCESS
			$UI.add_child(popup)
			popup.popup_centered()
		else:
			var popup = ConfirmationDialog.new()
			popup.window_title = "Navigation System"
			
			if placeType == "npcColony":
				popup.dialog_text = "Are you sure you want to raid this colony?"
			else:
				popup.dialog_text = "Are you sure you want to visit this resource site?"
			
			popup.connect("confirmed", self, "_setup_system_location", [placeType, placeIndex])
			popup.pause_mode = Node.PAUSE_MODE_PROCESS
			$UI.add_child(popup)
			popup.popup_centered()

func create_icon(iconImgPath: String, coordinates, type: String, index: int):
	var newIcon = Area.new()
	
	var colShape = CollisionShape.new()
	colShape.shape = BoxShape.new()
	colShape.scale = Vector3(col_shape_scale, col_shape_scale, col_shape_scale)
	if type == Global.location_type.playerColony:
		colShape.disabled = true
	
	var newSprite = Sprite3D.new()
	newSprite.texture = load(iconImgPath)
	
	
	newIcon.add_child(colShape)
	newIcon.add_child(newSprite)
	newIcon.add_to_group("icon")
	$Planet.add_child(newIcon)
	
	newIcon.translation = $Planet.get_coords_from_lat_long(coordinates.lat, coordinates.long)
	newIcon.transform = newIcon.transform.looking_at($Planet.translation, Vector3(0, 1, 0))
	newSprite.scale = Vector3(icon_scale, icon_scale, icon_scale)
	newIcon.connect("input_event", self, "_icon_area_clicked", [type, index])

func remove_current_icons():
	for node in $Planet.get_children():
		if node.is_in_group("icon"):
			node.queue_free()

func map_icons_to_planet():
	remove_current_icons()
	
	if Global.playerBaseData.planet == Global.planets[currently_selected_planet]:
		create_icon(icon_base_path + "PlayerColonyIcon.png", Global.playerBaseData.coords, Global.location_type.playerColony, 0)
	
	var place_index := 0
	
	for colony in Global.npcColonyData:
		if colony.planet == Global.planets[currently_selected_planet]:
			var iconPath = icon_base_path + "NpcColonyIcon.png"
			
			if colony.isDestroyed:
				iconPath = icon_base_path + "DestroyedColonyIcon.png"
			
			create_icon(iconPath, colony.coords, Global.location_type.npcColony, place_index)
		place_index += 1
	
	place_index = 0
	
	for rsc_site in Global.rscCollectionSiteData:
		if rsc_site.planet == Global.planets[currently_selected_planet]:
			create_icon(icon_base_path + "ResourceSiteIcon.png", rsc_site.coords, Global.location_type.rscSite, place_index)
		place_index += 1

func update_thumbnail_highlight_pos():
	$UI/Planet_Thumbnail_Container/Highlight.rect_position.x = currently_selected_planet * 32 + 2

func display_planet(planet_index):
	$UI/PlanetName_Label.text = Global.planets[planet_index]
	update_thumbnail_highlight_pos()
	
	var newMaterial = SpatialMaterial.new()
	newMaterial.albedo_texture = load("res://objects/planets/3d_sprites/" + Global.planets[planet_index] + " 3D.png")
	$Planet/MeshInstance.mesh.surface_set_material(0, newMaterial)
	
	map_icons_to_planet()

func _on_Mercury_Area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		currently_selected_planet = 0
		display_planet(currently_selected_planet)

func _on_Venus_Area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		currently_selected_planet = 1
		display_planet(currently_selected_planet)

func _on_EarthsMoon_Area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		currently_selected_planet = 2
		display_planet(currently_selected_planet)

func _on_Mars_Area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		currently_selected_planet = 3
		display_planet(currently_selected_planet)

func _on_Pluto_Area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		currently_selected_planet = 4
		display_planet(currently_selected_planet)

func _on_Return_Button_pressed():
	get_tree().change_scene("res://MainWorld.tscn")
