tool
extends Control

signal button_pressed

export var button_text := "OK" setget set_button_text
var button_size := Vector2(53, 30) setget set_button_size

onready var audio_player := $AudioStreamPlayer2D

var hover_on_sound := preload("res://audio/sfx/hover_on.wav")
var hover_off_sound := preload("res://audio/sfx/hover_off.wav")
var click_sound := preload("res://audio/sfx/click.wav")
var disabled := false setget set_button_disabled


func set_button_text(new_txt: String):
	if not has_node("Label") or not has_node("TextureButton"):
		return
	
	button_text = new_txt
	$Label.text = button_text
	
	# Resize button
	$Label.rect_size = $Label.get_font("font").get_string_size($Label.text)
	button_size.x = $Label.rect_size.x + 25
	$TextureButton.rect_size = button_size
	$Label.rect_position = ($TextureButton.rect_size / 2) - ($Label.rect_size / 2)

func set_button_size(new_size: Vector2):
	if has_node("TextureButton"):
		$TextureButton.rect_size = new_size

func set_button_disabled(isDisabled: bool):
	if has_node("TextureButton"):
		disabled = isDisabled
		$TextureButton.disabled = disabled
		if isDisabled:
			$Label.modulate = Color(0.25, 0.25, 0.25)
		else:
			$Label.modulate = Color(1, 1, 1)

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
