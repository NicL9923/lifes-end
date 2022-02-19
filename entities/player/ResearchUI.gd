extends Control

# TODO: how to show progress? TextureProgress on button?
# TODO: add command to complete research items in DevConsole

const research_tree = {
	improved_weapons_1 = { id = 0, cur_progress = 0, pts_to_complete = 1000 },
	improved_weapons_2 = { id = 1, cur_progress = 0, pts_to_complete = 1250 },
	improved_weapons_3 = { id = 2, cur_progress = 0, pts_to_complete = 1500 },
	improved_weapons_4 = { id = 3, cur_progress = 0, pts_to_complete = 2000 },
	improved_weapons_5 = { id = 4, cur_progress = 0, pts_to_complete = 2500 },
	modular_construction = { id = 5, cur_progress = 0, pts_to_complete = 2000 },
	advanced_healthcare = { id = 6, cur_progress = 0, pts_to_complete = 2000 },
	carbon_scrubbing = { id = 7, cur_progress = 0, pts_to_complete = 5000 },
	metal_by_any_means = { id = 8, cur_progress = 0, pts_to_complete = 1000 },
	production_is_power = { id = 9, cur_progress = 0, pts_to_complete = 2000 },
	natural_gas_is_natural = { id = 10, cur_progress = 0, pts_to_complete = 3000 },
	oil_is_what_we_know = { id = 11, cur_progress = 0, pts_to_complete = 4000 },
	efficient_construction_practices = { id = 12, cur_progress = 0, pts_to_complete = 2500 },
	efficient_engineering = { id = 13, cur_progress = 0, pts_to_complete = 2000 },
	this_is_what_weve_become = { id = 14, cur_progress = 0, pts_to_complete = 3500 },
	careful_extraction = { id = 15, cur_progress = 0, pts_to_complete = 1000 },
	quality_from_passion = { id = 16, cur_progress = 0, pts_to_complete = 2000 },
	harness_our_planets_energy = { id = 17, cur_progress = 0, pts_to_complete = 3000 },
	harness_the_power_of_the_stars = { id = 18, cur_progress = 0, pts_to_complete = 4000 },
	advanced_solar_cells = { id = 19, cur_progress = 0, pts_to_complete = 2000 },
	maximizing_natures_bounty = { id = 20, cur_progress = 0, pts_to_complete = 3000 },
	maximizing_natures_bounty_2 = { id = 21, cur_progress = 0, pts_to_complete = 4000 },
	discover_your_fate = { id = 22, cur_progress = 0, pts_to_complete = 5000 }
}

export var daily_research_points := 250
var cur_research_id := -1 # -1 means no current research


func _ready():
	connect_to_daynight_cycle()
	load_completed_research()

func connect_to_daynight_cycle():
	get_tree().get_current_scene().get_node("DayNightCycle").connect("day_has_passed", self, "handle_new_day")

func handle_new_day():
	if cur_research_id == -1:
		return
	
	# Add daily progress to current research
	research_tree[cur_research_id].cur_progress += daily_research_points * Global.modifiers.researchSpeed
	
	if research_tree[cur_research_id].cur_progress == research_tree[cur_research_id].pts_to_complete:
		Global.playerResearchedItemIds.append(cur_research_id) # Add its id to Global.completedResearchIds
		# Notification that the research item is complete
		# Set flag/effect of that research

func load_completed_research():
	for id in Global.playerResearchedItemIds:
		pass # TODO: set any flags/modifiers/etc for already completed research from save data (where cur_progress == pts_to_complete)

func _on_Close_Button_pressed():
	self.visible = false
