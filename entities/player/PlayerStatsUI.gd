extends Control

onready var max_health_lbl := $PlayerStats_Panel/MaxHealth_Label

onready var cmdr_stat_lbl := $PlayerStats_Panel/Cmdr_Label
onready var engr_stat_lbl := $PlayerStats_Panel/Engr_Label
onready var biol_stat_lbl := $PlayerStats_Panel/Biol_Label
onready var doc_stat_lbl := $PlayerStats_Panel/Doc_Label

onready var damage_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/Dmg_Lbl
onready var solar_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/Solar_Lbl
onready var research_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/Research_Lbl
onready var build_speed_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/BuildSpeed_Lbl
onready var food_prod_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/FoodProd_Lbl
onready var water_prod_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/WaterProd_Lbl
onready var pol_dmg_lbl := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/PollutionDmg_Lbl
onready var metal_dep_val := $PlayerStats_Panel/Modifiers/ScrollContainer/VBoxContainer/MetalDepValue_Lbl

onready var cur_colonists_lbl := $PlayerStats_Panel/CurColonists_Label
onready var colonies_destr_lbl := $PlayerStats_Panel/ColoniesDestroyed_Label

onready var alignment_lbl := $PlayerStats_Panel/Alignment_Label


func _ready():
	pass

func _process(_delta):
	max_health_lbl.text = "Max Health: " + str(Global.playerStats.max_health)
	
	cmdr_stat_lbl.text = "Commander: " + str(Global.playerStats.cmdr)
	engr_stat_lbl.text = "Engineer: " + str(Global.playerStats.engr)
	biol_stat_lbl.text = "Biologist: " + str(Global.playerStats.biol)
	doc_stat_lbl.text = "Doctor: " + str(Global.playerStats.doc)
	
	damage_lbl.text = "Damage: " + str(Global.modifiers.playerTeamWeaponDamage) + "x"
	solar_lbl.text = "Solar Energy: " + str(Global.modifiers.solarEnergyProduction) + "x"
	research_lbl.text = "Research Speed: " + str(Global.modifiers.researchSpeed) + "x"
	build_speed_lbl.text = "Build Speed: " + str(Global.modifiers.buildSpeed) + "x"
	food_prod_lbl.text = "Food Production: " + str(Global.modifiers.foodProduction) + "x"
	water_prod_lbl.text = "Water Production: " + str(Global.modifiers.waterProduction) + "x"
	pol_dmg_lbl.text = "Pollution Damage: " + str(Global.modifiers.pollutionDamage) + "x"
	metal_dep_val.text = "Metal Deposit Value: " + str(Global.modifiers.metalDepositValue) + "x"
	
	cur_colonists_lbl.text = "Current Colonists: " + str(Global.playerBaseData.colonists.size())
	colonies_destr_lbl.text = "Colonies Destroyed: " + str(get_destroyed_colonies_count())
	
	alignment_lbl.text = "Alignment: " + ("Good" if Global.subEndingIsGood else "Evil") + " (" + str(int(Global.playerStats.humanity)) + ")"

func get_destroyed_colonies_count():
	var destr_colonies := 0
	
	for colony in Global.npcColonyData:
		if colony.isDestroyed:
			destr_colonies += 1
	
	return destr_colonies

func _on_Close_Button_button_pressed():
	self.visible = false
