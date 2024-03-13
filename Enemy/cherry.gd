extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		Global.Gold += 10
		var tween_move = get_tree().create_tween()
		var tween_vis = get_tree().create_tween()
		tween_move.tween_property(self, "position", position - Vector2(0, 100), 0.5)
		tween_vis.tween_property(self, "modulate:a", 0, 0.5)
		tween_move.tween_callback(queue_free)
