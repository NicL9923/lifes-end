extends Node2D

export var time_between_shots := 10

onready var muzzle := $Muzzle
var time_since_last_shot: int


func _physics_process(delta):
	time_since_last_shot -= delta

func shoot(gun_angle, group_of_entity_that_shot):
	if time_since_last_shot <= 0:
			var bullet := preload("res://objects/weapons/Bullet.tscn").instance()
			bullet.rotation = gun_angle
			bullet.global_position = muzzle.global_position
			if group_of_entity_that_shot:
				bullet.dmg_exclusion = [group_of_entity_that_shot]
			get_tree().get_root().add_child(bullet)
			time_since_last_shot = time_between_shots
