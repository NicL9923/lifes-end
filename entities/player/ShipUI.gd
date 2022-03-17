extends Control

onready var ship_upgrade_progress_bar := $Ship_Panel/TextureProgress
onready var upgrade_btn := $Ship_Panel/Upgrade_Button
onready var cost_lbl := $Ship_Panel/Cost_Label

const next_upgrade_text := ["Travel on-planet", "Travel 40 million miles", "Travel 80 million miles", "Travel anywhere in the system"]


func _process(_delta):
	ship_upgrade_progress_bar.value = (Global.playerShipData.level) * 25
	$Ship_Panel/Current_Lbl.text = next_upgrade_text[Global.playerShipData.level - 1]
	
	if Global.playerShipData.level == 4:
		upgrade_btn.disabled = true
		cost_lbl.visible = false
		$Ship_Panel/NextUpgrade_Lbl.text = ""
	else:
		$Ship_Panel/NextUpgrade_Lbl.text = "Next Upgrade: " + next_upgrade_text[Global.playerShipData.level]
		cost_lbl.text = "Cost: " + str(Global.ship_upgrade_costs[Global.playerShipData.level - 1]) + " metal"
		
		if Global.playerResources.metal < Global.ship_upgrade_costs[Global.playerShipData.level - 1]:
			upgrade_btn.disabled = true
		else:
			upgrade_btn.disabled = false

func _on_Close_Button_button_pressed():
	self.visible = false

func _on_Upgrade_Button_button_pressed():
	Global.playerResources.metal -= Global.ship_upgrade_costs[Global.playerShipData.level - 1]
	Global.playerShipData.level += 1
