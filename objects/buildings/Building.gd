extends Area2D

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed
var isBeingBuilt := false
var isPlayerBldg := false
var bldgLvl: int
var has_to_be_unlocked := false
var sec_to_build := float(60 / Global.modifiers.buildSpeed)
var cur_seconds_to_build := sec_to_build
var energy_cost_to_run := 0
var has_energy := true
var energy_blink_timer := 0.5
var popup = null
var bldg_limit = null
var popup_activation_distance = null

var bldg_key: String
var bldg_name: String
var bldg_desc: String

var cost_to_recruit_colonist = null
var daily_colonist_healing_amt = null
var metal_produced_per_day = null
var food_produced_per_day = null
var water_produced_per_day = null
var energy_produced = null
var pollution_produced_per_day = null
var pollution_removed_per_day = null

onready var col_hlt := $CollisionHighlight
onready var energy_icon := $EnergyIcon
onready var static_body := $StaticBody2D
onready var bldg_progr := $BuildingProgress
onready var bldg_sprite := $BuildingSprite
onready var popup_panel := $PopupUI

# TODO: Need to handle bldg levels (and those w/o any)
	# Probably handle most of this in BaseManager?
	# HQ upgrades allows upgrading other bldgs to higher levels

# TODO: Make sure crafting and research progress stop when respective bldgs are out of power (notify CraftingUI and ResearchUI somehow)

# TODO: Maintenance ideas:
	# Clicking a button toggles that mode that shows applicable icons on each building it applies to (i.e. metal + cost-number/4-directions-arrows/hammer)
	# Player clicks building to do the above operation and has to confirm (popup dialog)
	# Probably need to start giving buildings unique IDs (or something to track it in both playerBaseData and game tree)


func init(b_key, bldg_template_obj, building_lvl):
	self.bldg_key = b_key
	bldg_name = bldg_template_obj.bldg_name
	bldg_desc = bldg_template_obj.bldg_desc
	cost_to_build = bldg_template_obj.cost_to_build
	bldgLvl = building_lvl
	
	if "energy_cost_to_run" in bldg_template_obj:
		energy_cost_to_run = bldg_template_obj.energy_cost_to_run
	
	if "has_to_be_unlocked" in bldg_template_obj:
		has_to_be_unlocked = bldg_template_obj.has_to_be_unlocked
	
	if "bldg_limit" in bldg_template_obj:
		bldg_limit = bldg_template_obj.bldg_limit
	
	if "popup" in bldg_template_obj:
		popup = bldg_template_obj.popup
		
		if "popup_activation_distance" in bldg_template_obj:
			popup_activation_distance = bldg_template_obj.popup_activation_distance # TODO: add this to buildings that need something other than the default
		else:
			popup_activation_distance = 75
	
	if "cost_to_recruit_colonist" in bldg_template_obj:
		cost_to_recruit_colonist = bldg_template_obj.cost_to_recruit_colonist
	if "daily_colonist_healing_amt" in bldg_template_obj:
		daily_colonist_healing_amt = bldg_template_obj.daily_colonist_healing_amt
	if "metal_produced_per_day" in bldg_template_obj:
		metal_produced_per_day = bldg_template_obj.metal_produced_per_day
	if "food_produced_per_day" in bldg_template_obj:
		food_produced_per_day = bldg_template_obj.food_produced_per_day
	if "water_produced_per_day" in bldg_template_obj:
		water_produced_per_day = bldg_template_obj.water_produced_per_day
	if "pollution_produced_per_day" in bldg_template_obj:
		pollution_produced_per_day = bldg_template_obj.pollution_produced_per_day
	if "energy_produced" in bldg_template_obj:
		energy_produced = bldg_template_obj.energy_produced
	if "pollution_removed_per_day" in bldg_template_obj:
		pollution_removed_per_day = bldg_template_obj.pollution_removed_per_day
	
	handle_special_bldg_cases(bldg_template_obj)

func _ready():
	bldg_sprite.texture = load("res://objects/buildings/" + bldg_key.to_lower() + ".png")
	var sprite_size = bldg_sprite.texture.get_size()
	
	col_hlt.rect_size = sprite_size
	col_hlt.rect_position = Vector2(-1 * col_hlt.rect_size.x / 2, -1 * col_hlt.rect_size.y / 2)
	
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = sprite_size / 2
	
	static_body.get_node("CollisionShape2D").shape = RectangleShape2D.new()
	static_body.get_node("CollisionShape2D").shape.extents = sprite_size / 2
	
	if popup != null:
		generate_and_connect_popup()
	
	static_body.add_to_group("building")
	bldg_progr.visible = false

func _process(delta):
	if popup != null:
		popup_panel.visible = is_player_in_popup_distance()
		
		for btn in popup_panel.get_children():
			btn.disabled = not self.has_energy
	
	if isBeingBuilt:
		handle_building_building(delta)
	handle_energy_display(delta)

