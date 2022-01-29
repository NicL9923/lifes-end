extends Spatial

var currently_selected_planet := 2
var player_rotate_sensitivity := 1
var mouse_pressed := false


func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://MainGame.tscn")
	
	map_icons_to_planet()

func _input(event):
	# Handle player dragging/rotating planet
	if event is InputEventMouseButton:
		mouse_pressed = event.pressed
	if event is InputEventMouseMotion and mouse_pressed:
		$Planet.rotation_degrees = Vector3($Planet.rotation_degrees.x + (event.relative.x * player_rotate_sensitivity), $Planet.rotation_degrees.y + (event.relative.y * player_rotate_sensitivity), $Planet.rotation_degrees.z)

func map_icons_to_planet():
	# TODO: map icons to planets
		# Check player and npc bases for planet, and if it's the current one, map those icons (Sprite3D)
	var coords = $Planet.get_coords_from_lat_long(60, 60)
	print(coords)
	
	var test_sprite = Sprite3D.new()
	test_sprite.texture = load("res://objects/ship.png")
	$Planet.add_child(test_sprite)
	test_sprite.translation = coords

func update_thumbnail_highlight_pos():
	$UI/Planet_Thumbnail_Container/Highlight.rect_position.x = currently_selected_planet * 32 + 2

func display_planet(planet_index):
	$UI/PlanetName_Label.text = Global.planets[planet_index]
	update_thumbnail_highlight_pos()
	
	# TODO: apply planet's specific shader to mesh

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
