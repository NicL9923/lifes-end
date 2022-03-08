tool
extends Button

export var research_name := "Default name" setget set_research_name
export var research_description := "Default description" setget set_research_description
var research_progress: int


func _ready():
	pass

func set_research_name(new_research_name):
	research_name = new_research_name
	$Name_Label.text = new_research_name

func set_research_description(new_research_description):
	research_description = new_research_description
	$Desc_Label.text = new_research_description
