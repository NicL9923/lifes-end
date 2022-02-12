extends Area2D

export var speed := 600
export var damage := 25
var velocity
var angle

func _ready():
	velocity = Vector2(speed, 0).rotated(rotation)
	self.add_to_group("bullets")

func _process(delta):
	position += velocity * delta

# TODO: need to flesh these out
func _on_Bullet_area_entered(area):
	queue_free()
	if area.is_in_group("enemy") or area.is_in_group("good_guy"):
		area.take_damage(damage)

func _on_Bullet_body_entered(body):
	queue_free()
	if body.is_in_group("enemy") or body.is_in_group("good_guy"):
		body.take_damage(damage)
