extends Area2D

var cost_to_build: int
var isBeingPlaced: bool # Need this var and check so menu doesn't show when building's being placed
var isBeingBuilt := false
var isPlayerBldg := false
var has_to_be_unlocked := false
var sec_to_build := float(60 / Global.modifiers.buildSpeed)
var cur_seconds_to_build := sec_to_build
var energy_cost_to_run := 0
var has_energy := true
var energy_blink_timer := 0.5
var popup = null
var bldg_limit = null
var popup_activation_distance = null
var max_health
var health

var bldg_size: Vector2
var bldg_key: String
var bldg_name: String
var bldg_desc: String

var repair_mode := false
var move_mode := false
var is_being_moved := false
var idx_in_global_bldgs: int # Just used when moving this bldg to update its global_pos
var scrap_mode := false

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
onready var upgrade_icon := $UpgradeIcon
onready var repair_icon := $RepairIcon
onready var move_icon := $MoveIcon
onready var scrap_icon := $ScrapIcon
onready var static_body := $StaticBody2D
onready var bldg_progr := $BuildingProgress
onready var healthbar := $Healthbar
onready var bldg_sprite := $BuildingSprite
onready var popup_panel := $PopupUI

# TODO: Need to handle bldg levels (and those w/o any)
	# Probably handle most of this in BaseManager?
	# HQ upgrades allows upgrading other bldgs to higher levels

# TODO: Make sure crafting and research progress stop when respective bldgs are out of power (notify CraftingUI and ResearchUI somehow)


func init(b_key, bldg_template_obj):
	self.bldg_key = b_key
	bldg_name = bldg_template_obj.bldg_name
	bldg_desc = bldg_template_obj.bldg_desc
	cost_to_build = bldg_template_obj.cost_to_build
	
	if "max_health" in bldg_template_obj:
		max_health = bldg_template_obj.max_health
	else:
		max_health = 100
	health = max_health
	
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
	if self.bldg_key == "HQ":
		bldg_sprite = load("res://objects/buildings/HQ_Anim_Sprite.tscn").instance()
		add_child_below_node($BuildingSprite, bldg_sprite)
		self.bldg_size = bldg_sprite.frames.get_frame("default", 0).get_size()
	else:
		bldg_sprite.texture = load("res://objects/buildings/" + bldg_key.to_lower() + ".png")
		self.bldg_size = bldg_sprite.texture.get_size()
	
	col_hlt.rect_size = self.bldg_size
	col_hlt.rect_position = Vector2(-1 * col_hlt.rect_size.x / 2, -1 * col_hlt.rect_size.y / 2)
	
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = (self.bldg_size / 2) - (Vector2.ONE * 16)
	
	static_body.get_node("CollisionShape2D").shape = RectangleShape2D.new()
	static_body.get_node("CollisionShape2D").shape.extents = self.bldg_size / 2
	
	popup_panel.visible = false
	if popup != null:
		generate_and_connect_popup()
	
	static_body.add_to_group("building")
	bldg_progr.visible = false

func _process(delta):
	if popup != null:
		popup_panel.visible = is_player_in_popup_distance() and !Global.player.isInCombat and !isBeingPlaced and !isBeingBuilt and !is_being_moved and has_energy
	
	if isBeingBuilt:
		handle_building_building(delta)
	else:
		handle_energy_display(delta)
	
	handle_healthbar()
	
	if Input.is_action_just_pressed("ui_cancel"):
		scrap_mode = false
		scrap_icon.visible = false
		repair_mode = false
		repair_icon.visible = false
		move_mode = false
		move_icon.visible = false
	
	if is_being_moved:
		handle_being_moved()

func generate_and_connect_popup():
	popup_panel.rect_size.x = 125
	popup_panel.rect_size.y = self.popup.size() * 35
	popup_panel.rect_pivot_offset = popup_panel.rect_size / 2
	popup_panel.rect_position = Vector2(-1 * popup_panel.rect_size.x / 2, -1 * popup_panel.rect_size.y / 2)
	
	var btn_height := 3
	for btn in self.popup:
		var new_btn = preload("res://ui/buttons/LE_Button.tscn").instance()
		new_btn.button_text = btn.btn_text
		new_btn.rect_position = Vector2((125 / 2) - (new_btn.get_node("TextureButton").rect_size.x / 2), btn_height)
		new_btn.connect("button_pressed", self, btn.connect_fn)
		
		popup_panel.add_child(new_btn)
		btn_height += 30

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
	return (Global.player.position.distance_to(self.position) < popup_activation_distance)

func handle_healthbar():
	healthbar.max_value = max_health
	healthbar.value = health
	
	if health == max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true

