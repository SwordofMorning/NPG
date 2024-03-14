extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
# How many times ghosts are generated during dash
const DASH_TIMES = 10
# iterator for DASH_TIMES
var dash_remain_times = DASH_TIMES
const DASH_SPEED_MULTIPLE = 5
const DASH_SPEED_DEFAULT = 1
var speed_multiple = DASH_SPEED_DEFAULT

# -1 is left, 1 is right
var player_direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var Ghost = preload("res://Player/Ghost.tscn")

@onready var anime = get_node("AnimationPlayer")

func _ready():
	pass
	
func _on_dash_timer_timeout():
	if dash_remain_times > 0:
		dash_remain_times -= 1
		var ghost = Ghost.instantiate()
		ghost.position = position
		ghost.get_node("Sprite2D").flip_h = get_node("AnimatedSprite2D").flip_h
		get_parent().add_child(ghost)
	else:
		speed_multiple = DASH_SPEED_DEFAULT
		dash_remain_times = DASH_TIMES
		get_node("DashTimer").stop()
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func Player_Death_or_Out_Game():
	if (Global.Health <= 0) or (Global.enemy_nums < 0):
		#queue_free()
		Utils.SaveGame()
		var world = get_parent().get_parent()
		world.Out_World()

func _physics_process(delta):
# Grvaity
	if not is_on_floor(): velocity.y += gravity * delta
# Jump
	if Input.is_action_pressed("Move_Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anime.play("Jump")
# Left and Right Move		
	if Input.is_action_pressed("Move_Left"):
		player_direction = -1
		anime.play("Run")
		get_node("AnimatedSprite2D").flip_h = true
	elif Input.is_action_pressed("Move_Right"):
		player_direction = 1
		anime.play("Run")
		get_node("AnimatedSprite2D").flip_h = false
	elif Input.is_action_just_released("Move_Left") or Input.is_action_just_released("Move_Right"):
		player_direction = 0
		anime.play("Idle")
# Dash
	if Input.is_action_pressed("Move_Dash"):
		get_node("DashTimer").start()
		gravity = 0
		speed_multiple = DASH_SPEED_MULTIPLE

	velocity.x = player_direction * SPEED * speed_multiple
	
	move_and_slide()
	Player_Death_or_Out_Game()
