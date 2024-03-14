extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween_vis = get_tree().create_tween()
	tween_vis.tween_property(self, "modulate:a", 0, 0.08)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
