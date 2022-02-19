extends Control

onready var ship_panel := $Ship_Panel
onready var ship_upgrade_progress_bar := $Ship_Panel/TextureProgress
onready var upgrade_btn := $Ship_Panel/Upgrade_Button
onready var cost_lbl := $Ship_Panel/Cost_Label


func _ready():
	pass

func _process(_delta):
	ship_upgrade_progress_bar.value = (Global.playerShipData.level - 1) * 25
	
	if Global.playerShipData.level == 5:
		upgrade_btn.disabled = true
		cost_lbl.visible = false
	else:
		cost_lbl.text = "Cost: " + str(Global.ship_upgrade_costs[Global.playerShipData.level - 1]) + " metal"
		
		if Global.playerResources.metal < Global.ship_upgrade_costs[Global.playerShipData.level - 1]:
			upgrade_btn.disabled = true
		else:
			upgrade_btn.disabled = false


func _on_Upgrade_Button_pressed():
	Global.playerResources.metal -= Global.ship_upgrade_costs[Global.playerShipData.level - 1]
	Global.playerShipData.level += 1


func _on_Close_Button_pressed():
	ship_panel.visible = false
