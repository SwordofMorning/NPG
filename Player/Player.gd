extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const WALL_JUMP_VELOCITY = -260

# -1 is left, 1 is right
var player_direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var Ghost = preload("res://Player/Ghost.tscn")

@onready var anime = get_node("AnimationPlayer")

func _ready():
	pass
	
############################################################ Dash ############################################################

# How many times ghosts are generated during dash
const DASH_TIMES = 10
# iterator for DASH_TIMES
var dash_remain_times = DASH_TIMES
const DASH_SPEED_MULTIPLE = 5
const DASH_SPEED_DEFAULT = 1
var speed_multiple = DASH_SPEED_DEFAULT
	
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
		
############################################################ Wall Jump ############################################################

var is_wall_jump = false
var wall_jump_direction = 0

func _on_wall_jump_timer_timeout():
	is_wall_jump = false
	wall_jump_direction = 0
	get_node("WallJumpTimer").stop()

############################################################ Anime State Machine ############################################################

enum Anime_State {
	Jump,
	Wall_Jump,
	Run,
	Idle,
	Wall_Slide,
	Fall,
}
var anime_state = Anime_State.Idle

enum Anime_State_Convert {
	Run_Pressed,
	Run_Released,
	Jump,
	On_Floor
}
var anime_state_convert = Anime_State_Convert.Run_Released

func State_Machine(state, convert):
	if state == Anime_State.Idle:
		if convert == Anime_State_Convert.Run_Pressed:
			return Anime_State.Run
		elif convert == Anime_State_Convert.Jump:
			return Anime_State.Jump
	elif state == Anime_State.Run:
		if convert == Anime_State_Convert.Run_Released:
			return Anime_State.Idle
		elif convert == Anime_State_Convert.Jump:
			return Anime_State.Jump
	elif state == Anime_State.Jump:
		if velocity.y > 0:
			return Anime_State.Fall
	elif state == Anime_State.Fall:
		if is_on_floor():
			anime_state_convert = Anime_State_Convert.On_Floor
			return Anime_State.Idle
		elif is_on_wall():
			# v.x needs to be in the opposite vector to wall's normal
			if (velocity.x > 0 and get_wall_normal().x < 0) or (velocity.x < 0 and get_wall_normal().x > 0):
				return Anime_State.Wall_Slide
			else:
				return Anime_State.Fall
	elif state == Anime_State.Wall_Slide:
		if is_on_floor():
			return Anime_State.Idle
		elif convert == Anime_State_Convert.Jump:
			is_wall_jump = true
			wall_jump_direction = get_wall_normal().x
			get_node("WallJumpTimer").start()
			return Anime_State.Wall_Jump
		elif is_on_wall():
			if (velocity.x > 0 and get_wall_normal().x < 0) or (velocity.x < 0 and get_wall_normal().x > 0):
				return Anime_State.Wall_Slide
			else:
				return Anime_State.Fall
	elif state == Anime_State.Wall_Jump:
		if velocity.y > 0:
			return Anime_State.Fall
	return state

############################################################ Process ############################################################

func _physics_process(delta):
## Grvaity
	if not is_on_floor(): velocity.y += gravity * delta
## Left and Right Move
	if Input.is_action_pressed("Move_Left"):
		player_direction = -1
		get_node("AnimatedSprite2D").flip_h = true
		anime_state_convert = Anime_State_Convert.Run_Pressed
	elif Input.is_action_pressed("Move_Right"):
		player_direction = 1
		get_node("AnimatedSprite2D").flip_h = false
		anime_state_convert = Anime_State_Convert.Run_Pressed
	elif Input.is_action_just_released("Move_Left") or Input.is_action_just_released("Move_Right"):
		player_direction = 0
		anime_state_convert = Anime_State_Convert.Run_Released
## Jump
	if Input.is_action_pressed("Move_Jump") and (is_on_floor() or anime_state == Anime_State.Wall_Slide):		
		if anime_state == Anime_State.Wall_Slide:
			velocity.y = WALL_JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY
		anime_state_convert = Anime_State_Convert.Jump
## Dash
	if Input.is_action_pressed("Move_Dash"):
		get_node("DashTimer").start()
		gravity = 0
		velocity.y = 0
		speed_multiple = DASH_SPEED_MULTIPLE
## v.x
	if not is_wall_jump:
		velocity.x = player_direction * SPEED * speed_multiple
	elif is_wall_jump:
		velocity.x = wall_jump_direction * SPEED

	anime_state = State_Machine(anime_state, anime_state_convert)

## Animation Play
	if anime_state == Anime_State.Jump:
		anime.play("Jump")
	elif anime_state == Anime_State.Run:
		anime.play("Run")
	elif anime_state == Anime_State.Idle:
		anime.play("Idle")
	elif anime_state == Anime_State.Wall_Slide:
		anime.play("Climb")
		velocity.y /= 2
	elif anime_state == Anime_State.Fall:
		anime.play("Fall")
	elif anime_state == Anime_State.Wall_Jump:
		anime.play("Jump")
	
	move_and_slide()
	Player_Death_or_Out_Game()

func Player_Death_or_Out_Game():
	if (Global.Health <= 0) or (Global.enemy_nums < 0):
		#queue_free()
		Utils.SaveGame()
		var world = get_parent().get_parent()
		world.Out_World()
