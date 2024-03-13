extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const SPEED = 50.0
var player 
var chase = false

func _physics_process(delta):
	velocity.y += gravity * delta;
	player = get_node("../../Player/Player")
	var direction = (player.position - self.position).normalized()
	if (get_node("AnimatedSprite2D").animation != "Death"):
		if (chase == true):
			velocity.x = direction.x * SPEED
			get_node("AnimatedSprite2D").play("Jump")
		else:
			velocity.x = 0
			get_node("AnimatedSprite2D").play("Idle")
	else:
		velocity.x = 0
		
	if (direction.x > 0):
		get_node("AnimatedSprite2D").flip_h = true
	elif (direction.x < 0):
		get_node("AnimatedSprite2D").flip_h = false
		
	move_and_slide();

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true



func _on_player_detection_body_exited(body):
	if (body.name == "Player"):
		chase = false


func Death():
	Global.Gold += 5
	Global.enemy_nums -= 1
	get_node("AnimatedSprite2D").play("Death")
	await get_node("AnimatedSprite2D").animation_finished
	# enemy out queue (kill it)
	self.queue_free()
	print(Global.enemy_nums)

func _on_kill_enemy_body_entered(body):
	if body.name == "Player":
		Death()

func _on_kill_player_body_entered(body):
	if body.name == "Player":
		Global.Health -= 3
		Death()
