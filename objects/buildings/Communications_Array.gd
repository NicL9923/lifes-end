extends Area2D

func _ready():
	pass

func _process(delta):
	#Check if player within collection distance
	if Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat:
		$PopupUI.visible = true
	else:
		$PopupUI.visible = false


# TODO: hook this up when world map gets implemented
func _on_WorldMap_Button_pressed():
	pass
