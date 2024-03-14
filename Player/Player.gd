extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED_MULTIPLE = 5
const DASH_REMAIN = 10
var dash_remain = DASH_REMAIN

# -1 is left, 1 is right
var player_direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var Ghost = preload("res://Player/Ghost.tscn")

@onready var anime = get_node("AnimationPlayer")

signal move_jump
signal move_left
signal move_right
signal move_stop
signal move_dash

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_W:
			emit_signal("move_jump")
		elif event.keycode == KEY_A:
			emit_signal("move_left")
		elif event.keycode == KEY_D:
			emit_signal("move_right")
		elif event.keycode == KEY_SHIFT:
			emit_signal("move_dash")
	elif event is InputEventKey and event.is_released():
		if event.keycode == KEY_W or event.keycode == KEY_SHIFT:
			pass
		elif event.keycode == KEY_A or event.keycode == KEY_D:
			emit_signal("move_stop")

func _ready():
	connect("move_jump", _on_move_jump, 0)
	connect("move_left", _on_move_left, 0)
	connect("move_right", _on_move_right, 0)
	connect("move_stop", _on_move_stop, 0)
	connect("move_dash", _on_move_dash, 0)
	
func _on_move_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		anime.play("Jump")
		
func _on_move_left():
	player_direction = -1
	velocity.x = player_direction * SPEED
	anime.play("Run")
	get_node("AnimatedSprite2D").flip_h = true
		
func _on_move_right():
	player_direction = 1
	velocity.x = player_direction * SPEED
	anime.play("Run")
	get_node("AnimatedSprite2D").flip_h = false

func _on_move_stop():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	anime.play("Idle")
	
func _on_move_dash():
	get_node("DashTimer").start()
	velocity.x += player_direction * SPEED * DASH_SPEED_MULTIPLE
	gravity = 0
	
func _on_dash_timer_timeout():
	if dash_remain > 0:
		dash_remain -= 1
		var ghost = Ghost.instantiate()
		ghost.position = position
		ghost.get_node("Sprite2D").flip_h = get_node("AnimatedSprite2D").flip_h
		get_parent().add_child(ghost)
	else:
		velocity.x -= player_direction * SPEED * DASH_SPEED_MULTIPLE
		dash_remain = DASH_REMAIN
		get_node("DashTimer").stop()
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
		
