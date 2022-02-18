extends Control

const MAX_STAT_VALUE := 10
export var remaining_attr_pts := 18

onready var remaining_pts_lbl = $Lbl_RemPnts
onready var cmdr_spinbox = $Cmdr_HBox/Cmdr_SpinBox
onready var biol_spinbox = $Bio_HBox/Biol_SpinBox
onready var engr_spinbox = $Engr_HBox/Engr_SpinBox
onready var doc_spinbox = $Doc_HBox/Doc_SpinBox

var cur_cmdr: int
var cur_biol: int
var cur_engr: int
var cur_doc: int

func _ready():
	update_remaining_points_lbl()
	
	cur_cmdr = cmdr_spinbox.value
	cur_biol = biol_spinbox.value
	cur_engr = engr_spinbox.value
	cur_doc = doc_spinbox.value

func update_remaining_points_lbl():
	remaining_pts_lbl.text = "Points remaining: " + String(remaining_attr_pts)

func _on_Cmdr_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_cmdr:
		cmdr_spinbox.value = cur_cmdr
		return
	
	remaining_attr_pts -= (value - cur_cmdr)
	Global.playerStats.cmdr = value
	cur_cmdr = value
	
	update_remaining_points_lbl()

func _on_Biol_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_biol:
		biol_spinbox.value = cur_biol
		return
	
	remaining_attr_pts -= (value - cur_biol)
	Global.playerStats.biol = value
	cur_biol = value
	
	update_remaining_points_lbl()

func _on_Engr_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_engr:
		engr_spinbox.value = cur_engr
		return
	
	remaining_attr_pts -= (value - cur_engr)
	Global.playerStats.engr = value
	cur_engr = value
	
	update_remaining_points_lbl()

func _on_Doc_SpinBox_value_changed(value):
	if remaining_attr_pts == 0 and value > cur_doc:
		doc_spinbox.value = cur_doc
		return
	
	remaining_attr_pts -= (value - cur_doc)
	Global.playerStats.doc = value
	cur_doc = value
	
	update_remaining_points_lbl()


func _on_Launch_Button_pressed():
	get_tree().change_scene("res://cutscenes/IntroCinematic.tscn")
