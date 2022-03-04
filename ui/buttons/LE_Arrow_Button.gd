tool
extends Control

signal button_pressed

onready var audio_player := $AudioStreamPlayer2D

var hover_on_sound := preload("res://audio/sfx/hover_on.wav")
var hover_off_sound := preload("res://audio/sfx/hover_off.wav")
var click_sound := preload("res://audio/sfx/click.wav")
var disabled := false setget set_button_disabled

func set_button_disabled(isDisabled: bool):
	if has_node("TextureButton"):
		disabled = isDisabled
		$TextureButton.disabled = disabled

func _on_TextureButton_mouse_entered():
	audio_player.stream = hover_on_sound
	audio_player.play()

func _on_TextureButton_mouse_exited():
	audio_player.stream = hover_off_sound
	audio_player.play()

func _on_TextureButton_pressed():
	audio_player.stream = click_sound
	audio_player.play()
	
	emit_signal("button_pressed")
