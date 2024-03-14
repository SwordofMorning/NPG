extends Node2D

# Exit Game
func _on_exit_button_pressed():
	get_tree().quit()

var World = preload("res://World.tscn")

# Start Game
func _on_play_button_pressed():
	Global.Health = 10
	Global.enemy_nums = 4
	get_tree().change_scene_to_file("res://World.tscn")

func _ready():
	Utils.LoadGame()