func handle_being_moved():
	var snapped_mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position()).snapped(Vector2.ONE * Global.cellSize)
	self.global_position = snapped_mouse_pos
	
	# Handle odd-tile-sized buildings (to be placed on same "grid" as even-tile-sized ones which naturally work properly)
	var bldg_tile_size = self.bldg_size / Global.cellSize
	if int(bldg_tile_size.x) % 2 == 1:
		self.global_position.x += 16
	if int(bldg_tile_size.y) % 2 == 1:
		self.global_position.y += 16
	
	if self.get_overlapping_bodies().size() == 0:
		col_hlt.color = Color(0.0, 1.0, 0.0, 0.5)
		
		if Input.is_action_just_pressed("shoot"):
			Global.playerBaseData.buildings[idx_in_global_bldgs].global_pos = self.global_position
			idx_in_global_bldgs = -1
			Global.set_building_tiles(get_tree().get_current_scene().tilemap, self, true)
			self.modulate.a = 1.0
			col_hlt.visible = false
			$StaticBody2D/CollisionShape2D.disabled = false
			is_being_moved = false
	else:
		col_hlt.color = Color(1.0, 0.0, 0.0, 0.5)

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

func take_damage(amt):
	health = clamp(health - amt, 0, max_health)
	
	if health == 0:
		destruct(false)

func destruct(isScrapping: bool):
	# This is probably pretty terrible, but instead of an ID we're IDing bldgs based on their
	# global_pos as it should technically be unique at all times
	if isPlayerBldg:
		for bldg in Global.playerBaseData.buildings:
			if bldg.global_pos == self.global_position:
				Global.playerBaseData.buildings.erase(bldg)
				get_tree().get_current_scene().base_mgr.buildings.erase(bldg)
				Global.set_building_tiles(get_tree().get_current_scene().tilemap, self, false)
				break
	
	if isScrapping:
		# Return a portion of the cost to construct the specific bldg to player's resources
		Global.playerResources.metal += (cost_to_build / 4)
	
	queue_free()

##################### BUILDING BUTTON FUNCS ################################

func _on_RecruitColonist_Button_pressed():
	randomize()
	
	if Global.playerResources.metal < self.cost_to_recruit_colonist:
		Global.push_player_notification("You need " + self.cost_to_recruit_colonist + " metal to recruit a colonist!")
		return
	
	Global.playerResources.metal -= self.cost_to_recruit_colonist
	
	var first_name_idx := int(rand_range(0, Global.entity_names.first.size() - 1))
	var last_name_idx := int(rand_range(0, Global.entity_names.last.size() - 1))
	
	var new_colonist = load("res://entities/allies/AlliedColonist.tscn").instance()
	new_colonist.ent_name = Global.entity_names.first[first_name_idx] + " " + Global.entity_names.last[last_name_idx]
	new_colonist.id = Global.playerBaseData.colonists.size() # This keeps IDs simple and incremental
	new_colonist.global_position = Global.get_position_in_radius_around(self.global_position, 5)
	
	Global.playerBaseData.colonists.append({
		id = new_colonist.id,
		ent_name = new_colonist.ent_name,
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

func _on_BldgMove_Button_pressed():
	for bldg in get_tree().get_current_scene().base_mgr.buildings:
		bldg.move_mode = true
		bldg.move_icon.visible = true
		bldg.scrap_mode = false
		bldg.repair_mode = false

func _on_BldgRepair_Button_pressed():
	for bldg in get_tree().get_current_scene().base_mgr.buildings:
		bldg.repair_mode = true
		bldg.repair_icon.visible = true
		bldg.scrap_mode = false
		bldg.move_mode = false

func _on_BldgScrap_Button_pressed():
	for bldg in get_tree().get_current_scene().base_mgr.buildings:
		if bldg.bldg_key == "HQ":
			bldg.scrap_mode = false
		else:
			bldg.scrap_mode = true
			bldg.scrap_icon.visible = true
		
		bldg.repair_mode = false
		bldg.move_mode = false

func _on_Research_Button_pressed():
	Global.player.research_ui.show()

func _on_ViewShip_Button_pressed():
	Global.player.ship_ui.show()

func _on_Building_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if scrap_mode:
			destruct(true)
		elif repair_mode:
			var cost_to_repair = (max_health - health) / 20
			
			if Global.playerResources.metal >= cost_to_repair:
				Global.playerResources.metal -= cost_to_repair
				health = max_health
			else:
				Global.push_player_notification("You need " + str(cost_to_repair) + " metal to repair this building!")
		elif move_mode:
			Global.set_building_tiles(get_tree().get_current_scene().tilemap, self, false)
			
			for i in range(0, Global.playerBaseData.buildings.size() - 1):
				if Global.playerBaseData.buildings[i].global_pos == self.global_position:
					idx_in_global_bldgs = i
					break
			
			$StaticBody2D/CollisionShape2D.disabled = true
			col_hlt.visible = true
			self.modulate.a = 0.75
			is_being_moved = true
