extends Control

const research_tree = [
	{ id = 0, cur_progress = 0, pts_to_complete = 1500, effect = { id = Global.RESEARCH_EFFECTS.WPN_DMG, value = 1.5 } }, # improved_weapons_1
	{ id = 1, cur_progress = 0, pts_to_complete = 2500, effect = { id = Global.RESEARCH_EFFECTS.WPN_DMG, value = 2.0 }, prereqs = [0] }, # improved_weapons_2
	{ id = 2, cur_progress = 0, pts_to_complete = 2000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_MAINTENANCE_BLDG } }, # modular_construction
	{ id = 3, cur_progress = 0, pts_to_complete = 2000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_MEDBAY } }, # advanced_healthcare
	{ id = 4, cur_progress = 0, pts_to_complete = 5000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_CARBON_SCRUBBER } }, # carbon_scrubbing
	{ id = 5, cur_progress = 0, pts_to_complete = 1000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_MINING_OPERATION } }, # metal_by_any_means
	{ id = 6, cur_progress = 0, pts_to_complete = 3000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_GAS_POWER }, prereqs = [5] }, # natural_gas_is_natural
	{ id = 7, cur_progress = 0, pts_to_complete = 4000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_OIL_POWER }, prereqs = [6] }, # oil_is_what_we_know
	{ id = 8, cur_progress = 0, pts_to_complete = 2000, effect = { id = Global.RESEARCH_EFFECTS.BUILD_SPEED, value = 2.0 } }, # efficient_engineering
	{ id = 9, cur_progress = 0, pts_to_complete = 4000, effect = { id = Global.RESEARCH_EFFECTS.BUILD_SPEED, value = 3.0 }, prereqs = [8] }, # advanced_manufacturing
	{ id = 10, cur_progress = 0, pts_to_complete = 3500, effect = { id = Global.RESEARCH_EFFECTS.POLLUTION_DMG, value = 0.5 }, prereqs = [9] }, # this_is_what_weve_become
	{ id = 11, cur_progress = 0, pts_to_complete = 1000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_SMELTERY } }, # careful_extraction
	{ id = 12, cur_progress = 0, pts_to_complete = 3000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_GEOTHERMAL_POWER }, prereqs = [11] }, # harness_our_planets_energy
	{ id = 13, cur_progress = 0, pts_to_complete = 4000, effect = { id = Global.RESEARCH_EFFECTS.UNLOCK_NUCLEAR_POWER }, prereqs = [12] }, # harness_the_power_of_the_stars
	{ id = 14, cur_progress = 0, pts_to_complete = 2000, effect = { id = Global.RESEARCH_EFFECTS.SOLAR, value = 1.5 } }, # advanced_solar_cells
	{ id = 15, cur_progress = 0, pts_to_complete = 3000, effect = { id = Global.RESEARCH_EFFECTS.FOOD, value = 1.5 }, prereqs = [14] }, # maximizing_natures_bounty
	{ id = 16, cur_progress = 0, pts_to_complete = 4000, effect = { id = Global.RESEARCH_EFFECTS.METAL_DEPOSIT_VALUE, value = 2.0 }, prereqs = [15] }, # maximizing_natures_bounty_2
	{ id = 17, cur_progress = 0, pts_to_complete = 5000, effect = { id = Global.RESEARCH_EFFECTS.DISCOVER_YOUR_FATE }, ending_prereqs = [[7, 10], [14, 17]] } # discover_your_fate
]

export var daily_research_points := 350
onready var research_btn_cont := $Research_Panel/Research_Btn_Container
var cur_research_id := -1 # -1 means no current research


func _ready():
	connect_to_daynight_cycle()
	load_completed_research()
	connect_research_buttons()

func _process(_delta):
	set_current_research_options()

func set_current_research_options():
	for btn in research_btn_cont.get_children():
		var research_id = int(btn.name.replace("research_", ""))
		
		btn.get_node("TextureProgress").value = (research_tree[research_id].cur_progress / research_tree[research_id].pts_to_complete) * 100
		
		# Handle prereqs for ending (discover your fate)
		if "ending_prereqs" in research_tree[research_id]:
			var one_set_of_prereqs_met := false
			
			for prereq_opt_grp in research_tree[research_id].ending_prereqs:
				var all_prereqs_in_opt_grp_met := true
				for prereq_id in prereq_opt_grp:
					if research_tree[prereq_id].cur_progress != research_tree[prereq_id].pts_to_complete:
						all_prereqs_in_opt_grp_met = false
						break
				
				if all_prereqs_in_opt_grp_met:
					one_set_of_prereqs_met = true
					break
			
			btn.disabled = false if one_set_of_prereqs_met else true
			break
		
		# Handle prereqs for all normal research
		if "prereqs" in research_tree[research_id]:
			var all_prereqs_met := true
			for prereq_id in research_tree[research_id].prereqs:
				if research_tree[prereq_id].cur_progress != research_tree[prereq_id].pts_to_complete:
					all_prereqs_met = false
					break
			
			btn.disabled = false if all_prereqs_met else true
			

