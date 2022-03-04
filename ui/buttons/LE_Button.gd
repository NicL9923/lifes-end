tool
extends Control

onready var audio_player := $AudioStreamPlayer2D

var hover_on_sound := preload("res://audio/sfx/hover_on.wav")
var hover_off_sound := preload("res://audio/sfx/hover_off.wav")
var click_sound := preload("res://audio/sfx/click.wav")


func _ready():
	pass

func _process(delta):
	pass


func _on_TextureButton_mouse_entered():
	audio_player.stream = hover_on_sound
	audio_player.play()

func _on_TextureButton_mouse_exited():
	audio_player.stream = hover_off_sound
	audio_player.play()

func _on_TextureButton_pressed():
	audio_player.stream = click_sound
	audio_player.play()
	
	# TODO: figure out how to let this be connect-able (probably just emit another signal from $LE_Button here?)
