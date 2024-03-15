extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "value", Global.Dash_Cool_Down_Percentage, 0.1).set_trans(Tween.TRANS_LINEAR)
