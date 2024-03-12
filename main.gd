extends Node2D

# Exit Game
func _on_exit_button_pressed():
	get_tree().quit()

# Start Game
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://World.tscn")
