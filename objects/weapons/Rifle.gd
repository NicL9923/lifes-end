extends Node2D

export var time_between_shots := 10

onready var gun_muzzle := $Muzzle
var time_since_last_shot: int


func _physics_process(delta):
	time_since_last_shot -= delta

func shoot(gun_angle):
	if time_since_last_shot <= 0:
			var bullet := preload("res://objects/weapons/Bullet.tscn").instance()
			bullet.rotation = gun_angle
			bullet.global_position = gun_muzzle.global_position
			get_tree().get_root().add_child(bullet)
			time_since_last_shot = time_between_shots
