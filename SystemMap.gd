extends Control

var currently_selected_planet := 2


func _ready():
	pass

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://MainGame.tscn")

func update_thumbnail_highlight_pos():
	$Planet_Thumbnail_Container/Highlight.rect_position.x = currently_selected_planet * 32 + 2

func display_planet(planet_index):
	$PlanetName_Label.text = Global.planets[planet_index]
	update_thumbnail_highlight_pos()
	
	# TODO: load 3D planet mesh

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
