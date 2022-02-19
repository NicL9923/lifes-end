extends Control

onready var max_health_lbl := $PlayerStats_Panel/MaxHealth_Label

onready var cmdr_stat_lbl := $PlayerStats_Panel/Cmdr_Label
onready var engr_stat_lbl := $PlayerStats_Panel/Engr_Label
onready var biol_stat_lbl := $PlayerStats_Panel/Biol_Label
onready var doc_stat_lbl := $PlayerStats_Panel/Doc_Label

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
	
	cur_colonists_lbl.text = "Current Colonists: " + str(Global.playerBaseData.colonists.size())
	colonies_destr_lbl.text = "Colonies Destroyed: " + str(get_destroyed_colonies_count())
	
	alignment_lbl.text = "Alignment: " + ("Good" if Global.subEndingIsGood else "Evil")

func get_destroyed_colonies_count():
	var destr_colonies := 0
	
	for colony in Global.npcColonyData:
		if colony.isDestroyed:
			destr_colonies += 1
	
	return destr_colonies

func _on_Close_Button_pressed():
	self.visible = false
