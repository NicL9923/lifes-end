extends Control
#TODO: come up with traits/benefits/negatives to planets
	#One idea is solar/radiation exposure for effectiveness of power plants such as Solar
	
	# Mercury (Extreme amounts of solar radiation), Pluto (Farthest from other habitable planets),
	# Earth's Moon (familiar = morale/combat boost?), Mars (The Next Frontier = largest concentration of other colonies),
	# Venus (Volatile = More natural events)

var currently_selected_planet := 2


func _ready():
	display_planet(currently_selected_planet)


func _on_Select_Button_pressed():
	Global.playerBaseData.planet = Global.planets[currently_selected_planet]
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
	$Planet_Thumbnail_Container/Highlight.rect_position.x = currently_selected_planet * 32 + 2

func display_planet(planet_index):
	$PlanetName_Label.text = Global.planets[planet_index]
	$Planet_Sprite.texture = load("res://objects/planets/sprites/" + Global.planets[planet_index] + ".png")
	
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
