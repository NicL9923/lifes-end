extends Area2D

export var depositValue := 3
export var collectionDist := 35
var canBeCollected := false


func _ready():
	pass

func _process(delta):
	#Check if player within collection distance
	if Global.player.position.distance_to(self.position) < collectionDist:
		canBeCollected = true
	else:
		canBeCollected = false
	
	if canBeCollected:
		$PlayerHint.visible = true
		
		if Input.is_action_pressed("activate"):
			Global.playerMetal += depositValue
			queue_free()
	else:
		$PlayerHint.visible = false