func generate_and_connect_popup():
	popup_panel.rect_size.x = 125
	popup_panel.rect_size.y = self.popup.size() * 35
	popup_panel.rect_pivot_offset = popup_panel.rect_size / 2
	popup_panel.rect_position = Vector2(-1 * popup_panel.rect_size.x / 2, -1 * popup_panel.rect_size.y / 2)
	
	var btn_pos := Vector2(40, 10)
	for btn in self.popup:
		var new_btn = Button.new()
		new_btn.text = btn.btn_text
		new_btn.rect_position = btn_pos
		new_btn.connect("pressed", self, btn.connect_fn)
		
		popup_panel.add_child(new_btn)
		btn_pos.y += 30

func handle_special_bldg_cases(bto):
	match bto.bldg_name:
		Global.buildings.Barracks.bldg_name:
			cost_to_recruit_colonist *= Global.player_stat_modifier_formula(Global.playerStats.cmdr)
		Global.buildings.Medbay.bldg_name:
			bldg_desc = "Heals colonists by " + str(self.daily_colonist_healing_amt) + " per day"
		Global.buildings.Greenhouse.bldg_name:
			bldg_desc = "Produces " + str(self.food_produced_per_day) + " Food per day"
		Global.buildings.Water_Recycling_System.bldg_name:
			bldg_desc = "Produces " + str(self.water_produced_per_day) + " Water per day"
		Global.buildings.Power_Industrial_Coal.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy, and " + str(self.pollution_produced_per_day) + " Pollution per day"
		Global.buildings.Power_Industrial_Gas.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy, and " + str(self.pollution_produced_per_day) + " Pollution per day"
		Global.buildings.Power_Industrial_Oil.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy, and " + str(self.pollution_produced_per_day) + " Pollution per day"
		Global.buildings.Power_Sustainable_Solar.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy"
		Global.buildings.Power_Sustainable_Geothermal.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy"
		Global.buildings.Power_Sustainable_Nuclear.bldg_name:
			bldg_desc = "Produces " + str(self.energy_produced) + " Energy"
		Global.buildings.Smeltery.bldg_name:
			bldg_desc = "Produces " + str(self.metal_produced_per_day) + " Metal per day"
		Global.buildings.Mining_Operation.bldg_name:
			bldg_desc = "Produces " + str(self.metal_produced_per_day) + " Metal and " + str(self.pollution_produced_per_day) + " Pollution per day"
		Global.buildings.Carbon_Scrubber.bldg_name:
			bldg_desc = "Removes " + str(self.pollution_removed_per_day) + " pollution per day"

func is_player_in_popup_distance():
	return (Global.player.position.distance_to(self.position) < popup_activation_distance and !Global.player.isInCombat and !isBeingPlaced)

func handle_building_building(delta):
	if cur_seconds_to_build <= 0.0:
		bldg_progr.visible = false
		bldg_sprite.self_modulate = Color(1, 1, 1)
		bldg_progr.value = 100
		isBeingBuilt = false
	else:
		bldg_sprite.self_modulate = Color(0.25, 0.25, 0.25) # Darken the building
		bldg_progr.visible = true
		cur_seconds_to_build -= delta
		bldg_progr.value = ((sec_to_build - cur_seconds_to_build) / sec_to_build) * 100

func handle_energy_display(delta):
	if self.has_energy:
		energy_icon.visible = false
		bldg_sprite.self_modulate = Color(1, 1, 1)
	else:
		bldg_sprite.self_modulate = Color(0.25, 0.25, 0.25) # Darken the building
		if energy_blink_timer > 0:
			energy_blink_timer -= delta
		else:
			energy_icon.visible = !energy_icon.visible
			energy_blink_timer = 0.5


##################### BUILDING BUTTON FUNCS ################################

func _on_RecruitColonist_Button_pressed():
	if Global.playerResources.metal < self.cost_to_recruit_colonist:
		Global.push_player_notification("You need " + self.cost_to_recruit_colonist + " metal to recruit a colonist!")
		return
	
	Global.playerResources.metal -= self.cost_to_recruit_colonist
	
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

func _on_SystemMap_Button_pressed():
	Global.player.get_parent().remove_child(Global.player) # Necessary to make sure the player node doesn't get automatically freed (aka destroyed)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://SystemMap.tscn")

func _on_Craft_Button_pressed():
	Global.player.crafting_ui.visible.show()

func _on_Build_Button_pressed():
	Global.player.building_panel.show()

func _on_SaveGame_Button_pressed():
	Global.save_game()

func _on_BldgUpgrade_Button_pressed():
	pass

func _on_BldgMove_Button_pressed():
	pass

func _on_BldgRepair_Button_pressed():
	pass

func _on_BldgScrap_Button_pressed():
	pass

func _on_Research_Button_pressed():
	Global.player.research_ui.show()

func _on_ViewShip_Button_pressed():
	Global.player.ship_ui.show()
