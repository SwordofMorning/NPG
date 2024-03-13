extends Node2D

var Cherry = preload("res://Enemy/cherry.tscn")

func _on_timer_timeout():
	var CherryTemp = Cherry.instantiate()
	var rng = RandomNumberGenerator.new()
	var rngInt = randi_range(100, 500)
	CherryTemp.position = Vector2(rngInt, 490)
	add_child(CherryTemp)
