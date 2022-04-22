extends Control

onready var tn_highlight = $Planet_Thumbnail_Container/Highlight
onready var planet_name_lbl = $PlanetName_Label
onready var planet_sprite = $Planet_Sprite
onready var trait1_lbl = $TraitsRect/Trait1_Lbl
onready var trait2_lbl = $TraitsRect/Trait2_Lbl

var currently_selected_planet := 2


func _ready():
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
			trait1_lbl.text = "-Sol Amplexus (2.5x solar production)"
			trait2_lbl.text = "-Resource rich"
		"Venus":
			trait1_lbl.text = "-Volatile (more natural events)"
			trait2_lbl.text = ""
		"Earth's Moon":
			trait1_lbl.text = "-Dark Side of the Moon (.75x solar production)"
			trait2_lbl.text = "-Close to Home (Heavily populated)"
		"Mars":
			trait1_lbl.text = "-Polar Ice Caps (2x water production)"
			trait2_lbl.text = "-The Next Frontier (Heavily populated)"
		"Pluto":
			trait1_lbl.text = "-Isolated"
			trait2_lbl.text = "-Resource rich"
	
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

func _on_Select_Button_button_pressed():
	Global.playerBaseData.planet = Global.planets[currently_selected_planet]
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://MainWorld.tscn")

func _on_Left_Button_button_pressed():
	if currently_selected_planet != 0:
		currently_selected_planet -= 1
		display_planet(currently_selected_planet)

func _on_Right_Button_button_pressed():
	if currently_selected_planet != Global.planets.size() - 1:
		currently_selected_planet += 1
		display_planet(currently_selected_planet)
