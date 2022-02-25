extends Control

onready var tn_highlight = $Planet_Thumbnail_Container/Highlight
onready var planet_name_lbl = $PlanetName_Label
onready var planet_sprite = $Planet_Sprite

var currently_selected_planet := 2


func _ready():
	display_planet(currently_selected_planet)


func _on_Select_Button_pressed():
	Global.playerBaseData.planet = Global.planets[currently_selected_planet]
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://MainWorld.tscn")

func _on_Left_Button_pressed():
	if currently_selected_planet != 0:
		currently_selected_planet -= 1
		display_planet(currently_selected_planet)

func _on_Right_Button_pressed():
	if currently_selected_planet != Global.planets.size() - 1:
		currently_selected_planet += 1
		display_planet(currently_selected_planet)

func update_thumbnail_highlight_pos():
	tn_highlight.rect_position.x = currently_selected_planet * 32 + 2

func display_planet(planet_index):
	var plt_name = Global.planets[planet_index]
	
	planet_name_lbl.text = plt_name
	planet_sprite.texture = load("res://objects/planets/sprites/" + plt_name + ".png")
	
	# Display planet traits
	match plt_name:
		"Mercury":
			pass
			# Sol Amplexus (2.5x solar production)
			# Sparsely populated
			# Resource rich
		"Venus":
			pass # Volatile (more natural events - less raids)
		"Earth's Moon":
			pass
			# Dark Side of the Moon (0.75x solar production)
			# Close to Home (Heavily populated)
		"Mars":
			pass
			# Polar Ice Caps (2x water production)
			# The Next Frontier (Heavily populated)
		"Pluto":
			pass
			# Isolated
			# Resource rich
	
	update_thumbnail_highlight_pos()

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
