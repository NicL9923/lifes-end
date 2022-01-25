extends Control
#TODO: come up with traits/benefits/negatives to planets
	#One idea is solar/radiation exposure for effectiveness of power plants such as Solar

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

func display_planet(planet_index):
	$PlanetName_Label.text = Global.planets[planet_index]
	$Planet_Sprite.texture = load("res://objects/planets/sprites/" + Global.planets[planet_index] + ".png")
