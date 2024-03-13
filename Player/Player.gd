extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anime = get_node("AnimationPlayer")

signal move_jump
signal move_left
signal move_right
signal move_stop

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_W:
			emit_signal("move_jump")
		elif event.keycode == KEY_A:
			emit_signal("move_left")
		elif event.keycode == KEY_D:
			emit_signal("move_right")
	elif event is InputEventKey and event.is_released():
		if event.keycode == KEY_W:
			pass
		elif event.keycode == KEY_A or event.keycode == KEY_D:
			emit_signal("move_stop")

func _ready():
	connect("move_jump", _on_move_jump, 0)
	connect("move_left", _on_move_left, 0)
	connect("move_right", _on_move_right, 0)
	connect("move_stop", _on_move_stop, 0)
	
func _on_move_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		anime.play("Jump")
		
func _on_move_left():
	velocity.x = -1 * SPEED
	anime.play("Run")
	get_node("AnimatedSprite2D").flip_h = true
		
func _on_move_right():
	velocity.x = 1 * SPEED
	anime.play("Run")
	get_node("AnimatedSprite2D").flip_h = false

func _on_move_stop():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	anime.play("Idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()
	
	if (Global.Health <= 0) or (Global.enemy_nums < 0):
		#queue_free()
		Utils.SaveGame()
		var world = get_parent().get_parent()
		world.Out_World()
