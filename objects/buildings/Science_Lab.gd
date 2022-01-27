extends Area2D

var isBeingPlaced: bool

func _ready():
	pass

func _process(delta):
	#Check if player within collection distance
	if Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced:
		$PopupUI.visible = true
	else:
		$PopupUI.visible = false


# TODO: open player research panel when implemented
func _on_Research_Button_pressed():
	pass
