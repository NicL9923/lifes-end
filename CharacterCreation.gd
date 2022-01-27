extends Control

const MAX_STAT_VALUE := 10
export var remaining_attr_pts := 18
var cur_cmdr: int
var cur_biol: int
var cur_engr: int
var cur_doc: int

func _ready():
	update_remaining_points_lbl()
	
	cur_cmdr = $VBoxContainer/HBoxContainer/Cmdr_SpinBox.value
	cur_biol = $VBoxContainer/HBoxContainer2/Biol_SpinBox.value
	cur_engr = $VBoxContainer/HBoxContainer3/Engr_SpinBox.value
	cur_doc = $VBoxContainer/HBoxContainer4/Doc_SpinBox.value

func update_remaining_points_lbl():
	$HBoxContainer/Lbl_RemPnts.text = "Points remaining: " + String(remaining_attr_pts)

func _on_Cmdr_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_cmdr:
		$VBoxContainer/HBoxContainer/Cmdr_SpinBox.value = cur_cmdr
		return
	
	remaining_attr_pts -= (value - cur_cmdr)
	Global.playerCmdrStat = value
	cur_cmdr = value
	
	update_remaining_points_lbl()

func _on_Biol_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_biol:
		$VBoxContainer/HBoxContainer2/Biol_SpinBox.value = cur_biol
		return
	
	remaining_attr_pts -= (value - cur_biol)
	Global.playerBiolStat = value
	cur_biol = value
	
	update_remaining_points_lbl()

func _on_Engr_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_engr:
		$VBoxContainer/HBoxContainer3/Engr_SpinBox.value = cur_engr
		return
	
	remaining_attr_pts -= (value - cur_engr)
	Global.playerEngrStat = value
	cur_engr = value
	
	update_remaining_points_lbl()

func _on_Doc_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_doc:
		$VBoxContainer/HBoxContainer4/Doc_SpinBox.value = cur_doc
		return
	
	remaining_attr_pts -= (value - cur_doc)
	Global.playerDocStat = value
	cur_doc = value
	
	update_remaining_points_lbl()


func _on_Launch_Button_pressed():
	get_tree().change_scene("res://cutscenes/IntroCinematic.tscn")
