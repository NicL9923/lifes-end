extends Node2D

func _ready():
	pass

func save_game():
	var save_game = File.new()
	#TODO: check if existing saves so that: names of files will just be 'SaveX' where X is the next available num starting from 1
	save_game.open("user://savegame.save", File.WRITE)
	
	#TODO: to_json() the variables in Global that need saving
	
	save_game.close()
