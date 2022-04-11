extends Control

var metal_to_gift := 0
var food_to_gift := 0
var water_to_gift := 0
var humanity_received := 0.0

func _ready():
	pass

func _process(delta):
	$Panel/Metal_Slider.max_value = Global.playerResources.metal
	$Panel/Food_Slider.max_value = Global.playerResources.food
	$Panel/Water_Slider.max_value = Global.playerResources.water
	
	metal_to_gift = $Panel/Metal_Slider.value
	$Panel/Metal_Slider/Label.text = str($Panel/Metal_Slider.value)
	food_to_gift = $Panel/Food_Slider.value
	$Panel/Food_Slider/Label.text = str($Panel/Food_Slider.value)
	water_to_gift = $Panel/Water_Slider.value
	$Panel/Water_Slider/Label.text = str($Panel/Water_Slider.value)
	
	humanity_received = (metal_to_gift * 0.5) + (food_to_gift * 0.25) + (water_to_gift * 0.2)
	
	$Panel/Label.text = "+" + str(humanity_received) + " humanity"


func _on_Gift_Btn_button_pressed():
	Global.change_metal_by(-metal_to_gift)
	Global.change_food_by(-food_to_gift)
	Global.change_water_by(-water_to_gift)
	
	Global.add_player_humanity(humanity_received)
	
	hide()
	
	# Reset this UI's values
	metal_to_gift = 0
	food_to_gift = 0
	water_to_gift = 0
	humanity_received = 0.0

func _on_Close_Button_button_pressed():
	hide()
