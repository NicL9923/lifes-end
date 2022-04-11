extends Control

var npc_col_id: int

var food_to_trade := 0
var water_to_trade := 0

var metal_val := 0


func _ready():
	pass

func _process(delta):
	$Panel/Food_Slider.min_value = -Global.playerResources.food
	$Panel/Food_Slider.max_value = Global.npcColonyData[npc_col_id].resources.food
	$Panel/Water_Slider.min_value = -Global.playerResources.water
	$Panel/Water_Slider.max_value = Global.npcColonyData[npc_col_id].resources.water
	
	food_to_trade = $Panel/Food_Slider.value
	$Panel/Food_Slider/Label.text = str($Panel/Food_Slider.value)
	water_to_trade = $Panel/Water_Slider.value
	$Panel/Water_Slider/Label.text = str($Panel/Water_Slider.value)
	
	metal_val = -food_to_trade + (-water_to_trade * 2)
	
	var give_str = ""
	var receive_str = ""
	
	if metal_val < 0:
		give_str += str(abs(metal_val)) + " metal "
	else:
		receive_str += str(metal_val) + " metal "
	
	if food_to_trade < 0:
		give_str += str(abs(food_to_trade)) + " food "
	else:
		receive_str += str(food_to_trade) + " food "
	
	if water_to_trade < 0:
		give_str += str(abs(water_to_trade)) + " water "
	else:
		receive_str += str(water_to_trade) + " water "
	
	if give_str.length() > 0:
		$Panel/Label.text = "You will give " + give_str
		
		if receive_str.length() > 0:
			$Panel/Label.text += "and receive " + receive_str
	else:
		$Panel/Label.text = "You will receive " + receive_str
	
	if (metal_val < 0 and abs(metal_val) > Global.playerResources.metal) or (food_to_trade < 0 and abs(food_to_trade) > Global.playerResources.food) or (water_to_trade < 0 and abs(water_to_trade) > Global.playerResources.water):
		$Panel/Trade_Btn.disabled = true
	else:
		$Panel/Trade_Btn.disabled = false

func _on_Trade_Btn_button_pressed():
	Global.change_food_by(food_to_trade)
	Global.change_water_by(water_to_trade)
	Global.change_metal_by(metal_val)
	
	hide()
	
	# Reset this UI's values
	food_to_trade = 0
	water_to_trade = 0
	metal_val = 0
	$Panel/Food_Slider.value = 0
	$Panel/Water_Slider.value = 0

func _on_Close_Button_button_pressed():
	hide()
