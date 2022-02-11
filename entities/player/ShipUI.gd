extends Control


func _ready():
	pass

func _process(_delta):
	$Ship_Panel/TextureProgress.value = (Global.playerShipData.level - 1) * 25
	
	if Global.playerShipData.level == 5:
		$Ship_Panel/Upgrade_Button.disabled = true
		$Ship_Panel/Cost_Label.visible = false
	else:
		$Ship_Panel/Cost_Label.text = "Cost: " + str(Global.ship_upgrade_costs[Global.playerShipData.level - 1]) + " metal"
		
		if Global.playerBaseMetal < Global.ship_upgrade_costs[Global.playerShipData.level - 1]:
			$Ship_Panel/Upgrade_Button.disabled = true
		else:
			$Ship_Panel/Upgrade_Button.disabled = false


func _on_Upgrade_Button_pressed():
	Global.playerBaseMetal -= Global.ship_upgrade_costs[Global.playerShipData.level - 1]
	Global.playerShipData.level += 1


func _on_Close_Button_pressed():
	$Ship_Panel.visible = false
