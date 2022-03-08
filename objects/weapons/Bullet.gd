extends Area2D

export var speed := 600
export var damage := 25
var velocity
var angle
var dmg_exclusion := []

func _ready():
	velocity = Vector2(speed, 0).rotated(rotation)
	self.add_to_group("bullets")

func _process(delta):
	position += velocity * delta

func able_to_take_dmg(node):
	if not node.is_in_group("player_team") and not node.is_in_group("enemy"):
		return false
	
	for exclusion in dmg_exclusion:
		if node.is_in_group(exclusion):
			return false
	
	return true

func _on_Bullet_area_entered(area):
	if able_to_take_dmg(area):
		queue_free()
		area.take_damage(damage)

func _on_Bullet_body_entered(body):
	if able_to_take_dmg(body):
		queue_free()
		body.take_damage(damage * (Global.modifiers.playerTeamWeaponDamage if body.is_in_group("enemy") else 1.0))
