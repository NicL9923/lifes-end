extends Control

const MAX_STAT_VALUE := 10
export var remaining_attr_pts := 0

onready var remaining_pts_lbl := $Lbl_RemPnts
onready var cmdr_pts := $Cmdr_HBox/Pts_Label
onready var bio_pts := $Bio_HBox/Pts_Label
onready var engr_pts := $Engr_HBox/Pts_Label
onready var doc_pts := $Doc_HBox/Pts_Label
onready var launch_btn := $Launch_Btn

var cur_cmdr: int
var cur_bio: int
var cur_engr: int
var cur_doc: int


func _ready():
	$FadeTransition.visible = true
	$AnimationPlayer.play("fade_in")
	
	$Cmdr_HBox/ArrowCont/Up_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [true, "cmdr"])
	$Cmdr_HBox/ArrowCont/Down_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [false, "cmdr"])
	$Bio_HBox/ArrowCont/Up_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [true, "bio"])
	$Bio_HBox/ArrowCont/Down_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [false, "bio"])
	$Engr_HBox/ArrowCont/Up_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [true, "engr"])
	$Engr_HBox/ArrowCont/Down_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [false, "engr"])
	$Doc_HBox/ArrowCont/Up_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [true, "doc"])
	$Doc_HBox/ArrowCont/Down_Arrow.connect("button_pressed", self, "_on_Arrow_button_pressed", [false, "doc"])
	
	launch_btn.disabled = true
	
	cur_cmdr = int(cmdr_pts.text)
	Global.playerStats.cmdr = cur_cmdr
	cur_bio = int(bio_pts.text)
	Global.playerStats.biol = cur_bio
	cur_engr = int(engr_pts.text)
	Global.playerStats.engr = cur_engr
	cur_doc = int(doc_pts.text)
	Global.playerStats.doc = cur_doc
	
	update_points_labels()

func check_all_fields_completed():
	if Global.playerName.length() > 0 and Global.playerName.length() <= 20 and remaining_attr_pts == 0:
		launch_btn.disabled = false
	else:
		launch_btn.disabled = true

func update_points_labels():
	remaining_pts_lbl.text = "Points remaining: " + str(remaining_attr_pts)
	cmdr_pts.text = str(cur_cmdr)
	bio_pts.text = str(cur_bio)
	engr_pts.text = str(cur_engr)
	doc_pts.text = str(cur_doc)
	check_all_fields_completed()

func _on_Cmdr_value_changed(new_value):
	if new_value < 0 or new_value > 10:
		return
	if remaining_attr_pts == 0 and new_value > cur_cmdr:
		cmdr_pts.text = str(cur_cmdr)
		return
	
	remaining_attr_pts -= (new_value - cur_cmdr)
	Global.playerStats.cmdr = new_value
	cur_cmdr = new_value

func _on_Bio_value_changed(new_value):
	if new_value < 0 or new_value > 10:
		return
	if remaining_attr_pts == 0 and new_value > cur_bio:
		bio_pts.text = str(cur_bio)
		return
	
	remaining_attr_pts -= (new_value - cur_bio)
	Global.playerStats.biol = new_value
	cur_bio = new_value

func _on_Engr_value_changed(new_value):
	if new_value < 0 or new_value > 10:
		return
	if remaining_attr_pts == 0 and new_value > cur_engr:
		engr_pts.text = str(cur_engr)
		return
	
	remaining_attr_pts -= (new_value - cur_engr)
	Global.playerStats.engr = new_value
	cur_engr = new_value

func _on_Doc_value_changed(new_value):
	if new_value < 0 or new_value > 10:
		return
	if remaining_attr_pts == 0 and new_value > cur_doc:
		doc_pts.text = str(cur_doc)
		return
	
	remaining_attr_pts -= (new_value - cur_doc)
	Global.playerStats.doc = new_value
	cur_doc = new_value

func _on_LineEdit_text_changed(new_text):
	if new_text.length() > 0 and new_text.length() <= 20:
		Global.playerName = new_text
	
	check_all_fields_completed()

func _on_Launch_Btn_button_pressed():
	$AnimationPlayer.play("fade_out")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://cutscenes/IntroCinematic.tscn")

func _on_Arrow_button_pressed(isUp: bool, type: String):
	match type:
		"cmdr": _on_Cmdr_value_changed(cur_cmdr + (1 if isUp else -1))
		"bio": _on_Bio_value_changed(cur_bio + (1 if isUp else -1))
		"engr": _on_Engr_value_changed(cur_engr + (1 if isUp else -1))
		"doc": _on_Doc_value_changed(cur_doc + (1 if isUp else -1))
	
	update_points_labels()