func connect_research_buttons():
	for btn in research_btn_cont.get_children():
		var research_id = int(btn.name.replace("research_", ""))
		btn.connect("pressed", self, "set_current_research", [research_id])

func connect_to_daynight_cycle():
	# warning-ignore:return_value_discarded
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")
	print('connected to DN cycle')

func handle_new_day():
	update_current_research()

func set_current_research(id):
	cur_research_id = id

func update_current_research():
	if cur_research_id == -1:
		return
	
	# Add daily progress to current research
	research_tree[cur_research_id].cur_progress = clamp(research_tree[cur_research_id].cur_progress + (daily_research_points * Global.modifiers.researchSpeed), 0, research_tree[cur_research_id].pts_to_complete)
	
	if research_tree[cur_research_id].cur_progress >= research_tree[cur_research_id].pts_to_complete:
		Global.playerResearchedItemIds.append(cur_research_id) # Add its id to Global.completedResearchIds
		
		# Notification that the research item is complete
		Global.push_player_notification("Your current research just finished!")
		
		# Handle ending here so we don't redo it after loading a savegame
		if research_tree[cur_research_id].effect.id == Global.RESEARCH_EFFECTS.DISCOVER_YOUR_FATE:
			handle_ending_trigger()
			return
		
		handle_completed_research(cur_research_id)
		
		set_current_research(-1)

func load_completed_research():
	for id in Global.playerResearchedItemIds:
		research_tree[id].cur_progress = research_tree[id].pts_to_complete
		handle_completed_research(id)

func handle_completed_research(research_id):
	# Set flag/effect of completed research
	if research_tree[research_id].effect.id >= Global.RESEARCH_EFFECTS.UNLOCK_MAINTENANCE_BLDG:
		handle_building_unlock(research_tree[research_id].effect.id)
	else:
		handle_modifier_update(research_tree[research_id].effect.id, research_tree[research_id].effect.value)

func handle_modifier_update(effect_id, effect_val):
	match effect_id:
		# *= so different modifier effects stack (ex: planet traits)
		Global.RESEARCH_EFFECTS.WPN_DMG: Global.modifiers.playerTeamWeaponDamage *= effect_val
		Global.RESEARCH_EFFECTS.SOLAR: Global.modifiers.solarEnergyProduction *= effect_val
		Global.RESEARCH_EFFECTS.RESEARCH_SPEED: Global.modifiers.researchSpeed *= effect_val
		Global.RESEARCH_EFFECTS.BUILD_SPEED: Global.modifiers.buildSpeed *= effect_val
		Global.RESEARCH_EFFECTS.FOOD: Global.modifiers.foodProduction *= effect_val
		Global.RESEARCH_EFFECTS.POLLUTION_DMG: Global.modifiers.pollutionDamage *= effect_val
		Global.RESEARCH_EFFECTS.METAL_DEPOSIT_VALUE: Global.modifiers.metalDepositValue *= effect_val

func handle_building_unlock(effect_id):
	match effect_id:
		Global.RESEARCH_EFFECTS.UNLOCK_MAINTENANCE_BLDG: Global.playerBaseData.unlockedBuildings.append("Maintenance")
		Global.RESEARCH_EFFECTS.UNLOCK_MEDBAY: Global.playerBaseData.unlockedBuildings.append("Medbay")
		Global.RESEARCH_EFFECTS.UNLOCK_CARBON_SCRUBBER: Global.playerBaseData.unlockedBuildings.append("Carbon_Scrubber")
		Global.RESEARCH_EFFECTS.UNLOCK_MINING_OPERATION: Global.playerBaseData.unlockedBuildings.append("Mining_Operation")
		Global.RESEARCH_EFFECTS.UNLOCK_GAS_POWER: Global.playerBaseData.unlockedBuildings.append("Power_Industrial_Gas")
		Global.RESEARCH_EFFECTS.UNLOCK_OIL_POWER: Global.playerBaseData.unlockedBuildings.append("Power_Industrial_Oil")
		Global.RESEARCH_EFFECTS.UNLOCK_SMELTERY: Global.playerBaseData.unlockedBuildings.append("Smeltery")
		Global.RESEARCH_EFFECTS.UNLOCK_GEOTHERMAL_POWER: Global.playerBaseData.unlockedBuildings.append("Power_Sustainable_Geothermal")
		Global.RESEARCH_EFFECTS.UNLOCK_NUCLEAR_POWER: Global.playerBaseData.unlockedBuildings.append("Power_Sustainable_Nuclear")
	
	Global.player.get_node("UI/BuildingUI").generate_building_buttons() # Regenerate building buttons so the newly unlocked bldg appears

func handle_ending_trigger():
	# TODO: fade out to white then fade in to ending cinematic
	
	Global.player.get_parent().remove_child(Global.player) # Necessary to make sure the player node doesn't get automatically freed (aka destroyed)
	
	# warning-ignore:return_value_discarded
	Global.get_tree().change_scene("res://cutscenes/EndingCinematic.tscn")

func _on_Close_Button_button_pressed():
	self.visible = false
