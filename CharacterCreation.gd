extends Control

const MAX_STAT_VALUE := 10
export var remaining_attr_pts := 0

onready var remaining_pts_lbl = $Lbl_RemPnts
onready var cmdr_spinbox = $Cmdr_HBox/Cmdr_SpinBox
onready var biol_spinbox = $Bio_HBox/Biol_SpinBox
onready var engr_spinbox = $Engr_HBox/Engr_SpinBox
onready var doc_spinbox = $Doc_HBox/Doc_SpinBox
onready var launch_btn = $"Launch Button"

var cur_cmdr: int
var cur_biol: int
var cur_engr: int
var cur_doc: int

# TODO: Handle bug with remaining amts going bonkers if you manually edit values...or
# just replace the spin boxes entirely w/ a btn-only system

func _ready():
	$AnimationPlayer.play("fade_in")
	
	launch_btn.disabled = true
	update_remaining_points_lbl()
	
	cur_cmdr = cmdr_spinbox.value
	Global.playerStats.cmdr = cur_cmdr
	cur_biol = biol_spinbox.value
	Global.playerStats.biol = cur_biol
	cur_engr = engr_spinbox.value
	Global.playerStats.engr = cur_engr
	cur_doc = doc_spinbox.value
	Global.playerStats.doc = cur_doc

func check_all_fields_completed():
	if Global.playerName.length() > 0 and Global.playerName.length() <= 20 and remaining_attr_pts == 0:
		launch_btn.disabled = false
	else:
		launch_btn.disabled = true

func update_remaining_points_lbl():
	remaining_pts_lbl.text = "Points remaining: " + String(remaining_attr_pts)
	check_all_fields_completed()

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
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://cutscenes/IntroCinematic.tscn")


func _on_LineEdit_text_changed(new_text):
	if new_text.length() > 0 and new_text.length() <= 20:
		Global.playerName = new_text
	
	check_all_fields_completed()
