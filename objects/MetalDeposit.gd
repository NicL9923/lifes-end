extends StaticBody2D

export var depositValue := 3
export var collectionDist := 35.0
var canBeCollected := false


func _ready():
	randomly_scale_deposit()

func _process(_delta):
	#Check if player within collection distance
	if Global.player.position.distance_to(self.position) < collectionDist:
		canBeCollected = true
	else:
		canBeCollected = false
	
	if canBeCollected:
		$PlayerHint.visible = true
		
		if Input.is_action_pressed("activate"):
			Global.playerResources.metal += depositValue
			queue_free()
	else:
		$PlayerHint.visible = false

func randomly_scale_deposit():
	randomize()
	
	var new_scale := rand_range(0.5, 2.0)
	self.scale = Vector2(new_scale, new_scale)
	depositValue *= new_scale * Global.modifiers.metalDepositValue
	collectionDist = collectionDist * new_scale if new_scale > 1 else collectionDist
