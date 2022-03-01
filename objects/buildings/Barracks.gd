extends Building

onready var recruit_colonist_btn := $PopupUI/RecruitColonist_Button
export var cost_to_recruit_colonist := 30

func _init():
	cost_to_build = 25
	bldg_name = "Barracks"
	bldg_desc = "Recruit colonists, and view your stats"
	energy_cost_to_run = 5

func _ready():
	cost_to_recruit_colonist *= Global.player_stat_modifier_formula(Global.playerStats.cmdr)

func _process(delta):
	handle_energy_display(delta)
	$PopupUI.visible = is_player_in_popup_distance()
	
	if Global.playerResources.metal < cost_to_recruit_colonist or not self.has_energy:
		recruit_colonist_btn.disabled = true
	else:
		recruit_colonist_btn.disabled = false

func _on_RecruitColonist_Button_pressed():
	Global.playerResources.metal -= cost_to_recruit_colonist
	
	var new_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
	new_colonist.id = Global.playerBaseData.colonists.size() # This keeps IDs simple and incremental
	new_colonist.global_position = Global.get_position_in_radius_around(self.global_position, 5)
	
	Global.playerBaseData.colonists.append({
		id = new_colonist.id,
		health = new_colonist.health
	})
	
	get_tree().get_current_scene().base_mgr.add_colonist(new_colonist)
	get_tree().get_current_scene().add_child(new_colonist)

func _on_ViewStats_Button_pressed():
	Global.player.player_stats_ui.show()
