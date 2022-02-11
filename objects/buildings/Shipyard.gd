extends Building

func _ready():
	cost_to_build = 25

func _process(_delta):
	if Global.player.position.distance_to(self.position) < Global.building_activiation_distance and !Global.player.isInCombat and !isBeingPlaced:
		$PopupUI.visible = true
	else:
		$PopupUI.visible = false

func _on_ShipUpgrade_Button_pressed():
	Global.player.ship_panel.show()
